# Install Motech Audit Security Skills

This repository publishes reusable Agent Skills in the portable `SKILL.md` directory format. The Agent Skills specification requires a skill directory with a `SKILL.md` file and YAML frontmatter containing `name` and `description`. The `name` must match the directory name.

## Install with the skills CLI

The skills CLI can install one skill from a GitHub repository:

```bash
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-security-review
```

To install specifically for Codex in the current project:

```bash
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-security-review -a codex -y
```

To install globally for Codex:

```bash
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-security-review -g -a codex -y
```

The CLI can configure agent-specific directories. Review the repository and skill instructions before installing, inspect the CLI output, and check which files or links were created.

## Manual installation

If you do not use the CLI, copy the entire `skills/solidity-security-review` directory into the skill directory supported by your agent. Follow that agent's current documentation for the exact location and whether it needs a restart or reload.

## How to use

1. Open an authorized Solidity project in your coding assistant.
2. Confirm the assistant has loaded `solidity-security-review/SKILL.md`.
3. Specify the exact source files, commit SHA, dependencies, and intended review scope.
4. Require findings to separate observed evidence from hypotheses and to state whether tests or static analysis actually ran.
5. Reproduce material findings independently before relying on them.

A sample first-run prompt and a worked access-control case are in [Getting started](getting-started.md) and [Access-control review walkthrough](access-control-walkthrough.md).

## Compatibility statement

The skill follows the portable Agent Skills folder and Markdown format. The CLI documents agent-specific installation targets, including Codex. This repository does not claim that every assistant version has been tested or that all agents expose identical discovery, tool-use, or execution behavior. When documenting an integration, include the product, version, installation method, skill commit SHA, and observed result.

## Security and privacy

Only provide source code you are authorized to review. Do not send confidential customer code to an external model without permission. This skill provides review assistance and does not replace a complete independent audit.
