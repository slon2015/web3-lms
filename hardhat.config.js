require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan"); // npm install --save-dev @nomiclabs/hardhat-etherscan
require("dotenv/config"); // npm install dotenv
require("hardhat-gas-reporter"); // npm install hardhat-gas-reporter
//npm install --save-dev @openzeppelin/contracts for package.json

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    
    networks: {
      hardhat: {
      },
      bnbtestnet: {
        url: "https://data-seed-prebsc-1-s1.binance.org:8545",
        chainId: 97,
        gasPrice: 20000000000,
        accounts: [process.env.BNB_WALLET_PRIVATE_KEY],
        },
      },

  solidity: "0.8.17",

  etherscan: {
    apiKey: process.env.BNBTESTNETSCAN_API_KEY,
  },
  
};
