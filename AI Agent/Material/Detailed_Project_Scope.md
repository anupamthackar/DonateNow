# Detailed Project Scope — DonateNow

> Phase: 07 — Detailed Scope (Implementation-Ready)
> Previous: [Project_Boundaries.mdc](./Project_Boundaries.mdc) | [Project_Scope.mdc](./Project_Scope.mdc)
> Derived From: [PRD.mdc](./PRD.mdc) | [KPI.mdc](./KPI.mdc) | [Personas](./persona/) | [architecture.mdc](./extended/architecture.mdc) | [ERD.mdc](./extended/ERD.mdc) | [features.mdc](./extended/features/features.mdc) | [security.mdc](./extended/security.mdc) | [style-guide.mdc](./extended/style-guide.mdc) | [error_handling.mdc](./extended/error_handling.mdc)

---

## Purpose

This document consolidates all context engineering files into a **single implementation-ready reference**. It maps every feature to its technical implementation, the context files that define it, the KPIs that verify it, and the acceptance criteria that gate it.

---

## 1. Implementation Modules

### Module 1: Project Setup & Configuration

| Item | Detail | Source |
|---|---|---|
| **Framework** | Next.js 14+ (App Router) | [frontend_persona.mdc](./persona/frontend_persona.mdc) |
| **Database** | Supabase (PostgreSQL) | [database_persona.mdc](./persona/database_persona.mdc) |
| **Payments** | Razorpay (Test Mode) | [backend_persona.mdc](./persona/backend_persona.mdc) |
| **Hosting** | Vercel (Free Tier) | [deployment.mdc](./extended/deployment.mdc) |
| **Styling** | CSS Modules + CSS Variables | [style-guide.mdc](./extended/style-guide.mdc) |
| **Font** | Inter (Google Fonts) | [style-guide.mdc](./extended/style-guide.mdc) |
| **Icons** | Lucide React | [style-guide.mdc](./extended/style-guide.mdc) |

#### Setup Tasks
```
1. npx create-next-app@latest ./ (App Router, no Tailwind, CSS Modules)
2. npm install razorpay @supabase/supabase-js @supabase/auth-helpers-nextjs lucide-react
3. Create .env.local from .env.example
4. Create Supabase project + run migration SQL
5. Create Razorpay test mode keys
6. Configure folder structure per architecture.mdc
```

#### Files Created
```
├── .env.local               ← From extended/.env.example
├── .gitignore               ← Include .env.local
├── src/lib/supabase/client.js
├── src/lib/supabase/server.js
├── src/lib/razorpay.js
├── src/lib/utils.js
├── src/lib/validators.js
├── src/lib/logger.js
└── src/styles/globals.css    ← CSS variables from style-guide.mdc
```

---

### Module 2: Database Setup

| Item | Detail | Source |
|---|---|---|
| **Tables** | causes, donations, admin_users | [ERD.mdc](./extended/ERD.mdc) |
| **RLS** | Enabled on all tables | [security.mdc](./extended/security.mdc) |
| **Indexes** | 10 indexes defined | [database_persona.mdc](./persona/database_persona.mdc) |
| **Triggers** | updated_at auto-update | [ERD.mdc](./extended/ERD.mdc) |
| **Seed** | 1 cause + 1 admin user | [ERD.mdc](./extended/ERD.mdc) |

#### Verification
| KPI | Description |
|---|---|
| KPI-020 | RLS blocks public read on donations |
| KPI-017 | No payment card data in any column |

---

### Module 3: Public Donation Page (`/`)

| Item | Detail | Source |
|---|---|---|
| **Route** | `src/app/page.js` | [architecture.mdc](./extended/architecture.mdc) |
| **Rendering** | SSR (Server-Side Rendering) | [frontend_persona.mdc](./persona/frontend_persona.mdc) |
| **Data** | Fetch active cause from Supabase | [ERD.mdc](./extended/ERD.mdc) |
| **Features** | US-01.1 through US-01.5 | [features.mdc](./extended/features/features.mdc) |
| **Design** | Primary Green, centered layout, max-width 720px | [style-guide.mdc](./extended/style-guide.mdc) |

#### Components
| Component | File | Purpose |
|---|---|---|
| CauseCard | `src/components/CauseCard.js` | Displays cause title, description, progress |
| DonationForm | `src/components/DonationForm.js` | Amount buttons, custom input, donor fields, submit |

