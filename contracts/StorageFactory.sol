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
    mapping(string buyerId => string[] productIds) private cartRoom;

    event ProductStored(string indexed productId, string ipfsHash);
    event ProductDeleted(string indexed productId);

    modifier onlySeller(string memory _sellerId) {
        require(userManager.getUserInfo(_sellerId).userType ==  UserHelper.UserType.SELLER, "Not a seller.");
        _;
    }

    modifier onlyBuyer(string memory _buyerId) {
        require(userManager.getUserInfo(_buyerId).userType == UserHelper.UserType.BUYER, "Not a buyer.");
        _;
    }

    function logStorageRoom() public view {
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

    function logCartRoom(string memory _buyerId) public view {
        console.log("Logging cart data : -------------------------------");
        for (uint256 i = 0; i < cartRoom[_buyerId].length; i++) {
            
            console.log("Product id :%s => %s ",i, cartRoom[_buyerId][i]);
            
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
        logStorageRoom();
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
        logStorageRoom();
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

    function addToCart(string memory _buyerId, string memory _productId) public onlyBuyer(_buyerId) returns (bool) {

        if (cartRoom[_buyerId].length == 0) {
            cartRoom[_buyerId] = new string[](0);
            cartRoom[_buyerId].push(_productId);
            return true;
        }
        logStorageRoom();
        require(keccak256(abi.encodePacked(storageRoom[_productId].productId)) == keccak256(abi.encodePacked(_productId)), "Product not found!");

        // Find the index of the productId in the buyer's cart
        uint256 indexToRemove = findProductIndex(cartRoom[_buyerId], _productId);

        // Check if the product is in the buyer's cart
        require(indexToRemove >= cartRoom[_buyerId].length, "Product found in the cart");

        cartRoom[_buyerId].push(_productId);
        logCartRoom(_buyerId);
        return true;
    }

    function removeFromCart(string memory _buyerId, string memory _productId) public onlyBuyer(_buyerId) returns (bool) {
        // Check if the buyerId exists in the mapping
        require(cartRoom[_buyerId].length > 0, "Buyer not found in the cart");
        require(keccak256(abi.encodePacked(storageRoom[_productId].productId)) == keccak256(abi.encodePacked(_productId)), "Product not found!");
        // Find the index of the productId in the buyer's cart
        uint256 indexToRemove = findProductIndex(cartRoom[_buyerId], _productId);

        // Check if the product is in the buyer's cart
        require(indexToRemove < cartRoom[_buyerId].length, "Product not found in the cart");

        // Remove the product from the buyer's cart
        removeProductAtIndex(cartRoom[_buyerId], indexToRemove);
        logCartRoom(_buyerId);

        return true;
    }

    function findProductIndex(string[] storage productsInCart, string memory target) internal view returns (uint256) {
        // Iterate over the array to find the index of the target product
        for (uint256 i = 0; i < productsInCart.length; i++) {
            if (keccak256(abi.encodePacked(productsInCart[i])) == keccak256(abi.encodePacked(target))) {
                return i;
            }
        }
        // Return an out-of-bounds value if not found
        return type(uint256).max;
    }

    function removeProductAtIndex(string[] storage products, uint256 indexToRemove) internal {
        // Move the last element to the index to be removed
        if (indexToRemove < products.length - 1) {
            products[indexToRemove] = products[products.length - 1];
        }

        // Remove the last element (pop)
        products.pop();
    }

    // You may also want to include a function to retrieve the products in a buyer's cart
    function getCart(string memory _buyerId) public  onlyBuyer(_buyerId) view returns (string[] memory) {
        logCartRoom(_buyerId);
        return cartRoom[_buyerId];
    }

}
