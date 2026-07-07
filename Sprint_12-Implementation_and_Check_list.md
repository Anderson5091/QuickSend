# Implement Sprint 12 — Didit KYC Integration

This plan outlines the implementation of Sprint 12 for the QuickSend ecosystem. Sprint 12 replaces the mock/simulated KYC flow with **real identity verification via Didit's Standalone APIs**, keeping users entirely within the QuickSend app (no redirect to external pages).

## User Review Required

> [!IMPORTANT]
> **Three KYC Tiers**
> - **Tier 0 → 1** ($500/mo limit) — Name, email, DOB, nationality, country, selfie
> - **Tier 1 → 2** ($5,000/mo limit) — ID document image (passport/ID/driver license) + selfie + face match
> - **Tier 2 → 3** (unlimited) — Proof of address document + source of funds declaration

> [!WARNING]
> **Didit API Keys**
> Store secrets in Railway environment: `DIDIT_API_KEY` (API key for Didit Standalone APIs) and `DIDIT_API_BASE_URL` (default: `https://api.didit.me/v1`). These must be set before any KYC operations will succeed.

> [!NOTE]
> **No Redirects**
> Unlike Didit's hosted flow, the Standalone API approach keeps the user entirely within QuickSend. The backend orchestrates calls to Didit's REST endpoints synchronously per tier step.

---

## Proposed Changes

### 1. Database Schema — KYC Enhancements

#### [MODIFY] [schema.prisma](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/prisma/schema.prisma) & [rail-backend schema.prisma](file:///C:/Anderson/Quick.Money/QuickSend/rail-backend/prisma/schema.prisma)
- Added `kycTier` (Int, default 0) and `kycStatus` (String, default "none") fields to `User` model
- Added `nationality` (String?) and `diditVerificationId` (String?) fields to `KycProfile` model
- Added **KycEvent** model — tracks every KYC action: event type, status, provider, raw payload, user and profile IDs, timestamps

### 2. Backend Configuration

#### [MODIFY] [env.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/config/env.ts)
- Added `DIDIT_API_KEY` and `DIDIT_API_BASE_URL` to environment config

#### [MODIFY] [id-generator.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/utils/id-generator.ts)
- Added `QSKE` prefix mapping for KycEvent model

#### [MODIFY] [database.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/config/database.ts)
- Added `kycEvent` to `ExtendedPrismaClient` interface

#### [MODIFY] [rateLimiter.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/middleware/rateLimiter.ts)
- Added `kycLimiter` (10 requests per 15 minutes) for KYC submission endpoints

### 3. Backend Didit Service

#### [NEW] [didit.service.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/kyc/didit.service.ts)
- `verifyId(documentFront, documentBack, documentType)` → POST `/id-verification/` — verifies identity document images
- `passiveLiveness(selfieImage)` → POST `/passive-liveness/` — checks selfie for liveness
- `faceMatch(selfieImage, documentFront)` → POST `/face-match/` — compares selfie to document photo
- `verifyProofOfAddress(poaImage)` → POST `/poa/` — verifies proof of address document
- `amlScreen(fullName, nationality, dateOfBirth)` → POST `/aml/` — AML/sanctions screening
- `databaseValidation(field, value)` → POST `/database-validation/` — validates identity data against databases
- Each function handles request building, error wrapping, and returns parsed JSON result

### 4. Backend KYC Service

#### [NEW] [kyc.service.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/kyc/kyc.service.ts)
- **`processTier1(userId, data)`** — validates nationality/country, calls Didit `passiveLiveness` + `databaseValidation`, creates/updates `KycProfile` with personal info, logs `KycEvent` per step, sets user `kycTier=1` and `kycStatus=approved`
- **`processTier2(userId, data)`** — calls `verifyId` + `faceMatch`, updates profile with `diditVerificationId`, logs events, sets user `kycTier=2`
- **`processTier3(userId, data)`** — calls `verifyProofOfAddress` + `amlScreen`, updates profile with source of funds, logs events, sets user `kycTier=3`
- **`getKycStatus(userId)`** — returns current tier, status, limits, upcoming limit, recent KycEvents
- **`getTierLimits()`** — returns hardcoded limits per tier: T0=$500, T1=$500, T2=$5,000, T3=unlimited

