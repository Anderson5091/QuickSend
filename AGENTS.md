# QuickSend — Agent Instructions

## Project Layout
```
admin-app/        React + Vite admin frontend
web-app/          Web frontend
backend-app/      Express + TypeScript backend (source of truth)
rail-backend/     Mirror of backend-app deployed to Railway (separate git repo)
```

## Monorepo Key Facts
- **admin-app**: Vite + React, Zustand stores, axios client, Tailwind CSS
- **backend-app**: Express, Prisma (Postgres), JWT auth, rate limiting, WAF
- **rail-backend**: NOT built independently — synced via `sync-to-rail.ps1` from `backend-app/`
- `rail-backend/` is its own git repo; Railway auto-deploys on push to its remote

## Deploy Pipeline (Critical)
1. Edit source in `backend-app/src/`
2. Run `../sync-to-rail.ps1` (or `npm run sync`) from `backend-app/` → copies `src/` + configs to `rail-backend/`
3. To deploy: `sync-to-rail.ps1 -Push` (or `npm run sync:push`) → commits rail-backend + submodule, pushes both
4. Railway builds from `rail-backend/Dockerfile`: `npm install → prisma generate → npm run build (tsc) → node dist/server.js`

**Gotcha**: `backend-app/dist/` is stale. Railway generates `dist/` at build time from the Dockerfile. The running backend is always `rail-backend/` deployed on Railway.

## Development Commands
| Action | Directory | Command |
|--------|-----------|---------|
| Frontend dev server | `admin-app/` | `npm run dev` (vite) |
| Backend dev server | `backend-app/` | `npm run dev` (tsx watch) |
| TypeScript check | `admin-app/` or `backend-app/` | `npx tsc --noEmit` |
| Build backend | `backend-app/` | `npm run build` (tsc → dist/) |
| DB push (Railway) | Auto in `preDeployCommand` | `npx prisma db push --accept-data-loss` |
| Generate Prisma client | `backend-app/` | `npx prisma generate` |

## Critical Architecture Notes
- All routes mounted under `/api/v1/` (e.g., `/admin/transfers` → `/api/v1/admin/transfers`)
- Admin API requires role middleware: `requireRole("SUPER_ADMIN", "ADMIN", ...)`
- **Auth check**: `authenticate` middleware decodes JWT → sets `req.userId`, `req.userRole`; returns 401 if invalid
- **Role check**: `requireRole()` returns 403 if user role not in allowed list
- Both `backend-app/` and `rail-backend/` have `src/` files. `rail-backend/` may be out of sync if sync script hasn't been run.

## API Client (Frontend)
- `admin-app/src/api/client.ts`: axios instance with `baseURL: ENV.API_URL` (default: `https://corequicksend.up.railway.app/api/v1`)
- Auth token attached via `Authorization: Bearer <token>` header
- All admin endpoints work through `AdminApi` or `AgentApi` service objects

## Common Gotchas
- If an admin page shows "No data" but the dashboard says data exists: the API endpoint likely doesn't exist on the **deployed** backend. Run sync + push to get latest code to Railway.
- If API returns 401 (Unauthorized): check if JWT is valid, not expired, and route exists in the deployed backend's `dist/`
- If API returns 403 (Forbidden): current user role isn't in the route's `requireRole(...)` list
- The `rail-backend/dist/` on disk may differ from what Railway serves. Railway builds fresh from source.
- Route changes in `backend-app/src/` need sync + push to reach production

## Progress
### Done
- Reverted changes to enforce separate rows for transfer and activity (payout) in agent activity:
  - Backend endpoint `GET /agent/:id/transactions` returns raw transaction types (TRANSFER and PAYOUT) without enrichment.
  - Frontend AgentActivity.tsx renders each transaction as a row with its type (TRANSFER or PAYOUT) and does not merge or add extra payout status columns.
  - This ensures that transfers and payouts appear as distinct rows in the activity feed, allowing users to see both types separately.
