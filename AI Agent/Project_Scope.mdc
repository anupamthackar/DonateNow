# Project Scope — DonateNow

> Phase: 05 — Scope Definition
> Previous: [Personas](./persona/) | [KPI.mdc](./KPI.mdc) | [PRD.mdc](./PRD.mdc) | [business_idea.mdc](./business_idea.mdc)
> Next: [Project_Boundaries.mdc](./Project_Boundaries.mdc) | [Detailed_Project_Scope.md](./Material/Detailed_Project_Scope.md)
> Extended: [architecture.mdc](./extended/architecture.mdc) | [features.mdc](./extended/features/features.mdc)

---

## Executive Summary

DonateNow is a native iOS donation platform for a local NGO to replace manual bank-transfer-based donation collection. The app will enable donors to give via a clean native interface, process payments through Razorpay (test mode) using the iOS SDK, display a thank-you confirmation, and provide an in-app admin panel for the NGO team to track donor information.

**Scope**: MVP — single cause, single NGO, one-time donations, test mode payments, native iOS (iPhone + iPad).

---

## Business Context

### Organization
- Type: Local NGO (Non-Governmental Organization)
- Size: Small team (2-5 members managing donations)
- Current Process: Bank transfers + manual spreadsheet tracking
- Geographic Focus: India (INR currency)

### Business Drivers
1. Eliminate manual reconciliation overhead
2. Provide donors a modern, digital giving experience
3. Enable real-time visibility into donation data
4. Leverage native iOS capabilities for a premium feel

### Industry Context
- Digital donation platforms are standard for NGOs globally
- Indian NGOs increasingly adopt UPI and digital payment methods
- Regulatory requirement for donor records (FCRA, 80G in future)

---

## Business Goals

| # | Goal | Measurable Outcome | Timeline |
|---|---|---|---|
| BG-01 | Digitize donation collection | 100% donations via app | MVP Launch |
| BG-02 | Automate donor tracking | Zero manual data entry | MVP Launch |
| BG-03 | Improve donor experience | Native app flow < 3 screens | MVP Launch |
| BG-04 | Provide real-time visibility | Admin dashboard live in-app | MVP Launch |
| BG-05 | Support Apple Ecosystem | Universal App (iPhone + iPad) | MVP Launch |

---

## Project Objectives

| # | Objective | Deliverable |
|---|---|---|
| PO-01 | Build donation screen | `DonationView` — cause display + form |
| PO-02 | Integrate Razorpay payments | Razorpay iOS SDK integration (test mode) |
| PO-03 | Build thank-you confirmation | `ThankYouView` — donation summary |
| PO-04 | Build admin authentication | `AdminLoginView` — Supabase Auth |
| PO-05 | Build admin dashboard | `AdminDashboardView` — stats + navigation |
| PO-06 | Build donor log | `DonorLogView` — searchable list |
| PO-07 | Design database schema | 3 tables: causes, donations, admin_users |
| PO-08 | Implement server-side logic | Supabase Edge Functions for Razorpay verification |

---

## Stakeholders

| Stakeholder | Role | Interest | Involvement |
|---|---|---|---|
| NGO Management | Sponsor | Project success, donor visibility | Decision approval |
| NGO Admin Team | Primary User | Daily use of admin panel | Testing, feedback |
| Donors | End User | Easy donation experience | Use app |
| Developer | Builder | Clean code, proper architecture | Development |
| AI Agent | Builder | Context-aware development | Follow PRD + Personas |

---

## Target Users

### User 1: Donor
- **Who**: General public, NGO supporters, well-wishers
- **Tech Comfort**: Basic smartphone user (iOS)
- **Needs**: Simple form, familiar payment method (UPI/card), instant confirmation
- **Frequency**: One-time or occasional donations
- **Device**: iPhone (80%) + iPad (20%)

### User 2: NGO Admin
- **Who**: NGO team member responsible for donation management
- **Tech Comfort**: Moderate — can use mobile apps
- **Needs**: View donor list, search donors, see totals, date filters
- **Frequency**: Daily or weekly access
- **Device**: iPhone (30%) + iPad (70%)

---

## Scope Definition

### In Scope ✅

| # | Item | Details |
|---|---|---|
| 1 | Donation Screen | Cause display, predefined amounts, custom amount, donor form |
| 2 | Razorpay Payment (iOS SDK) | Native payment sheet presentation, delegate callbacks |
| 3 | Thank-You Screen | Donation summary with amount, reference ID, date |
| 4 | Admin Login | Email/password via Supabase Auth Swift SDK |
| 5 | Admin Dashboard | Total donations count, total amount |
| 6 | Donor Log | Name, email, amount, date, status — searchable, filterable list |
| 7 | Database Schema | causes, donations, admin_users tables with RLS |
| 8 | Server Logic | Supabase Edge Functions (create-order, verify-payment, webhook) |
| 9 | Universal App | Adaptive layout for iPhone and iPad (iOS 16+) |
| 10 | Error Handling | Payment failures, validation errors, network errors via Alerts |

### Out of Scope ❌

