# Implement Sprint 4 - Payout Engine (Frontend)

This plan outlines the frontend implementation of Sprint 4 for the QuickSend Web Application. Sprint 4 introduces the Payout Engine — the money movement layer responsible for executing settlements through partner channels (bank, mobile money, cash pickup), tracking delivery status in real time, and handling retry logic.

## User Review Required

> [!IMPORTANT]
> **Mocking Backend Responses**
> Similar to Sprint 2 and 3, payout API calls use a local mocked data layer (with simulated network delays and a simulated settlement flow) so the UI can be fully interacted with immediately. The mock simulates the full payout lifecycle (PENDING → QUEUED → PROCESSING → SENT_TO_PARTNER → CONFIRMED → DELIVERED) with 2-second transitions between each state.

> [!WARNING]
> **Payout Tracker UX**
> The PayoutTracker page uses a real-time update mechanism via `CustomEvent` listeners on `window` to reflect status changes as the mock flow progresses. In production this would be replaced with a WebSocket connection.

## Open Questions

> [!TIP]
> Please advise on the following:
> 1. **Retry Strategy**: The current retry UI allows manual retry with a max of 3 attempts. Should we also implement automatic retry with exponential backoff (10s, 30s, 60s) as described in the development document?
> 2. **Payout History**: Should we build a payout history list page separate from the transactions page?

---

## Proposed Changes

### 1. Payout Core Features Layer

#### [NEW] [payout.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/payout/payout.types.ts)
- Define `PayoutStatus` type (`PENDING | QUEUED | PROCESSING | SENT_TO_PARTNER | CONFIRMED | DELIVERED | FAILED`).
- Define `PayoutOrder` type (id, transferId, partner, payoutMethod, status, externalReference, attemptCount).
- Define `PayoutEvent` and `PartnerLog` types.

#### [NEW] [payout.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/payout/payout.api.ts)
- Mock API with simulated payout lifecycle flow.
- `execute()` - creates payout order and starts simulation.
- `getStatus()` - fetches current payout order status.
- `retry()` - resets status and re-runs the flow, incrementing attempt count.

#### [NEW] [payout.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/payout/payout.store.ts)
- Zustand store to manage payout state, execute payouts, fetch status, and listen for real-time updates.

---

### 2. Transfer Updates

#### [MODIFY] [transfer.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/transfer.types.ts)
- Added `payoutOrderId` and `payoutStatus` fields to `Transfer` interface.
- Updated `TransferStatus` type with full lifecycle statuses.

#### [MODIFY] [transfer.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/transfer.api.ts)
- Updated mock to return `payoutOrderId` and `payoutStatus` on transfer creation.

---

### 3. Payout Tracker Page

#### [NEW] [PayoutTracker.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/payout/PayoutTracker.tsx)
- **Design**: Clean tracking interface with a real-time status banner, settlement details card, and timeline progress.
- **Features**:
  - Status banner with contextual messaging (pending, processing, delivered, failed).
  - Settlement details (Order ID, Partner, Attempts, External Reference).
  - Timeline progress indicator with animated steps.
  - Retry button (visible on FAILED status, max 3 attempts).
  - Success celebration view on DELIVERED status.
  - Real-time updates via CustomEvent listener.

---

### 4. Send Money Updates

#### [MODIFY] [SendMoney.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/transfers/SendMoney.tsx)
- After transfer creation, automatically initiate payout execution.
- Updated success state (Step 4) to display payout status badge.
- Added "Track Payout Settlement" button linking to the PayoutTracker page.

---

### 5. Routing System

#### [MODIFY] [protected.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/routes/protected.tsx)
- Added route: `/payout/:id` → `<PayoutTracker />`

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/features/payout/payout.types.ts` | Payout type definitions |
| `src/features/payout/payout.api.ts` | Payout API with mock settlement simulation |
| `src/features/payout/payout.store.ts` | Zustand store for payout state management |
| `src/pages/payout/PayoutTracker.tsx` | Real-time payout tracking page |

### Modified Files
| File | Changes |
|------|---------|
| `src/features/transfers/transfer.types.ts` | Added `payoutOrderId`, `payoutStatus` fields |
| `src/features/transfers/transfer.api.ts` | Mock returns payout order reference |
| `src/pages/transfers/SendMoney.tsx` | Payout execution integration + tracking link |
| `src/routes/protected.tsx` | Added `/payout/:id` route |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (`npm run build`) — **PASSED**
- [x] No linting errors introduced

### Manual Verification
- Navigate to Send Money flow
- Complete a transfer
- Verify payout auto-executes on success screen
- Click "Track Payout Settlement"
- Watch the real-time timeline progress through all states
- Verify retry button appears on failure (simulate by setting mock to return FAILED)
- Confirm "Send Another Transfer" clears state correctly

---

# Sprint 4 Payout Engine Tasks

- `[x]` Core Architecture
  - `[x]` Create `payout.types.ts`
  - `[x]` Create `payout.api.ts` with mock settlement simulation
  - `[x]` Create `payout.store.ts`
- `[x]` Transfer Updates
  - `[x]` Update `transfer.types.ts` with payout fields
  - `[x]` Update `transfer.api.ts` mock to return payout reference
- `[x]` UI Pages
  - `[x]` Create `src/pages/payout/PayoutTracker.tsx` (real-time tracking page)
  - `[x]` Update `src/pages/transfers/SendMoney.tsx` (payout integration)
- `[x]` Routing
  - `[x]` Update `src/routes/protected.tsx` with `/payout/:id`
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Full UI flow validation ready
