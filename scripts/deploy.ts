import { ethers } from "hardhat";

async function main() {
  const Nft = await ethers.getContractFactory("NFTContract");
  const name = 'Torsten Sharks';
  const symbol = 'Torsten_Sharks';

  const nft = await Nft.deploy(name, symbol);

  await nft.deployed();

  console.log(`NFT contract deployed to ${nft.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
