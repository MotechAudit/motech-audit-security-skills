// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Safer alternative for this simple use case: no arbitrary delegatecall.
/// @dev Real upgradeable proxies require audited authorization and storage layouts.
contract SafeDelegatecallVault {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function double(uint256 value) external pure returns (uint256) {
        return value * 2;
    }
}
