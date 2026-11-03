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

## Integrity rules
Do not invent code references, test runs, CVSS scores, audit certifications, or security guarantees. Distinguish observed facts from reasoning. Treat AI output as assistance, not an independent formal audit report.
