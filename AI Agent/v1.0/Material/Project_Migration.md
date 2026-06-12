# Project Migration: Next.js (Web) to Native iOS (Swift/SwiftUI)

This document details the migration of the **DonateNow** application from a Next.js web application to a fully native iOS application.

---

## 1. Migration Overview & Objectives

The primary goal of the migration was to transition the DonateNow platform from a web-based client (Next.js) to a high-performance, native iOS experience.

### Key Objectives
* **Enhanced User Experience**: Provide fluid, native UI components (using SwiftUI) with smooth springs, hover animations, and gesture-driven actions.
* **Security Hardening**: Move sensitive operations (Razorpay order creation and webhook verification) out of client-side code and into secure Supabase Edge Functions. Secure admin authentication states using the native iOS Keychain.
* **Mobile Payments Integration**: Utilize the native **Razorpay iOS SDK** for a seamless, on-device payment sheet (UPI, Cards, Netbanking) instead of web-based redirects.
* **Universal Layout**: Implement adaptive SwiftUI layouts suitable for both iPhone and iPad viewports.

---

## 2. Tech Stack Comparison

| Architectural Layer | Legacy Web Stack (Next.js) | Migrated Native iOS Stack | Rationale |
| :--- | :--- | :--- | :--- |
| **Frontend Framework** | Next.js (React) / Tailwind CSS | **SwiftUI** (Swift 5.9+) | Native rendering, smooth animations, and platform-specific UI integration. |
| **State Management** | React hooks (`useState`, `useContext`) | **MVVM Pattern** (`@Observable` models) | Clean separation of views, business logic, and UI states. |
| **Backend Integration** | Next.js API Routes | **Supabase Swift SDK** | Real-time database synchronizations, email auth, and native API execution. |
| **Secure Key Storage** | Browser `localStorage` | **iOS Keychain Services** | Hardware-backed cryptographic security for session tokens. |
| **Payment Interface** | Web Checkout Redirect / API | **Razorpay iOS SDK** | Fluid, quick, and native checkout sheet matching iOS UX guidelines. |
| **Custom Server Logic**| Next.js Serverless Functions | **Supabase Edge Functions** (Deno/TS) | Keeps private API secrets off-device and verifies payment signatures. |

---

## 3. Database & Backend Changes

To support the native iOS client, the database schema and backend APIs were adapted:

1. **Supabase Edge Functions**:
   * `create-order`: Generates a secure Razorpay order token server-side.
   * `verify-payment`: Validates the signature of completed transactions and writes records to the `donations` table.
   * `razorpay-webhook`: Listens to asynchronous events from Razorpay to guarantee database consistency in case the app enters the background during checkout.
2. **Row-Level Security (RLS) & Permissions**:
   * Postgres table-level `SELECT` and `INSERT` grants were re-configured to allow the `service_role` (used by Edge Functions) and authenticated administrators to fetch logs.
   * A synchronization trigger was established to automatically link authenticated users with the `admin_users` table.
3. **Database Constraints Handling**:
   * Client View-Models were updated to pass a `nil` `cause_id` for mock/local test transactions, preventing foreign key constraint violations while testing with a clean remote DB.

---

## 4. UI Components & Architecture Migration

Below is the mapping of components from the legacy web architecture to the new native iOS code:

### Directory Mapping

```
Legacy Web (Next.js)                 ───►   Migrated iOS (Xcode Project)
src/pages/index.js (Donation UI)     ───►   src/Frontend/DonateNow/DonateNow/Views/Public/DonationView.swift
src/components/CauseCard.js          ───►   src/Frontend/DonateNow/DonateNow/Views/Components/CauseCardView.swift
src/pages/admin/dashboard.js         ───►   src/Frontend/DonateNow/DonateNow/Views/Admin/AdminDashboardView.swift
src/pages/admin/logs.js              ───►   src/Frontend/DonateNow/DonateNow/Views/Admin/DonorLogView.swift
src/api/verify.js                    ───►   src/Backend/functions/verify-payment/index.ts
```

### Key UI Features Re-engineered:
* **Glow Metrics Card**: Created a SwiftUI linear gradient overlay with soft drop-shadows and real-time font scaling for total donation values.
* **Goal Progress Cards**: Programmed entrance transitions where progress bars animate their width from 0% to the target percentage dynamically upon loading.
* **Skeleton Shimmers**: Added a custom reusable `.shimmer()` ViewModifier to present smooth loading state representations during API calls.
* **Deterministic Avatars**: Implemented a color hash utility to assign distinct, persistent avatar backgrounds to donors based on their names.

---

## 5. Verification & Testing Strategy

Verification of the migration was done via a multi-tier testing pipeline:
1. **Unit Tests (Swift Testing)**: Checks helper logic including validations (email/amount formatters) and model JSON parsing.
2. **Integration Tests (Swift Testing)**: Verifies live HTTP connections to Supabase and Edge Function responses (including bad request error parsing).
3. **UI Tests (XCUITest)**: Automates navigation pathways (Donation form completion, simulator payment validation, and Admin console access).
