# QUICK SEND

# DEVELOPMENT ARCHITECTURE DOCUMENT

Version: 1.0

Date: June 2026

Classification: Engineering & System Architecture

---

# 1. PURPOSE

This document defines the technical architecture, backend systems, frontend applications, database structure, treasury infrastructure, security controls, and deployment model for Quick Send.

Quick Send is a stablecoin-powered remittance platform allowing users to send USDT and deliver money through:

* Bank Transfers
* Mobile Wallets
* Cash Pickup
* Agent Networks
* Door Delivery

---

# 2. SYSTEM OVERVIEW

Quick Send consists of:

1. Mobile Application
2. Web Application
3. Backend API
4. Admin Control Tower
5. Treasury System
6. Settlement Engine
7. Compliance Engine
8. Notification Service
9. Partner Integration Layer

---

# 3. TECHNOLOGY STACK

## Frontend

Mobile:

* React Native
* TypeScript

Web:

* React
* Vite
* TypeScript

Admin Panel:

* React

---

## Backend

* Node.js
* Express.js

Architecture:

* Modular Monolith (Phase 1)
* Microservices (Phase 3)

---

## Database

Primary:

* MySQL 8

Cache:

* Redis

---

## Messaging

* RabbitMQ

Used for:

* Notifications
* Settlement jobs
* Compliance processing
* Payout execution

---

## File Storage

S3-Compatible Object Storage

Stores:

* KYC documents
* Compliance files
* Audit exports

---

# 4. SYSTEM MODULES

## Authentication Service

Responsibilities:

* Registration
* Login
* Password management
* MFA
* Session handling

---

## User Service

Responsibilities:

* Profile management
* User settings
* Beneficiaries
* Preferences

---

## Wallet Service

Responsibilities:

* USDT deposits
* USDT withdrawals
* Balance management
* Internal transfers

---

## Remittance Service

Responsibilities:

* Transfer creation
* Fee calculations
* FX conversions
* Transfer lifecycle

---

## Treasury Service

Responsibilities:

* Hot wallet monitoring
* Warm wallet balancing
* Cold storage management

---

## Compliance Service

Responsibilities:

* KYC
* AML
* Sanctions screening
* Risk scoring

---

## Notification Service

Channels:

* Email
* SMS
* Push notifications
* In-App notifications

---

# 5. HIGH LEVEL ARCHITECTURE

Client Apps

↓

API Gateway

↓

Application Layer

↓

Core Services

↓

Database

↓

External Partners

---

# 6. DATABASE DESIGN

## Users

users

* id
* email
* phone
* password_hash
* status
* created_at

---

## Profiles

profiles

* id
* user_id
* first_name
* last_name
* country
* date_of_birth

---

## Wallets

wallets

* id
* user_id
* currency
* balance
* status

---

## Wallet Addresses

wallet_addresses

* id
* user_id
* network
* address

---

## Beneficiaries

beneficiaries

* id
* user_id
* country
* payout_method
* full_name
* details

---

## Transfers

transfers

* id
* user_id
* beneficiary_id
* amount_usdt
* fee
* exchange_rate
* destination_amount
* status

---

## Ledger

ledger_entries

* id
* wallet_id
* debit
* credit
* balance_after
* transaction_reference

---

## KYC

kyc_documents

* id
* user_id
* document_type
* file_url
* status

---

## Audit Logs

audit_logs

* id
* actor_id
* action
* entity
* entity_id
* timestamp

---

# 7. WALLET ARCHITECTURE

Every user receives:

Primary Asset:

USDT

Supported Networks:

* TRON
* Ethereum
* Polygon
* Solana

Each network generates:

Unique deposit address.

Withdrawals require:

* MFA
* Risk verification
* AML checks

---

# 8. TREASURY ARCHITECTURE

## Hot Wallet

Purpose:

Operational liquidity.

Stores:

5–10% of reserves.

---

## Warm Wallet

Purpose:

Operational reserve.

Stores:

20–30% of reserves.

---

## Cold Wallet

Purpose:

Long-term custody.

Stores:

