const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const MonadToken = await hre.ethers.getContractFactory("MonadToken");

  const name = "MonadToken";
  const symbol = "MONAD";
  const initialSupply = hre.ethers.parseUnits("1000000", 18); // FIXED

  const token = await MonadToken.deploy(name, symbol, initialSupply);
  await token.waitForDeployment();

  const address = await token.getAddress();

  console.log("MonadToken deployed to:", address);
  console.log("Owner (deployer):", deployer.address);
  console.log("Explorer link: https://explorer.monad.xyz/address/" + address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
