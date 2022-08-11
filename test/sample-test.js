const { ethers } = require("hardhat")

/* test/sample-test.js */
describe("NFTMarket", function() {
  it("Should create and execute market sales", async function() {
    /* deploy the marketplace */
  
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace")
    const nftMarketplace = await NFTMarketplace.deploy()
    await nftMarketplace.deployed()

    const auctionPrice = ethers.utils.parseUnits('1000', 'ether')

    /* create two tokens */
    await nftMarketplace.createToken("https://www.mytokenlocation.com", auctionPrice)
    await nftMarketplace.createToken("https://www.mytokenlocation2.com", auctionPrice)
      
    const [owner, buyer] = await ethers.getSigners()

    /* Owner put up the NFT for sale */            
    await nftMarketplace.putupforSale(1, auctionPrice)  
    
    /* Print the balance before buyer puchases the NFT */
    balance = await owner.getBalance();
    //console.log('Owner Balance before purchase : ', balance);
    console.log('Owner Balance before purchase : ', ethers.utils.formatEther(balance));
    balance = await buyer.getBalance();
    console.log('Buyer Balance before purchase : ', ethers.utils.formatEther(balance));

    /* Buyer purchases the NFT */                
    await nftMarketplace.connect(buyer).buyItem(1, { value: auctionPrice })

    /* Print the balance after buyer puchases the NFT */
    balance = await owner.getBalance();
    console.log('Owner Balance after purchase : ', ethers.utils.formatEther(balance));    
    balance = await buyer.getBalance();
    console.log('Buyer Balance after purchase : ', ethers.utils.formatEther(balance));

    /* query for and return the unsold items */
    items = await nftMarketplace.fetchMyNFTs()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nftMarketplace.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)

  })
})