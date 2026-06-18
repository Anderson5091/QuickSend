# Implement Sprint 3 - Transfer Engine (Frontend)

This plan outlines the frontend implementation of Sprint 3 for the QuickSend Web Application. Sprint 3 introduces the core remittance functionality: the Transfer Engine. Users will be able to manage beneficiaries and execute cross-border transfers by obtaining dynamic FX quotes, reviewing fees, and finalizing the transfer.

As with previous sprints, all UI components will adhere to the premium, mobile-first design system utilizing gradients, micro-animations, and clean typography.

## User Review Required

> [!IMPORTANT]
> **Mocking Backend Responses**
> Similar to Sprint 2, I will implement the services to use a local mocked data layer (with simulated network delays) if the actual backend API endpoints are not yet available. This will allow us to fully test the UI logic and transitions. Please let me know if you would prefer to connect directly to the real API instead.

> [!WARNING]
> **Send Money Flow UX**
> The design document outlines a multi-step "Send Money" flow:
> 1. Select Beneficiary
> 2. Get Quote (Enter amount, choose method, see fees & FX)
> 3. Confirm & Create Transfer
> 
> I plan to implement this as a multi-step wizard inside a single `/transfer` route using local state to transition between steps, ensuring a smooth, single-page-application feel. If you prefer separate routes (e.g., `/transfer/select`, `/transfer/quote`), please advise.

## Open Questions

> [!TIP]
> Please advise on the following:
> 1. **Mock Data Configuration**: Do you want me to proceed with mock service layers for the Beneficiary, Quote, and Transfer APIs so the frontend can be interacted with immediately?
> 2. **Navigation Flow**: Should we implement the Send Money flow as a multi-step wizard on one page, or split it across distinct routes?

---

## Proposed Changes

### 1. Beneficiary Core Features Layer

#### [NEW] [beneficiary.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/beneficiaries/beneficiary.types.ts)
- Define `Beneficiary` type (id, fullName, country, payoutMethod, bankName, accountNumber, etc.).

#### [NEW] [beneficiary.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/beneficiaries/beneficiary.api.ts)
- Axios API definitions for CRUD operations on beneficiaries.

#### [NEW] [beneficiary.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/beneficiaries/beneficiary.store.ts)
- Zustand store to fetch and manage the user's beneficiary list. (Including a mock service wrapper).

---

### 2. Transfer & Quote Core Features Layer

#### [NEW] [transfer.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/transfer.types.ts)
- Define `Quote` type (amount, fee, fxRate, destinationAmount).
- Define `Transfer` type (id, beneficiaryId, amount, payoutMethod, status, referenceId).

#### [NEW] [transfer.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/transfer.api.ts) & [quote.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/quote.api.ts)
- Axios API definitions for getting a quote and submitting a transfer.

#### [NEW] [transfer.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/transfers/transfer.store.ts)
- Zustand store to manage active transfer drafts, handle quote retrieval, and process the final transfer creation. (Including a mock service wrapper).

---

### 3. UI Pages

#### [NEW] [Beneficiaries.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/beneficiaries/Beneficiaries.tsx)
- **Design**: Clean list view of saved beneficiaries with a premium "Add New" form modal or inline form.
- **Features**: List saved contacts and allow adding new ones with required fields (Name, Country, Method, Account details).

#### [NEW] [SendMoney.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/transfers/SendMoney.tsx)
- **Design**: A sleek, multi-step wizard layout for cross-border remittance.
- **Step 1 (Select Beneficiary)**: Search and select from the user's saved beneficiaries.
- **Step 2 (Quote Engine)**: Input USDT amount. Dynamically fetch and display the FX rate, calculated fee, and final destination amount.
- **Step 3 (Confirmation)**: Review the complete transfer details and submit, resulting in a clean success state with a `referenceId`.

---

### 4. Routing System

