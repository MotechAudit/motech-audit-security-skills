---
name: solidity-security-review
description: Evidence-driven Solidity smart contract security review workflow for authorized codebases.
---

# Solidity Security Review — Motech Audit

## Scope and authorization
Only review code the user owns or is authorized to assess. Keep customer source code private and follow project data-handling requirements.

## Workflow
1. Inventory Solidity versions, dependencies, build system, proxies, external calls, and trust boundaries.
2. Identify privileged roles and functions that can transfer funds, upgrade contracts, mint tokens, change fees, pause services, or alter critical configuration.
3. Trace deposits, withdrawals, accounting, approvals, oracle reads, callbacks, and cross-contract interactions.
4. Review reentrancy, access control, authorization, arithmetic/rounding, unchecked external calls, signature replay, front-running/MEV, oracle manipulation, initialization, upgradeability, denial of service, and unsafe assumptions.
5. For each candidate issue, specify the affected file/function, exploit preconditions, a concrete attack path, impact, and proposed mitigation.
6. Validate with a minimal Foundry test or static-analysis evidence when available. Clearly mark unverified hypotheses.
7. Summarize coverage gaps and remaining assumptions. Never claim absence of vulnerabilities.

## Finding format
- **Title**:
- **Severity**: Critical / High / Medium / Low / Informational (provisional until validated)
- **Status**: Confirmed / Suspected / Needs manual verification
- **Location**: exact file, function and lines if actually inspected
- **Description and impact**:
- **Preconditions and attack scenario**:
- **Evidence / reproduction**:
- **Remediation**:

## Sample finding (fictional and educational)

The following example uses an imaginary contract and illustrative line numbers. It is not a finding against this repository or a real deployed target.

```solidity
// Fictional example: illustrative code only.
function withdraw(uint256 amount) external {
    require(credit[msg.sender] >= amount, "insufficient credit");
    (bool ok, ) = payable(msg.sender).call{value: amount}("");
    require(ok, "transfer failed");
    credit[msg.sender] -= amount;
}
```

- **Title**: Re-entrancy may allow repeated withdrawals
- **Severity**: High (provisional) — if the contract holds withdrawable funds and the caller can re-enter before their credit is reduced, repeated withdrawals could drain funds beyond the caller's recorded credit. Confirm the actual reachability and potential loss before final severity assignment.
- **Status / verification**: Suspected — illustrative reasoning only. No test, static analysis, or exploit execution is claimed.
- **Location**: `contracts/examples/CreditVault.sol`, `withdraw(uint256)`, illustrative lines 2–6. These are fictional references, not inspected repository locations.
- **Preconditions and attack scenario**: The contract has sufficient Ether; an attacker has a positive credit balance; and the recipient can execute a fallback function that calls `withdraw` again before the original call updates `credit`.
- **Description and impact**: The external call occurs before the credit balance is reduced. During the callback, the old balance may still satisfy the require check, potentially allowing more Ether to be withdrawn than the caller's recorded credit.
- **Evidence / reproduction**: The ordering in the fictional snippet shows the external call before the state update. This is a code-level illustration, not executed test evidence.
- **Severity rationale**: High is a provisional example because successful exploitation could cause direct loss of contract funds. Actual severity depends on reachable call paths, available balance, and applicable safeguards.
- **Remediation**: Apply the checks-effects-interactions pattern by reducing the caller's credit before the external call, relying on transaction reversion if the transfer fails. Consider a reentrancy guard as defense in depth.
- **Verification status**: Not tested. A reviewer should add a focused Foundry regression test with a re-entering recipient and run the project's validation workflow before marking the issue Confirmed.

## Integrity rules
Do not invent code references, test runs, CVSS scores, audit certifications, or security guarantees. Distinguish observed facts from reasoning. Treat AI output as assistance, not an independent formal audit report.
