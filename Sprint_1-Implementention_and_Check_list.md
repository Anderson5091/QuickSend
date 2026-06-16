# Implement Sprint 1 - Authentication & App Foundation

This plan outlines the implementation of Sprint 1 for the QuickSend Web application. We will set up the core tech stack (Tailwind CSS, Zustand, React Query, React Router, Axios) and implement a premium mobile-first web interface for the Authentication flow (Login, Register) and the Home page shell.

## User Review Required

> [!IMPORTANT]
> **Aesthetic Styling & Tailwind CSS Version:**
> We will configure the application using Tailwind CSS. Please clarify if you prefer Tailwind CSS v3 (as detailed in the setup commands in the spec) or the latest Tailwind CSS v4.
> We will also implement a premium modern fintech design system (curated gradient colors, rounded cards, glassmorphic effects, outfit/inter typography, and subtle micro-animations) to ensure the application looks exceptional.

> [!WARNING]
> **Minimal vs. Production-Grade Sprint 1:**
> The `QuickSend_Devellopment.md` file contains two versions of Sprint 1:
> 1. **Minimal Shell**: Simple structure directly using `src/pages/Login.tsx`, `src/pages/Register.tsx`, `src/pages/Home.tsx`, and `src/store/authStore.ts`.
> 2. **Production-Grade**: Deep feature-based structure with route guards (`ProtectedRoute`, `PublicRoute`), service layers (`AuthService`), custom api client interceptors, config folders, layouts, and reusable components (`Button`, `Input`, `Card`).
>
> We recommend implementing the **Production-Grade** structure since it forms a robust and scalable architecture for the subsequent sprints (USDT wallets, Payout, Treasury, Compliance).

## Open Questions

> [!IMPORTANT]
> Please review and advise on the following:
> 1. **Tailwind CSS version**: Should we install Tailwind v3 or Tailwind v4?
> 2. **Structure selection**: Should we go with the **Production-Grade** structure (recommended) or the **Minimal Shell**?
> 3. **API endpoint URL**: The client is configured with `https://api.quicksend.com/api/v1` as default. Should we keep it or change it to `http://localhost:5000/api/v1` for local development?

---

## Proposed Changes

### Dependencies & Setup
We need to install the required npm dependencies to support Zustand, React Query, React Router, Axios, Zod, and React Hook Form.

#### [MODIFY] [package.json](file:///C:/Anderson/QuickSend-Web/package.json)
- Add required dependencies: `axios`, `react-router-dom`, `zustand`, `@tanstack/react-query`, `react-hook-form`, `zod`, `@hookform/resolvers`, `lucide-react` (for icons).
- Add devDependencies: `tailwindcss`, `postcss`, `autoprefixer` if Tailwind v3 is selected.

---

### Configuration & Core Layer

#### [NEW] [env.ts](file:///C:/Anderson/QuickSend-Web/src/config/env.ts)
- Define standard environment variables accessor.

#### [NEW] [constants.ts](file:///C:/Anderson/QuickSend-Web/src/config/constants.ts)
- Core app constants (token storage keys, network names, etc.).

#### [NEW] [client.ts](file:///C:/Anderson/QuickSend-Web/src/api/client.ts)
- Base Axios client configuration.

#### [NEW] [interceptors.ts](file:///C:/Anderson/QuickSend-Web/src/api/interceptors.ts)
- Request/response interceptors to attach the JWT bearer token automatically.

#### [NEW] [auth.api.ts](file:///C:/Anderson/QuickSend-Web/src/api/auth.api.ts)
- API endpoint calls for `login`, `register`, `logout`, `refresh`, and `me`.

#### [NEW] [token.ts](file:///C:/Anderson/QuickSend-Web/src/utils/token.ts)
- Secure localStorage wrappers for access token management.

---

### State Management & Services

#### [NEW] [auth.store.ts](file:///C:/Anderson/QuickSend-Web/src/features/auth/auth.store.ts)
- Zustand auth store keeping track of current user profile, token, and authentication state.