#### [MODIFY] [protected.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/routes/protected.tsx)
- Add new routes for the Sprint 3 module:
  - `/beneficiaries` -> `<Beneficiaries />`
  - `/wallet/transfer` -> `<SendMoney />` (This will override the current empty placeholder logic in Sprint 2 for the 'Transfer' button).

#### [MODIFY] [Dashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/dashboard/Dashboard.tsx)
- Ensure the "Send" and "Transfer" buttons correctly link to the new `/wallet/transfer` route. Add a "Beneficiaries" link to the Navigation layout if appropriate.

---

## Verification Plan

### Automated Tests
- Validate TypeScript compilation (`npm run build`).
- Ensure no new linting errors are introduced.

### Manual Verification
- Navigate to the Beneficiaries page and test adding a new recipient.
- Start the Send Money flow.
- Verify the Quote engine correctly calculates `destinationAmount` based on the input amount, fee, and FX rate.
- Confirm that the final step creates a transfer and returns a mock success status.


# Sprint 3 Transfer Engine Tasks

- `[x]` Core Architecture
  - `[x]` Create `beneficiary.types.ts`, `beneficiary.api.ts`, `beneficiary.store.ts`
  - `[x]` Create `transfer.types.ts`, `transfer.api.ts`, `quote.api.ts`
  - `[x]` Create `transfer.store.ts`
- `[x]` UI Pages
  - `[x]` Create `src/pages/beneficiaries/Beneficiaries.tsx` (List & Add form)
  - `[x]` Create `src/pages/transfers/SendMoney.tsx` (Wizard flow)
- `[x]` Routing & Dashboard
  - `[x]` Update `src/routes/protected.tsx`
  - `[x]` Update Dashboard navigation links
- `[x]` Verification
  - `[x]` TypeScript build check
  - `[x]` UI flow validation


# Sprint 3 Walkthrough: Transfer Engine

We have successfully completed the **Sprint 3: Transfer Engine** frontend implementation! QuickSend has now evolved from a simple wallet into a fully functional remittance platform, allowing users to select beneficiaries, get real-time exchange quotes, and create transfers.

## What Was Built

### 1. Beneficiary Management System
- **State & Service:** Created a robust Zustand store (`beneficiary.store.ts`) with typed definitions and a fallback mocked service wrapper (`beneficiary.api.ts`).
- **Beneficiaries Page (`/beneficiaries`):**
  - Displays a clean, grid-based list of the user's saved recipients.
  - Implements dynamic iconography depending on the chosen payout method (`BANK`, `MOBILE_MONEY`, `CASH_PICKUP`).
  - Includes a beautiful modal form to add a new recipient with conditionally rendered inputs based on the payout method selected (e.g., hiding Bank Name when selecting Mobile Money).
  - Navigation added smoothly into the `Dashboard` header.

### 2. Send Money Wizard (Quote & Transfer)
- **State & Service:** Implemented the `quote.api.ts` and `transfer.api.ts` alongside a dedicated `transfer.store.ts`. The quote engine accurately simulates calculating FX Rates and static/percentage-based fees.
- **Wizard Flow (`/wallet/transfer`):**
  - **Step 1:** Users search through their saved list and select a beneficiary.
  - **Step 2:** Users input the amount they wish to send in USDT. The system validates against the active Wallet balance and triggers the `Quote API` to calculate exact fees, exchange rates, and the final payout amount (`destinationAmount`).
  - **Step 3:** A premium review screen breaks down the transaction costs clearly before final confirmation.
  - **Step 4:** Success screen providing the `referenceId` and smooth links to the Transactions history.

### 3. Verification
- Ensured all code conforms perfectly to TypeScript constraints (`verbatimModuleSyntax` rules maintained from previous sprints). 
- `npm run build` executed successfully with 0 errors!

## Next Steps
You can preview the changes by ensuring your development server is running:
```bash
c
```

Feel free to try creating a new beneficiary and running through the "Send" money flow from the Dashboard! Let me know when you are ready to proceed to the next phase!
