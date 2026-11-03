// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Deliberately vulnerable educational example. Never deploy with real funds.
contract VulnerableAccessVault {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    // VULNERABILITY: missing authorization check.
    function withdrawAll(address payable recipient) external {
        (bool ok,) = recipient.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
