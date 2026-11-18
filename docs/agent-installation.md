# Install Motech Audit Security Skills

This repository publishes reusable Agent Skills in the portable `SKILL.md` directory format. The Agent Skills specification requires a skill directory with a `SKILL.md` file and YAML frontmatter containing `name` and `description`. The `name` must match the directory name.

## Install with the skills CLI

The skills CLI requires Node.js 22.20 or later. Install each Motech skill with its own command:

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

## Install the focused vulnerability detector

Project-local installation:

```bash
npx skills add MotechAudit/motech-audit-security-skills --skill solidity-vulnerability-detection -a codex -y
```

After both commands finish, verify that the two `SKILL.md` files exist under the destination reported by the CLI. With project-local Codex installation, Codex scans `.agents/skills` from the working directory up to the repository root. User-level skills are scanned from `~/.agents/skills`.

Use the broad review workflow for an end-to-end assessment and the focused detector when investigating concrete vulnerability hypotheses. They are complementary workflows, not independent audit certifications.

## Codex-specific installation

Codex can load repository skills from `.agents/skills` and user skills from `~/.agents/skills`. For a repeatable project-local setup, run the skills CLI from the root of your test project:

```bash
npx skills add MotechAudit/motech-audit-security-skills \
  --skill solidity-security-review \
  --skill solidity-vulnerability-detection \
  -a codex -y
```

Alternatively, use Codex's built-in `$skill-installer` and ask it to install each public skill directory:

- `https://github.com/MotechAudit/motech-audit-security-skills/tree/main/skills/solidity-security-review`
- `https://github.com/MotechAudit/motech-audit-security-skills/tree/main/skills/solidity-vulnerability-detection`

After installation, open Codex's `/skills` selector and confirm both skill names are visible. If they are missing, verify the actual destination path and restart Codex.

See [Codex real-agent integration test](codex-integration-test.md) for the three acceptance scenarios, expected analysis signals, and an evidence log. Repository CI validates skill metadata; it does not prove successful installation or behavior in a particular Codex version.

## Manual installation

If you do not use the CLI, copy the entire `skills/solidity-security-review` and/or `skills/solidity-vulnerability-detection` directory into the skill directory supported by your agent. Follow that agent's current documentation for the exact location and whether it needs a restart or reload.

## How to use

1. Open an authorized Solidity project in your coding assistant.
2. Confirm the assistant has loaded the intended skill: `solidity-security-review/SKILL.md` for a broad audit workflow and/or `solidity-vulnerability-detection/SKILL.md` for a focused vulnerability hunt.
3. Specify the exact source files, commit SHA, dependencies, and intended review scope.
4. Require findings to separate observed evidence from hypotheses and to state whether tests or static analysis actually ran.
5. Reproduce material findings independently before relying on them.

A sample first-run prompt and a worked access-control case are in [Getting started](getting-started.md) and [Access-control review walkthrough](access-control-walkthrough.md).

## Compatibility statement

Both skills follow the portable Agent Skills folder and Markdown format. The CLI documents agent-specific installation targets, including Codex. This repository does not claim that every assistant version has been tested or that all agents expose identical discovery, tool-use, or execution behavior. When documenting an integration, include the product, version, installation method, skill commit SHA, and observed result.

## Security and privacy

Only provide source code you are authorized to review. Do not send confidential customer code to an external model without permission. These skills provide review assistance and do not replace a complete independent audit.
