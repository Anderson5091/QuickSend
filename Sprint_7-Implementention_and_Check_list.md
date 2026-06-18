# Implement Sprint 7 — Idempotency + Wallet Locking

This plan outlines the implementation of Sprint 7 for the QuickSend ecosystem. Sprint 7 introduces two critical safety layers: **Idempotency Keys** for preventing duplicate API execution, and **Wallet Locking** for preventing concurrent spending and double-spend attacks.

## User Review Required

> [!IMPORTANT]
> **Idempotency Middleware**
> The `Idempotency-Key` header is required on `POST /api/v1/transfers`. The key must be 8-128 characters. Replaying the same key with the same request body returns the cached response. Replaying with different parameters returns a 422 error.

> [!WARNING]
> **Wallet Locking**
> Locking is in-memory by default. For production across multiple instances, replace with Redis-based distributed locking via the same `LockService` interface. The lock TTL defaults to 5 seconds.

---

## Proposed Changes

### 1. Idempotency Middleware

#### [NEW] [idempotency.middleware.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/middleware/idempotency.middleware.ts)
- Reads `Idempotency-Key` header from incoming requests
- Computes SHA-256 hash of `(body + url + userId)` for request identity
- On first request: proceeds to handler, intercepts `res.json()` to capture + persist response
- On duplicate key with same hash: returns cached 200 response
- On duplicate key with different hash: returns 422 error
- Persists keys in Prisma `IdempotencyKey` table

### 2. Wallet Locking Service

#### [NEW] [lock.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/services/lock.service.ts)
- In-memory `Map<string, LockEntry>` with holder token + expiry
- `acquire(resource, ttlMs)` — retries up to 100 times with 50ms backoff, throws if exhausted
- `release(resource, lockId)` — only the lock holder can release
- `withLock<T>(resource, fn)` — convenience wrapper with auto-acquire/release
- `isLocked(resource)` — check without acquiring

### 3. Transfer Integration

#### [MODIFY] [transfer.orchestrator.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/transfer/transfer.orchestrator.ts)
- Entire transfer creation wrapped in `lockService.withLock("wallet:${wallet.id}", ...)`
- Balance check moved inside the lock to prevent race conditions
- Ledger DEBIT entry created while holding the lock
- Emits `TRANSFER_CREATED` event on success

#### [MODIFY] [transfer.routes.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/transfer/transfer.routes.ts)
- Added `idempotencyMiddleware` to `POST /api/v1/transfers` route

### 4. Protection Layers Summary

| Layer | Mechanism | Scope |
|-------|-----------|-------|
| Idempotency Key | `Idempotency-Key` header → Prisma table | Prevents duplicate API execution |
| Wallet Lock | In-memory mutex per wallet ID | Prevents concurrent spending |
| Unique Ledger Key | `uniqueKey` on LedgerEntry (DEBIT/CREDIT + reference) | Prevents duplicate ledger writes |

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/middleware/idempotency.middleware.ts` | Idempotency header check + response caching |
| `src/services/lock.service.ts` | In-memory mutex with retry + timeout |

### Modified Files
| File | Changes |
|------|---------|
| `src/modules/transfer/transfer.orchestrator.ts` | Wallet lock + balance check inside lock |
| `src/modules/transfer/transfer.routes.ts` | Idempotency middleware on POST |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (Backend) — **PASSED**

### Manual Verification
- Send `POST /api/v1/transfers` with `Idempotency-Key: test-key-123`
- Send same request again → 200 with cached response
- Send same key but different body → 422 error
- Without `Idempotency-Key` header → request proceeds normally
- Concurrent transfer requests for same wallet → second one waits for lock, then processes correctly

---

# Sprint 7 Idempotency + Locking Tasks

- `[x]` Idempotency Middleware
  - `[x]` Create middleware with header reading + validation
  - `[x]` Implement request hashing for identity check
  - `[x]` Persist completed responses to Prisma IdempotencyKey table
  - `[x]` Return cached response on duplicate key
  - `[x]` Return 422 on key reuse with different parameters
- `[x]` Wallet Locking
  - `[x]` Create LockService with acquire/release/withLock
  - `[x]` Implement retry loop with 50ms backoff, 100 max retries
  - `[x]] Implement holder validation for release
- `[x]` Transfer Integration
  - `[x]` Wrap transfer creation in wallet lock
  - `[x]` Move balance check inside lock scope
  - `[x]` Add idempotency middleware to transfer route
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Manual idempotency flow validation
