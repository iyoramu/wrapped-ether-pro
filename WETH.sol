// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
 * @title Wrapped Ether (WETH)
 * @dev Canonical implementation of Wrapped Ether conforming to ERC-20 with additional features:
 * - ERC-2612 Permit extension for gasless approvals
 * - ERC-5805 Voting extension
 * - Optimized deposit/withdraw functions
 * - Event emission for all operations
 * - Comprehensive error handling
 */
contract WETH is ERC20, ERC20Permit, ERC20Votes {
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    error ZeroAmount();
    error TransferFailed();

    /**
     * @dev Constructor that initializes the ERC-20 token with name "Wrapped Ether" and symbol "WETH"
     */
    constructor() ERC20("Wrapped Ether", "WETH") ERC20Permit("Wrapped Ether") {}

    /**
     * @dev Fallback function that allows the contract to receive ETH and mint WETH
     */
    receive() external payable {
        deposit();
    }

    /**
     * @dev Function to deposit ETH and receive WETH tokens
     */
    function deposit() public payable {
        if (msg.value == 0) revert ZeroAmount();
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Function to withdraw ETH by burning WETH tokens
     * @param amount The amount of WETH to burn/ETH to withdraw
     */
    function withdraw(uint256 amount) public {
        if (amount == 0) revert ZeroAmount();
        _burn(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
        
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    // The following functions are overrides required by Solidity for the voting extensions

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
