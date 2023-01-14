const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require('chai');

describe('Plot contract', function () {
  async function deployTokenFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Plot = await ethers.getContractFactory('ParkZone');
    const contract = await Plot.deploy(30, [24.3211512, 32.43546]);

    await contract.deployed();

    // Fixtures can return anything you consider useful for your tests
    return { Plot, contract, owner, addr1, addr2 };
  }

  it('Should set the right owner', async function () {
    const { contract, owner } = await loadFixture(deployTokenFixture);

    expect(await contract.owner()).to.equal(owner.address);
  });

  it('Should set the right amount of parking slots', async function () {
    const { contract } = await loadFixture(deployTokenFixture);

    expect(await contract.numberOfParkings()).to.equal(30);
  });

  it('Should mint and transfer all nfts to owner', async function () {
    const { contract, owner } = await loadFixture(deployTokenFixture);

    await contract.batchMint([1, 2, 3, 4, 5]);

    expect(await contract.balanceOf(owner.address)).to.equal(5);
  });

  it('Should book the parking slot and transfer nft to booker', async function () {
    const { contract, owner, addr1 } = await loadFixture(deployTokenFixture);

    await contract.batchMint([1, 2, 3, 4, 5]);

    // await contract.connect(addr1).bookParking(2);
  });

  //   it('Should transfer tokens between accounts', async function () {
  //     const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
  //       deployTokenFixture,
  //     );

  //     // Transfer 50 tokens from owner to addr1
  //     await expect(
  //       hardhatToken.transfer(addr1.address, 50),
  //     ).to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);

  //     // Transfer 50 tokens from addr1 to addr2
  //     // We use .connect(signer) to send a transaction from another account
  //     await expect(
  //       hardhatToken.connect(addr1).transfer(addr2.address, 50),
  //     ).to.changeTokenBalances(hardhatToken, [addr1, addr2], [-50, 50]);
  //   });
});
