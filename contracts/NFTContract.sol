// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTContract is ERC721Enumerable, Ownable {
    //--------------------------------------------------
    // VARIABLES
    using Strings for uint256;

    string public baseURI =
        "https://gateway.pinata.cloud/ipfs/QmTHzNnS5ukkoAKNQvEGh7YXtdkYtLv2Q1obhWkUHqUHxy/";
    string public baseExtension = ".json";

    uint256 public maxSupply = 5400;
    uint256 public ogUserCost = 0.027 ether;
    uint256 public whitelistUserCost = 0.029 ether;
    uint256 public maxMintAmountPerTx = 2;

    // Number of nfts is limited to 2 per wallet during whitelisting
    uint256 public nftPerAddressLimit = 2;

    bool public paused = false;
    bool public revealed = true;
    bool public whitelistMintEnabled;

    mapping(address => uint256) public addressMintedBalance;
    mapping(address => uint256) public balances;

    //--------------------------------------------------
    // ERRORS

    error NFT_ContractIsPaused();
    error NFT_InvalidMintAmount();
    error NFT_ExceededMaxMintAmountPerTx();
    error NFT_MaxSupplyExceeded();
    error NFT_ExceededMaxNftPerAddress();
    error NFT_InsufficientFunds();
    error NFT_QueryForNonExistentToken(uint256 tokenId);

    //--------------------------------------------------
    // CONSTRUCTOR

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    //---------------------------------------------------
    // FUNCTIONS
    function mint(
        uint256 _mintAmount,
        bool _isOg,
        bool _isWhitelisted
    ) external payable {
        if (paused) revert NFT_ContractIsPaused();
        if (_mintAmount == 0) revert NFT_InvalidMintAmount();
        if (_mintAmount > maxMintAmountPerTx) {
            revert NFT_ExceededMaxMintAmountPerTx();
        }

        uint256 supply = totalSupply();

        if (supply + _mintAmount > maxSupply) {
            revert NFT_MaxSupplyExceeded();
        }

        uint256 cost;
        if (msg.sender != owner()) {
            if (_isOg == true) cost = ogUserCost;
            else cost = whitelistUserCost;

            if (msg.value < cost * _mintAmount) revert NFT_InsufficientFunds();

            uint256 mintedCount = addressMintedBalance[msg.sender];
            if (
                (mintedCount + _mintAmount > nftPerAddressLimit) &&
                ((_isOg == true) || (_isWhitelisted == true))
            ) revert NFT_ExceededMaxNftPerAddress();
            unchecked {
                addressMintedBalance[msg.sender] = mintedCount + _mintAmount;
            }
        }

        for (uint256 i = 1; i <= _mintAmount; ) {
            _safeMint(msg.sender, supply + i);
            unchecked {
                ++i;
            }
        }
    }

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; ) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
            unchecked {
                ++i;
            }
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert NFT_QueryForNonExistentToken(tokenId);

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    //-------------------------------------------------
    // OWNER FUNCTIONS

    function setBaseURI(string memory _newBaseURI) public payable onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause(bool _state) external payable onlyOwner {
        paused = _state;
    }

    //--------------------------------------------------
    // WITHDRAW FUNCTION

    function withdraw() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    //--------------------------------------------------
    // BALANCE OF CONTRACT

    function totalBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    //--------------------------------------------------
    // INTERNAL FUNCTION
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
