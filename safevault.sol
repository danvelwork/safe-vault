// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureVault {
    struct Deposit {
        uint256 amount;
        bytes32 passwordHash;
    }

    mapping(address => Deposit) private deposits;

    // User deposits ETH with a hashed password
    function deposit(bytes32 passwordHash) external payable {
        require(msg.value > 0, "Must send some ETH to deposit");

        // Store deposit amount and password hash
        deposits[msg.sender] = Deposit({
            amount: msg.value,
            passwordHash: passwordHash
        });
    }

    // Withdraw funds by providing the correct password
    function withdraw(string memory password) external {
        Deposit storage userDeposit = deposits[msg.sender];

        require(userDeposit.amount > 0, "No funds to withdraw");

        // Hash the provided password and compare it to the stored hash
        bytes32 hashedInput = keccak256(abi.encodePacked(password));
        require(hashedInput == userDeposit.passwordHash, "Incorrect password");

        uint256 amountToWithdraw = userDeposit.amount;

        // Clear the user's deposit record
        userDeposit.amount = 0;

        // Transfer the funds to the caller
        (bool success, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success, "Withdrawal failed");
    }
}