### 5. Backend KYC Routes

#### [REWRITE] [kyc.routes.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/kyc/kyc.routes.ts)
- `POST /api/v1/kyc/tier-1` — [authenticated] Zod-validated: nationality, country, dateOfBirth, selfieImage (base64), fullName, address (optional). Calls `processTier1`
- `POST /api/v1/kyc/tier-2` — [authenticated] Multipart/form-data: idImage, selfieImage, documentType. Calls `processTier2`
- `POST /api/v1/kyc/tier-3` — [authenticated] Multipart/form-data: poaImage, sourceOfFunds. Calls `processTier3`
- `GET /api/v1/kyc/status` — [authenticated] Returns current KYC status, tier, limits, events

### 6. Backend Admin Routes

#### [MODIFY] [admin.routes.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/modules/admin/admin.routes.ts)
- Enhanced `GET /api/v1/admin/kyc/pending` — now returns `userKycTier`, `userKycStatus`, and `lastEvent` (latest KycEvent with type/status/payload) per pending profile
- Added `GET /api/v1/admin/kyc/:id` — returns KycProfile detail with user info and full event history
- Updated approve/reject endpoints to set both `kycTier` and `kycStatus` on User model + log KycEvent
- Updated `GET /api/v1/admin/dashboard` — added `kycTiers` breakdown with counts per tier (0/1/2/3)

### 7. Route Registration

#### [MODIFY] [app.ts](file:///C:/Anderson/Quick.Money/QuickSend/backend-app/src/app.ts)
- Registered `kycRoutes` at `/api/v1/kyc` with `kycLimiter` middleware

### 8. Web-App Compliance Frontend

#### [MODIFY] [compliance.types.ts](file:///C:/Anderson/Quick.Money/QuickSend/web-app/src/features/compliance/compliance.types.ts)
- Updated `KycStatusResult` with `kycTier`, `kycStatus`, `limits`, `upcomingLimit`, `events: KycEvent[]`
- Added `KycEvent` type with `id`, `eventType`, `status`, `provider`, `rawPayload`, `createdAt`

#### [MODIFY] [compliance.api.ts](file:///C:/Anderson/Quick.Money/QuickSend/web-app/src/features/compliance/compliance.api.ts)
- Replaced mock `getStatus` with real API call to `GET /api/v1/kyc/status`
- Added `submitTier1(data)` — POSTs JSON with base64 selfie to `/api/v1/kyc/tier-1`
- Added `submitTier2(data)` — POSTs multipart form with idImage/selfieImage/documentType
- Added `submitTier3(data)` — POSTs multipart form with poaImage/sourceOfFunds

#### [REWRITE] [compliance.store.ts](file:///C:/Anderson/Quick.Money/QuickSend/web-app/src/features/compliance/compliance.store.ts)
- New Zustand store with state: `kycStatus`, `loading`, `submitResult`, `submitError`, `tier2Loading`, `tier3Loading`
- Actions: `fetchStatus()`, `submitTier1()`, `submitTier2()`, `submitTier3()`
- Error handling and loading states per action

#### [REWRITE] [KYC.tsx](file:///C:/Anderson/Quick.Money/QuickSend/web-app/src/pages/compliance/KYC.tsx)
- Tier selector route: /compliance/kyc?tier=1|2|3
- **Tier 1 form**: fullName, dateOfBirth, nationality, country, selfie webcam/upload as base64 → real API submission
- **Tier 2 form**: document type selector (passport/national_id/driver_license), id image upload, selfie image upload → rendered to canvas, posted as multipart
- **Tier 3 form**: poa image upload, source of funds text input → posted as multipart
- Result display: shows Didit scores (liveness %, face match %, AML hits count, etc.) after submission
- Loading spinners during API calls

#### [REWRITE] [ComplianceCenter.tsx](file:///C:/Anderson/Quick.Money/QuickSend/web-app/src/pages/compliance/ComplianceCenter.tsx)
- Fetches real `kycStatus` from store on mount
- Shows current tier, status badge, limits per tier, and upcoming limit
- Displays recent KycEvent history as a timeline
- Upgrade button navigates to `/compliance/kyc?tier=N+1`

