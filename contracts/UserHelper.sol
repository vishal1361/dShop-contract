// SPDX-License-Identifier: Unlicense
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
        string name;
        string email;
        string password;
        address payable account;
        UserType userType;
    }

    mapping(string => User) private users;
    mapping(string email => string id) private userEmails;

    event UserAdded(string id, string name, string email, string userType);

    function userExists(string memory _userId) public view returns(bool) {
        return bytes(users[_userId].id).length > 0;
    }

    function getUserInfo(string memory _id) public view returns(User memory) {
        return users[_id];
    }

    function findUserByEmail(string memory _email) public view returns(User memory) {
        return users[userEmails[_email]] ;
    }

    function verifyUserDetails(string memory _email, string memory _password, string memory _userType) public view returns(bool) {
        if (bytes(userEmails[_email]).length > 0) {
            string memory userId = userEmails[_email];
            User memory user = users[userId];

            string memory userTypeEnum = userTypeToString(user.userType);

            if (keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked(userTypeEnum))) {
                return (keccak256(abi.encodePacked(_password)) == keccak256(abi.encodePacked(user.password)));
            }
        }

        return false;
    }


    function userTypeToString(UserType _userType) internal pure returns (string memory) {
        if (_userType == UserType.BUYER) {
            return "BUYER";
        } else if (_userType == UserType.SELLER) {
            return "SELLER";
        } else if (_userType == UserType.ADMIN) {
            return "ADMIN";
        } else {
            revert("Invalid user type");
        }
    }

    function addUser(
        string memory _id,
        string memory _name,
        string memory _email,
        string memory _password,
        address payable _account,
        string memory _userType
    ) public returns(User memory) {
        // Basic input validation
        require(bytes(_id).length > 0, "Invalid ID");
        require(bytes(_name).length > 0, "Invalid username");
        require(bytes(_password).length > 0, "Invalid password");
        require(bytes(_email).length > 0, "Invalid email");

        // Check if the user already exists
        require(keccak256(abi.encodePacked(userEmails[_email])) == keccak256(abi.encodePacked('')), "User Exists!!!");

        UserType userType;
        if (keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("BUYER"))) {
            userType = UserType.BUYER;
        } else if (keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("SELLER"))) {
            userType = UserType.SELLER;
        } else if (keccak256(abi.encodePacked(_userType)) == keccak256(abi.encodePacked("ADMIN"))) {
            userType = UserType.ADMIN;
        } else {
            require(false, "User type is incorrect.");
        }

        users[_id] = User({
            id: _id,
            name: _name,
            email: _email,
            password: _password,
            account: _account,
            userType: userType
        });

        userEmails[_email] = _id;

        emit UserAdded(_id, _name, _email, _userType);

        return users[_id];
    }
}