60–80% of reserves.

---

# 9. TRANSFER ENGINE

Transfer lifecycle:

Draft

↓

Quote Generated

↓

Transfer Created

↓

Compliance Review

↓

Treasury Settlement

↓

Partner Processing

↓

Delivered

↓

Completed

---

# 10. PAYOUT ENGINE

## Bank Transfers

Partner API receives:

* Name
* Account
* Amount

Returns:

* Tracking ID
* Status

---

## Mobile Wallet

Partner API receives:

* Mobile number
* Operator
* Amount

---

## Cash Pickup

Generates:

* Pickup code
* Recipient verification token

---

## Door Delivery

Generates:

* Delivery order
* Courier assignment

---

# 11. COMPLIANCE ENGINE

## KYC Levels

Tier 1

* Name
* Phone
* Email

Tier 2

* Government ID

Tier 3

* Address Verification
* Enhanced Due Diligence

---

## AML Monitoring

Checks:

* Transaction size
* Frequency
* Country risk
* Sanctions lists

---

# 12. RISK ENGINE

Risk scoring based on:

* Device fingerprint
* Geolocation
* Transaction velocity
* Wallet history
* Compliance profile

Risk score:

0-100

---

# 13. API ARCHITECTURE

Base URL

/api/v1

---

Authentication

POST /auth/register

POST /auth/login

POST /auth/logout

POST /auth/refresh

---

Wallet

GET /wallet

GET /wallet/addresses

POST /wallet/withdraw

POST /wallet/internal-transfer

---

Beneficiaries

GET /beneficiaries

POST /beneficiaries

PUT /beneficiaries/:id

DELETE /beneficiaries/:id

---

Transfers

POST /transfers/quote

POST /transfers

GET /transfers

GET /transfers/:id

POST /transfers/:id/cancel

---

KYC

POST /kyc/upload

GET /kyc/status

---

# 14. ADMIN CONTROL TOWER

Modules:

## Dashboard

Platform KPIs.

---

## Users

User management.

---

## KYC Review

Approve/reject verification.

---

## Transfers

Track all transfers.

---

## Treasury

Wallet monitoring.

---

## Partners

Partner management.

---

## Risk

Fraud investigations.

---

## Audit

System audit logs.

---

# 15. SECURITY

Authentication:

* JWT
* Refresh Tokens

Access Control:

* RBAC

Encryption:

* AES-256
* TLS 1.3

Additional Controls:

* MFA
* Device fingerprinting
* IP monitoring

---

# 16. INFRASTRUCTURE

Production Environment

Frontend:

* Vercel or VPS

Backend:

* Linux VPS Cluster

Database:

* Managed MySQL

Cache:

* Redis

Queue:

* RabbitMQ

Storage:

* Object Storage

Monitoring:

* Grafana
* Prometheus

---

# 17. DEVELOPMENT PHASES

## Sprint 1

Foundation

* Authentication
* User profiles
* Database setup

---

## Sprint 2

USDT Wallet

* Deposit addresses
* Balance management
* Internal ledger

---

## Sprint 3

Beneficiary Management

* Beneficiaries
* Country engine

---

## Sprint 4

Transfer Engine

* Quotes
* Transfers
* Fee calculation

---

## Sprint 5

Payout Engine

* Bank transfers
* Mobile wallet payouts

---

## Sprint 6

Compliance

* KYC
* AML
* Risk engine

---

## Sprint 7

Admin Control Tower

* Operations dashboard
* Treasury dashboard

---

## Sprint 8

Notifications

* SMS
* Email
* Push notifications

---

## Sprint 9

Partner APIs

* Settlement integrations
* Cash pickup integrations

---

## Sprint 10

Production Launch

* Security audit
* Load testing
* Monitoring
* Disaster recovery

---

# 18. LONG-TERM ROADMAP

Phase 2

* Business accounts
* Payroll payouts
* Merchant payouts

Phase 3

* Public API platform
* White-label remittance infrastructure

Phase 4

* Global payout network
* Direct country corridors
* Real-time settlement rails

---

END OF DOCUMENT