### 9. Admin-App KYC Review

#### [MODIFY] [admin.types.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.types.ts)
- Updated `PendingKycItem` with `userKycTier`, `userKycStatus`, `lastEvent` (type/status/payload)
- Updated `AdminDashboardData` with `kycTiers` record

#### [MODIFY] [admin.api.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.api.ts)
- `getPendingKyc()` returns enhanced type with last event and user KYC info
- Added `getKycDetail(kycId)` → returns profile + user + events
- Added `kycTiers` to `getDashboard()` mock/real response

#### [MODIFY] [admin.store.ts](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/features/admin/admin.store.ts)
- Added `kycDetail` state and `fetchKycDetail` action

#### [REWRITE] [KycReview.tsx](file:///C:/Anderson/Quick.Money/QuickSend/admin-app/src/pages/admin/KycReview.tsx)
- Displays each pending KYC with: name, email, tier badge, status badge, userKycTier/Status, last event with Didit scores (AML hits, liveness %, face match %, ID status, POA status)
- Detail button opens a modal with full profile info, Didit verification ID, and full event history with raw payload display
- Approve/Reject buttons per pending item

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `backend-app/src/modules/kyc/didit.service.ts` | 6 Didit Standalone API wrappers |
| `backend-app/src/modules/kyc/kyc.service.ts` | KYC tier orchestration logic |

### Modified Files
| File | Changes |
|------|---------|
| `backend-app/prisma/schema.prisma` | New User.kycTier/kycStatus, KycProfile.nationality/diditVerificationId, KycEvent model |
| `rail-backend/prisma/schema.prisma` | Same schema additions (mirrored) |
| `backend-app/src/config/env.ts` | Added DIDIT_API_KEY, DIDIT_API_BASE_URL |
| `backend-app/src/utils/id-generator.ts` | Added QSKE prefix for KycEvent |
| `backend-app/src/config/database.ts` | Added kycEvent to ExtendedPrismaClient |
| `backend-app/src/middleware/rateLimiter.ts` | Added kycLimiter (10/15min) |
| `backend-app/src/modules/kyc/kyc.routes.ts` | Rewrote with tier-1/2/3 + status endpoints |
| `backend-app/src/modules/admin/admin.routes.ts` | Enhanced KYC admin endpoints + dashboard kycTiers |
| `backend-app/src/app.ts` | Registered kycRoutes with kycLimiter |
| `web-app/src/features/compliance/compliance.types.ts` | Updated KycStatusResult, added KycEvent |
| `web-app/src/features/compliance/compliance.api.ts` | Real API calls + tier submission methods |
| `web-app/src/features/compliance/compliance.store.ts` | Rewrote with real fetch/submit actions |
| `web-app/src/pages/compliance/KYC.tsx` | Rewrote with real tier forms + API submission |
| `web-app/src/pages/compliance/ComplianceCenter.tsx` | Rewrote with real status + events |
| `admin-app/src/features/admin/admin.types.ts` | Updated PendingKycItem, AdminDashboardData |
| `admin-app/src/features/admin/admin.api.ts` | Added getKycDetail, enhanced getPendingKyc |
| `admin-app/src/features/admin/admin.store.ts` | Added kycDetail + fetchKycDetail |
| `admin-app/src/pages/admin/KycReview.tsx` | Rewrote with Didit score display + detail modal |

---

## Verification Plan

### Automated Checks
- [x] TypeScript compilation (Backend) — **PASSED**
- [x] TypeScript compilation (Admin) — **PASSED**
- [x] TypeScript compilation (Web) — **PASSED**
- [x] Prisma generate (Backend) — **PASSED**
- [x] Prisma generate (Rail) — **PASSED**
- [x] Prisma db push — **PASSED**

