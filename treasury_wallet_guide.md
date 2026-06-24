# Treasury Wallets
Programmable wallets for managing your Quicksend stablecoin treasury

## What Makes a Wallet a "Treasury Wallet"?
A Treasury Wallet is any Crossmint wallet created with owner: "COMPANY". This single parameter changes how the wallet behaves:

Dimension       Treasury Wallet (owner: "COMPANY")
Visibility      Appears under the Users tab in the Console
Intended operator       Your finance/ops team or backend systems
Typical signer   Server signer or Cloud KMS
Custody model    Custodial — your organization holds all keys
Common extensions        On/off-ramp, regulated transfers, internal transfers

## Key Capabilities

### Programmable Controls
Treasury Wallets support the same signer architecture as all Crossmint wallets. For treasury use cases, this means you can:
Set role-based access by assigning different server signers to different backend services.
Enforce multi-signature requirements by configuring multiple signers that must co-approve high-value transactions.
Automate workflows by combining server signers with your backend logic for scheduled payments, rebalancing, or threshold-based actions.

### Security and Compliance
Smart contract wallets: Each treasury wallet is backed by its own smart contract, providing enhanced security and programmability compared to traditional MPC or TEE-based custody.
SOC-2 compliance: Independently audited security controls and processes.
Audit trails: Immutable logs of all treasury operations for compliance and auditing.
Transaction monitoring: Real-time monitoring via dashboards, APIs, and webhooks.

### Liquidity Management
Treasury Wallets integrate with Crossmint's on-ramp and off-ramp infrastructure:
Fund via bank transfer: Convert fiat to stablecoins using Crossmint's onramp.
Fund via crypto: Send assets directly to the treasury wallet address.
Withdraw to bank: Convert stablecoins back to fiat via Crossmint's offramp.

## Common Use Cases
### Corporate Treasury Management
### Payment Operations
### Liquidity Management
    Optimize treasury operations by managing liquidity across chains and protocols.
    Cross-chain rebalancing: Move funds between chains based on preset rules or triggers.
    Liquidity aggregation: Consolidate funds from multiple sources into your treasury.
    Automated conversion: Set rules to maintain target balances across different stablecoins.
    Gas optimization: Crossmint's gas sponsorship handles transaction fees.

## Wallet Creation & Funding (QuickSend Setup)

### Created Wallets (12 Total)
4 chains x 3 tiers: HOT, WARM, COLD

| Network | Chain ID | HOT | WARM | COLD |
|---------|----------|-----|------|------|
| BASE | base-sepolia | `0x68C2DC7147B87d49b2cf683b9dD63F3F97e461b8` | `0xea7a7B9C85965c4ce7CeB3B4e2b978F0F2EAB195` | `0xFE7Be3090Da132C32367555365E5b80B71ac3C00` |
| ETHEREUM | ethereum-sepolia | `0x0ec5aD4038FA8233a45Bd90574725aBe464E0dDd` | `0xB6344a9bD24c9F9299DF038086944c063a007a2A` | `0x1Ec833d9AE8b44d9d4B10baf201A607024032eF3` |
| SOLANA | solana | `8G8sdgViXMJa42FLRQSuta7qqa5Semk2fAEggYDZBbeN` | `CjkH41rHXbbrTJb3bMKVMu5ELG7TuHtu4E11HnHYNnxg` | `GVQ41fgiLeWsXBcQ1myEZKcQJUngZzrBcUYXLiqpkC9T` |
| POLYGON | polygon-amoy | `0xe6fb5d72925aBb5550e1d5c038e6a8dB9D195bcc` | `0xee2Ad0F05B8A9C6B8e362505727BF9a6B04BbCA9` | `0x70bdD4d570f5A988E255A23e26Aba8C2A534C8d9` |

### Creation (SDK v1.6.0)
```typescript
import { createCrossmint, CrossmintWallets } from "@crossmint/wallets-sdk";

const crossmint = createCrossmint({ apiKey: "<server-api-key>" });
const walletsSdk = CrossmintWallets.from(crossmint);

const wallet = await walletsSdk.createWallet({
  chain: "base-sepolia",
  recovery: { type: "server", secret: "<recovery-secret>" },
});
```

Note: `owner` and `alias` require enterprise Treasury Wallets feature (contact Crossmint support). `signers` array omitted (causes collision when recovery/signer secrets match).

### Funding (Staging Only)
Max **100 units/call**, only **USDXM** token. 1000 USDXM = 10 sequential calls:

```typescript
const wallet = await cw.getWallet("<address>", { chain: "<chain>" });
for (let i = 0; i < 10; i++) {
  await wallet.apiClient.fundWallet("<address>", {
    amount: 100,
    token: "usdxm",
    chain: "<chain>",
  });
}
```

### Env Variables
```
CROSSMINT_API_KEY=sk_staging_...
WALLET_RECOVERY_SECRET=xmsk1_...
```

### Service Files
- **Creation**: `rail-backend/src/services/crossmint.service.ts` / `backend-app/src/services/crossmint.service.ts`
- **Bootstrap**: `rail-backend/src/modules/treasury/treasury-bootstrap.service.ts`
- **Model**: `TreasuryWallet` in Prisma schema (walletType, chain, network, address, status)
- **DB**: All 12 addresses stored with status `ACTIVE`

# secret code creation

Method 2: Using Openssl (Terminal)
If you prefer using your terminal directly:

Bash
openssl rand -hex 32
Where to Store It
Once generated, never hardcode this secret into your codebase. Treat it with the same level of security as a database password or private key.

Add it to your environment variables file (.env):
the exact match with the first on can be create like this: "xmsk1_" + (openssl rand -hex 32)
Code snippet
# .env
RECOVERY_SECRET=your_generated_64_character_hex_string_here
CROSSMINT_SERVER_API_KEY=sk_staging_...