#### User Flow
```
Page loads (SSR) → Cause fetched from Supabase → CauseCard rendered
  → User selects amount → Fills name + email → Clicks "Donate Now"
  → POST /api/create-order → Razorpay Checkout opens
```

#### Validation Rules (Client-Side)
| Field | Rule | Error Message |
|---|---|---|
| Amount | Required, ≥ 1, ≤ 100000, numeric | "Enter a valid amount between ₹1 and ₹1,00,000" |
| Name | Required, ≥ 2 characters | "Please enter your name" |
| Email | Required, valid email format | "Please enter a valid email address" |
| Phone | Optional, 10-digit numeric | "Please enter a valid 10-digit phone number" |

#### Verification
| KPI | Description |
|---|---|
| KPI-004 | Cause display renders from Supabase |
| KPI-005 | Predefined + custom amounts work |
| KPI-006 | Form validation passes/fails correctly |
| KPI-013 | Page loads < 3 seconds |
| KPI-022 | Mobile responsive (360px+) |

---

### Module 4: Payment Integration (Razorpay)

| Item | Detail | Source |
|---|---|---|
| **Order Creation** | `src/app/api/create-order/route.js` | [PRD.mdc](./PRD.mdc) → Section 4 |
| **Verification** | `src/app/api/verify-payment/route.js` | [PRD.mdc](./PRD.mdc) → Section 4 |
| **Webhook** | `src/app/api/webhook/razorpay/route.js` | [PRD.mdc](./PRD.mdc) → Section 4 |
| **Checkout** | Razorpay Checkout.js (client-side) | [frontend_persona.mdc](./persona/frontend_persona.mdc) |
| **SDK** | `src/lib/razorpay.js` (server-side) | [backend_persona.mdc](./persona/backend_persona.mdc) |

#### Payment Flow (Technical)
```
Step 1: Client → POST /api/create-order { amount: 500, currency: "INR" }
Step 2: Server → Razorpay.orders.create({ amount: 50000, currency: "INR" })
Step 3: Server → Return { order_id, amount, currency, key_id }
Step 4: Client → Open Razorpay Checkout with order_id
Step 5: User pays (test card: 4111 1111 1111 1111)
Step 6: Razorpay → Returns { razorpay_order_id, razorpay_payment_id, razorpay_signature }
Step 7: Client → POST /api/verify-payment { razorpay_*, donor_info }
Step 8: Server → Verify signature using HMAC SHA256
Step 9: Server → INSERT into donations (status: 'pending')
Step 10: Server → Return { success: true, donation_id }
Step 11: Client → Redirect to /thank-you?id=donation_id
Step 12: Razorpay Webhook → POST /api/webhook/razorpay
Step 13: Server → Verify webhook signature → UPDATE status to 'completed'
```

#### State Machine Reference
> Full state machine in [error_handling.mdc](./extended/error_handling.mdc) → Section 1

```
initiated → pending → completed (happy path)
initiated → cancelled (user cancelled checkout)
pending → failed (webhook: payment.failed)
completed → refunded (manual action)
```

#### Razorpay Amount Note
- Razorpay API accepts amounts in **paise** (1 INR = 100 paise)
- ₹500 = 50000 paise
- Always convert: `amount_paise = amount_inr * 100`

#### Verification
| KPI | Description |
|---|---|
| KPI-001 | Payment flow works end-to-end in test mode |
| KPI-007 | Payment signature verified server-side |
| KPI-008 | Webhook updates donation status correctly |
| KPI-014 | API response < 500ms |
| KPI-018 | Webhook signature checked every time |

---

### Module 5: Thank-You Page (`/thank-you`)

| Item | Detail | Source |
|---|---|---|
| **Route** | `src/app/thank-you/page.js` | [architecture.mdc](./extended/architecture.mdc) |
| **Features** | US-03.1 through US-03.3 | [features.mdc](./extended/features/features.mdc) |
| **Data** | Donation details from query param or session | [PRD.mdc](./PRD.mdc) |

#### Components
| Component | File | Purpose |
|---|---|---|
| ThankYouCard | `src/components/ThankYouCard.js` | Success icon, donation summary, donate again button |

#### Display Content
```
✅ Thank You for Your Donation!
   Donor Name: Rahul Sharma
   Amount: ₹500
   Reference ID: pay_xxxxxxxxx
   Date: June 10, 2026
   
   [Donate Again →]
```

#### Edge Cases
- Direct access without donation → Redirect to `/` or generic message
- Invalid donation ID → "Donation not found" message