| # | Item | Reason |
|---|---|---|
| 1 | Android App | iOS only for MVP |
| 2 | Web Application | Native iOS app only |
| 3 | Recurring donations | MVP — future enhancement |
| 4 | Email notifications to donors | MVP — future enhancement |
| 5 | 80G tax receipt generation | Requires legal setup, future enhancement |
| 6 | Multi-cause support | MVP — single cause only |
| 7 | Donor account/login | Donors don't need accounts |
| 8 | CSV/PDF export | Complex on mobile, future enhancement |
| 9 | Apple Pay | Razorpay standard checkout only for MVP |
| 10 | Razorpay live mode | Test mode only for this project |
| 11 | Push Notifications | MVP — future enhancement |
| 12 | Charts/Graphs | Basic stats only in MVP |
| 13 | Admin user management | Single admin, manual setup via Supabase Dashboard |

---

## Business Processes

### Process 1: Donation Collection
```
Donor → Open App → Select Amount → Fill Info → Pay via Razorpay SDK → Thank You
```

### Process 2: Donor Tracking
```
Edge Function Verification → Insert Donation Record → Available in Admin Panel
```

### Process 3: Admin Reporting
```
Admin Login (App) → View Dashboard Stats → View/Search Donor Log → Logout
```

---

## Assumptions

| # | Assumption | Impact if Wrong |
|---|---|---|
| A-01 | NGO has a Razorpay account (or can create one) | Cannot process payments |
| A-02 | Target donors use Apple devices (iOS) | Cannot reach donors |
| A-03 | Indian donors primarily (INR, UPI, Indian cards) | Payment methods mismatch |
| A-04 | Single cause active at any time | UI design is simpler |
| A-05 | < 1000 donations/month initially | Free tier sufficient |
| A-06 | Supabase free tier is sufficient for MVP | No cost |
| A-07 | Mac hardware available for development | Cannot build iOS app |

---

## Constraints

| # | Constraint | Type | Impact |
|---|---|---|---|
| C-01 | Test mode only (no real money) | Business | Limited to demo/POC |
| C-02 | Single developer + AI agent | Resource | Sequential development |
| C-03 | Free tier services (Supabase) | Budget | Service limits apply |
| C-04 | Simulator distribution only | Technical | No App Store / TestFlight without $99 account |
| C-05 | iOS 16 Minimum Target | Technical | Features restricted to iOS 16+ API |

---

## Risks

| # | Risk | Probability | Impact | Mitigation |
|---|---|---|---|---|
| R-01 | Razorpay iOS SDK integration issues | Low | High | Follow official Razorpay docs exactly |
| R-02 | App rejection by App Store | Medium | High | Follow App Store guidelines (charity rules) |
| R-03 | Edge Function latency | Low | Medium | Keep functions lightweight and regionalized |
| R-04 | Payment reconciliation mismatch | Low | High | Dual verification (client verify + webhook) |
| R-05 | Admin credentials compromised | Low | High | Strong passwords, session expiry |
| R-06 | Donor data breach | Very Low | Critical | RLS, server-only secrets |

---

## Dependencies

| # | Dependency | Type | Owner | Status |
|---|---|---|---|---|
| D-01 | Razorpay Test Account | External | NGO / Developer | Required before dev |
| D-02 | Supabase Project | External | Developer | Required before dev |
| D-03 | Xcode 15+ | Tool | Developer | Required for dev |
| D-04 | NGO Cause Content | Content | NGO | Required for donation page |

---

## Success Criteria

> Detailed in [KPI.mdc](./KPI.mdc)

### MVP Launch Criteria (All must pass)
1. ✅ Payment flow works end-to-end in test mode (KPI-001)
2. ✅ Thank-you screen displays after donation (KPI-002)
3. ✅ Admin can view donor log in-app (KPI-003)
4. ✅ Admin views are auth-protected (KPI-021)
5. ✅ Universal layout looks good on iPhone and iPad (KPI-023)

---

## Non-Functional Expectations

| Aspect | Requirement | Reference |
|---|---|---|
| Performance | App launch < 2s | KPI-013 |
| Security | RLS, Keychain storage, edge function verification | [security.mdc](./extended/security.mdc) |
| Availability | Supabase 99.9% | Managed service |
| Accessibility | Dynamic Type support, VoiceOver labels | iOS Persona |
| Responsiveness | Universal App (Adaptive Layout) | KPI-023 |

---

## Future Scope (Post-MVP Roadmap)

| Phase | Features | Priority |
|---|---|---|
| Phase 2 | Push notifications, Email receipts (PDF) | P1 |
| Phase 3 | Multi-cause support, Apple Pay integration | P2 |
| Phase 4 | Recurring donations, donor accounts | P2 |
| Phase 5 | Share sheet, Home Screen Widgets, Android App | P3 |

---

## Scope Governance

### Change Request Process
1. Any scope change must be documented
2. Impact on timeline, KPIs, and architecture must be assessed
3. Approval required before implementation
4. Update PRD, KPI, and Scope documents accordingly

### Scope Freeze
- Scope is frozen after approval of this document
- Only bug fixes and approved changes during development
- Feature requests logged for future phases
