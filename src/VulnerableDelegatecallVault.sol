// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Deliberately vulnerable educational fixture. NEVER deploy with assets.
contract VulnerableDelegatecallVault {
    address public owner; // storage slot 0

    constructor() {
        owner = msg.sender;
    }

    /// @dev Anyone can select both target code and calldata.
    /// delegatecall executes the target's code in THIS contract's storage context.
    function execute(address target, bytes calldata data) external {
        (bool ok,) = target.delegatecall(data);
        require(ok, "delegatecall failed");
    }
}

/// @notice Attacker-controlled code used only by the Foundry demonstration.
contract DelegatecallOwnerOverwrite {
    address public owner; // also slot 0: collides with the vault's owner

    function overwriteOwner(address newOwner) external {
        owner = newOwner;
    }
}
