# Codex real-agent integration validation

This procedure checks whether Codex actually discovers and follows the two Motech Audit skills. A successful metadata CI job alone does not establish agent integration.

## 1. Prerequisites

- Codex CLI or the Codex IDE extension.
- Node.js 22.20 or later if using the Vercel Skills CLI.
- Git access to the public Motech Audit repository.
- Foundry installed if you intend to run the Solidity regression test.

Check the local tools first:

```bash
node --version
codex --version
forge --version
```

Record the versions. If a command is unavailable, record it as unavailable; do not infer a version.

## 2. Install both skills for Codex

The following command installs both skills globally for the Codex agent:

```bash
npx skills add MotechAudit/motech-audit-security-skills \
  --skill solidity-security-review \
  --skill solidity-vulnerability-detection \
  -a codex -g -y
```

The Codex target uses the user-level skills directory. The CLI prints its actual installation paths; keep that output as evidence.

To inspect the installation:

```bash
npx skills list
```

Confirm that both names appear:

- `solidity-security-review`
- `solidity-vulnerability-detection`

If the CLI reports that a skill already exists, inspect the target path before overwriting or removing anything. Do not delete existing skill folders blindly.

## 3. Confirm discovery inside Codex

Start or restart Codex after installation if the new skills are not visible. In Codex, run:

```text
/skills
```

Confirm that both Motech Audit skills appear in the list. You can also invoke them explicitly with `$solidity-security-review` and `$solidity-vulnerability-detection`.

Take a screenshot or copy the visible skill list into the test record. A successful CLI install by itself is not proof that the running Codex session discovered the skills.

## 4. Prepare the controlled test target

Use the public educational fixtures in this repository only:

- `src/VulnerableAccessVault.sol`
- `src/SafeAccessVault.sol`
- `test/AccessControl.t.sol`

Clone the repository and record the exact commit:

```bash
git clone https://github.com/MotechAudit/motech-audit-security-skills.git
cd motech-audit-security-skills
git rev-parse HEAD
```

These contracts are intentionally educational. Do not deploy them or fund them with real assets.

## 5. Test the broad review skill

In Codex, explicitly invoke:

```text
$solidity-security-review
```

Then provide this task:

```text
Review only src/VulnerableAccessVault.sol and src/SafeAccessVault.sol.
Use test/AccessControl.t.sol as supporting evidence.

Identify the intended authorization boundary, trace the public withdrawal
entry point, compare the vulnerable and mitigated implementations, and
report any concrete finding. State the exact file and function. Separate
direct source observations from behavior demonstrated by tests.

Do not modify files, install dependencies, contact an RPC endpoint, or
broadcast transactions. Do not claim tests were run unless you execute
them and show the observed output. End with scope limitations.
```

Expected observations to check manually:
- The vulnerable fixture's `withdrawAll(address payable)` has no owner authorization check.
- The caller selects the payable recipient, and the function attempts to transfer the vault's full Ether balance.
- The mitigated fixture checks `msg.sender == owner` before transferring.
- The report identifies the source files/functions accurately and does not invent line numbers or test output.

## 6. Test the focused vulnerability-detection skill

In Codex, explicitly invoke:

```text
$solidity-vulnerability-detection
```

Then provide this task:

```text
Perform a focused vulnerability hunt on src/VulnerableAccessVault.sol.
Use src/SafeAccessVault.sol as the comparison and test/AccessControl.t.sol
as supporting evidence.

Write one falsifiable vulnerability hypothesis. Trace the caller capability,
externally reachable entry point, relevant state/asset, authorization failure,
preconditions, and impact. Compare the mitigation. Use the skill's evidence
labels and finding template.

Do not run commands or modify files. Mark runtime reproduction as unverified
because no test has been executed in this task. Do not invent severity scores,
line numbers, tool results, or deployed-state assumptions.
```

Expected observations to check manually:
- The skill identifies an untrusted caller reaching `withdrawAll`.
- The hypothesis explains that an arbitrary payable recipient can be selected and the entire current vault balance is sent if the call succeeds.
- The safe comparison identifies the owner check.
- The report distinguishes source-level evidence from runtime reproduction and does not claim a Foundry test was executed.

## 7. Validate the regression test separately

Only after the two read-only Codex tasks, run the existing local regression test yourself:

```bash
forge test --match-contract AccessControlTest -vv
```

If that passes, record the actual terminal output, Foundry version, repository commit, and command. The expected test contract contains three cases; report the observed result rather than assuming a pass count.

The regression test validates these educational fixtures. It is not proof that the skills detect every vulnerability or that unrelated contracts are secure.

## 8. Integration acceptance record

Copy and complete this table. Leave unknown fields blank rather than guessing.

| Field | Observed result |
| --- | --- |
| Date and time | |
| macOS version | |
| Node.js version | |
| Codex version | |
| Skills CLI version/output | |
| Installed paths | |
| `/skills` shows both Motech skills | Pass / Fail |
| Broad review skill: correct source comparison | Pass / Fail |
| Focused detection skill: falsifiable hypothesis | Pass / Fail |
| Evidence labels used correctly | Pass / Fail |
| Any fabricated test/tool output | Yes / No |
| Foundry command and actual output | |
| Repository commit SHA | |
| Screenshots / transcript location | |

## 9. Pass criteria

The integration passes only when all of the following are evidenced:

1. Both skills are installed and discovered by the running Codex session.
2. Each skill can be explicitly invoked.
3. The broad skill gives a correct source-level comparison of the vulnerable and mitigated fixtures.
4. The focused detector constructs the correct reachable attack path and states its evidence level honestly.
5. Neither response fabricates test execution, tool output, line numbers, deployment facts, or security guarantees.
6. The Foundry result is recorded separately from the agent's analysis.

If installation/discovery succeeds but the output quality criteria fail, record the integration as partially passed and open a focused improvement issue. Do not claim cross-agent compatibility from this Codex test alone.
