# Implement Sprint 11 — Local Agent System

This plan outlines the implementation of Sprint 11 for the QuickSend ecosystem. Sprint 11 delivers the **Local Agent System** — a two-tier agent network (Partner External + Internal) with independent treasury wallets, commission tracking, balance top-ups, KPI scoring, and full admin management UI.

## User Review Required

> [!IMPORTANT]
> **Two Agent Types**
> - **Partner (External)** — has its own `BASE_TREASURY` wallet (own USDT) and a `COMMISSION` wallet. Adds user balance by spending from its own treasury. No reconciliation — topped up by Internal agents. Receives commission on add-balance, withdraw, and payment operations.
> - **Internal Agent** — has only a `COMMISSION` wallet. Adds user balance by spending from the **system HOT treasury** (QuickSend's own funds). Reconciliation is handled via QuickSend local bank deposits. Receives commission from QuickSend on user operations.

> [!WARNING]
> **Treasury Wallet Addresses**
> Agent wallets are currently created as local ledger records with placeholder addresses (`agent_base_treasury_<id>`). In production, these should be replaced with real Crossmint blockchain wallet creation via `crossmintService.createWallet()`.

---

## Proposed Changes

### 1. Database Schema — Agent Models

#### [MODIFY] [schema.prisma](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/prisma/schema.prisma) & [rail-backend schema.prisma](file:///C:/Anderson/Quick.Money/QuickSend/rail-backend/prisma/schema.prisma)
- Added **Agent** model — core agent entity with `type` (PARTNER | INTERNAL), `status`, `kpiRating`, `totalRewards`, timestamps
- Added **AgentWallet** model — per-agent wallets: `BASE_TREASURY` (partner only, pre-funded USDT) and `COMMISSION` (both types, earned fees)
- Added **AgentTransaction** model — ledger for all agent operations: `ADD_BALANCE`, `WITHDRAW`, `PAYMENT`, `COMMISSION`, `TOPUP`
- Added **AgentKpi** model — DAILY / WEEKLY / MONTHLY rollup of volume, commission, tx count, reward points, rating score

### 2. Backend Agent Module

#### [NEW] [agent.service.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/agent/agent.service.ts)
- **`addUserBalance(agentId, userId, fiatAmount, usdtAmount, commissionPercent)`**
  - Partner: deducts `usdtAmount` from own `BASE_TREASURY`, credits `commission` to own `COMMISSION`, credits `netUsdt` to user's wallet ledger
  - Internal: deducts from system `HOT` treasury wallet, credits `commission` to own `COMMISSION`, credits `netUsdt` to user's wallet ledger
  - Auto-records KPI entry
- **`executeWithdrawal(agentId, userId, amount, destAddress, commissionPercent)`**
  - Debits user's wallet ledger, credits `commission` to agent's `COMMISSION` wallet
- **`processGlobalPayment(agentId, userId, amount, paymentMethod, commissionPercent)`**
  - Debits user's wallet ledger, credits full `commission` to agent's `COMMISSION` wallet
- **`topUpPartnerBalance(internalAgentId, partnerAgentId, usdtAmount)`**
  - Only Internal agents can call this. Deducts from system `HOT` treasury, credits partner's `BASE_TREASURY`
- **`getAgentDashboard(agentId)`** — full agent overview with wallet balances, today's stats, recent transactions
- **`getAgentKpi(agentId, period?)`** — fetches KPI rollups filtered by period type
- **`recordKpi(agentId, volume, commission)`** — upserts DAILY / WEEKLY / MONTHLY KPI entries; reward points = `floor(volume * 0.01 + commission * 0.1)`

#### [NEW] [agent-auth.routes.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/agent/agent-auth.routes.ts)
- `POST /api/v1/agent/auth/login` — agent login with email/password, returns JWT with role `AGENT_PARTNER` or `AGENT_INTERNAL`, includes wallet info
- `GET /api/v1/agent/auth/me` — authenticated agent profile with wallet balances

#### [NEW] [agent.routes.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/agent/agent.routes.ts)
- `POST /api/v1/agent/create` — [SUPER_ADMIN, OPS] creates agent with type, auto-provisions wallets (2 for PARTNER, 1 for INTERNAL)
- `GET /api/v1/agent/list` — [SUPER_ADMIN, OPS, TREASURY] lists all agents with wallet balances and tx counts
- `GET /api/v1/agent/:id` — [SUPER_ADMIN, OPS, TREASURY] agent dashboard detail
- `POST /api/v1/agent/:id/toggle-status` — [SUPER_ADMIN] activate/suspend agent
- `POST /api/v1/agent/:id/add-balance` — [AGENT_PARTNER, AGENT_INTERNAL] add user balance with commission
- `POST /api/v1/agent/:id/withdraw` — [AGENT_PARTNER, AGENT_INTERNAL] execute user withdrawal with commission
- `POST /api/v1/agent/:id/process-payment` — [AGENT_PARTNER, AGENT_INTERNAL] process global payment with commission
- `POST /api/v1/agent/topup-partner` — [AGENT_INTERNAL] top up partner's base treasury
- `GET /api/v1/agent/:id/kpi` — [authenticated] get agent KPI rollups
- `GET /api/v1/agent/:id/transactions` — [authenticated] get agent transaction history

### 3. Route Registration

#### [MODIFY] [app.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/app.ts)
- Registered `agentRoutes` at `/api/v1/agent`
- Registered `agentAuthRoutes` at `/api/v1/agent/auth`

#### [MODIFY] [database.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/config/database.ts)
- Added `agent`, `agentWallet`, `agentTransaction`, `agentKpi` to `ExtendedPrismaClient` interface

### 4. Admin Frontend — Agent Management

#### [MODIFY] [admin.types.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.types.ts)
- Added `AGENT_PARTNER` and `AGENT_INTERNAL` to `AdminRole` union
- Added types: `Agent`, `AgentDetail`, `AgentTransactionItem`, `AgentWalletInfo`, `AgentKpiItem`

#### [MODIFY] [roles.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/roles.ts)
- Added `/agents` page accessible to `SUPER_ADMIN`, `OPS`, `TREASURY`

#### [MODIFY] [admin.api.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.api.ts)
- Added methods: `getAgents()`, `createAgent()`, `getAgentDetail()`, `toggleAgentStatus()`, `getAgentKpi()`
- Mock data for all agent endpoints

#### [MODIFY] [admin.store.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.store.ts)
- Added state: `agents`, `agentDetail`, `agentKpi`
- Added actions: `fetchAgents`, `createAgent`, `fetchAgentDetail`, `toggleAgentStatus`, `fetchAgentKpi`

#### [MODIFY] [AdminLayout.tsx](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/pages/admin/AdminLayout.tsx)
- Added `UserCog` icon import
- Added `/agents` entry to `navIconMap` and `navLabelMap`

#### [MODIFY] [routes/index.tsx](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/routes/index.tsx)
- Imported `AdminAgents` component
- Added `/agents` route with role protection

#### [NEW] [Agents.tsx](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/pages/admin/Agents.tsx)
- **Agent List** — cards showing name, type badge (purple=PARTNER, green=INTERNAL), status badge, wallet balances, tx count, KPI rating
- **Create Agent Form** — togglable form with fields for full name, email, password, phone, type selector (Partner/Internal)
- **Agent Detail Panel** — expandable on click: 4-card KPI row (Base Treasury, Commission Wallet, Today Volume, Today Commission), per-period KPI table with DAILY/WEEKLY/MONTHLY toggle, recent transactions table with type badges, wallets section with addresses and balances
- **Toggle Status** — suspend/activate button per agent

### 5. Seed Data

#### [MODIFY] [seed.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/prisma/seed.ts)
- Added `partner@quicksend.com` (PARTNER, password: `partner123`, BASE_TREASURY: 100,000 USDT, COMMISSION: 5,000 USDT)
- Added `internal@quicksend.com` (INTERNAL, password: `internal123`, COMMISSION: 2,500 USDT)

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `backend-app/src/modules/agent/agent.service.ts` | Agent business logic (add balance, withdraw, payment, top-up, KPI) |
| `backend-app/src/modules/agent/agent-auth.routes.ts` | Agent authentication (login, profile) |
| `backend-app/src/modules/agent/agent.routes.ts` | Agent CRUD + operation endpoints |
| `admin-app/src/pages/admin/Agents.tsx` | Full agent management UI page |

### Modified Files
| File | Changes |
|------|---------|
| `backend-app/prisma/schema.prisma` | New Agent, AgentWallet, AgentTransaction, AgentKpi models |
| `rail-backend/prisma/schema.prisma` | Same model additions (mirrored) |
| `backend-app/src/app.ts` | Registered agent routes |
| `backend-app/src/config/database.ts` | Extended PrismaClient interface |
| `backend-app/prisma/seed.ts` | Added 2 agent seed accounts |
| `admin-app/src/features/admin/admin.types.ts` | Agent type definitions |
| `admin-app/src/features/admin/roles.ts` | `/agents` page permission |
| `admin-app/src/features/admin/admin.api.ts` | Agent API methods + mocks |
| `admin-app/src/features/admin/admin.store.ts` | Agent state management |
| `admin-app/src/pages/admin/AdminLayout.tsx` | Agents nav link + icon |
| `admin-app/src/routes/index.tsx` | `/agents` route |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (Backend) — **PASSED**
- [x] TypeScript compilation (Admin) — **PASSED**
- [x] Prisma generate — **PASSED**

### Manual Verification
- Run `npx prisma generate && npx prisma db push` to apply new Agent models
- Run `npx tsx prisma/seed.ts` to seed agent accounts
- `POST /api/v1/admin/auth/login` as `admin@quicksend.com` → get admin token
- `POST /api/v1/agent/create` with admin token → create PARTNER + INTERNAL agents
- `GET /api/v1/agent/list` → verify both agent types appear with wallet info
- `POST /api/v1/agent/auth/login` as `partner@quicksend.com` → get agent token with `AGENT_PARTNER` role
- `POST /api/v1/agent/:id/add-balance` with agent token → verify user balance credited, agent treasury debited, commission credited
- `POST /api/v1/agent/:id/withdraw` with agent token → verify user debited, commission to agent wallet
- `POST /api/v1/agent/topup-partner` with internal agent token → verify partner's BASE_TREASURY increased
- `GET /api/v1/agent/:id/kpi` → verify KPI entries recorded after operations
- Admin UI: Navigate to `/agents` → verify agent list renders
- Admin UI: Click expand on an agent → verify detail panel with wallets, KPI table, transactions
- Admin UI: Click Create Agent → fill form → verify agent appears in list
- Admin UI: Toggle agent status → verify badge updates

---

# Sprint 11 Local Agent System Tasks

- `[x]` Database Schema
  - `[x]` Agent model
  - `[x]` AgentWallet model
  - `[x]` AgentTransaction model
  - `[x]` AgentKpi model
  - `[x]` Prisma generate (0 errors)
- `[x]` Agent Service
  - `[x]` addUserBalance (Partner: own treasury; Internal: system HOT)
  - `[x]` executeWithdrawal
  - `[x]` processGlobalPayment
  - `[x]` topUpPartnerBalance
  - `[x]` getAgentDashboard
  - `[x]` getAgentKpi
  - `[x]` recordKpi (DAILY/WEEKLY/MONTHLY upsert)
- `[x]` Agent Auth Routes
  - `[x]` POST /login (returns AGENT_PARTNER / AGENT_INTERNAL JWT role)
  - `[x]` GET /me (profile + wallets)
- `[x]` Agent Routes
  - `[x]` POST /create (admin, auto-provisions wallets)
  - `[x]` GET /list (admin)
  - `[x]` GET /:id (agent dashboard)
  - `[x]` POST /:id/toggle-status (admin)
  - `[x]` POST /:id/add-balance (agent)
  - `[x]` POST /:id/withdraw (agent)
  - `[x]` POST /:id/process-payment (agent)
  - `[x]` POST /topup-partner (internal agent only)
  - `[x]` GET /:id/kpi
  - `[x]` GET /:id/transactions
- `[x]` Route Registration
  - `[x]` agentRoutes mounted at /api/v1/agent
  - `[x]` agentAuthRoutes mounted at /api/v1/agent/auth
  - `[x]` ExtendedPrismaClient interface updated
- `[x]` Admin Frontend — Types & API
  - `[x]` Agent types in admin.types.ts
  - `[x]` Agent API methods + mocks
  - `[x]` Agent store state + actions
  - `[x]` Role permission for /agents page
- `[x]` Admin Frontend — UI
  - `[x]` Agents nav item in sidebar
  - `[x]` /agents route in router
  - `[x]` Agent list page with type/status badges
  - `[x]` Create agent form
  - `[x]` Expandable agent detail panel
  - `[x]` KPI table with DAILY/WEEKLY/MONTHLY toggle
  - `[x]` Transactions table
  - `[x]` Wallets display
  - `[x]] Toggle agent status button
- `[x]` Seed Data
  - `[x]` partner@quicksend.com (PARTNER, 100k base + 5k commission)
  - `[x]` internal@quicksend.com (INTERNAL, 2.5k commission)
- `[x]` Verification
  - `[x]` TypeScript build check — Backend (0 errors)
  - `[x]` TypeScript build check — Admin (0 errors)
  - `[x]` Prisma generate — Backend (0 errors)
