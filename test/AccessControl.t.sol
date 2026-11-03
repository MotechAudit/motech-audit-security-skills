// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/VulnerableAccessVault.sol";
import "../src/SafeAccessVault.sol";

contract UnauthorizedCaller {
    receive() external payable {}

    function withdrawVulnerable(VulnerableAccessVault vault) external {
        vault.withdrawAll(payable(address(this)));
    }

    function withdrawSafe(SafeAccessVault vault) external returns (bool) {
        (bool ok,) = address(vault).call(
            abi.encodeWithSelector(SafeAccessVault.withdrawAll.selector, payable(address(this)))
        );
        return ok;
    }
}

interface VmFunding {
    function deal(address account, uint256 newBalance) external;
}

contract AccessControlTest {
    VmFunding constant vm = VmFunding(address(uint160(uint256(keccak256("hevm cheat code")))));
    receive() external payable {}

    function testUnauthorizedCallerCanDrainVulnerableVault() public {
        vm.deal(address(this), 1 ether);
        VulnerableAccessVault vault = new VulnerableAccessVault{value: 1 ether}();
        UnauthorizedCaller caller = new UnauthorizedCaller();
        caller.withdrawVulnerable(vault);
        require(address(vault).balance == 0, "vault should be drained");
        require(address(caller).balance == 1 ether, "caller should receive funds");
    }

    function testUnauthorizedCallerCannotDrainSafeVault() public {
        vm.deal(address(this), 1 ether);
        SafeAccessVault vault = new SafeAccessVault{value: 1 ether}();
        UnauthorizedCaller caller = new UnauthorizedCaller();
        bool ok = caller.withdrawSafe(vault);
        require(!ok, "unauthorized withdrawal must revert");
        require(address(vault).balance == 1 ether, "funds must remain");
        require(address(caller).balance == 0, "caller must receive nothing");
    }

    function testOwnerCanWithdrawSafeVault() public {
        vm.deal(address(this), 1 ether);
        SafeAccessVault vault = new SafeAccessVault{value: 1 ether}();
        vault.withdrawAll(payable(address(this)));
        require(address(vault).balance == 0, "owner withdrawal failed");
    }
}