#### Verification
| KPI | Description |
|---|---|
| KPI-002 | Thank-you page displays after donation |
| KPI-023 | Error states for invalid access |

---

### Module 6: Admin Authentication

| Item | Detail | Source |
|---|---|---|
| **Login Page** | `src/app/admin/login/page.js` | [architecture.mdc](./extended/architecture.mdc) |
| **Auth Provider** | Supabase Auth (Email/Password) | [security.mdc](./extended/security.mdc) |
| **Session** | JWT in HTTP-only cookie | [security.mdc](./extended/security.mdc) |
| **Auth Guard** | Admin layout middleware | [backend_persona.mdc](./persona/backend_persona.mdc) |

#### Implementation
```
Login: supabase.auth.signInWithPassword({ email, password })
Logout: supabase.auth.signOut()
Guard: Check session in admin layout → redirect to /admin/login if null
```

#### Verification
| KPI | Description |
|---|---|
| KPI-009 | Admin login works, session persists |
| KPI-019 | Unauthenticated access returns 401 / redirects |

---

### Module 7: Admin Dashboard (`/admin`)

| Item | Detail | Source |
|---|---|---|
| **Route** | `src/app/admin/page.js` | [architecture.mdc](./extended/architecture.mdc) |
| **Features** | US-05.1 through US-05.3 | [features.mdc](./extended/features/features.mdc) |
| **Data** | GET /api/admin/stats + recent donations | [PRD.mdc](./PRD.mdc) → Section 4 |
| **Layout** | Sidebar + main content | [style-guide.mdc](./extended/style-guide.mdc) |

#### Components
| Component | File | Purpose |
|---|---|---|
| AdminSidebar | `src/components/AdminSidebar.js` | Navigation + logout |
| StatsCard | `src/components/StatsCard.js` | Total count, total amount, today's count |

#### Dashboard Stats
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Total Donations  │  │ Amount Raised    │  │ Today's Count    │
│ 150              │  │ ₹1,25,000        │  │ 5               │
└─────────────────┘  └─────────────────┘  └─────────────────┘

Recent Donations:
| Name          | Amount | Date       | Status    |
|---------------|--------|------------|-----------|
| Rahul Sharma  | ₹500   | 10/06/2026 | Completed |
| Priya Patel   | ₹1000  | 10/06/2026 | Completed |
| ...           | ...    | ...        | ...       |
[View All →]
```

#### Verification
| KPI | Description |
|---|---|
| KPI-012 | Dashboard stats aggregated correctly |
| KPI-015 | Admin dashboard loads < 3 seconds |

---

### Module 8: Donor Log (`/admin/donors`)

| Item | Detail | Source |
|---|---|---|
| **Route** | `src/app/admin/donors/page.js` | [architecture.mdc](./extended/architecture.mdc) |
| **Features** | US-06.1 through US-06.3 | [features.mdc](./extended/features/features.mdc) |
| **Data** | GET /api/admin/donations | [PRD.mdc](./PRD.mdc) → Section 4 |

#### Components
| Component | File | Purpose |
|---|---|---|
| DonorTable | `src/components/DonorTable.js` | Table with donor details |
| SearchBar | Part of DonorTable | Search by name/email |
| DateFilter | Part of DonorTable | Filter by date range |
| Pagination | Part of DonorTable | Navigate pages (20 per page) |

#### Table Columns
| Column | Source Field | Format |
|---|---|---|
| Donor Name | `donor_name` | Text |
| Email | `donor_email` | Text |
| Amount | `amount` | ₹{amount} (Indian format) |
| Date | `created_at` | DD/MM/YYYY HH:MM |
| Payment ID | `razorpay_payment_id` | Text (truncated) |
| Status | `status` | Badge (green=completed, red=failed) |

#### Verification
| KPI | Description |
|---|---|
| KPI-003 | Admin can view donor log |
| KPI-010 | Search by name/email works |
| KPI-011 | Date range filter works |
| KPI-016 | Table renders 100 records < 2 seconds |

---

## 2. Implementation Order

```
Phase 1: Foundation
  ├── 1.1 Project setup (Next.js, dependencies)
  ├── 1.2 Environment configuration (.env.local)
  ├── 1.3 Supabase setup (tables, RLS, seed data)
  ├── 1.4 Global styles (CSS variables from style-guide)
  └── 1.5 Utility libraries (supabase clients, razorpay, validators)

