// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OpenPasswordVault {
    struct Deposit {
        uint256 amount;
        bytes32 passwordHash;
    }

    // Mapping from password hash to the deposited amount
    mapping(bytes32 => uint256) private vault;

    // Deposit ETH with a hashed password
    function deposit(bytes32 passwordHash) external payable {
        require(msg.value > 0, "Must send some ETH to deposit");

        // Store the amount in the vault under the password hash
        vault[passwordHash] += msg.value;
    }

    // Withdraw a specified amount by providing the correct password
    function withdraw(string memory password, uint256 amount) external {
        // Hash the provided password
        bytes32 providedHash = keccak256(abi.encodePacked(password));

        // Check if the vault has enough funds under this password hash
        require(vault[providedHash] >= amount, "Insufficient funds or incorrect password");

        // Deduct the amount from the vault under this password hash
        vault[providedHash] -= amount;

        // Transfer the requested amount to the caller
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Check balance for a given password (use hashed password for security)
    function checkBalance(bytes32 passwordHash) external view returns (uint256) {
        return vault[passwordHash];
    }
}
