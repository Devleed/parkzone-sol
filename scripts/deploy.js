async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const Plot = await ethers.getContractFactory('ParkZone');
  const contract = await Plot.deploy(30, [24.3211512, 32.43546]);

  console.log('contract address:', contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
