# Input Validation: Maximum-Supply Enforcement

This case demonstrates a missing input-boundary check in a mint function. The protocol requirement for this fixture is explicit: total token supply must never exceed the configured `maxSupply`.

## Contracts

- [VulnerableCappedMint.sol](../src/VulnerableCappedMint.sol) — keeps an owner-only mint permission and rejects zero amounts, but does not enforce the configured supply cap.
- [FixedCappedMint.sol](../src/FixedCappedMint.sol) — preserves the same owner-only permission and zero-amount check, then rejects a mint that would exceed the cap.
- [InputValidation.t.sol](../test/InputValidation.t.sol) — reproduces the over-mint behavior and checks the mitigation and unchanged authorization boundary.

These are educational fixtures, not production token contracts. They omit ERC-20 balances, transfers, metadata, events, and other token functionality. Do not deploy them or use them to hold real assets.

## Vulnerable behavior

Both contracts are initialized with a positive `maxSupply`. Only the deployer (`owner`) may call `mint(uint256 amount)`, and both reject a zero amount.

The vulnerable fixture nevertheless accepts any positive amount from the owner. For example, with `maxSupply = 100`, two authorized calls of 60 and 50 increase `totalSupply` to 110. The access-control boundary is working; the missing check is the input/invariant validation for the declared cap.

## Mitigation

The fixed fixture checks:

```solidity
if (amount > maxSupply - totalSupply) revert SupplyCapExceeded();
```

The contract maintains `totalSupply <= maxSupply`, so subtracting the current supply from the cap gives the remaining mintable amount. This avoids relying on `totalSupply + amount` for the boundary check.

The owner check is unchanged in both fixtures. The case is intentionally scoped to a stated fixed-supply requirement; it is not a recommendation that every token should have a fixed cap or an owner-controlled mint function.

## Test coverage

The Foundry tests cover:

1. Owner minting below the cap in both fixtures.
2. Minting exactly up to the cap in the fixed fixture.
3. A single mint above the cap reverting.
4. Repeated mints being unable to exceed the cap.
5. The vulnerable fixture demonstrating over-minting.
6. Non-owner mint attempts remaining rejected in both fixtures.
7. Zero-amount mint attempts being rejected in both fixtures.

Run from the repository root:

```bash
forge test --match-path test/InputValidation.t.sol -vv
forge test -vv
```

## Scope and limitations

This example focuses on a minting input boundary and a single supply invariant. It does not model role rotation, pausing, ERC-20 transfer behavior, proxy initialization, supply changes through burns, rebasing, or tokenomics. A passing test validates only the scenarios encoded in the fixture; it is not a production security assessment.
