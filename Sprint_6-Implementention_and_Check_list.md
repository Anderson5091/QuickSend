# Implement Sprint 6 - Compliance Engine (Frontend)

This plan outlines the frontend implementation of Sprint 6 for the QuickSend Web Application. Sprint 6 introduces the Compliance Engine — the regulatory backbone responsible for KYC verification, AML screening, risk scoring, sanctions checks, and send limit enforcement.

## User Review Required

> [!IMPORTANT]
> **Mocking Backend Responses**
> All compliance API calls use a local mocked data layer with realistic KYC profile data, document statuses, AML checks, risk scores, and compliance history.

> [!WARNING]
> **Document Upload**
> The document upload button is functional in the UI but uses a mock API. In production, this would integrate with a secure document storage service (e.g., AWS S3) and a verification provider (e.g., Onfido, Jumio).

---

## Proposed Changes

### 1. Compliance Core Features Layer

#### [NEW] [compliance.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/compliance/compliance.types.ts)
- Define `KycTier` (1/2/3), `KycStatus`, `RiskLevel` (LOW/MEDIUM/HIGH/CRITICAL), `Decision` (APPROVE/REVIEW/BLOCK)
- Define `KycProfile`, `KycDocument`, `AmlCheck`, `SanctionsHit`, `RiskScore`, `ComplianceCase`, `ComplianceOverview`

#### [NEW] [compliance.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/compliance/compliance.api.ts)
- Mock API with realistic compliance data (approved KYC Tier 1, pending documents, LOW risk score, daily/monthly limits)
- `getOverview()` - full compliance status
- `uploadDocument(type)` - simulate document upload with 2s delay
- `requestTierUpgrade()` - request KYC tier upgrade

#### [NEW] [compliance.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/compliance/compliance.store.ts)
- Zustand store for compliance data: overview, documents, upload/upgrade states

---

### 2. Compliance Center Page

#### [NEW] [ComplianceCenter.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/compliance/ComplianceCenter.tsx)
- **Design**: Clean, comprehensive compliance dashboard with card-based layout.
- **Sections**:
  - **KYC Profile Card**: Full name, country, DOB, address, current tier with status badge. Tier upgrade button.
  - **Risk Score Gauge**: SVG circular gauge (0-100) with color-coded risk level and contributing factors.
  - **Send Limits**: Daily and monthly limit progress bars with remaining amounts.
  - **AML Screening**: Risk level display, flags count, last checked date, sanctions match status.
  - **KYC Documents**: Document list with status badges (Approved/Pending/Rejected). Upload dropdown selector with button.
  - **Compliance History**: Chronological list of past compliance cases with status indicators.
  - **Compliance Rules**: Grid of 6 rule cards explaining the compliance rules engine (sanctions, high value, velocity, tier restriction, critical risk, high risk review).

---

### 3. Routing & Navigation

#### [MODIFY] [protected.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/routes/protected.tsx)
- Added route: `/compliance` → `<ComplianceCenter />`

#### [MODIFY] [Dashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/dashboard/Dashboard.tsx)
- Added "Compliance" link in the top navigation bar.

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/features/compliance/compliance.types.ts` | Compliance type definitions (KYC, AML, risk, sanctions) |
| `src/features/compliance/compliance.api.ts` | Compliance API with realistic mock data |
| `src/features/compliance/compliance.store.ts` | Zustand store for compliance state management |
| `src/pages/compliance/ComplianceCenter.tsx` | Comprehensive compliance dashboard page |

### Modified Files
| File | Changes |
|------|---------|
| `src/routes/protected.tsx` | Added `/compliance` route |
| `src/pages/dashboard/Dashboard.tsx` | Added Compliance nav link |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (`npm run build`) — **PASSED**
- [x] No linting errors introduced

### Manual Verification
- Navigate to Dashboard and click "Compliance" nav link
- Verify KYC profile displays correct tier, name, country, and status badge
- Check risk score gauge animates with correct score and color
- Verify daily/monthly send limit bars show correctly
- Confirm AML screening section shows risk level and sanctions status
- Upload a test document via the dropdown selector
- Click "Upgrade" tier button and observe success message
- Scroll through compliance history and rules grid

---

# Sprint 6 Compliance Engine Tasks

- `[x]` Core Architecture
  - `[x]` Create `compliance.types.ts` (KYC, AML, Risk, Sanctions, Limits)
  - `[x]` Create `compliance.api.ts` with realistic mock data
  - `[x]` Create `compliance.store.ts`
- `[x]` UI Pages
  - `[x]` Create `src/pages/compliance/ComplianceCenter.tsx` (comprehensive dashboard)
- `[x]` Routing & Navigation
  - `[x]` Update `src/routes/protected.tsx` with `/compliance`
  - `[x]` Update `src/pages/dashboard/Dashboard.tsx` nav with Compliance link
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Full UI flow validation ready
