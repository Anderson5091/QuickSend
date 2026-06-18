# Implement Sprint 10 — Admin Live Dashboard

This plan outlines the implementation of Sprint 10 for the QuickSend ecosystem. Sprint 10 delivers the **Admin Live Dashboard** — a real-time operations center with live transaction feed, system monitoring, and instant WebSocket-driven updates.

## User Review Required

> [!IMPORTANT]
> **Real-Time Updates**
> The dashboard updates automatically via WebSocket push — no page refresh required. The live transaction feed appears both on the main Dashboard page and the dedicated Live Feed page.

> [!WARNING]
> **Static Mock Data**
> The KPI panel (Total Users, Volume, etc.) still uses REST-polled mock data. When connected to a live backend, WebSocket KPI updates will override the static values in real-time.

---

## Proposed Changes

### 1. Dashboard Live Transaction Feed

#### [MODIFY] [Dashboard.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/pages/admin/Dashboard.tsx)
- Added **Live Transactions** card alongside Active Alerts
- Shows the last 15 transactions from the WebSocket stream
- Each transaction shows: reference ID, amount, status (color-coded), payout method, timestamp
- Empty state: "Waiting for transactions..." when stream is idle
- Live/disconnected indicator in the dashboard header
- Status color mapping: PENDING_PAYOUT (amber), SENT_TO_PARTNER (blue), COMPLETED (emerald), FAILED (rose)
- Connects to `useAdminStreamStore` for real-time data

### 2. Live Feed Page

#### [NEW] [LiveFeed.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/pages/admin/LiveFeed.tsx)
- Full-screen live transaction monitor
- **Main Panel** (3/4 width):
  - Transaction feed with auto-scroll
  - System events feed (all ADMIN_EVENT types)
- **Side Panel** (1/4 width):
  - System Status: event count, active admins, connected users, uptime
  - Payout Updates: real-time payout status changes
  - Alerts: severity-coded live alerts (last 5)
- Clear Feed button
- Live/Disconnected badge

### 3. WebSocket Streaming Infrastructure

#### [NEW] [ws.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/features/admin/ws.service.ts)
- WebSocket client connected to backend's `/ws` endpoint
- JWT token authentication via query parameter
- Message dispatch to appropriate store handlers
- Auto-reconnect on connection loss (5 second delay)
- Heartbeat ping/pong every 30 seconds

#### [NEW] [stream.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/features/admin/stream.store.ts)
- Zustand store for all real-time streaming data
- Capped arrays: 100 transactions, 50 payout updates, 20 alerts, 50 system events

### 4. Integration

#### [MODIFY] [AdminLayout.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/pages/admin/AdminLayout.tsx)
- WebSocket connection lifecycle (connect on mount, disconnect on unmount)
- Live connection indicator (green/red dot) in sidebar
- "Live Feed" navigation item added with Radio icon
- Pulsing green dot on Live Feed nav when connected

#### [MODIFY] [routes/index.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/routes/index.tsx)
- Added `/live` route → `<LiveFeed />` component

---

## Deliverables Summary

### New Files Created
| File | Purpose |
|------|---------|
| `src/features/admin/ws.service.ts` | WebSocket client with auto-reconnect |
| `src/features/admin/stream.store.ts` | Zustand store for stream data |
| `src/pages/admin/LiveFeed.tsx` | Full live transaction monitor page |

### Modified Files
| File | Changes |
|------|---------|
| `src/pages/admin/Dashboard.tsx` | Live transaction feed card + status indicator |
| `src/pages/admin/AdminLayout.tsx` | WebSocket lifecycle + Live Feed nav + connection indicator |
| `src/routes/index.tsx` | `/live` route added |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (Admin) — **PASSED**

### Manual Verification
- Navigate to Dashboard → verify Live Transactions card appears
- Verify empty state shows "Waiting for transactions..."
- Navigate to `/live` → verify full live feed page
- Verify Live/Disconnected badge reflects WebSocket status
- Verify system status panel shows event count, connected users, uptime
- Click "Clear Feed" → verify feed resets
- Verify payout updates appear in side panel
- Verify alerts appear with severity color coding
- Verify sidebar connection indicator matches WebSocket state

---

# Sprint 10 Admin Live Dashboard Tasks

- `[x]` Dashboard Live Feed
  - `[x]` Add Live Transactions card to Dashboard
  - `[x]` Integrate with useAdminStreamStore
  - `[x]` Empty state handling
  - `[x]` Status color mapping
- `[x]` Live Feed Page
  - `[x]` Create LiveFeed.tsx
  - `[x]` Transaction feed with auto-scroll
  - `[x]` System events feed
  - `[x]` System status panel
  - `[x]` Payout updates panel
  - `[x]` Alerts panel
  - `[x]` Clear Feed button
- `[x]] WebSocket Infrastructure
  - `[x]` Create ws.service.ts
  - `[x]` Auto-reconnect
  - `[x]` Heartbeat
  - `[x]` Message dispatch
- `[x]` Stream Store
  - `[x]` Create stream.store.ts
  - `[x]` Capped arrays for all data types
- `[x]` Layout & Routing
  - `[x]` WebSocket lifecycle in AdminLayout
  - `[x]` Live Feed nav item
  - `[x]` Connection indicator
  - `[x]` `/live` route
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
  - `[x]` Full dashboard flow validation ready
