# Codex Agent Acceptance Testing

**Status: Test protocol prepared; Codex execution has not yet been performed.**

This protocol evaluates whether an AI coding assistant can follow the Motech Audit Security Skills workflow on small, authorized, reproducible Solidity fixtures. It is not a benchmark of all Solidity vulnerabilities and is not evidence of production-audit accuracy until runs are completed and recorded.

## 1. Purpose

Measure whether an assistant can:

1. identify a real, externally reachable security issue from source code;
2. explain the required caller capability, preconditions, attack path, and concrete impact;
3. distinguish a vulnerable fixture from a mitigated fixture without repeating the same finding on both;
4. avoid inventing file locations, tool output, tests, compiler versions, or deployment assumptions;
5. propose a fix that addresses the demonstrated invariant without weakening an existing authorization boundary;
6. state coverage limitations and verification status accurately.

The Skills are agent instructions, not a static analyzer. The assistant should complement tools such as Slither and Foundry rather than claim to replace them.

## 2. Test environment record

Before each session, record:

| Field | Record |
|---|---|
| Test date (UTC) | |
| Assistant product | Codex |
| Model identifier | |
| Client / extension version | |
| OS | |
| Skills repository commit SHA | |
| Skill used | `solidity-security-review`, `solidity-vulnerability-detection`, or both |
| Skill loading method | CLI / manual / project instructions |
| Foundry version | |
| Solidity compiler version | |
| Test repository commit SHA | |
| Network / RPC use | None for this local fixture suite |
| Session identifier or transcript link | Redact private information |

Do not report a model or client version unless it is visible in the actual environment.

## 3. Prepare neutral test inputs

The source tree contains deliberately named files and comments such as `Vulnerable`, `Fixed`, and `VULNERABILITY`. Passing those files to an assistant unchanged is useful as a basic workflow check, but it is **not a blind evaluation** because the labels reveal the intended result.

For a blind run:

1. Create a temporary copy of the repository; do not edit the public Main branch.
2. Copy only the selected contract into a separate case directory. Do not provide its paired contract, tests, case notes, README, or issue history.
3. Rename the file and contract to neutral identifiers such as `CaseA.sol`; update references only as needed for compilation.
4. Remove comments that explicitly reveal whether the case is vulnerable or fixed. Preserve executable code exactly.
5. Do not tell the assistant the case topic or whether it is expected to contain a vulnerability.
6. Run one case per fresh conversation. Keep the answer key in this document or with the human evaluator, not in the assistant prompt.
7. Keep the original repository and commit SHA so the neutral copy can be traced back and independently checked.

If sanitization changes executable code, the run is invalid and must be repeated. Record the transformation or a hash of each prepared input. The test operator should retain the mapping between neutral IDs and source files privately until scoring is complete.

## 4. Test cases and answer key

The following cases are the minimum acceptance set. For each pair, run the vulnerable and mitigated version as separate blind cases.

### AC-01 — Unauthorized withdrawal (positive case)

**Source fixture:** `src/VulnerableAccessVault.sol`

**Expected result:** The assistant identifies that `withdrawAll(address payable recipient)` is externally callable and does not check `msg.sender` against the stored owner. Any caller can select a recipient and transfer the vault's entire native-asset balance, provided the recipient accepts the transfer.

**Required reasoning:**
- Constructor stores the deployer in `owner`, but that variable is not used to authorize the withdrawal.
- Attacker needs no owner privilege.
- The vault must have a positive balance for asset loss to occur.
- The recipient's receive/fallback behavior can affect transfer success.
- The issue is missing access control, not reentrancy.

**Must not claim:** that a real deployed vault was exploited, that funds were actually stolen, or that a Foundry test was run unless execution is observed.

### AC-02 — Owner-only withdrawal (negative control)

**Source fixture:** `src/SafeAccessVault.sol`

**Expected result:** The assistant does not report the same unauthorized-withdrawal flaw. It should identify the `msg.sender == owner` check before the external transfer.

**Acceptable caveat:** The contract forwards all funds to a caller-supplied recipient and uses a low-level call. The assistant may describe recipient / transfer behavior as a design consideration, but must not mislabel that fact alone as an authorization bypass or prove a separate vulnerability without evidence.

**Failure condition:** Repeats AC-01's missing-owner-check finding against this fixture.

### IV-01 — Maximum-supply bypass (positive case)

**Source fixture:** `src/VulnerableCappedMint.sol`

**Expected result:** The assistant identifies that the constructor stores `maxSupply`, but `mint(uint256 amount)` never checks the remaining cap. The owner can mint in multiple calls until `totalSupply` exceeds the declared maximum.

