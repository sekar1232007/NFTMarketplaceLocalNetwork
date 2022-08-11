require("@nomiclabs/hardhat-waffle");
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks:{
    hardhat:{
      chainID: 1337
    },
    /*
    mumbai:{
      url: 'https://polygon-mumbai.g.alchemy.com/v2/kEyzItQvc6wu1DajdghUl6wkq7CG4s4E',
      accounts:[privateKey]
    },
    mainnet:{
      url:'https://polygon-mainnet.g.alchemy.com/v2/kEyzItQvc6wu1DajdghUl6wkq7CG4s4E',
      accounts:[privateKey]
    }*/
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }

  
};