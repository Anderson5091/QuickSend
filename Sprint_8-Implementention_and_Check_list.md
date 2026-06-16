# Implement Sprint 8 — Event Sourcing

This plan outlines the implementation of Sprint 8 for the QuickSend ecosystem. Sprint 8 converts the existing notification-oriented event system into a true **Event Sourcing** architecture where every state change is stored as an immutable, append-only, versioned event that can be replayed to rebuild aggregate state.

## User Review Required

> [!IMPORTANT]
> **Event Store Is Append-Only**
> The Event model now has a `@@unique([aggregateId, version])` constraint to prevent duplicate versions. Once written, events should never be updated or deleted (enforced at application level — no API exists for mutation).

> [!WARNING]
> **Replay vs Current State**
> The replay system rebuilds aggregate state purely from events. This can be used for consistency verification, but production use should cache snapshots for performance.

---

## Proposed Changes

### 1. Schema Update

#### [MODIFY] [schema.prisma](file:///C:/Anderson/Quick.Money/QuickSend-Backend/prisma/schema.prisma)
- Added `@@unique([aggregateId, version])` constraint on the `Event` model
- Prevents duplicate version writes (optimistic concurrency enforcement)

### 2. Event Store

#### [NEW] [event-store.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/events/event-store.service.ts)
- `appendEvent(aggregateId, type, payload, expectedVersion?)`: Appends event with version check.
  - If `expectedVersion` provided: version = expectedVersion + 1, Prisma unique constraint catches conflicts
  - If no version: queries the latest version, increments
  - Throws `Concurrency conflict` error on version collision
- `getEvents(aggregateId)`: All events for an aggregate in ascending version order
- `getEventsByType(type, since?)`: Events filtered by type
- `getAllEvents(limit)`: Recent events across all aggregates
- `getCurrentVersion(aggregateId)`: Latest version number
- `countEvents()`: Total event count
- Exports `replayFrom(events, reducer, initialState)` pure function
- Exports `StoredEvent`, `AggregateState`, `ReducerFn` types

### 3. Event Replay

#### [NEW] [event-replay.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/events/event-replay.service.ts)
- `rebuildWalletBalance(walletId)`: Replays WALLET_CREDITED/WALLET_DEBITED events to compute balance
- `rebuildTransferState(transferId)`: Replays transfer lifecycle events to determine current status
- `rebuildAggregate(aggregateId, reducer, initialState)`: Generic aggregate rebuild from events
- `rebuildFromScratch(reducer, initialState, eventTypeFilter?)`: Full system rebuild — processes all events to produce a `Map<aggregateId, state>`
- `verifyConsistency()`: Compares event-replayed wallet balances against ledger-computed balances, returns mismatches

### 4. Event Emitter Update

#### [MODIFY] [event.emitter.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/events/event.emitter.ts)
- Uses `eventStore.appendEvent()` for persistence (append-only, versioned)
- Falls back to `EventLog` audit table for backward compatibility
- Broadcasts all events via WebSocket `broadcastToAll()` for real-time streaming
- Maintains existing handler dispatch

### 5. Aggregate Reducers

| Aggregate | Event Types | Reducer |
|-----------|-------------|---------|
| `wallet:{walletId}` | WALLET_CREDITED, WALLET_DEBITED | Adds/subtracts amount from balance |
| `transfer:{transferId}` | TRANSFER_CREATED, TRANSFER_COMPLETED, TRANSFER_FAILED, PAYOUT_SENT, PAYOUT_CONFIRMED, PAYOUT_FAILED | Transitions status through lifecycle |

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/modules/events/event-store.service.ts` | Append-only event store with version control |
| `src/modules/events/event-replay.service.ts` | Aggregate rebuilding + consistency verification |

### Modified Files
| File | Changes |
|------|---------|
| `prisma/schema.prisma` | Added `@@unique([aggregateId, version])` on Event model |
| `src/modules/events/event.emitter.ts` | Uses EventStore for append-only persistence + WebSocket broadcast |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (Backend) — **PASSED**

### Manual Verification
- Create a transfer → verify Event record created with correct aggregateId and version
- Create another transfer for same aggregate → verify version increments
- Call `rebuildWalletBalance(walletId)` → verify returned balance matches actual balance
- Call `verifyConsistency()` → verify no mismatches between event replay and ledger
- Verify events appear in WebSocket broadcast

---

# Sprint 8 Event Sourcing Tasks

- `[x]` Schema
  - `[x]` Add `@@unique([aggregateId, version])` to Event model
- `[x]` Event Store
  - `[x]` Create event-store.service.ts with appendEvent
  - `[x]` Implement version checking with optimistic concurrency
  - `[x]` Implement event queries (by aggregate, by type, all)
  - `[x]` Export replayFrom pure function + types
- `[x]` Event Replay
  - `[x]` Create event-replay.service.ts
  - `[x]] Wallet balance reducer (CREDIT/DEBIT)
  - `[x]` Transfer state reducer (lifecycle events)
  - `[x]` Generic aggregate rebuild
  - `[x]` Full system rebuild from scratch
  - `[x]` Consistency verification against ledger
- `[x]` Event Emitter Integration
  - `[x]] Write to EventStore on emit
  - `[x]` WebSocket broadcast on emit
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Replay consistency validation
