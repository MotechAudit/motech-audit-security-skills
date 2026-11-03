# Example: using the Solidity Security Review skill

In an AI coding assistant that accepts project instructions, load `skills/solidity-security-review/SKILL.md` and ask:

> Review the Solidity contracts in this authorized local repository. Follow the Motech Audit Solidity Security Review workflow. First enumerate roles and fund flows, then investigate concrete vulnerabilities. Return evidence-based findings using the skill's output format. Label hypotheses as unverified. Do not invent tool results.

**Important:** This is a prompt-based skill, not an autonomous scanner. The assistant needs access to the actual code and, for validation, a separately configured Solidity test environment.
