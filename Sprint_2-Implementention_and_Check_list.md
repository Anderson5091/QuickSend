# Implement Sprint 2 - Wallet System (Frontend)

This plan outlines the frontend implementation of Sprint 2 for the QuickSend Web Application. Sprint 2 focuses on building out the "Wallet System", allowing users to view balances, generate deposit addresses with QR codes, request withdrawals, and view their transaction history. 

In line with the project's aesthetics guidelines, the new wallet pages will feature premium modern fintech designs, including vibrant gradients, micro-animations, glassmorphic cards, and responsive mobile-first layouts.

## User Review Required

> [!IMPORTANT]
> **API Endpoints Strategy**
> The backend for Sprint 2 is detailed in the design document, but it might not be built or fully operational yet. By default, I will configure the services to fetch from the actual API endpoints (e.g. `/api/v1/wallet`). If the backend is not yet available, please let me know if you would like me to build a mock service layer using `setTimeout` and local state, so that we can demonstrate and test the UI immediately.

> [!TIP]
> **Dependency Installation**
> We will be adding `qrcode.react` to generate dynamic QR codes for the deposit addresses. If you have any objections or prefer an alternative package, please let me know. We will also add `lucide-react` if it is not already installed to utilize clean SVG icons across the app.

## Open Questions

> [!WARNING]
> Please advise on the following:
> 1. **Navigation**: How should the user navigate between Dashboard, Wallet Home, Deposit, Withdraw, and Transactions? Should we add a bottom navigation bar for mobile or a side-nav/top-nav for desktop? 
> 2. **Mocking Backend**: Do you want me to mock the wallet API responses so the frontend can be fully interactive without a backend?

---

## Proposed Changes

### 1. Dependencies Setup
- Install `qrcode.react` for the Deposit address QR Code generator.
- Verify `lucide-react` is installed for premium iconography.

---

### 2. Wallet Core Features Layer
We will implement the wallet domain using the same production-ready architecture from Sprint 1.

#### [NEW] [wallet.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/wallet/wallet.types.ts)
- Define `Wallet` type (currency, availableBalance, pendingBalance).
- Define `Transaction` type (id, type, amount, network, status, timestamp).
- Define `DepositAddress` type (network, address).

#### [NEW] [wallet.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/wallet/wallet.api.ts)
- Axios API definitions: `getWallet()`, `getAddresses()`, `getTransactions()`, `withdraw()`, `internalTransfer()`.

#### [NEW] [wallet.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/wallet/wallet.service.ts)
- Service wrapper handling API errors and standardizing responses.

#### [NEW] [wallet.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/wallet/wallet.store.ts)
- Zustand store to manage the wallet state, balances, and deposit addresses so the user doesn't face loading screens repeatedly when navigating between wallet tabs.

---

### 3. Wallet UI Pages

#### [NEW] [WalletHome.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/wallet/WalletHome.tsx)
- **Design**: Premium glassmorphic hero card showing Total USDT Balance.
- **Features**: Quick action buttons (Deposit, Withdraw, Transfer) leading to respective pages. Brief preview of the latest 3 transactions. 

#### [NEW] [Deposit.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/wallet/Deposit.tsx)
- **Design**: Sleek layout with network selection tabs (TRON, ETH, POLYGON, SOLANA).
- **Features**: Displays dynamic QR Code via `qrcode.react`, formatted wallet address, and quick "Copy to Clipboard" with a success toast/animation.

#### [NEW] [Withdraw.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/wallet/Withdraw.tsx)
- **Design**: Modern form layout with clear step-by-step inputs.
- **Features**: Input fields for Destination Address, Network Selection, and Amount. Dynamic fee preview calculation, OTP validation simulation, and a sleek submit button with loading states.

#### [NEW] [Transactions.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/wallet/Transactions.tsx)
- **Design**: Clean list view with status indicators (Pending = Yellow, Completed = Green, Failed = Red).
- **Features**: Detailed list of deposits, withdrawals, and internal transfers, with dates, transaction hashes (shortened), and amounts.

---

### 4. Routing System

#### [MODIFY] [protected.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/routes/protected.tsx)
- Add new routes for the wallet module under the ProtectedRoute guard:
  - `/wallet` -> `<WalletHome />`
  - `/wallet/deposit` -> `<Deposit />`
  - `/wallet/withdraw` -> `<Withdraw />`
  - `/wallet/transactions` -> `<Transactions />`

