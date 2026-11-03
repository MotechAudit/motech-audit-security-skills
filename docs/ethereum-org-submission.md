# Ethereum.org Developer Tool Submission — Draft

**Status:** Submission prepared. The Foundry and skill-validation workflows have passed; acceptance remains at ethereum.org maintainers' discretion.

Official guidance: https://ethereum.org/contributing/adding-developer-tools/
Suggested developer tool form: https://github.com/ethereum/ethereum-org-website/issues/new?template=suggest_dev_tool.yaml

## Proposed listing
- **Name:** Motech Audit Security Skills
- **URL:** https://github.com/MotechAudit/motech-audit-security-skills
- **Category:** Agent Skills (subject to ethereum.org taxonomy and review)
- **Maintainer:** Motech Audit
- **Description:** Open-source agent instructions and reproducible Solidity security examples that help Ethereum developers investigate common smart contract vulnerabilities, document evidence-based findings, and test mitigations with Foundry.

## Differentiation
Combines a structured security-review skill with paired vulnerable and mitigated Solidity examples and Foundry tests. Findings must distinguish confirmed evidence from unverified hypotheses.

## Documentation
- README.md
- skills/solidity-security-review/SKILL.md
- examples/review-request.md
- src/ and test/ Foundry demonstration

## Before submitting
- [x] Confirm Foundry CI passed for the security example commit: https://github.com/MotechAudit/motech-audit-security-skills/actions/runs/41702167685
- [x] README includes Foundry installation and test commands
- [x] Verify public repository, license, usage limitations and logo are present
- [ ] Provide evidence of actual use and any external feedback, without fabricating adoption
- [ ] Confirm proposed category and contribution instructions are current

Listing is at ethereum.org maintainers' discretion; it is not an endorsement or audit certification.
