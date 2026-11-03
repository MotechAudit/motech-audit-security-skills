// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Educational mitigation: owner-only privileged withdrawal.
contract SafeAccessVault {
    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    function withdrawAll(address payable recipient) external {
        require(msg.sender == owner, "not owner");
        (bool ok,) = recipient.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
