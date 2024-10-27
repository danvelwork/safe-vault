// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UsernamePasswordVault {
    // Store the deposited amount using a unique hash of the username and password
    mapping(bytes32 => uint256) private vault;

    // Deposit ETH with separate username and password hash
    function deposit(string memory username, string memory password) external payable {
        require(msg.value > 0, "Must send some ETH to deposit");

        // Create a combined hash of the username and password
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));

        // Store the amount in the vault by the combined hash
        vault[combinedHash] += msg.value;
    }

    // Withdraw a specified amount by providing the correct username and password
    function withdraw(string memory username, string memory password, uint256 amount) external {
        // Generate the combined hash of the provided username and password
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));

        // Check that the vault has enough funds under this combined hash
        require(vault[combinedHash] >= amount, "Insufficient funds or incorrect credentials");

        // Deduct the amount from the vault under this combined hash
        vault[combinedHash] -= amount;

        // Transfer the requested amount to the caller
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Check balance for a given username and password
    function checkBalance(string memory username, string memory password) external view returns (uint256) {
        // Generate the combined hash of the provided username and password
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));

        // Return the balance stored under this hash
        return vault[combinedHash];
    }
}
