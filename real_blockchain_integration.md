# QUICK SEND TREASURY ARCHITECTURE V4

## Core Principle

Quick Send is not a crypto wallet application.

Quick Send is a custodial remittance and treasury platform.

Customers own account balances recorded in the Quick Send Ledger.

Customers do not own blockchain wallets.

All blockchain wallets are owned and controlled by Quick Send.

The ledger is the source of truth.

Blockchain wallets are settlement infrastructure only.

---

# System Overview

Customer App

↓

API Gateway

↓

Ledger Service

↓

Treasury Service

↓

Crossmint Wallet Infrastructure

↓

Base / Ethereum / Polygon / Solana

---

# Customer Experience

Customer sees:

Available Balance

USDT Balance

Transaction History

Add Money

Send Money

Withdraw

The customer never sees:

Private Keys

Seed Phrases

Wallet Ownership

Treasury Wallets

Recovery Signers

Crossmint Infrastructure

---

# Deposit Architecture

## Step 1: User Chooses Deposit Network

Customer selects:

Base

Polygon

Ethereum

Solana

Example:

Deposit 100 USDT via Base

---

## Step 2: Create Deposit Request

Treasury Service creates:

Deposit Request

Status:

PENDING

---

## Step 3: Generate Temporary Deposit Wallet

Crossmint Wallet Factory creates a new wallet.

One wallet per deposit request.

Example:

Deposit #10001

Wallet:
0xABC...

Deposit #10002

Wallet:
0xDEF...

Deposit #10003

Wallet:
0xXYZ...

Each wallet exists only for a single deposit.

Database:

deposit_wallets

id

deposit_request_id

crossmint_wallet_id

wallet_locator

address

chain

status

created_at

expires_at

Status:

CREATED

FUNDED

CONFIRMED

SWEPT

ARCHIVED

---

## Step 4: Customer Sends Funds

Customer Wallet

↓

Temporary Deposit Wallet

Blockchain confirms transaction.

---

## Step 5: Deposit Detection

Crossmint webhook

↓

Kafka Event

deposit.detected.v1

---

## Step 6: Compliance Review

Checks:

AML

Sanctions

Wallet Risk

Velocity Rules

Fraud Rules

Decision:

APPROVED

REVIEW

BLOCKED

---

## Step 7: Deposit Fee Calculation

Example:

Deposit:
100 USDT

Deposit Fee:
1 USDT

Net Amount:
99 USDT

---

## Step 8: Treasury Sweep

Temporary Deposit Wallet

↓

Hot Treasury Wallet

Temporary wallet status:

ARCHIVED

The wallet is never reused.

---

## Step 9: Ledger Credit

Accounting Entry

Debit

Treasury Asset
+99

Credit

Customer Liability
+99

Customer balance becomes:

99 USDT

---

# Withdrawal Architecture

Customer withdrawals never use deposit wallets.

All withdrawals are funded from Quick Send treasury liquidity.

Customer

↓

Ledger Debit

↓

Hot Withdrawal Wallet

↓

Recipient Address

---

## Withdrawal Flow

Customer requests:

100 USDT

Withdrawal fee:

2 USDT

Net amount:

98 USDT

Accounting

Debit

Customer Liability
100

Credit

Treasury Asset
98

Credit

Fee Revenue
2

Blockchain Settlement

Hot Treasury Wallet

↓

Recipient Wallet

98 USDT

---

# Treasury Wallet Hierarchy

## Hot Treasury Wallet

Purpose:

Customer withdrawals

Remittance settlements

Partner prefunding

Target Liquidity:

1–3 days operating volume

---

## Warm Treasury Wallet

Purpose:

Operational reserve

Automatically refills Hot Treasury

Target Liquidity:

1–4 weeks operating volume

---

## Cold Treasury Wallet

Purpose:

Long-term reserves

Protected by:

Multi-signature controls

Hardware security modules

Offline approval workflow

Stores most treasury assets

---

# Hot Treasury Refill Engine

Runs every minute.

Rule:

If Hot Treasury < Minimum Threshold

Warm Treasury

↓

Hot Treasury

Automatic transfer

Example:

Hot Treasury Threshold:

100,000 USDT

Current Balance:

82,000 USDT

System automatically transfers:

50,000 USDT

Warm

↓

Hot

---

# Ledger Architecture

The ledger is the source of truth.

Blockchain balances are never used as customer balances.

All customer balances exist inside the ledger.

Every transaction uses double-entry accounting.

Rule:

Total Debits = Total Credits

At all times.

---

# Event Sourcing Architecture

All actions become immutable events.

Examples:

deposit.requested.v1

deposit.wallet.created.v1

deposit.detected.v1

deposit.confirmed.v1

deposit.swept.v1

ledger.credit.posted.v1

withdrawal.requested.v1

withdrawal.approved.v1

withdrawal.sent.v1

withdrawal.confirmed.v1

ledger.debit.posted.v1

Events are never deleted.

---

# Crossmint Responsibilities

Create temporary deposit wallets

Manage treasury wallets

Monitor balances

Execute blockchain transfers

Provide transaction references

Provide wallet infrastructure

---

# Quick Send Responsibilities

Customer balances

Ledger accounting

Compliance

AML

Fraud detection

Treasury management

Fee calculation

Reconciliation

Remittance operations

Partner integrations

---

# Final Architecture

Customer

↓

Quick Send Ledger

↓

Treasury Service

↓

Hot Treasury

↓

