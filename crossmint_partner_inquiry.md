# Crossmint Partnership Inquiry — QuickSend

**Company:** QuickSend  
**Website:** [quicksend.co]  
**Contact:** [Your Name / Email / Phone]

---

## About QuickSend

QuickSend is a cross-border remittance and money transfer platform designed to provide fast, low-cost international payments. Our mission is to make global value transfer as seamless as sending a text message — bypassing the slow, expensive legacy correspondent banking system.

## Our Model

- **Settlement Rail:** Stablecoins (USDT) — we use USDT as the primary settlement layer between corridors.
- **User Experience:** Web2-complete — our end-users never touch wallets, seed phrases, or gas fees. All crypto complexity is abstracted behind our backend.
- **Corridors:** Focused on high-volume remittance lanes where traditional wire fees and settlement delays are most acute.

## Why Crossmint

We are building a production-grade stablecoin orchestration layer and are evaluating Crossmint as the infrastructure backbone for:

1. **Stablecoin Payouts** — On-chain USDT disbursements to recipients across multiple blockchains (e.g., Polygon, Solana, BSC) with low fees and high speed.
2. **Wallet Abstraction** — Delegated wallet creation, gas sponsorship, and transaction signing so our users never need to manage crypto primitives.
3. **Compliance & Screening** — Built-in sanction screening, AML checks, and on-chain analytics to keep us compliant across jurisdictions.

## What We're Looking For

We would love to connect with your sales and engineering teams to discuss:

- API capabilities and rate limits for high-volume payout flows
- Volume-based pricing (we expect meaningful transaction volumes from day one)
- Supported blockchains for USDT payouts and associated fees
- Gas station / sponsored transaction mechanics
- Compliance tooling (KYB/KYC integration, wallet screening)
- SLAs and uptime guarantees for production use
- Integration timeline and technical onboarding process

## Immediate Request: Treasury Wallet Activation (Staging)

We have already integrated Crossmint's Wallets SDK and created 12 treasury wallets (4 chains × 3 tiers: HOT, WARM, COLD) using `owner: "COMPANY"` with our staging API key. Per your documentation, the `owner` and `alias` parameters require the **enterprise Treasury Wallets feature** to be enabled on our project.

**Please activate the Treasury Wallets feature for our staging project:**

| Detail | Value |
|--------|-------|
| Project | QuickSend Staging |
| API Key | `sk_staging_5Mxy2wnP5eYYhAnrWQBtHuqPkhQeQU4PMdSpdPDZgcq2nrzkwthw9rjUX8eRynT1fD9zgyXk67HbGy7j4tWPZtKGr9nm9cF7iroHh6aF2viLbL8jpi2isgZaAcUN7nyGhspx8T6oDe7aGhEZo94zFBEs1e7YJ1hNKdepv1ZLzL23erepDQ5m868RDVnGE9kQ1M5GuXfe2r3uXNcDhgFJhuh5` |
| Wallets Created | 12 (BASE, ETHEREUM, SOLANA, POLYGON × HOT/WARM/COLD) |
| SDK | `@crossmint/wallets-sdk` |
| Target Chains | base-sepolia, ethereum-sepolia, solana, polygon-amoy |

Once enabled, we will proceed with funding and testing the wallet hierarchy (HOT → WARM → COLD rebalancing, internal transfers, and offramp flows).

## Next Step

A 30-minute call to walk through our architecture, review Crossmint's API docs together, and identify the fastest path to integration.

Looking forward to hearing from you.

---

**QuickSend Engineering Team**  
[your-email@quicksend.co]
