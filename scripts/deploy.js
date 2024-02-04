const fs = require('fs')

const MARKET_ABI = require('../artifacts/contracts/Market.sol/Market.json');
const CONTRACT_ABI_PATH = '/Users/Vishal/Desktop/Project/dShop/dShop-server/abis/contractAbi.json';

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);


  const market = await ethers.deployContract("Market");
  console.log("market token address:", await market.getAddress());
  console.log('Generating contract abi file in server...');
  
  // Writing ABI to a JSON file
  const abi = MARKET_ABI.abi;
  const abiJson = JSON.stringify(abi, null, 2);

  fs.writeFileSync(CONTRACT_ABI_PATH, abiJson);
  
  console.log(`Contract ABI written to: ${CONTRACT_ABI_PATH}`);
  console.log('Do not forget to push the changes to github in dShop-server!')
  console.log('Now verify the contract on blockchain! npx hardhat verify --network sepolia <address> <unlock time>');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
