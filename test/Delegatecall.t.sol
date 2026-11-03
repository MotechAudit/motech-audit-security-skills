// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/VulnerableDelegatecallVault.sol";
import "../src/SafeDelegatecallVault.sol";

/// @notice Reproducible demonstration of arbitrary delegatecall storage collision.
contract DelegatecallTest {
    function testArbitraryDelegatecallOverwritesOwner() public {
        VulnerableDelegatecallVault vault = new VulnerableDelegatecallVault();
        DelegatecallOwnerOverwrite attackerCode = new DelegatecallOwnerOverwrite();
        address attacker = address(0xBEEF);

        require(vault.owner() == address(this), "unexpected initial owner");

        vault.execute(
            address(attackerCode),
            abi.encodeWithSelector(
                DelegatecallOwnerOverwrite.overwriteOwner.selector,
                attacker
            )
        );

        require(vault.owner() == attacker, "owner overwrite not reproduced");
        require(attackerCode.owner() == address(0), "target storage should be unchanged");
    }

    function testSafeAlternativeHasNoArbitraryDelegatecall() public {
        SafeDelegatecallVault vault = new SafeDelegatecallVault();
        require(vault.owner() == address(this), "unexpected initial owner");
        require(vault.double(21) == 42, "expected result");

        // Attempt to invoke the vulnerable interface; no such entry point exists.
        (bool ok,) = address(vault).call(
            abi.encodeWithSignature(
                "execute(address,bytes)",
                address(new DelegatecallOwnerOverwrite()),
                abi.encodeWithSignature("overwriteOwner(address)", address(0xBEEF))
            )
        );
        require(!ok, "arbitrary delegatecall unexpectedly exposed");
        require(vault.owner() == address(this), "owner changed");
    }
}