Warm Treasury

↓

Cold Treasury

↓

Crossmint Wallet Infrastructure

↓

Blockchain Networks

Base

Ethereum

Polygon

Solana

Quick Send users never own blockchain wallets.

Quick Send owns all wallets.

Customers own ledger balances only.

Temporary deposit wallets are created after the customer selects a network, used once, swept into treasury, archived, and never reused.


For Quick Send, I would implement Crossmint as a custody and treasury infrastructure provider, not as an end-user wallet provider.

The architecture becomes:

Customer → Quick Send Ledger → Quick Send Treasury → Crossmint Wallets → Blockchain

Never:

Customer → Crossmint Wallet

QUICK SEND + CROSSMINT IMPLEMENTATION
Crossmint Wallet Inventory

At system bootstrap create permanent treasury wallets:

HOT_TREASURY_WALLET

WARM_TREASURY_WALLET

COLD_TREASURY_WALLET

Example bootstrap service:

import {
  createCrossmint,
  CrossmintWallets
} from "@crossmint/wallets-sdk";

const crossmint = createCrossmint({
  apiKey: process.env.CROSSMINT_API_KEY!,
});

const wallets = CrossmintWallets.from(crossmint);

export async function createTreasuryWallet() {
  return wallets.createWallet({
    chain: "base",
    recovery: {
      type: "server",
      secret: process.env.TREASURY_RECOVERY_SECRET!,
    },
  });
}

Store in database:

treasury_wallets

id
wallet_type
crossmint_wallet_id
address
chain
status
Deposit Request Flow

Customer:

Add Money

Selects:

USDT
Base

API:

POST /deposits

Payload:

{
  "userId": "usr_123",
  "chain": "base",
  "token": "USDT"
}
Create Temporary Deposit Wallet

Treasury Service:

export async function createDepositWallet() {
  const wallet = await wallets.createWallet({
    chain: "base",
    recovery: {
      type: "server",
      secret: process.env.DEPOSIT_SIGNER_SECRET!,
    },
  });

  return wallet;
}

Database:

deposit_wallets

id
deposit_request_id
crossmint_wallet_id
address
chain
status
expires_at

Status:

CREATED
FUNDED
CONFIRMED
SWEPT
ARCHIVED
Return Address To User

Response:

{
  "depositId": "dep_001",
  "network": "base",
  "address": "0xABC..."
}

User sends funds.

Deposit Monitoring

Background worker:

const balances = await wallet.balances([
  "usdt"
]);

When balance detected:

deposit.detected.v1

published to Kafka.

AML Check

Consumer:

deposit.detected.v1

↓

Compliance Service

Decision:

APPROVED
BLOCKED
MANUAL_REVIEW
Sweep To Hot Treasury

After approval:

await depositWallet.send(
  HOT_TREASURY_ADDRESS,
  "usdt",
  amount
);

Event:

deposit.swept.v1
Deposit Fee

Example:

Received = 100

Fee = 1

Net = 99
Ledger Credit

Create transaction:

Debit Treasury Asset +99

Credit Customer Liability +99

Customer sees:

Balance
99 USDT
Archive Wallet

Update:

status='ARCHIVED'

Wallet is never reused.

Withdrawal Flow

Customer:

Withdraw 100 USDT
Ledger Reservation

Before blockchain transfer:

Available Balance
500

Withdrawal
100

Create hold:

Pending Withdrawal
100
Compliance

Check:

AML
Risk
Velocity
Country
Send From Hot Treasury

Load treasury wallet:

const hotWallet =
  await wallets.getWallet(
    HOT_TREASURY_LOCATOR,
    {
      chain: "evm"
    }
  );

Send:

const tx = await hotWallet.send(
  destinationAddress,
  "usdt",
  "98"
);

Example:

Withdrawal Amount
100

Fee
2

Net Transfer
98
Store Transaction
withdrawals

id
user_id
amount
fee
net_amount

tx_hash
explorer_link

status
Ledger Posting
Debit Customer Liability
100

Credit Treasury Asset
98

Credit Fee Revenue
2
Treasury Auto Refill

Monitor:

const balances =
  await hotWallet.balances([
    "usdt"
  ]);

Rule:

Hot Treasury < 100,000

Execute:

await warmWallet.send(
  HOT_WALLET_ADDRESS,
  "usdt",
  "50000"
);

Event:

treasury.refilled.v1
Recommended Crossmint Configuration
Base Network

Primary treasury chain:

base

Used for:

USDT custody
Treasury operations
Withdrawals
Separate Signer Secrets
CROSSMINT_API_KEY=

DEPOSIT_SIGNER_SECRET=

TREASURY_SIGNER_SECRET=

TREASURY_RECOVERY_SECRET=

Do not use a single signer secret for everything.

Final Quick Send Crossmint Model
Customer
     ↓
Quick Send Ledger
     ↓
Deposit Request
     ↓
Create Temporary Crossmint Wallet
     ↓
Receive Funds
     ↓
AML Check
     ↓
Sweep To Hot Treasury
     ↓
Credit User Balance

--------------------------------

Customer Withdrawal
     ↓
Ledger Debit
     ↓
Hot Treasury Wallet
     ↓
Blockchain Transfer
     ↓
Settlement Complete

This implementation uses Crossmint exactly as a treasury and wallet infrastructure layer while keeping customer funds, balances, fees, compliance, and accounting fully controlled by Quick Send's ledger and event-sourcing architecture.
