<p align="center"><img src="motech-audit-logo.png" alt="Motech Audit official logo" width="220"></p>

# Motech Audit Security Skills

[![Latest release](https://img.shields.io/github/v/release/MotechAudit/motech-audit-security-skills)](https://github.com/MotechAudit/motech-audit-security-skills/releases/latest)
[![Foundry tests](https://github.com/MotechAudit/motech-audit-security-skills/actions/workflows/foundry-tests.yml/badge.svg)](https://github.com/MotechAudit/motech-audit-security-skills/actions/workflows/foundry-tests.yml)

Open-source agent skills for Ethereum smart contract security reviews, maintained by **Motech Audit**.

> Early-stage project. These skills assist security research and do not replace independent manual auditing. No Ethereum.org affiliation or endorsement is claimed.

## First skill: Solidity Security Review

Use the `skills/solidity-security-review/SKILL.md` workflow to review Solidity code, identify trust boundaries, enumerate privileged functions, investigate common vulnerability classes, and produce evidence-based findings. Every suspected issue must include a concrete code location, exploit preconditions, impact, and verification status.

## How to use

1. Open `skills/solidity-security-review/SKILL.md` in your AI coding assistant's project context.
2. Provide a Solidity repository or files that you are authorized to review.
3. Ask the assistant to follow the skill instructions and return findings in the specified format.
4. Independently reproduce suspected vulnerabilities using Foundry or other appropriate tools before treating them as confirmed.

For a complete first run, follow [Getting started](docs/getting-started.md), then work through the [access-control review example](docs/access-control-walkthrough.md). The guide documents explicit file loading and clearly states integration validation limits.

## Safety and limitations

- Never upload confidential customer code to an external model without permission.
- Do not claim a complete audit or guarantee that code is secure.
- Distinguish confirmed findings from hypotheses and informational observations.
- Do not fabricate tool output, line numbers, or exploit demonstrations.

## Reproducible security examples

This repository contains educational vulnerability/mitigation examples with Foundry regression tests:

| Topic | Vulnerable fixture | Mitigated fixture | Test |
| --- | --- | --- | --- |
| Reentrancy | [`VulnerableVault.sol`](src/VulnerableVault.sol) | [`SafeVault.sol`](src/SafeVault.sol) | [`Reentrancy.t.sol`](test/Reentrancy.t.sol) |
| Arbitrary delegatecall | [`VulnerableDelegatecallVault.sol`](src/VulnerableDelegatecallVault.sol) | [`SafeDelegatecallVault.sol`](src/SafeDelegatecallVault.sol) | [`Delegatecall.t.sol`](test/Delegatecall.t.sol) |
| Missing access control | [`VulnerableAccessVault.sol`](src/VulnerableAccessVault.sol) | [`SafeAccessVault.sol`](src/SafeAccessVault.sol) | [`AccessControl.t.sol`](test/AccessControl.t.sol) |

The reentrancy example demonstrates an external call before balance updates; the access-control example demonstrates an unrestricted privileged withdrawal; the delegatecall example demonstrates an unauthorized storage-slot overwrite. See [`docs/delegatecall-security.md`](docs/delegatecall-security.md) for details. **The vulnerable contract is for education only; never deploy it with real assets.**

Prerequisite: install [Foundry](https://book.getfoundry.sh/getting-started/installation).

```bash
git clone https://github.com/MotechAudit/motech-audit-security-skills.git
cd motech-audit-security-skills
forge test -vv
python3 scripts/validate_skills.py
```

The tests are also executed by [Foundry Security Examples](https://github.com/MotechAudit/motech-audit-security-skills/actions/workflows/foundry-tests.yml) in GitHub Actions. A passing fixture test validates these examples only; it does not prove unrelated contracts secure.

## Roadmap

- [x] Add reproducible Solidity fixtures and Foundry tests
- [x] Add CI validation for examples
- [ ] Document agent integrations and version compatibility
- [x] Publish initial v0.1.0 release and submit ethereum.org developer-tool suggestion ([issue #19684](https://github.com/ethereum/ethereum-org-website/issues/19684))

## Contributing

Issues and pull requests are welcome. Please avoid posting unpatched vulnerabilities in deployed third-party contracts; use responsible disclosure channels.

## License

MIT. See [LICENSE](LICENSE).
