require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require('dotenv').config();


const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY],
      gasPrice: 8000000000,
      allowUnlimitedContractSize: true
    },
    // hardhat: {
    //   chainId: 1337,
    //   allowUnlimitedContractSize: true
    // },
    localhost: {
      chainId: 31337,
      url: "http://127.0.0.1:8545/"
    }
  }
};
