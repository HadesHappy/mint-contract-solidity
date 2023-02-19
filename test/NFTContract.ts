import { expect } from 'chai';
import hre from 'hardhat';
import { time, loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { ethers } from 'hardhat';

describe("NFTContract", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployNFTContract() {
    const [owner, account1, account2] = await ethers.getSigners();
    const Nft = await hre.ethers.getContractFactory('NFTContract');

    const name = 'Torsten Sharks';
    const symbol = 'Torsten_Sharks';

    const nft = await Nft.deploy(name, symbol);
    return {nft, owner, account1, account2};
  }

  describe('deploy and set variables', async function() {
    it('set Phase', async function() {
      const {nft, owner, account1, account2} = await loadFixture(deployNFTContract);
      await nft.pause(false);
      await nft.connect(owner).mint(1, true, true, { value: ethers.utils.parseEther('0.027') });
      await nft.connect(account1).mint(1, false, true, {value: ethers.utils.parseEther('0.029')});
      await nft.connect(account2).mint(1, true, true, { value: ethers.utils.parseEther('0.027') });
      console.log('supply: ', await nft.totalSupply())
      console.log('max supply: ', await nft.maxSupply())
      const tokenId = await nft.walletOfOwner(account1.address)
      console.log('tokenId: ', tokenId);
      console.log('token Uri: ', await nft.tokenURI(Number(3)))
      console.log('balance: ', await nft.totalBalance())

    })
  })
});
