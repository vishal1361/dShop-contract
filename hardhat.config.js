require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");

const ALCHEMY_API_KEY = "dxqQOSX4fYAHB2n7n6PP-AD3NxPKCWeW";
const ETHERSCAN_API_KEY = "8W7UPGS9FNQTSSHR9BK7M43MR8M6QCTKUS";
const SEPOLIA_PRIVATE_KEY = "5b25cfaba3f69ec17f8b290888fbbfc3b3f707b294d7e06780b9c2a042a94eef";
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
      allowUnlimitedContractSize: true
    },
    hardhat: {
      allowUnlimitedContractSize: true
    }
  }
};
