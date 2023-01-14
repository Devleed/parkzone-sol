// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ParkZone is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint public numberOfParkings;
    uint public parkingSlotChargesForOneHour = 100000000000000;

    struct Location { 
        string longitude;
        string lattitude;
    }

    Location public location;

    mapping(uint => address) public bookedParkings;
    mapping(uint => uint) public timeBooked;

    event ParkingBooked(address indexed _booker, uint indexed _slot);
    event ParkingExpired(address indexed _booker, uint indexed _slot);

    constructor(uint _numberOfParkings, string[] memory _location) ERC721("ParkZone", "PKZ") {
        numberOfParkings = _numberOfParkings;
        location = Location(_location[0], _location[1]);
    }

    modifier validParkingSlot(uint _parkingSlot) {
        require(_parkingSlot <= numberOfParkings, "Invalid parking slot.");
        _;
    }

    function bookParking(uint _parkingSlot, uint _currentTime) public payable validParkingSlot(_parkingSlot) {
        require(bookedParkings[_parkingSlot] == address(0), "Parking slot already booked.");
        require(msg.value >= parkingSlotChargesForOneHour, "Charges for one slot is 0.0001 ETH.");

        transferNFT(owner(), msg.sender, _parkingSlot);

        bookedParkings[_parkingSlot] = msg.sender;
        timeBooked[_parkingSlot] = _currentTime;

        emit ParkingBooked(msg.sender, _parkingSlot);
    }

    function expireParking(uint _parkingSlot, uint _currentTime) public onlyOwner validParkingSlot(_parkingSlot) {
        require(bookedParkings[_parkingSlot] != address(0), "Slot is already empty.");

        bool isExpired = isParkingExpired(_parkingSlot, _currentTime);

        require(isExpired == true, "Parking is not yet expired.");
        
        transferNFT(bookedParkings[_parkingSlot], owner(), _parkingSlot);

        bookedParkings[_parkingSlot] = address(0);

        emit ParkingExpired(msg.sender, _parkingSlot);
    }

    function checkout(uint _parkingSlot, uint _currentTime) public payable validParkingSlot(_parkingSlot) {
        require(bookedParkings[_parkingSlot] != address(0), "Slot is already empty.");
        require(ownerOf(_parkingSlot) == msg.sender, "You're not owner of slot.");
        require(calculateCharges(_parkingSlot, _currentTime) <= msg.value, "Pay full charges please.");

        transferNFT(msg.sender, owner(), _parkingSlot);

        bookedParkings[_parkingSlot] = address(0);

        emit ParkingExpired(msg.sender, _parkingSlot);
    }

    function isParkingExpired(uint _parkingSlot, uint _currentTime) public view returns(bool) {
        require(bookedParkings[_parkingSlot] != address(0), "Parking slot is empty.");

        uint differenceInTimes = _currentTime - timeBooked[_parkingSlot];

        if(differenceInTimes > 60) {
            return true;
        }

        return false;
    }

    function batchMint(uint256[] memory _tokenIds) public onlyOwner {
        address plotOwner = owner();

        for (uint i = 0; i < _tokenIds.length; i++) {
            _safeMint(plotOwner, _tokenIds[i]);
        }
    }

    function updateNumberOfParkings(uint _numberOfParkings) public onlyOwner returns (uint) {
        numberOfParkings = _numberOfParkings;

        return numberOfParkings;
    }

    function calculateCharges(uint _parkingSlot, uint _currentTime) validParkingSlot(_parkingSlot) public view returns(uint)  {
        require(bookedParkings[_parkingSlot] != address(0), "Slot is empty.");

        return (_currentTime - timeBooked[_parkingSlot]) * (parkingSlotChargesForOneHour / 360);
    }

    // ? Private Functions
    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        _transfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}