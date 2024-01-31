// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {UserHelper} from "./UserHelper.sol";
import {PaymentHandler} from "./PaymentHandler.sol";

import "hardhat/console.sol";

contract OrderHandler {
    UserHelper internal userManager;
    PaymentHandler internal paymentHandler;

    constructor(UserHelper _userManager) {
        userManager = _userManager;
        paymentHandler = new PaymentHandler();
        console.log("Deployed OrderHandler...");
    }

    struct Order {
        string orderId;
        string productId;
        string buyerId;
        string sellerId;
        string timeStamp;
        uint256 amount;
        string expectedDelivery;
    }

    mapping(string => Order) private orders;
    mapping(string userId => string[] orderIds) private userOrderMapping;
    mapping(string userId => string[] orderIds) private canceledOrders;

    event OrderPlaced(string orderId, string productId, string sellerId, string buyerId, string timeStamp, uint256 amount, string expectedDelivery);
    event OrderCancelled(string orderId, string reason);

    modifier onlyBuyer(string memory _buyerId) {
        require(userManager.getUserInfo(_buyerId).userType ==  UserHelper.UserType.BUYER, "Not a buyer.");
        _;
    }


    function orderExists(string memory _orderId) public view returns(bool) {
        return bytes(orders[_orderId].orderId).length > 0;
    }

    function placeOrder(
        string memory _orderId,
        string memory _productId,
        string memory _sellerId,
        string memory _buyerId,
        string memory _timeStamp,
        uint256 _amount,
        string memory _expectedDelivery
    ) public onlyBuyer(_buyerId) payable returns(bool) {
        // Basic input validation
        require(bytes(_orderId).length > 0, "Invalid orderId");
        require(bytes(_productId).length > 0, "Invalid productId");
        require(bytes(_sellerId).length > 0, "Invalid sellerId");
        require(bytes(_buyerId).length > 0, "Invalid buyerId");
        require(bytes(_timeStamp).length > 0, "Invalid timeStamp");
        require(_amount > 0, "Invalid amount");
        require(bytes(_expectedDelivery).length > 0, "Invalid expectedDelivery");
        

        // Ensure buyer and seller exist
        require(userManager.userExists(_buyerId) == true, "Buyer does not exist");
        require(userManager.userExists(_sellerId), "Seller does not exist");
        
        // PAY
        UserHelper.User memory seller = userManager.getUserInfo(_sellerId);
        require(paymentHandler.pay{value: msg.value}(_amount, seller.account), "Payment unsuccesful");

        orders[_orderId] = Order({
            orderId: _orderId,
            productId: _productId,
            sellerId: _sellerId,
            buyerId: _buyerId,
            timeStamp: _timeStamp,
            amount: _amount,
            expectedDelivery: _expectedDelivery
        });

        userOrderMapping[_buyerId].push(_orderId);

        emit OrderPlaced(_orderId, _productId, _sellerId, _buyerId, _timeStamp, _amount, _expectedDelivery);

        return true;
    }

    function myOrders(string memory _buyerId) public view onlyBuyer(_buyerId) returns(string[] memory) {
        require(userManager.userExists(_buyerId) == true, "Buyer does not exist");
        return userOrderMapping[_buyerId];
        
    }

    function cancelOrder(string memory _orderId, string memory _reason) public onlyBuyer(_orderId) returns(bool) {
        require(orderExists(_orderId), "Order does not exist");
        
        Order memory order = orders[_orderId];
        string[] storage buyerOrders = userOrderMapping[order.buyerId];

        
        for (uint256 i = 0; i < buyerOrders.length; i++) {
            if (keccak256(bytes(buyerOrders[i])) == keccak256(bytes(_orderId))) {
                buyerOrders[i] = buyerOrders[buyerOrders.length - 1];
                buyerOrders.pop();
                break;
            }
        }

        userOrderMapping[order.buyerId] = buyerOrders;
        canceledOrders[order.buyerId].push(_orderId);
        
        delete orders[_orderId];

        emit OrderCancelled(_orderId, _reason);
        return true;
    }
}
