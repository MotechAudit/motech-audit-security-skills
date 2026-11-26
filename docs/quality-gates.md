# Skill Quality Gates

The repository's validation workflow checks the published Skill files for structural and reference-integrity problems. It is a documentation-quality gate, not a Solidity analyzer, agent benchmark, or security certification.

## Automated checks

Run locally:

```bash
python -m unittest discover -s tests -v
python scripts/validate_skills.py
```

The validator checks:

1. Required YAML frontmatter and valid `name`.
2. Matching Skill name and directory name.
3. Required `description` and its length limit.
4. Optional `compatibility` field length.
5. A Markdown title and the recommended 500-line ceiling.
6. Relative Markdown links in each published `SKILL.md` resolve to existing paths inside this repository.

External HTTP(S) links are intentionally not fetched. The workflow therefore does not establish that external sites are online, current, or authoritative. Anchor fragments are not checked against target headings.

## What passing means

A passing validation run means that the tested Skill metadata and local references satisfy these checks at the tested commit. It does not demonstrate:

- that an AI assistant loads or follows the Skill correctly;
- that a particular model or editor integration is compatible;
- that vulnerability findings are accurate or complete;
- that the Solidity examples are secure;
- that a target contract has been fully audited.

Use the [Getting Started guide](getting-started.md) and record the agent, version, loading method, Skill commit, target scope, actual commands, and observed results when reporting integration tests.

## Contributing

When changing a Skill, update its local links and tests in the same pull request. Add a regression test for any new validation behavior. Never mark a test as passed unless the corresponding CI run or local command actually completed successfully.
