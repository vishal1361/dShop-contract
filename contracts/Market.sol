// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {StorageFactory} from "./StorageFactory.sol";
import {OrderHandler} from "./OrderHandler.sol";
import {UserHelper} from "./UserHelper.sol";

import "hardhat/console.sol";

contract Market {
    StorageFactory internal marketStorageFactory;
    OrderHandler internal marketOrderHandler;
    UserHelper internal userManager;
    address internal OWNER;

    constructor() {
        userManager = new UserHelper();
        marketStorageFactory = new StorageFactory(userManager);
        marketOrderHandler = new OrderHandler(userManager);
        
        OWNER = msg.sender;
        console.log("Deployed Market...");
    }

    modifier onlyBuyer(string memory _buyerId) {
        require(userManager.getUserInfo(_buyerId).userType ==  UserHelper.UserType.BUYER, "Not a buyer.");
        _;
    }

    modifier onlySeller(string memory _sellerId) {
        require(userManager.getUserInfo(_sellerId).userType ==  UserHelper.UserType.SELLER, "Not a seller.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == OWNER, "Only authorized for admin.");
        _;
    }

    // OrderHandler 

    function buyProduct(
        string memory _orderId,
        string memory _productId,
        string memory _sellerId,
        string memory _buyerId,
        string memory _timeStamp,
        uint256 _amount,
        string memory _expectedDelivery
    ) public onlyBuyer(_buyerId) payable returns(bool) {

        return marketOrderHandler.placeOrder{value: msg.value}(
            _orderId, 
            _productId, 
            _sellerId, 
            _buyerId, 
            _timeStamp, 
            _amount, 
            _expectedDelivery
        );
    }

    function myOrders(string memory _buyerId) public view onlyBuyer(_buyerId) returns(string[] memory) {
        return marketOrderHandler.myOrders(_buyerId);
    }

    function cancelOrder(string memory _orderId, string memory _reason) public onlyBuyer(_orderId) returns(bool) {
        return marketOrderHandler.cancelOrder(_orderId, _reason);
    }

    // StorageFactory

    function storeProductInStorage(
        string memory _productId, 
        string memory _sellerId, 
        string memory _ipfsHash
    ) public onlySeller(_sellerId) returns(bool) {
        require(userManager.userExists(_sellerId) == true, "Seller Not registered.");
        return marketStorageFactory.storeProduct(_productId, _sellerId, _ipfsHash);
    }

    function removeProductFromStorage(string memory _productId, string memory _sellerId) public onlySeller(_sellerId) returns(bool){
        return marketStorageFactory.deleteProductById(_productId, _sellerId);
    }

    function listAllProducts() public view returns(StorageFactory.Product[] memory) {
        return marketStorageFactory.retrieveAll();
    }

    function getProductByProductId(string memory _productId) public view returns (StorageFactory.Product memory) {
        return marketStorageFactory.retrieveProductByProductId(_productId);
    }

    function getProductBySellerId(string memory _sellerId) public view returns (StorageFactory.Product[] memory) {
        return marketStorageFactory.retrieveProductBySellerId(_sellerId);
    }

    function getCart(string memory _buyerId) public view returns (string[] memory) {
        return marketStorageFactory.getCart(_buyerId);
    }

    function removeFromCart(string memory _buyerId, string memory _productId) public onlyBuyer(_buyerId) returns (bool) {
        return marketStorageFactory.removeFromCart(_buyerId, _productId);
    }

    function addToCart(string memory _buyerId, string memory _productId) public onlyBuyer(_buyerId) returns (bool) {
        return marketStorageFactory.addToCart(_buyerId, _productId);
    }

    // UserHelper
    function userExists(string memory _userId) public view returns(bool) { 
        return userManager.userExists(_userId);
    }

    function getUserInfo(string memory _id) public view returns(UserHelper.User memory) { 
        return userManager.getUserInfo(_id);
    }

    function findUserByEmail(string memory _email) public view returns(UserHelper.User memory) {
        return userManager.findUserByEmail(_email) ;
    }

    function verifyUserDetails(string memory _email, string memory _password, string memory _userType) public view returns(bool) {
        return userManager.verifyUserDetails(_email, _password, _userType);
    }

    function addUser(
        string memory _id,
        string memory _name,
        string memory _email,
        string memory _password,
        address payable _account,
        string memory _userType
    ) public returns(UserHelper.User memory) {
        return userManager.addUser(_id, _name, _email, _password, _account, _userType);
    }
}
