// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {UserHelper} from "./UserHelper.sol";

import "hardhat/console.sol";

contract StorageFactory {
    UserHelper private userManager;

    constructor(UserHelper _userManager) {
        userManager = _userManager;
        console.log("Deployed StorageFactory.");
    }

    struct Product {
        string productId;
        string sellerId;
        string ipfsHash;
    }

    mapping(string productId => Product product) private storageRoom;
    string[] private productIds;

    event ProductStored(string indexed productId, string ipfsHash);
    event ProductDeleted(string indexed productId);

    modifier onlySeller(string memory _sellerId) {
        require(userManager.getUserInfo(_sellerId).userType ==  UserHelper.UserType.SELLER, "Not a seller.");
        _;
    }
    function logState() public view {
        console.log("Logging product data : -------------------------------");
        for (uint256 i = 0; i < productIds.length; i++) {
            string memory key = productIds[i];
            console.log("PS No - %s *******************", i);
            console.log("Product id : %s ", storageRoom[key].productId);
            console.log("Seller Id: ", storageRoom[key].sellerId);
            console.log("Product Hash: ", storageRoom[key].ipfsHash);
            console.log("*******************************");
        }
        console.log("---------------------------------------------------");
    }

    function storeProduct(string memory _productId, string memory _sellerId, string memory _ipfsHash) public onlySeller(_sellerId) returns (bool) {
        require(bytes(_productId).length > 0, "Invalid productId");
        require(bytes(_sellerId).length > 0, "Invalid sellerId");
        require(bytes(_ipfsHash).length > 0, "Invalid ipfsHash");

        storageRoom[_productId] = Product(_productId, _sellerId, _ipfsHash);
        productIds.push(_productId);

        emit ProductStored(_productId, _ipfsHash);
        logState();
        return true;
    }

    function deleteProductById(string memory _productId, string memory _sellerId) public onlySeller(_sellerId) returns (bool) {
        require(bytes(_productId).length > 0, "Invalid productId");

        // Check if the product exists
        require(bytes(storageRoom[_productId].productId).length > 0, "Product not found");

        delete storageRoom[_productId];

        // Remove the productId from the productIds array
        for (uint256 i = 0; i < productIds.length; i++) {
            if (keccak256(bytes(productIds[i])) == keccak256(bytes(_productId))) {
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }

        emit ProductDeleted(_productId);
        logState();
        return true;
    }

    function retrieveAll() public view returns (Product[] memory) {
        Product[] memory products = new Product[](productIds.length);

        for (uint256 i = 0; i < productIds.length; i++) {
            products[i] = storageRoom[productIds[i]];
        }

        return products;
    }

    function retrieveProductByProductId(string memory _productId) public view returns (Product memory) {
        require(bytes(_productId).length > 0, "Invalid productId");

        return storageRoom[_productId];
    }

    function retrieveProductBySellerId(string memory _sellerId) public view returns (Product[] memory) {
    require(userManager.userExists(_sellerId), "Seller not found.");

    Product[] memory products = new Product[](productIds.length);

    uint256 count = 0;

    for (uint256 i = 0; i < productIds.length; i++) {
        if(keccak256(bytes(storageRoom[productIds[i]].sellerId)) == keccak256(bytes(_sellerId))) {
            products[count] = storageRoom[productIds[i]];
            count++;
        }
    }

    // Resize the array to remove unused slots
    assembly {
        mstore(products, count)
    }

    return products;
}

}
