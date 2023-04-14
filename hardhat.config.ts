import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-gas-reporter";

import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";
import { HardhatUserConfig } from "hardhat/types";
dotenvConfig({ path: resolve(__dirname, "./.env") });

const config: HardhatUserConfig = {
  networks: {
    hardhat: {},
    bnbtestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [process.env.BNB_WALLET_PRIVATE_KEY!],
    },
  },

  solidity: "0.8.17",

  etherscan: {
    apiKey: process.env.BNBTESTNETSCAN_API_KEY,
  },
};

export default config;
