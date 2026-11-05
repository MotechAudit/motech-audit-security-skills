# Getting started

This repository provides a review workflow for an AI coding assistant plus educational Solidity fixtures. Start with the public examples before reviewing your own authorized code.

## Prepare the repository

Install Git, Python 3, and [Foundry](https://book.getfoundry.sh/getting-started/installation), then run:

```bash
git clone https://github.com/MotechAudit/motech-audit-security-skills.git
cd motech-audit-security-skills
forge --version
python3 --version
forge test -vv
python3 scripts/validate_skills.py
```

The compiler configuration is in [foundry.toml](../foundry.toml) and pins Solidity 0.8.24. Foundry may need network access to obtain that compiler. Record your Foundry version and commit SHA when sharing results.

## Load the workflow explicitly

Open this repository in an AI coding assistant that can read project files. Ask it to read [the review skill](../skills/solidity-security-review/SKILL.md) and the scoped source files. Providing a path alone does not prove that the assistant loaded the file; ask it to summarize the scope before starting.

Copy this prompt:

```text
Read skills/solidity-security-review/SKILL.md and follow its workflow.
Review only src/VulnerableAccessVault.sol and src/SafeAccessVault.sol.
Inspect test/AccessControl.t.sol as supporting evidence.
These are public educational fixtures that I authorize you to assess.

First summarize the scope and trust boundaries. Then report findings using
the skill's finding format, with exact inspected locations, preconditions,
severity rationale, remediation, and verification status.

If terminal access is available, run:
forge test --match-contract AccessControlTest -vv
Record the actual command, tool version, commit SHA, and result.
If execution is unavailable or fails, say so and leave dynamic verification
unconfirmed. Do not invent output or treat expected assertions as executed evidence.
End with coverage gaps and assumptions.
```

Compare your result with the [access-control walkthrough](access-control-walkthrough.md). AI responses may vary; a matching narrative is not a substitute for running the tests.

## Assistant compatibility

| Usage path | Status |
| --- | --- |
| Explicitly reading the Markdown workflow and source files | Documented manual approach; requires a file-capable assistant |
| Automatic skill discovery or installation | Not validated by this guide |
| Specific Codex, Claude Code, or Cursor versions | No version-specific compatibility claim |
| Assistant terminal execution | Depends on the host's available tools and permissions |

This guide does not install a plugin or automatically register a skill. When reporting an integration, include the product/version, loading method, commit SHA, prompt, and observed result. Do not include credentials or private customer code.

## Review your own project

Replace the fixture scope with an authorized repository and specify its commit, dependencies, excluded files, intended roles, and expected behavior. Give the assistant access to the workflow file as well as the target files. Obtain permission before sending confidential code to an external model. Reproduce candidate findings independently; this workflow does not replace a formal manual audit.
