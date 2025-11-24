# Smart Account Modules

Workspace for reusable account-abstraction adapters, paymasters, and helper libraries that any protocol can consume.

## Goals

1. Provide EntryPoint-compatible Solidity modules that forward signed actions while preserving existing EOA semantics.
2. Offer TypeScript utilities (UserOperation builders, crypto helpers) that multiple projects can share.
3. Keep the architecture extensible so new payment/messaging protocols can plug in with minimal effort.

## Structure

```
smart-accounts/
├─ contracts/
│  ├─ modules/SmartAccountModule.sol   # EIP-712 module
│  └─ paymaster/Paymaster.sol          # baseline ERC-4337 paymaster
├─ tasks/aa.ts                         # sample UserOp builder task
├─ src/aa/userOpBuilder.ts             # TypeScript helpers for UserOps
├─ hardhat.config.ts
├─ tsconfig.json
└─ package.json
```

### SmartAccountModule.sol
- Minimal smart-account module that expects to be called from an EntryPoint-compatible account.
- Verifies EIP-712 signatures for message or payment calls, then forwards them to arbitrary targets.
- Maintains per-account nonces to prevent replay attacks in AA flows.

### Paymaster.sol
- Skeleton paymaster that deposits/withdraws to EntryPoint and enforces an allowlist of smart accounts.
- Acts as a reference for implementing shared funding policies (gas sponsorship, KYC gating, rate limits, etc.).

### TypeScript helpers (`src/aa/userOpBuilder.ts`)
- Utility to build and encode `UserOperation` structs plus helper for `paymasterAndData`.
- Any protocol can import this to keep UserOp construction consistent across repos.

### Next Steps

1. Implement EntryPoint account template (e.g., SimpleAccount fork or Safe module) that integrates this module.
2. Flesh out Paymaster policies (limits, metadata checks) and add comprehensive tests.
3. Extend `tasks/aa.ts` with real bundler submissions & gas estimations.
4. Publish this workspace as an npm package so multiple projects can depend on it directly.

## Development

```
npm install
npx hardhat compile
```

Additional scripts/tests will be added as modules mature.