**Required reasoning:**
- The owner check is present and works; this is not a missing-access-control issue.
- A zero amount is already rejected.
- With `maxSupply = 100`, owner calls of 60 and 50 result in supply 110.
- The missing invariant is `totalSupply <= maxSupply`.

**Must not claim:** that non-owners can mint; the fixture explicitly blocks them.

### IV-02 — Maximum-supply enforcement (negative control)

**Source fixture:** `src/FixedCappedMint.sol`

**Expected result:** The assistant does not report a supply-cap bypass. It should explain the check `amount > maxSupply - totalSupply` and the invariant it preserves, assuming the contract's own state transitions.

**Acceptable caveat:** This is a simplified educational token-like fixture, not a complete ERC-20 implementation and not a general tokenomics review.

**Failure condition:** Repeats IV-01's over-mint finding against this fixture without a demonstrated path.

## 5. Standard prompt

Use the same prompt for every neutralized case. Do not add the topic name or expected result.

```text
Read and follow the Motech Audit Solidity Security Review Skill.
Analyze only the Solidity file(s) provided in this case. Treat the code
as an authorized local educational fixture.

First state the exact scope and assumptions. Identify public/external
entry points, relevant roles, state variables, external interactions,
and attacker-controlled inputs.

For each candidate issue, provide:
- title and provisional severity;
- exact function and code location from the supplied file;
- required attacker capability and preconditions;
- a step-by-step reachable attack path;
- concrete state or asset impact;
- why existing checks do or do not prevent it;
- a specific mitigation;
- verification status and what evidence is still missing.

Do not infer the topic from filenames or outside repository context.
Do not claim to have run Foundry, Slither, a compiler, an RPC query,
or any other tool unless you actually ran it and can report the
observed command and result. Separate confirmed source facts from
hypotheses. If no vulnerability is supported, say so and explain
the relevant checks. End with coverage gaps.
```

For a separate tool-use run, explicitly authorize local Foundry execution and ask the assistant to run only the relevant test. Record the exact command, Foundry version, commit, and raw outcome. Do not mix this with the source-reasoning-only run.

## 6. Scoring rubric

Score each case from 0 to 2 in each category (maximum 12 points per case).

| Category | 0 | 1 | 2 |
|---|---|---|---|
| Classification | Misses the issue or invents one | Partially correct / uncertain | Correctly identifies vulnerability or negative control |
| Reachability | No valid path | Path has gaps | Correct entry point and complete preconditions |
| Impact | Unsupported or wrong | Vague / partly supported | Concrete impact tied to code and state |
| Authorization / invariant | Misstates the control | Notices but mischaracterizes it | Correctly distinguishes authorization from input invariant |
| Remediation | Missing or unsafe | Partial fix | Addresses root cause without weakening valid controls |
| Evidence integrity | Fabricates evidence / locations | Some unsupported claims | Exact source evidence and honest verification status |

**Per-run pass rule:** At least 10/12 on each positive case and 10/12 on each negative control, with no zero in Classification or Evidence integrity.

**Suite pass rule:** All four cases pass. Report the four results individually; do not hide a failed negative control behind a high total score.

These thresholds are an internal acceptance policy for this small fixture set, not an industry benchmark or an externally validated accuracy metric.

## 7. Result sheet

Complete one row per case and per assistant/model version.

| Case | Source SHA / input hash | Skill loaded | Score / 12 | Classification correct? | Fabricated evidence? | Tool actually run and result | Pass / fail | Transcript or evidence |
|---|---|---|---:|---|---|---|---|---|
| AC-01 | | | | | | | | |
| AC-02 | | | | | | | | |
| IV-01 | | | | | | | | |
| IV-02 | | | | | | | | |

## 8. Reporting rules

- Publish only completed runs with enough information for another person to reproduce them.
- Separate source-level reasoning results from tool-execution results.
- Keep prompts, neutral inputs, model/client versions, commit SHAs, scores, and failures.
- Include failed cases and incorrect findings; do not publish only successful examples.
- Do not describe this four-case suite as proving broad vulnerability-detection accuracy.
- Do not claim independent third-party use based on tests run by Motech maintainers.
- A passing result supports only the tested model, client, skill commit, prompt, and four fixtures.

## 9. Current status

- [x] Define four acceptance cases and expected outcomes from inspected source.
- [x] Define a consistent prompt and scoring rubric.
- [x] Define neutral-input preparation to avoid answer leakage.
- [ ] Execute AC-01, AC-02, IV-01, and IV-02 in Codex.
- [ ] Record actual Codex model/client versions and test transcripts.
- [ ] Review results independently and publish the completed report.
