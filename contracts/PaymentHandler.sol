// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";

contract PaymentHandler {

    address private owner;
    
    uint256 private platformFeePercentage; 
    AggregatorV3Interface internal priceFeed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only authorized for admin");
        _;
    }

    constructor() {
        platformFeePercentage = 2;
        owner = msg.sender;
        console.log("Deployed PaymentHandler");
        priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
    }

    function getPriceRate(uint256 _amount) public view returns (uint256) {
        (, int price,,,) = priceFeed.latestRoundData();
        uint adjust_price = uint(price) * 1e10;
        uint usd = _amount * 1e18;
        uint rate = (usd * 1e18) / adjust_price;
        return rate;
    }

    function pay(uint256 _amountInUsd, address  _to) external payable returns (bool) {
        uint256 platformFee = (msg.value * platformFeePercentage) / 100;
        uint256 amountToTransfer = msg.value - platformFee;

        require(msg.value >= getPriceRate(_amountInUsd), "Error in conversion");

        // Transfer the remaining amount to the specified receiver's address
        (bool success, ) = payable(_to).call{value: amountToTransfer}("");
        require(success, "Transfer to receiver failed");

        return true;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
