# Implement Sprint 5 - Treasury System (Frontend)

This plan outlines the frontend implementation of Sprint 5 for the QuickSend Web Application. Sprint 5 introduces the Treasury System — the institutional-grade liquidity engine responsible for managing USDT reserves across a hot/warm/cold wallet architecture, monitoring network balances, and enabling rebalancing operations.

## User Review Required

> [!IMPORTANT]
> **Mocking Backend Responses**
> All treasury API calls use a local mocked data layer with simulated network delays. The mock provides realistic wallet balances across 4 networks (TRON, ETH, SOLANA, POLYGON) with 3 wallet tiers each (HOT, WARM, COLD), including risk evaluation and sample treasury movements.

> [!WARNING]
> **Admin vs User Dashboard**
> The Treasury Dashboard is currently placed in the main app navigation. In production, this would likely be restricted to admin roles. The mock simulates institutional-level data for demonstration purposes.

## Open Questions

> [!TIP]
> Please advise on the following:
> 1. **Role-Based Access**: Should the Treasury Dashboard be restricted to admin users only? If so, we should build an admin role system.
> 2. **Real Rebalance Triggers**: The current "Rebalance" button triggers a mock API. In production, would you like this to actually move funds via blockchain RPC calls?

---

## Proposed Changes

### 1. Treasury Core Features Layer

#### [NEW] [treasury.types.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/treasury/treasury.types.ts)
- Define `WalletTier` (`HOT | WARM | COLD`), `Network` (`TRON | ETH | SOLANA | POLYGON`), `RiskLevel` (`STABLE | WARNING | CRITICAL`)
- Define `TreasuryWallet`, `LiquiditySnapshot`, `TreasuryMovement`, `TreasuryOverview`, `RebalanceResult`

#### [NEW] [treasury.api.ts](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/features/treasury/treasury.api.ts)
- Mock API with realistic wallet balances across all networks and tiers.
- `getOverview()` - returns total reserves, liquidity by network, risk levels, recent movements.
- `getWallets()` - returns all treasury wallet details.
- `triggerRebalance(network)` - simulates a rebalancing operation with 2s delay.

#### [NEW] [treasury.store.ts](file:///C:/Anderson.Quick.Money/QuickSend-Web/src/features/treasury/treasury.store.ts)
- Zustand store for treasury data: overview, wallets, movements, rebalance state.

---

### 2. Treasury Dashboard Page

#### [NEW] [TreasuryDashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/treasury/TreasuryDashboard.tsx)
- **Design**: Comprehensive financial dashboard with gradient header, network cards, and movement log.
- **Features**:
  - **Total Reserves Hero Card**: Shows aggregate USDT reserves across all networks with visual indicators.
  - **Network Breakdown Cards**: Per-network view with color-coded risk badges (STABLE/WARNING/CRITICAL). Each card shows proportional bar charts for HOT/WARM/COLD balances with individual amounts.
  - **Rebalance Button**: Per-network rebalancing trigger with loading state and success feedback.
  - **Treasury Movements Log**: Chronological list of recent inter-wallet transfers with directional icons.
  - **Liquidity Distribution Model**: Educational section explaining the hot/warm/cold architecture with visual cards.

---

### 3. Routing & Navigation

#### [MODIFY] [protected.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/routes/protected.tsx)
- Added route: `/treasury` → `<TreasuryDashboard />`

#### [MODIFY] [Dashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Web/src/pages/dashboard/Dashboard.tsx)
- Added "Treasury" link in the top navigation bar.

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/features/treasury/treasury.types.ts` | Treasury type definitions (wallets, networks, risk, movements) |
| `src/features/treasury/treasury.api.ts` | Treasury API with realistic mock data across 4 networks |
| `src/features/treasury/treasury.store.ts` | Zustand store for treasury state management |
| `src/pages/treasury/TreasuryDashboard.tsx` | Comprehensive treasury dashboard page |

### Modified Files
| File | Changes |
|------|---------|
| `src/routes/protected.tsx` | Added `/treasury` route |
| `src/pages/dashboard/Dashboard.tsx` | Added Treasury nav link |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (`npm run build`) — **PASSED**
- [x] No linting errors introduced

### Manual Verification
- Navigate to Dashboard and click "Treasury" nav link
- Verify total reserves hero card displays correctly
- Check each network card shows correct HOT/WARM/COLD balances with proportional bars
- Click "Rebalance" on a network and observe loading state + success message
- Scroll through the treasury movements log
- Verify the liquidity distribution model section is informative and well-styled

---

# Sprint 5 Treasury System Tasks

- `[x]` Core Architecture
  - `[x]` Create `treasury.types.ts` (WalletTier, Network, RiskLevel, etc.)
  - `[x]` Create `treasury.api.ts` with realistic mock data (4 networks x 3 tiers)
  - `[x]` Create `treasury.store.ts`
- `[x]` UI Pages
  - `[x]` Create `src/pages/treasury/TreasuryDashboard.tsx` (comprehensive dashboard)
- `[x]` Routing & Navigation
  - `[x]` Update `src/routes/protected.tsx` with `/treasury`
  - `[x]` Update `src/pages/dashboard/Dashboard.tsx` nav with Treasury link
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Full UI flow validation ready
