require('@nomicfoundation/hardhat-toolbox');

const GOERLI_PRIVATE_KEY =
  '72443666c98402dbea36dad599caad6a5c1987a74481fa618dae849175668c35';

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/80ba3747876843469bf0c36d0a355f71`,
      accounts: [GOERLI_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: '3MB1GI7WAG539CW1NKSHW22I7C2WH8HGB8',
  },
  paths: ['@openzeppelin/contracts/contracts/*.sol'],
};