#### [NEW] [auth.service.ts](file:///C:/Anderson/QuickSend-Web/src/features/auth/services/auth.service.ts)
- Business logic layer separating component code from raw API requests.

---

### UI Components & Layouts

#### [NEW] [Button.tsx](file:///C:/Anderson/QuickSend-Web/src/components/ui/Button.tsx)
- Reusable button component with loading state, variant styles (primary, secondary), and hover animations.

#### [NEW] [Input.tsx](file:///C:/Anderson/QuickSend-Web/src/components/ui/Input.tsx)
- Reusable input component with error helper text, labels, focus states, and styling.

#### [NEW] [Card.tsx](file:///C:/Anderson/QuickSend-Web/src/components/ui/Card.tsx)
- Styled container for forms and status displays.

#### [NEW] [ProtectedRoute.tsx](file:///C:/Anderson/QuickSend-Web/src/components/guards/ProtectedRoute.tsx)
- Route guard redirecting unauthenticated users to `/login`.

#### [NEW] [PublicRoute.tsx](file:///C:/Anderson/QuickSend-Web/src/components/guards/PublicRoute.tsx)
- Route guard preventing authenticated users from accessing login/register pages (redirecting them to `/dashboard`).

---

### Pages & Routing

#### [NEW] [Login.tsx](file:///C:/Anderson/QuickSend-Web/src/pages/auth/Login.tsx)
- Sleek, modern mobile-first login page with form validation, error states, and responsive styling.

#### [NEW] [Register.tsx](file:///C:/Anderson/QuickSend-Web/src/pages/auth/Register.tsx)
- Account creation screen matching the registration fields (Email, Password, Password confirmation).

#### [NEW] [Home.tsx](file:///C:/Anderson/QuickSend-Web/src/pages/Home.tsx) or [Dashboard.tsx](file:///C:/Anderson/QuickSend-Web/src/pages/dashboard/Dashboard.tsx)
- Authenticated app home shell showing user email, USDT balance card, quick actions (Deposit, Send, Withdraw, History), and recent transactions list.

#### [NEW] [index.tsx](file:///C:/Anderson/QuickSend-Web/src/routes/index.tsx)
- Main router file declaring routes and wrapping them in route guards.

#### [MODIFY] [App.tsx](file:///C:/Anderson/QuickSend-Web/src/App.tsx)
- Set up RouterProvider.

#### [MODIFY] [main.tsx](file:///C:/Anderson/QuickSend-Web/src/main.tsx)
- Initialize QueryClientProvider and interceptor bindings.

#### [MODIFY] [index.css](file:///C:/Anderson/QuickSend-Web/src/index.css)
- Tailwind base/components/utilities and base style overrides.

#### [NEW] [.env](file:///C:/Anderson/QuickSend-Web/.env)
- Environment file containing configuration options.

---

## Verification Plan

### Automated Tests
- Validate TypeScript compilation (`npm run build`).
- Verify ESLint configuration check (`npm run lint`).

### Manual Verification
- Launch local development server (`npm run dev`).
- Test registration flow.
- Test login flow and persistence (refreshing the page).
- Verify route guards (trying to access `/dashboard` when logged out, and `/login` when logged in).
- Verify responsive layout matches premium mobile-first aesthetics.

# Sprint 1 Implementation Checklist

- [ok] Install dependencies and devDependencies
- [ok] Setup Tailwind CSS configuration
- [ok] Create environment configuration and Axios API client
- [ok] Implement secure token storage utility
- [ok] Setup Zustand auth store and auth service layer
- [ok] Create layout components and route guards (Protected and Public routes)
- [ok] Create reusable UI components (Button, Input, Card, etc.) with premium styling
- [ok] Implement Register, Login, and Dashboard pages
- [ok] Setup React Router navigation configuration
- [ok] Integrate React Query and client setup in main entrypoints
- [ok] Verify build and test locally

