Below is a **focused development document for QuickSend KYC module only**, assuming the app already exists and supports **Tier 0–3 wallet limits**.

---

# QuickSend — KYC Development Document (Didit Integration)

## 1. Purpose

This module handles **identity verification (KYC)** for upgrading users from:

* Tier 0 → Tier 1 → Tier 2 → Tier 3

It integrates with Didit as the external verification provider while QuickSend remains the system of record for user status and wallet limits.

---

## 2. Scope

### Included

* Tier 1 identity data collection
* Document upload flow
* Didit verification session creation
* Webhook handling
* KYC status updates
* Tier upgrade logic integration
* Audit logging

### Excluded

* Wallet system (already implemented)
* Transaction system (already implemented)
* Treasury system (already implemented)

---

## 3. KYC Tier Definition (QuickSend Context)

### Tier 1 (Basic Identity Verification)

Required fields:

* Legal full name
* Date of birth
* Nationality
* Country of residence
* Full address

Purpose:

* Establish basic identity
* Enable entry-level sending/receiving limits

---

### Tier 2 (Document Verification)

Required:

* Government-issued ID (passport / national ID / driver’s license)
* Selfie / liveness check

---

### Tier 3 (Enhanced Due Diligence - EDD)

Required:

* Source of funds (optional questionnaire)
* Address proof
* Manual review (if flagged by risk engine)

---

## 4. System Architecture

```text id="kky8z1"
[Mobile / Web App]
        ↓
[KYC API Gateway - QuickSend Backend]
        ↓
[Didit Verification API]
        ↓
[Didit Processing Engine]
        ↓
[Webhook Callback to QuickSend]
        ↓
[KYC Service Updates User Tier]
        ↓
[Wallet Limits Engine]
```

---

## 5. Database Design

### 5.1 users table (existing extension)

```sql id="u1kyc0"
ALTER TABLE users ADD COLUMN kyc_tier INT DEFAULT 0;
ALTER TABLE users ADD COLUMN kyc_status VARCHAR(20) DEFAULT 'unverified';
ALTER TABLE users ADD COLUMN didit_session_id VARCHAR(255);
ALTER TABLE users ADD COLUMN didit_verification_id VARCHAR(255);
```

---

### 5.2 kyc_profiles table

```sql id="u1kyc1"
CREATE TABLE kyc_profiles (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,

    -- Tier 1 data
    full_name VARCHAR(255),
    date_of_birth DATE,
    nationality VARCHAR(100),
    country VARCHAR(100),
    address TEXT,

    -- Status
    current_tier INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',

    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

---

### 5.3 kyc_events table (audit log)

```sql id="u1kyc2"
CREATE TABLE kyc_events (
    id UUID PRIMARY KEY,
    user_id UUID,
    event_type VARCHAR(50),
    status VARCHAR(50),
    provider VARCHAR(50) DEFAULT 'didit',
    raw_payload JSON,
    created_at TIMESTAMP
);
```

---

## 6. Tier 1 Flow (Core Focus)

### Step 1 — User submits Tier 1 data

Frontend form:

* full_name
* date_of_birth
* nationality
* country
* address

Backend:

```text id="kycflow1"
POST /kyc/tier-1/submit
```

---

### Step 2 — Store Tier 1 profile

* Save in `kyc_profiles`
* Mark status = `pending_verification`

---

### Step 3 — Create Didit session

```text id="kycflow2"
POST Didit API:
- identity_data
- user reference ID
```

Store:

* `didit_session_id`

---

### Step 4 — User completes verification

Depending on Tier progression:

* Upload ID (Tier 2 trigger)
* Selfie capture

---

### Step 5 — Webhook from Didit

```text id="kycflow3"
EVENT: verification.completed
```

Payload includes:

* status (approved/rejected)
* risk_score
* document validation result

---

### Step 6 — Update QuickSend system

If approved:

```text id="kycflow4"
kyc_tier = 1 or 2 or 3
kyc_status = approved
```

Trigger:

* Wallet limit update
* Transaction enablement

---

## 7. API Endpoints

### Tier 1 Submission

```http id="api1"
POST /api/v1/kyc/tier-1
```

Request:

```json id="req1"
{
  "full_name": "John Doe",
  "date_of_birth": "1995-01-01",
  "nationality": "Haitian",
  "country": "Haiti",
  "address": "Delmas 33"
}
```

---

### Start Verification Session

```http id="api2"
POST /api/v1/kyc/start
```

Response:

```json id="res1"
{
  "didit_session_id": "abc123",
  "status": "pending"
}
```

---

### Webhook

```http id="api3"
POST /api/v1/webhooks/didit
```

---

## 8. Business Rules

### Tier Upgrade Logic

| Condition       | Action               |
| --------------- | -------------------- |
| Tier 1 approved | Enable basic sending |
| Tier 2 approved | Increase limits      |
| Tier 3 approved | Full access          |

---

### Risk Handling

* If risk_score > threshold → manual review
* If document mismatch → reject + retry
* If liveness fail → restart Tier 2

---

## 9. Security Requirements

* Encrypt all PII fields (AES-256)
* Do not store raw documents unless required
* Use signed webhook validation from Didit
* Log all KYC events (immutable audit trail)
* Rate-limit KYC submissions

---

## 10. Success Criteria

* Tier 1 completion success rate > 90%
* Verification response time < 60 seconds
* Zero unauthorized KYC upgrades
* Full audit traceability per user

---

## 11. Future Extensions

* AI fraud scoring layer (optional)
* Multi-provider KYC fallback (Onfido, Sumsub)
* Biometric re-verification for Tier 3
* Automated sanctions screening refresh

---

If you want next, I can design:

* **Full backend architecture (NestJS / Node / Go)**
* **Webhook security + signature verification**
* **Wallet limit engine tied to KYC tiers**
* **Database schema integrated with your treasury system**

Just tell me.
