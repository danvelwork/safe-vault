// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TwoFactorVault {
    struct Deposit {
        uint256 amount;
        bytes32 usernameHash;
        bytes32 passwordHash;
    }

    mapping(address => Deposit) private deposits;

    // Deposit ETH with separate hashes for username and password
    function deposit(bytes32 usernameHash, bytes32 passwordHash) external payable {
        require(msg.value > 0, "Must send some ETH to deposit");

        // Store the deposit with the username and password hashes
        deposits[msg.sender] = Deposit({
            amount: msg.value,
            usernameHash: usernameHash,
            passwordHash: passwordHash
        });
    }

    // Withdraw funds by providing the correct username and password
    function withdraw(string memory username, string memory password) external {
        Deposit storage userDeposit = deposits[msg.sender];
        require(userDeposit.amount > 0, "No funds to withdraw");

        // Verify the username and password hashes separately
        bytes32 providedUsernameHash = keccak256(abi.encodePacked(username));
        bytes32 providedPasswordHash = keccak256(abi.encodePacked(password));
        
        require(providedUsernameHash == userDeposit.usernameHash, "Incorrect username");
        require(providedPasswordHash == userDeposit.passwordHash, "Incorrect password");

        uint256 amountToWithdraw = userDeposit.amount;
        
        // Clear the deposit to prevent re-entrancy
        userDeposit.amount = 0;

        // Transfer the funds to the caller
        (bool success, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success, "Withdrawal failed");
    }
}
