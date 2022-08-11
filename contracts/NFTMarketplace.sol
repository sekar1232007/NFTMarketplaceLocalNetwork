// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
      uint256 tokenId;
      address payable owner;
      uint256 price;
      uint256 state;
    }

    event MarketItemCreated (
      uint256 indexed tokenId,
      address owner,
      uint256 price,
      uint256 state
    );

    constructor() ERC721("Metaverse Tokens", "METT") {
      owner = payable(msg.sender);
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId, price);
      idToMarketItem[newTokenId].state = 1;//state 1 is, Item is created
      return newTokenId;
    }

    function createMarketItem(
      uint256 tokenId,
      uint256 price
    ) private {
      require(price > 0, "Price must be at least 1 wei");
      
      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        price,
        1
      );

      //_transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        price,
        1
      );
    }

    /* allows someone to resell a token they have purchased */
    function putupforSale(uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only owner can sell the item");
      idToMarketItem[tokenId].state = 2;
      idToMarketItem[tokenId].price = price;
        }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function buyItem(
      uint256 tokenId
      ) public payable {
      uint price = idToMarketItem[tokenId].price;
      address payable seller = idToMarketItem[tokenId].owner;
      require(msg.value == price, "Please submit the asking price in order to complete the purchase");
      idToMarketItem[tokenId].owner = payable(msg.sender);
      idToMarketItem[tokenId].state = 3;
      payable(seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if ((idToMarketItem[i+1].state == 2)||(idToMarketItem[i+1].state == 1)) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < itemCount; i++) {
        uint currentId = i + 1;
        if ((idToMarketItem[currentId].state == 2)||(idToMarketItem[currentId].state == 1)) { 
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
          //console.log("totalItemCount : %s, itemCount : %s, msg.sender : %s, idToMarketItem[i + 1].owner : %s ", totalItemCount, itemCount,msg.sender,idToMarketItem[i + 1].owner);
          console.log("totalItemCount : ", totalItemCount);
          console.log("itemCount : ", itemCount);
          console.log("msg.sender : ", msg.sender);
          console.log("totalItemCoidToMarketItem[i + 1].ownerunt : ", idToMarketItem[i + 1].owner);

        }
      }
      
       return items;
    }

function getItemState(uint256 tokenId) public view returns (uint) {
      return idToMarketItem[tokenId].state;
    }
}