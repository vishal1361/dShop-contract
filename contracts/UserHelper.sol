// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract UserHelper {

    constructor() {
        console.log("Deployed UserHelper...");
    }
    enum UserType{
        BUYER,
        SELLER,
        ADMIN
    }

    struct User {
        string id;
        string username;
        string password;
        string name;
        string email;
        address payable account;
        UserType userType;
    }

    mapping(string => User) private users;

    event UserAdded(string id, string username, string name, string email,address account, string userType);

    function userExists(string memory _userId) public view returns(bool) {
        return bytes(users[_userId].id).length > 0;
    }

    function getUserInfo(string memory _id) public view returns(User memory) {
        return users[_id];
    }

    function addUser(
        string memory _id,
        string memory _username,
        string memory _password,
        string memory _name,
        string memory _email,
        address payable _account,
        string memory _userType
    ) public returns(bool) {
        // Basic input validation
        require(bytes(_id).length > 0, "Invalid ID");
        require(bytes(_username).length > 0, "Invalid username");
        require(bytes(_password).length > 0, "Invalid password");
        require(bytes(_name).length > 0, "Invalid name");
        require(bytes(_email).length > 0, "Invalid email");
        

        // Check if the user already exists
        require(bytes(users[_id].id).length == 0, "User already exists");
        
        UserType userType;
        if(keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("BUYER"))) {
            userType = UserType.BUYER;
        } else if(keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("SELLER"))) {
            userType = UserType.SELLER;
        } else if(keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("ADMIN"))) {
            userType = UserType.ADMIN;
        } else {
            require(false, "User type is incorrect.");
        }

        users[_id] = User({
            id: _id,
            username: _username,
            password: _password,
            name: _name,
            email: _email,
            account: _account,
            userType: userType
        });

        emit UserAdded(_id, _username, _name, _email,_account, _userType);

        return true;
    }
}
