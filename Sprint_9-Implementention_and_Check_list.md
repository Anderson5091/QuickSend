# Implement Sprint 9 — Real-Time WebSocket System

This plan outlines the implementation of Sprint 9 for the QuickSend ecosystem. Sprint 9 upgrades the WebSocket server with **admin-specific channels**, creates an **event streaming service** that pushes real-time data to connected admin dashboards, and adds a WebSocket client + live transaction feed to the Admin Frontend.

## User Review Required

> [!IMPORTANT]
> **Admin WebSocket Role Detection**
> The WebSocket server reads the `role` from the JWT token. Admin roles (`SUPER_ADMIN`, `ADMIN`, `COMPLIANCE`, `OPS`, `TREASURY`) automatically join the admin broadcast group. Regular users only see their own events.

> [!WARNING]
> **Connection Requirements**
> The admin client connects to `ws://localhost:3001/ws?token=<jwt>`. The WebSocket server is on the same HTTP server as Express. Auto-reconnect is built in with a 5-second delay.

---

## Proposed Changes

### 1. WebSocket Server — Admin Channels

#### [MODIFY] [ws.handler.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/websocket/ws.handler.ts)
- Reads `role` from JWT token (`decoded.role`)
- Maintains `adminSockets: Set<AuthenticatedSocket>` — all admin connections
- Auto-joins admin sockets to admin group if role is in `ADMIN_ROLES`
- `broadcastToAdmins(data)` — sends only to admin sockets
- `getAdminCount()` / `getConnectedUserCount()` — metrics for system status
- Supports `SUBSCRIBE` message type for future channel expansion
- Pings admin count and user count on connect/disconnect

### 2. Event Streaming Service

#### [NEW] [event-stream.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/services/event-stream.service.ts)
- `streamToAdmin(eventType, data)` — generic admin event push
- `streamLiveTransaction(transaction)` — real-time transfer data
- `streamPayoutUpdate(payout)` — payout status changes
- `streamKpiUpdate(kpis)` — live KPI counter updates
- `streamAlert(severity, message)` — real-time alert push
- `broadcastSystemStatus()` — event count, connected admins/users, uptime

### 3. Event Emitter Integration

#### [MODIFY] [event.emitter.ts](file:///C:/Anderson/Quick.Money/QuickSend-Backend/src/modules/events/event.emitter.ts)
- After persisting event, calls `broadcastToAll({ type: "EVENT", eventType, payload, timestamp })`
- All system events are automatically streamed to all connected WebSocket clients

### 4. Admin Frontend — WebSocket Client

#### [NEW] [ws.service.ts](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/features/admin/ws.service.ts)
- `connectAdminStream()` — creates WebSocket to backend with JWT token
- Handles `onmessage` dispatches to stream store:
  - `LIVE_TRANSACTION` → adds to transaction feed
  - `PAYOUT_UPDATE` → adds to payout updates
  - `KPI_UPDATE` → updates KPI counters
  - `ALERT` → adds to alert feed
  - `ADMIN_EVENT` / `EVENT` → adds to system events list
  - `SYSTEM_STATUS` → updates system status
- `disconnectAdminStream()` — clean shutdown
- Auto-reconnect with 5s delay on disconnect
- Heartbeat ping every 30s

#### [NEW] [stream.store.ts](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/features/admin/stream.store.ts)
- Zustand store with arrays for: `liveTransactions`, `payoutUpdates`, `alerts`, `adminEvents`
- `kpis` record and `systemStatus` data
- All arrays capped (100 transactions, 50 payouts, 20 alerts, 50 events)
- `connected` boolean flag

### 5. Admin Frontend — Layout Integration

#### [MODIFY] [AdminLayout.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/pages/admin/AdminLayout.tsx)
- Connects to WebSocket stream on mount, disconnects on unmount
- Displays live/connected indicator with green/red dot in sidebar
- "Live Feed" nav item with pulsing green dot when connected
- Footer shows connection status text

### 6. Admin Live Feed Page

#### [NEW] [LiveFeed.tsx](file:///C:/Anderson/Quick.Money/QuickSend-Admin/src/pages/admin/LiveFeed.tsx)
- **Transaction Feed**: Scrollable list of live transactions with reference ID, amount, status, payout method, timestamp
- **System Events**: All `ADMIN_EVENT` types with event type and entity info
- **System Status Panel**: Event count, active admins, connected users, uptime
- **Payout Updates**: Side panel with payout status changes
- **Alerts**: Side panel with severity-coded real-time alerts
- Clear Feed button to reset local state
- Live/disconnected indicator in header

---

## Deliverables Summary

### New Files Created (Backend)
| File | Purpose |
|------|---------|
| `src/services/event-stream.service.ts` | Admin-targeted event streaming |

### New Files Created (Admin Frontend)
| File | Purpose |
|------|---------|
| `src/features/admin/ws.service.ts` | WebSocket client with auto-reconnect |
| `src/features/admin/stream.store.ts` | Zustand store for stream data |
| `src/pages/admin/LiveFeed.tsx` | Live transaction feed page |

### Modified Files
| File | Changes |
|------|---------|
| `src/websocket/ws.handler.ts` | Admin role detection, admin sockets set, broadcastToAdmins |
| `src/modules/events/event.emitter.ts` | WebSocket broadcast on event emit |
| `src/pages/admin/AdminLayout.tsx` | WebSocket connect/disconnect, live indicator, Live Feed nav |

---

## Verification Plan

### Automated Tests
- [x] TypeScript compilation (Backend) — **PASSED**
- [x] TypeScript compilation (Admin) — **PASSED**

### Manual Verification
- Log in to admin panel → verify green "Live" indicator in sidebar
- Navigate to `/live` → verify empty state shows "Waiting for transactions..."
- Create a transfer via backend → verify it appears in the live feed
- Verify system status panel shows event count and uptime
- Disconnect WebSocket → verify red "Disconnected" indicator
- Reconnect → verify green indicator returns

---

# Sprint 9 Real-Time System Tasks

- `[x]` Backend WebSocket
  - `[x]` JWT role detection in ws.handler.ts
  - `[x]` Admin sockets set + broadcastToAdmins
  - `[x]` getAdminCount / getConnectedUserCount
- `[x]` Event Streaming
  - `[x]` Create event-stream.service.ts
  - `[x]` streamToAdmin, streamLiveTransaction, streamPayoutUpdate
  - `[x]` streamAlert, broadcastSystemStatus
- `[x]` Event Emitter Broadcast
  - `[x]` WebSocket broadcast on every event emit
- `[x]` Admin WebSocket Client
  - `[x]` Create ws.service.ts with connect/disconnect
  - `[x]] Auto-reconnect with 5s delay
  - `[x]` Heartbeat ping every 30s
- `[x]` Admin Stream Store
  - `[x]` Create stream.store.ts
  - `[x]` Live transactions, payout updates, alerts, events, kpis, system status
- `[x]` Admin Layout
  - `[x]` WebSocket connect on mount, disconnect on unmount
  - `[x]` Live indicator with green/red dot
  - `[x]` Live Feed nav item with pulsing dot
- `[x]` Live Feed Page
  - `[x]` Create LiveFeed.tsx with transaction feed, events, status
- `[x]` Verification
  - `[x]` TypeScript build check (0 errors)