Phase 2: Donation Flow
  ├── 2.1 Donation page (/, CauseCard, DonationForm)
  ├── 2.2 Create order API (/api/create-order)
  ├── 2.3 Razorpay Checkout integration
  ├── 2.4 Verify payment API (/api/verify-payment)
  ├── 2.5 Thank-you page (/thank-you)
  └── 2.6 Webhook handler (/api/webhook/razorpay)

Phase 3: Admin Panel
  ├── 3.1 Admin login (/admin/login)
  ├── 3.2 Admin layout (sidebar, auth guard)
  ├── 3.3 Admin dashboard (/admin, stats API)
  └── 3.4 Donor log (/admin/donors, donations API)

Phase 4: Polish & Verify
  ├── 4.1 Error handling (all error states)
  ├── 4.2 Loading states (all async operations)
  ├── 4.3 Mobile responsive (all pages)
  ├── 4.4 KPI verification (all 25 KPIs)
  └── 4.5 Deployment (Vercel + environment setup)
```

---

## 3. Complete File Manifest

```
src/
├── app/
│   ├── layout.js                          ← Root layout (font, metadata, globals)
│   ├── page.js                            ← Donation page (Module 3)
│   ├── thank-you/
│   │   └── page.js                        ← Thank-you page (Module 5)
│   ├── admin/
│   │   ├── layout.js                      ← Admin layout + auth guard (Module 6)
│   │   ├── login/
│   │   │   └── page.js                    ← Admin login (Module 6)
│   │   ├── page.js                        ← Admin dashboard (Module 7)
│   │   └── donors/
│   │       └── page.js                    ← Donor log (Module 8)
│   └── api/
│       ├── create-order/
│       │   └── route.js                   ← Create Razorpay order (Module 4)
│       ├── verify-payment/
│       │   └── route.js                   ← Verify payment (Module 4)
│       ├── webhook/
│       │   └── razorpay/
│       │       └── route.js               ← Razorpay webhook (Module 4)
│       ├── admin/
│       │   ├── donations/
│       │   │   └── route.js               ← Donor log API (Module 8)
│       │   └── stats/
│       │       └── route.js               ← Dashboard stats API (Module 7)
│       └── health/
│           └── route.js                   ← Health check
├── components/
│   ├── CauseCard.js                       ← Module 3
│   ├── DonationForm.js                    ← Module 3
│   ├── ThankYouCard.js                    ← Module 5
│   ├── AdminSidebar.js                    ← Module 7
│   ├── StatsCard.js                       ← Module 7
│   ├── DonorTable.js                      ← Module 8
│   ├── LoadingSpinner.js                  ← Shared
│   ├── ErrorMessage.js                    ← Shared
│   └── EmptyState.js                      ← Shared
├── lib/
│   ├── supabase/
│   │   ├── client.js                      ← Browser Supabase client
│   │   └── server.js                      ← Server Supabase client
│   ├── razorpay.js                        ← Razorpay SDK init
│   ├── validators.js                      ← Input validation functions
│   ├── utils.js                           ← Formatting, helpers
│   └── logger.js                          ← Structured logging
└── styles/
    ├── globals.css                         ← CSS variables + base styles
    ├── donation.module.css                 ← Donation page styles
    ├── thankyou.module.css                 ← Thank-you page styles
    └── admin.module.css                    ← Admin panel styles
```

**Total Files: 28 source files**
**Total Context Files: 19 (8 main + 11 extended)**
**Total KPIs: 25**
**Total User Stories: 16**

---

## 4. Cross-Reference Summary

| Module | PRD Section | Features | KPIs | Persona | Extended Files |
|---|---|---|---|---|---|
| Setup | — | — | — | All 3 | architecture, deployment, .env.example |
| Database | — | — | KPI-017, 020 | Database | ERD, security |
| Donation Page | §3.1, §4.1 | F01 (US-01.*) | KPI-004–006, 013, 022 | Frontend | style-guide, features |
| Payment | §3.1, §4.1–4.3 | F02 (US-02.*) | KPI-001, 007–008, 014, 018 | Backend | security, error_handling |
| Thank-You | §3.1 | F03 (US-03.*) | KPI-002, 023 | Frontend | style-guide |
| Admin Auth | §3.4 | F04 (US-04.*) | KPI-009, 019 | Backend | security |
| Dashboard | §3.4 | F05 (US-05.*) | KPI-012, 015 | Frontend | architecture |
| Donor Log | §3.4 | F06 (US-06.*) | KPI-003, 010–011, 016 | Frontend + Backend | features |
