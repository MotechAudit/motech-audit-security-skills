# Arbitrary delegatecall and storage collisions

**Educational fixture only — do not deploy vulnerable contracts.**

## Vulnerability

`VulnerableDelegatecallVault.execute(target, data)` accepts an arbitrary target and calldata from any caller. EVM `delegatecall` runs the target's code using the *calling contract's* storage, address, and balance context. The attack contract writes its own slot 0, which is actually the vault's `owner` slot 0. The caller can therefore overwrite ownership without being authorized.

## Reproduce

```bash
forge test --match-contract DelegatecallTest -vv
```

- `testArbitraryDelegatecallOverwritesOwner`: demonstrates the unauthorized owner change and verifies the target contract's storage remains unchanged.
- `testSafeAlternativeHasNoArbitraryDelegatecall`: verifies the example's direct, stateless operation and rejects the arbitrary `execute(address,bytes)` interface.

## Mitigation and limitations

Avoid exposing arbitrary `delegatecall` targets and calldata. Where delegatecall is required (e.g., proxy patterns), enforce strict upgrade authorization, implementation trust, and storage-layout compatibility, and use established, reviewed patterns. The safe fixture intentionally **does not** implement a proxy; it demonstrates removing unnecessary delegatecall. These tests do not constitute a complete security audit.
