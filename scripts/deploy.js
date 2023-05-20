const { ethers } = require("hardhat");

async function main() {
  const contractFactory = await ethers.getContractFactory("LendingPlatform");

  console.log("Deploying... Steady Lads");
  const contract = await contractFactory.deploy(
    "0xea455a4A28653BD24d43b87029D93Fb67d4C691b"
  );

  console.log(contract);

  // This is the token contract that I deployed before
  //Because this contract requires a LP token
  await contract.deployed();
  console.log("Deployed. Well done guys!");
}

main();