#### [MODIFY] [Dashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/dashboard/Dashboard.tsx)
- Update the Dashboard to include actual links/buttons navigating to the new Wallet routes.

---

## Verification Plan

### Automated Tests
- Validate TypeScript compilation (`npm run build`).
- Ensure no new linting errors are introduced.

### Manual Verification
- Start the dev server (`npm run dev`) and test navigation to the Wallet module.
- Check Wallet Home for aesthetic layout and accurate balance display (from mock or real API).
- Test the Deposit page, select different networks, ensure the QR code and address update dynamically, and click "Copy" to verify clipboard logic.
- Navigate to the Withdraw page, fill out the form to ensure validation logic catches empty fields.
- Test the Transactions history page layout.
- Confirm mobile responsiveness on all new screens using Chrome DevTools device mode.


# Sprint 2 Wallet System Tasks

- `[x]` Install Dependencies
  - `[x]` Install `qrcode.react` and `lucide-react`
- `[x]` Define Types & Store
  - `[x]` Create `src/features/wallet/wallet.types.ts`
  - `[x]` Create `src/features/wallet/wallet.api.ts`
  - `[x]` Create `src/features/wallet/wallet.service.ts` (with Mocking)
  - `[x]` Create `src/features/wallet/wallet.store.ts`
- `[x]` Create Wallet Pages
  - `[x]` Create `src/pages/wallet/WalletHome.tsx`
  - `[x]` Create `src/pages/wallet/Deposit.tsx`
  - `[x]` Create `src/pages/wallet/Withdraw.tsx`
  - `[x]` Create `src/pages/wallet/Transactions.tsx`
- `[x]` Routing & Navigation
  - `[x]` Update `src/routes/protected.tsx`
  - `[x]` Create responsive navigation layout (Top Nav / Bottom Nav)
- `[x]` Verification
  - `[x]` Check build
  - `[x]` Manual UI testing


# Sprint 2 Walkthrough: Wallet System 

We successfully completed the frontend deliverables for Sprint 2! QuickSend now features a premium, interactive wallet system that enables users to view balances, generate deposit addresses with QR codes, request withdrawals, and check their transaction histories.

## Features Implemented

### 1. Wallet State Management
- Integrated Zustand to manage the `wallet.store.ts` state.
- Implemented `WalletService` with a realistic mocked API layer (with loading delays) so the UI can be fully tested while the backend is being finalized.
- Defined robust types `Wallet`, `DepositAddress`, and `Transaction` in `wallet.types.ts`.

### 2. Premium Wallet Screens
All screens follow the premium, mobile-first design system utilizing gradients, micro-animations, and clean typography:

- **Dashboard Upgrade**: 
  - Connected the Dashboard to the live wallet store so that it properly renders the user's mock USDT balance.
  - Quick action buttons now link to the respective new Wallet pages.
  - The latest transactions feed dynamically fetches from the Wallet Store.
  
- **Wallet Home (`/wallet`)**:
  - Displays a premium glassmorphic hero card showing the Total USDT Balance.
  - Provides quick action links to Deposit, Withdraw, Transfer, and History.

- **Deposit Page (`/wallet/deposit`)**:
  - Lets users switch between different networks (TRON, ETHEREUM, POLYGON, SOLANA).
  - Dynamically renders a QR code for the specific network using `qrcode.react`.
  - Copy-to-clipboard functionality with a nice visual feedback (changing to a checkmark).

- **Withdraw Page (`/wallet/withdraw`)**:
  - Form layout for users to pick a destination address, network, and amount.
  - Simulates dynamic network fees and shows exactly how much the user will receive.
  - Performs max amount validation against the active balance.

- **Transaction History (`/wallet/transactions`)**:
  - Clean list of recent transfers, deposits, and withdrawals.
  - Beautiful visual categorization (Blue for deposits, Red/Purple for withdrawals, Green for transfers).

### 3. Architecture Health
- Successfully fixed leftover `verbatimModuleSyntax` TypeScript errors from Sprint 1 ensuring type safety across the entire API and service layers.
- The React application (`vite build` & `tsc`) successfully builds with 0 errors.

## Next Steps
You can run the development server via:
```bash
npm run dev
```

Feel free to click around the Dashboard and Wallet screens! Once you're ready, we can move forward to **Sprint 3: Transfer Engine**.