### Manual Verification
- Set `DIDIT_API_KEY` and `DIDIT_API_BASE_URL` in Railway environment
- Log in as a Tier 0 user → navigate to /compliance → see "Upgrade to Tier 1" CTA
- Complete Tier 1: upload selfie → verify KYC status shows Tier 1 Approved in ComplianceCenter
- Complete Tier 2: upload ID image + selfie → verify KYC status shows Tier 2 Approved
- Complete Tier 3: upload POA + source of funds → verify KYC status shows Tier 3 Approved
- Check ComplianceCenter shows correct limits per tier and upcoming limit
- Admin: login → navigate to KYC Review → verify pending applications show Didit scores (liveness %, face match %, AML hits)
- Admin: click Detail on a pending KYC → verify modal shows full profile, Didit verification ID, event history with raw payload
- Admin: Approve/Reject a KYC application → verify User tier/status updates
- Admin: Check dashboard → verify kycTiers breakdown shows correct counts
- Verify rate limiting: send >10 KYC requests in 15 min → receive 429 Too Many Requests

---

# Sprint 12 Didit KYC Integration Tasks

- `[x]` Database Schema
  - `[x]` User.kycTier (Int, default 0)
  - `[x]` User.kycStatus (String, default "none")
  - `[x]` KycProfile.nationality (String?)
  - `[x]` KycProfile.diditVerificationId (String?)
  - `[x]` KycEvent model
  - `[x]` Prisma generate (0 errors)
- `[x]` Backend Configuration
  - `[x]` env.ts — DIDIT_API_KEY, DIDIT_API_BASE_URL
  - `[x]` id-generator.ts — QSKE prefix
  - `[x]` database.ts — ExtendedPrismaClient.kycEvent
  - `[x]` rateLimiter.ts — kycLimiter (10/15min)
- `[x]` Didit Service
  - `[x]` verifyId (document front/back + type)
  - `[x]` passiveLiveness (selfie)
  - `[x]` faceMatch (selfie + document)
  - `[x]` verifyProofOfAddress (poa image)
  - `[x]` amlScreen (name + nationality + dob)
  - `[x]` databaseValidation (field + value)
- `[x]` KYC Service
  - `[x]` processTier1 (liveness + database validation)
  - `[x]` processTier2 (id verification + face match)
  - `[x]` processTier3 (poa + aml screening)
  - `[x]` getKycStatus (tier + limits + events)
  - `[x]` getTierLimits (T0=$500, T1=$500, T2=$5k, T3=unlimited)
- `[x]` KYC Routes
  - `[x]` POST /tier-1 (JSON, base64 selfie, zod-validated)
  - `[x]` POST /tier-2 (multipart, idImage + selfieImage + documentType)
  - `[x]` POST /tier-3 (multipart, poaImage + sourceOfFunds)
  - `[x]` GET /status (current tier, limits, events)
- `[x]` Admin Routes
  - `[x]` GET /kyc/pending (enhanced with lastEvent + userKyc fields)
  - `[x]` GET /kyc/:id (profile + user + events)
  - `[x]` Approve/reject updates User.kycTier/kycStatus + logs KycEvent
  - `[x]` GET /dashboard includes kycTiers breakdown
- `[x]` Route Registration
  - `[x]` kycRoutes at /api/v1/kyc with kycLimiter
- `[x]` Web-App Compliance
  - `[x]` compliance.types.ts — KycStatusResult + KycEvent
  - `[x]` compliance.api.ts — real getStatus + submitTier1/2/3
  - `[x]` compliance.store.ts — fetchStatus + submitTier1/2/3
  - `[x]` KYC.tsx — real tier forms + base64/multipart submission + score display
  - `[x]` ComplianceCenter.tsx — real status + limits + events + upgrade nav
- `[x]` Admin-App KYC Review
  - `[x]` admin.types.ts — enhanced PendingKycItem + kycTiers in dashboard
  - `[x]` admin.api.ts — getKycDetail + enhanced getPendingKyc
  - `[x]` admin.store.ts — kycDetail + fetchKycDetail
  - `[x]` KycReview.tsx — Didit score display + detail modal + approve/reject
- `[x]` Infrastructure
  - `[x]` Prisma generate — Backend (0 errors)
  - `[x]` Prisma generate — Rail (0 errors)
  - `[x]` Prisma db push — Backend (0 errors)
- `[x]` Verification
  - `[x]` TypeScript build check — Backend (0 errors)
  - `[x]` TypeScript build check — Admin (0 errors)
  - `[x]` TypeScript build check — Web (0 errors)
