# Codex real-agent integration test

This guide is the acceptance protocol for testing the published Motech Audit skills in a real Codex installation. It distinguishes repository CI from agent behavior: a passing metadata workflow does not prove that Codex discovered, loaded, or followed a skill.

## 1. Prerequisites

- Codex CLI or the Codex IDE extension, signed in and able to read a local project.
- Node.js 22.20 or later if using the Vercel `skills` CLI.
- Git and Foundry installed if you want to verify the Solidity examples dynamically.
- A clean, non-customer test workspace. Do not use private customer source code for this acceptance test.

Record the versions before testing:

```bash
codex --version
node --version
forge --version
git --version
```

If a command is unavailable, record `not installed`; do not infer a version.

## 2. Install both skills into the test project

From the root of a throwaway test project, run:

```bash
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-security-review -a codex -y
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-vulnerability-detection -a codex -y
```

This is a project-local installation. The expected Codex project skill directory is `.agents/skills/`. Codex also supports user-level skills in `~/.agents/skills/`. Check the project-local installation:

```bash
test -f .agents/skills/solidity-security-review/SKILL.md \
  && echo "review skill installed"
test -f .agents/skills/solidity-vulnerability-detection/SKILL.md \
  && echo "detector skill installed"
```

If you prefer Codex's built-in installer, invoke `$skill-installer` in Codex and ask it to install each public GitHub skill directory:

- `https://github.com/MotechAudit/motech-audit-security-skills/tree/main/skills/solidity-security-review`
- `https://github.com/MotechAudit/motech-audit-security-skills/tree/main/skills/solidity-vulnerability-detection`

Follow the installer output and verify where it placed each skill. Current Codex documentation lists project-level `.agents/skills` (including the repository root) and user-level `~/.agents/skills` as discovery locations. Restart Codex if newly installed skills do not appear in the skill selector.

## 3. Confirm discovery and explicit invocation

Open the test project in Codex and run `/skills` to inspect available skills. Record whether both names appear. If you installed them under `~/.agents/skills`, verify those exact paths instead of expecting project-local files.

Then invoke each explicitly:

```text
$solidity-security-review
```

```text
$solidity-vulnerability-detection
```

Ask Codex to state which skill it loaded and summarize the scope of the instructions it followed. Do not count a response that merely mentions a skill name as proof of loading; inspect the visible skill selector or request the skill's title and workflow sections.

## 4. Test A — broad security review (access control)

Use the repository fixtures or a clean clone of this repository. From the repository root, prompt Codex:

```text
$solidity-security-review

Review only:
- src/VulnerableAccessVault.sol
- src/SafeAccessVault.sol

Use test/AccessControl.t.sol as supporting evidence. These are public educational
fixtures and I authorize this local review. Do not modify files.

Identify the intended authorization boundary, inspect the withdrawal paths,
and report findings in the skill's finding format. Include exact source
locations, attacker preconditions, impact, remediation, and coverage gaps.

If Foundry is available, run:
forge test --match-path test/AccessControl.t.sol -vv

Record the exact command, Forge version, commit SHA, and observed result.
If you cannot run the test, state that dynamic verification was not performed.
Do not invent output or claim the whole project is secure.
```

Expected review signal (not text to copy verbatim):

- The vulnerable fixture's `withdrawAll(address payable)` is externally callable without checking `msg.sender == owner`.
- An unprivileged caller can choose a recipient and withdraw the vault's full native-asset balance.
- The safe fixture checks the owner before transfer.
- The existing test file exercises unauthorized drain, unauthorized rejection, and legitimate owner withdrawal.

The skill should identify the vulnerable path, not report the same issue against the safe fixture.

## 5. Test B — focused vulnerability detection (reentrancy)

Prompt Codex:

```text
$solidity-vulnerability-detection

Investigate only:
- src/VulnerableVault.sol
- src/SafeVault.sol
- test/Reentrancy.t.sol

These are public educational fixtures and I authorize a local review. Do not
modify files or interact with a live deployment.

Write a falsifiable vulnerability hypothesis, trace the attacker callback,
state the violated accounting invariant, compare the mitigation, and classify
the evidence using Confirmed / Suspected / Needs information / Not reproduced.

If Foundry is available, run:
forge test --match-path test/Reentrancy.t.sol -vv

Record the exact command, Forge version, commit SHA, and observed result.
Do not call a source-pattern observation a reproduced exploit if the test
was not actually executed.
```

Expected review signal:

- The vulnerable fixture makes an external call before clearing `balances[msg.sender]`.
- The attacker callback can re-enter while the old balance is still recorded.
- The regression test asserts the vault loses assets beyond the attacker's deposit.
- The safe fixture clears the balance before the external call (checks-effects-interactions).

Do not infer production exploitability from an educational test alone; state the fixture's assumptions and scope.

## 6. Test C — focused detection (arbitrary delegatecall)

Prompt Codex:

```text
$solidity-vulnerability-detection

Investigate only:
- src/VulnerableDelegatecallVault.sol
- src/SafeDelegatecallVault.sol
- test/Delegatecall.t.sol

These are public educational fixtures and I authorize local analysis.
Trace the externally reachable entry point, attacker-controlled target and
calldata, storage context, and owner-slot overwrite. Compare the safe
alternative. If Foundry is available, run:
forge test --match-path test/Delegatecall.t.sol -vv

Record exact tool versions, commit SHA, and observed result. Do not claim
dynamic validation if the command was not run.
```

Expected review signal:

- `execute(address,bytes)` is unrestricted and accepts attacker-selected code and calldata.
- The selected code executes in the vault's storage context and can overwrite the slot used by `owner`.
- The safe fixture does not expose an arbitrary delegatecall entry point.

## 7. Record results

Copy this table into the integration log and fill it using observed results only.

| Check | Result | Evidence |
| --- | --- | --- |
| Codex version recorded | Not run | Version string |
| Both skills installed | Not run | Paths and install output |
| Both skills visible in `/skills` | Not run | Screenshot or transcript |
| Explicit invocation of both skills | Not run | Prompt/transcript |
| Test A analysis quality | Not run | Finding and source locations |
| Test A Foundry test | Not run | Command and output, or not run |
| Test B analysis quality | Not run | Hypothesis and attack path |
| Test B Foundry test | Not run | Command and output, or not run |
| Test C analysis quality | Not run | Hypothesis and storage trace |
| Test C Foundry test | Not run | Command and output, or not run |

## 8. Pass criteria

A Codex integration is **accepted for this tested setup** only when:

1. Both skills are installed in a directory Codex scans and both appear in `/skills`.
2. Each skill can be explicitly invoked.
3. Test A identifies the missing authorization check and does not misattribute it to the safe fixture.
4. Test B explains the external-call-before-effect ordering and the callback sequence.
5. Test C explains attacker-selected delegatecall and the caller storage context.
6. Tool execution claims match the recorded terminal output; skipped commands are marked not run.
7. Every result includes the Codex version, skill source/ref, test commit, and relevant tool versions.

This is a small acceptance suite, not a measure of recall across all Solidity vulnerabilities, and not a security certification. Re-run it after material skill changes and record regressions rather than silently changing expected results.
