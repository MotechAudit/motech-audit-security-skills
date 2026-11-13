# Running Foundry Tests

A beginner's guide to installing Foundry and running the educational tests in this repository. The tests reproduce the vulnerability examples so you can see each weakness (and its fix) in action.

## Install Foundry

Follow the official instructions at https://book.getfoundry.sh/getting-started/installation. The quickest way on Linux and macOS:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verify the install:

```bash
forge --version
```

You also need Git (to clone the repository) and Python 3 (to run the skill validator in `scripts/validate_skills.py`).

## Clone and run the tests

```bash
git clone https://github.com/MotechAudit/motech-audit-security-skills.git
cd motech-audit-security-skills
forge install
forge test -vv
```

`forge install` fetches the test dependencies (forge-std). `forge test -vv` runs every test and prints a line per test with its gas cost.

To run a single test file, use `--match-path`:

```bash
forge test --match-path test/Reentrancy.t.sol -vv
forge test --match-path test/AccessControl.t.sol -vv
forge test --match-path test/Delegatecall.t.sol -vv
```

To run a single test by name, use `--match-test`:

```bash
forge test --match-test testVulnerableVaultCanBeDrained -vvv
```

(`-vvv` adds execution traces, which is useful when a test fails and you want to see the call sequence.)

## What the tests demonstrate

All three test files follow the same pattern: a vulnerable contract is attacked in a test, and the fixed contract resists the same attack.

### Reentrancy — `test/Reentrancy.t.sol`

- `testVulnerableVaultCanBeDrained` — the attacker contract re-enters `withdraw()` from its `receive()` function before the vault clears the balance, draining the vault. Demonstrates the classic reentrancy bug: external call before state update.
- `testSafeVaultPreventsReentrantDrain` — the same attack against `SafeVault`, which clears the balance before sending ETH (checks-effects-interactions). The attacker gets back only its own deposit.

### Access control — `test/AccessControl.t.sol`

- `testUnauthorizedCallerCanDrainVulnerableVault` — anyone can call the privileged withdrawal on `VulnerableAccessVault` because it has no owner check.
- `testUnauthorizedCallerCannotDrainSafeVault` — the same call on `SafeAccessVault` reverts, because only the owner may withdraw.
- `testOwnerCanWithdrawSafeVault` — the owner can still withdraw normally, so the fix does not break legitimate use.

### Delegatecall — `test/Delegatecall.t.sol`

- `testArbitraryDelegatecallOverwritesOwner` — an attacker passes a malicious contract address to the vulnerable vault's delegatecall, and the delegatecall overwrites the vault's owner storage slot.
- `testSafeAlternativeHasNoArbitraryDelegatecall` — the fixed vault does not expose an arbitrary delegatecall, so the same attack cannot run.

## Validate the skills (optional)

After the Foundry tests, you can also validate the skill definitions:

```bash
python3 scripts/validate_skills.py
```

This checks that the skill files in `skills/` are well-formed. It is a separate check from the Foundry tests.

## What passing tests do (and do not) prove

Passing tests show that the educational examples behave as documented: the vulnerable contracts are exploitable in the demonstrated way, and the fixed contracts resist that specific attack. They do **not** guarantee that a smart contract is secure. A complete review also needs manual analysis of every external call, access control, and edge case — tests only cover the cases someone wrote.

## Troubleshooting

- **`forge: command not found`** — Foundry is not on your `PATH`. Re-run `foundryup`, then restart your terminal (or run `export PATH="$HOME/.foundry/bin:$PATH"`).
- **`Source "forge-std/Test.sol" not found`** — dependencies are missing. Run `forge install` from the repository root.
- **A test fails after you changed code** — read the failure output, then re-run that single test with `-vvv` to see the trace.
