// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Educational mitigation that enforces the configured maximum supply.
contract FixedCappedMint {
    address public immutable owner;
    uint256 public immutable maxSupply;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    error Unauthorized();
    error ZeroAmount();
    error SupplyCapExceeded();

    constructor(uint256 maxSupply_) {
        require(maxSupply_ > 0, "zero max supply");
        owner = msg.sender;
        maxSupply = maxSupply_;
    }

    function mint(uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized();
        if (amount == 0) revert ZeroAmount();

        // Subtraction avoids relying on totalSupply + amount for the cap check.
        // The invariant totalSupply <= maxSupply is maintained by this contract.
        if (amount > maxSupply - totalSupply) revert SupplyCapExceeded();

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
    }
}
