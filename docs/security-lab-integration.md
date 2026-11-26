# Using Motech Security Skills with the Solidity Security Lab

Motech Audit maintains two complementary open-source projects:

- [Motech Audit Security Skills](https://github.com/MotechAudit/motech-audit-security-skills) provides AI-agent workflows for structured Solidity security review and focused vulnerability detection.
- [Motech Solidity Security Lab](https://github.com/MotechAudit/motech-solidity-security-lab) provides source-level vulnerable/mitigated examples, Foundry tests, and Slither analysis workflows.

They are complementary projects, not one combined executable product. Installing a Skill does not automatically install, run, or validate the separate Security Lab. A reviewer must clone the Lab and run its tests separately when using it as a reference.

## Topic-to-evidence map

| Review topic | Security Lab reference | What the Lab demonstrates |
|---|---|---|
| Reentrancy | [VulnerableVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/VulnerableVault.sol) · [FixedVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/FixedVault.sol) · [Reentrancy.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/Reentrancy.t.sol) | External calls before state updates and the checks-effects-interactions mitigation. |
| Access control | [VulnerableFeeVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/access-control/VulnerableFeeVault.sol) · [FixedFeeVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/access-control/FixedFeeVault.sol) · [AccessControl.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/AccessControl.t.sol) | An unrestricted privileged setter compared with owner-restricted state changes. |
| Delegatecall and storage | [VulnerableDelegateCaller.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/delegatecall/VulnerableDelegateCaller.sol) · [FixedExternalCaller.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/delegatecall/FixedExternalCaller.sol) · [DelegatecallStorageCollision.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/DelegatecallStorageCollision.t.sol) | Delegatecall storage-context behavior and a normal-call comparison. |
| `tx.origin` authorization | [VulnerableTxOriginWallet.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/tx-origin/VulnerableTxOriginWallet.sol) · [FixedOwnerWallet.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/tx-origin/FixedOwnerWallet.sol) · [TxOrigin.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/TxOrigin.t.sol) | Transaction-origin checks compared with immediate-caller authorization. |
| Fee-on-transfer accounting | [VulnerableFeeOnTransferVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/erc20/VulnerableFeeOnTransferVault.sol) · [FixedFeeOnTransferVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/erc20/FixedFeeOnTransferVault.sol) · [FeeOnTransferAccounting.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/FeeOnTransferAccounting.t.sol) | Requested transfer amount compared with the balance delta actually received. |
| ERC-20 optional returns and allowances | [SafeERC20CompatibilityVault.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/erc20/SafeERC20CompatibilityVault.sol) · [SafeAllowanceManager.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/src/erc20/SafeAllowanceManager.sol) · [ERC20Compatibility.t.sol](https://github.com/MotechAudit/motech-solidity-security-lab/blob/main/test/ERC20Compatibility.t.sol) | SafeERC20 handling and forceApprove for zero-first allowance tokens. |

The Skills project also contains a separate [maximum-supply input-validation case](../src/VulnerableCappedMint.sol) with its own [fixed fixture](../src/FixedCappedMint.sol), [Foundry tests](../test/InputValidation.t.sol), and [case notes](input-validation.md). That case is maintained in the Skills repository; it is not currently a Security Lab case.

## Suggested workflow

1. Use [Solidity Security Review](../skills/solidity-security-review/SKILL.md) for a broad review, or [Solidity Vulnerability Detection](../skills/solidity-vulnerability-detection/SKILL.md) for a focused hunt.
2. Treat Skill output as a structured review aid. Record the exact target commit, scope, assumptions, and validation actually performed.
3. When a matching educational case exists, read the paired vulnerable and mitigated contracts in the Security Lab.
4. Clone the Lab repository separately and run the documented Foundry tests if you need to reproduce the example. See the [Lab README](https://github.com/MotechAudit/motech-solidity-security-lab#run-the-tests) for dependencies and commands.
5. Do not treat a passing educational fixture test as proof that a different contract is secure. Reproduce any finding against the authorized target code and its actual assumptions.

## Project boundaries

- Security Skills are agent instructions and reusable review workflows.
- Security Lab is a standalone collection of educational Solidity source examples and validation tests.
- The projects have independent releases and CI workflows.
- Some Skills topics do not yet have a matching Lab example. The mapping above lists only the examples that currently exist.
- Neither project claims to replace a complete independent smart-contract audit.
