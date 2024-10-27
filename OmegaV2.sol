// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PooledVault {
    // Single pooled balance for all deposits
    uint256 private totalPoolBalance;

    // Mapping of hashed (username + password) to individual deposits
    mapping(bytes32 => uint256) private individualBalances;

    // Deposit function that adds to the pooled balance
    function deposit(string memory username, string memory password) external payable {
        require(msg.value > 0, "Must send some ETH to deposit");

        // Create a unique identifier for the user's deposit using a combined hash of username and password
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));

        // Update individual balance for the user and increase the total pool balance
        individualBalances[combinedHash] += msg.value;
        totalPoolBalance += msg.value;
    }

    // Withdraw function that allows withdrawal of a specific amount based on username and password
    function withdraw(string memory username, string memory password, uint256 amount) external {
        // Generate the combined hash of username and password
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));

        // Verify that the user has enough balance in the pool
        require(individualBalances[combinedHash] >= amount, "Insufficient funds or incorrect credentials");

        // Deduct from the user's internal balance and from the pool
        individualBalances[combinedHash] -= amount;
        totalPoolBalance -= amount;

        // Transfer the requested amount to the caller
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Check individual balance for a given username and password (for verification)
    function checkBalance(string memory username, string memory password) external view returns (uint256) {
        bytes32 combinedHash = keccak256(abi.encodePacked(username, password));
        return individualBalances[combinedHash];
    }

    // Function to check the total balance in the pool (for transparency)
    function getPoolBalance() external view returns (uint256) {
        return totalPoolBalance;
    }
}
