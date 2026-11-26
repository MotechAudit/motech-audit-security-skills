// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Educational example of missing maximum-supply validation.
/// @dev DO NOT deploy. Owner authorization exists, but mint() does not enforce maxSupply.
contract VulnerableCappedMint {
    address public immutable owner;
    uint256 public immutable maxSupply;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    error Unauthorized();
    error ZeroAmount();

    constructor(uint256 maxSupply_) {
        require(maxSupply_ > 0, "zero max supply");
        owner = msg.sender;
        maxSupply = maxSupply_;
    }

    function mint(uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized();
        if (amount == 0) revert ZeroAmount();

        // Vulnerability: the declared maxSupply is never checked.
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
    }
}
