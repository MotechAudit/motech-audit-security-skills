# Access-control review walkthrough

This worked example connects inspected source code, a candidate finding, the existing reproduction tests, and the mitigation. It is educational and is not a customer audit.

## Scope and assumptions

- [VulnerableAccessVault.sol](../src/VulnerableAccessVault.sol): deliberately unrestricted withdrawal.
- [SafeAccessVault.sol](../src/SafeAccessVault.sol): owner-only withdrawal.
- [AccessControl.t.sol](../test/AccessControl.t.sol): local reproduction and regression tests.
- Intended policy: only the deploying owner may withdraw the vault's Ether.
- Assets: native Ether held by the fixture; no tokens, proxies, or deployed targets.

## Trace the trust boundary

The vulnerable constructor stores the deployer as owner. However, withdrawAll(address payable) is external and never checks that owner. The caller selects the recipient and the function sends the entire balance there. An unrelated account or contract therefore crosses the intended owner boundary.

## Worked finding

- **Title**: Missing authorization permits withdrawal of all vault Ether.
- **Severity**: High, provisional under the stated owner-only policy, because an unrelated caller can transfer the full balance without privilege or a prior deposit. A production rating requires its actual context and rubric.
- **Status**: Needs manual verification of runtime behavior; the source-level missing check is directly observable. This document does not claim a test run.
- **Location**: src/VulnerableAccessVault.sol, withdrawAll(address payable), lines 13–16 at baseline commit 964491992278262c37e18f2a3ad9cf0deffd6214. Recheck locations after changes.
- **Description and impact**: The owner field does not enforce authorization. Any caller can choose a payable recipient and withdraw the vault's current Ether balance.
- **Preconditions and attack scenario**: The fixture has a positive balance and the chosen recipient accepts Ether. A non-owner calls withdrawAll with its own recipient; the entire balance is transferred.
- **Evidence / reproduction**: Inspect the missing check, then run the focused tests below. Existing assertions describe the intended reproduction; they are not an execution log.
- **Remediation**: Require msg.sender == owner before transferring funds. The mitigated fixture assigns an immutable owner during construction and checks that role in withdrawAll.
- **Verification status**: Record the actual test result, tool version, and reviewed commit before describing runtime behavior as reproduced.

## Reproduce and check the mitigation

From the repository root:

```bash
git rev-parse HEAD
forge --version
forge test --match-contract AccessControlTest -vv
```

| Existing test | Expected assertion |
| --- | --- |
| testUnauthorizedCallerCanDrainVulnerableVault | The local vault's 1 Ether moves to the unrelated caller contract |
| testUnauthorizedCallerCannotDrainSafeVault | The unauthorized call fails; 1 Ether remains in the vault and the caller receives nothing |
| testOwnerCanWithdrawSafeVault | The owner can still withdraw successfully |

The tests fund local fixtures with Foundry's deal cheatcode; no real Ether is needed. A passing vulnerable-fixture test means the test successfully demonstrates the vulnerability.

Inspect the owner check in [SafeAccessVault.sol](../src/SafeAccessVault.sol), then run all examples:

```bash
forge test -vv
python3 scripts/validate_skills.py
```

Record failures exactly. If forge is missing or a compiler download fails, report that limitation rather than claiming the tests passed.

## Coverage limits

These tests cover three defined authorization scenarios. They do not establish production readiness, test every recipient behavior, assess ownership recovery or key compromise, or review token accounting and upgradeability. The mitigated fixture is a teaching example, not a general-purpose vault recommendation.
