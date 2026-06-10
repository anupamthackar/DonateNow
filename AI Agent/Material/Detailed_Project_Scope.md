# Detailed Project Scope — DonateNow

> Phase: 07 — Detailed Scope (Implementation-Ready)
> Previous: [Project_Boundaries.mdc](../Project_Boundaries.mdc) | [Project_Scope.mdc](../Project_Scope.mdc)
> Derived From: [PRD.mdc](../PRD.mdc) | [KPI.mdc](../KPI.mdc) | [Personas](../persona/) | [architecture.mdc](../extended/architecture.mdc) | [ERD.mdc](../extended/ERD.mdc) | [features.mdc](../extended/features/features.mdc) | [security.mdc](../extended/security.mdc) | [style-guide.mdc](../extended/style-guide.mdc) | [error_handling.mdc](../extended/error_handling.mdc)

---

## Purpose

This document consolidates all context engineering files into a **single implementation-ready reference** for native iOS development. It maps every feature to its technical implementation, the context files that define it, the KPIs that verify it, and the acceptance criteria that gate it.

---

## 1. Implementation Modules

### Module 1: Project Setup & Configuration

| Item | Detail | Source |
|---|---|---|
| **Framework** | SwiftUI / Swift 5.9+ | [frontend_persona.mdc](../persona/frontend_persona.mdc) |
| **Architecture** | MVVM | [architecture.mdc](../extended/architecture.mdc) |
| **Database/Auth** | Supabase Swift SDK | [backend_persona.mdc](../persona/backend_persona.mdc) |
| **Payments** | Razorpay iOS SDK | [backend_persona.mdc](../persona/backend_persona.mdc) |
| **Environment** | Config.xcconfig | [security.mdc](../extended/security.mdc) |
| **Styling** | Color Assets + ViewModifiers | [style-guide.mdc](../extended/style-guide.mdc) |

#### Setup Tasks
```
1. Create new Xcode Project (App, SwiftUI, Swift)
2. Add Swift Packages: supabase-swift
3. Add CocoaPods/SPM: razorpay-pod
4. Create Config.example.xcconfig and Config.xcconfig
5. Setup Info.plist to read from xcconfig
6. Create Supabase project + run migration SQL
7. Setup Edge Functions locally (`supabase init`)
8. Configure folder structure per architecture.mdc
```

#### Files Created
```
├── DonateNowApp.swift
├── Configuration/
│   ├── Config.xcconfig
│   └── Config.example.xcconfig
├── Services/
│   └── SupabaseManager.swift
├── Utils/
│   └── Constants.swift
└── Theme/
    ├── Color+Extensions.swift
    └── Typography.swift
```

---

### Module 2: Database Setup & Edge Functions

| Item | Detail | Source |
|---|---|---|
| **Tables** | causes, donations, admin_users | [ERD.mdc](../extended/ERD.mdc) |
| **RLS** | Enabled on all tables | [security.mdc](../extended/security.mdc) |
| **Functions** | create-order, verify-payment, razorpay-webhook | [architecture.mdc](../extended/architecture.mdc) |

#### Verification
| KPI | Description |
|---|---|
| KPI-019 | RLS blocks public read on donations |
| KPI-018 | No payment card data in any column |

---

### Module 3: Public Donation Screen

| Item | Detail | Source |
|---|---|---|
| **View** | `DonationView.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **ViewModel** | `DonationViewModel.swift` | [frontend_persona.mdc](../persona/frontend_persona.mdc) |
| **Data** | `supabase.from("causes").select()` | [ERD.mdc](../extended/ERD.mdc) |
| **Features** | US-01.1 through US-01.5 | [features.mdc](../extended/features/features.mdc) |
| **Design** | Adaptive width for iPad | [style-guide.mdc](../extended/style-guide.mdc) |

#### Components
| Component | File | Purpose |
|---|---|---|
| CauseCardView | `CauseCardView.swift` | Displays cause title, description, progress |
| CustomTextField | `CustomTextField.swift` | Reusable text field with error state |
| AmountPill | `AmountPill.swift` | Predefined amount button |

#### Verification
| KPI | Description |
|---|---|
| KPI-004 | Cause display renders from Supabase |
| KPI-005 | Predefined + custom amounts work |
| KPI-009 | Form validation passes/fails correctly |
| KPI-013 | App launches < 2 seconds |
| KPI-023 | Universal layout (iPhone + iPad) |

---

### Module 4: Payment Integration (Razorpay)

| Item | Detail | Source |
|---|---|---|
| **Service** | `PaymentService.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **Order Creation** | Edge Function: `create-order` | [PRD.mdc](../PRD.mdc) → Section 4 |
| **Verification** | Edge Function: `verify-payment` | [PRD.mdc](../PRD.mdc) → Section 4 |
| **Webhook** | Edge Function: `razorpay-webhook` | [PRD.mdc](../PRD.mdc) → Section 4 |

#### Payment Flow (Technical)
```
1. DonationViewModel → calls create-order Edge Function
2. Edge Function → returns order_id
3. PaymentService → initializes RazorpayCheckout with order_id
4. User pays in native sheet (test card: 4111 1111 1111 1111)
5. RazorpaySDK → delegate onPaymentSuccess
6. PaymentService → calls verify-payment Edge Function
7. Edge Function → verifies HMAC SHA256 → INSERTS donation
8. Edge Function → returns success
9. DonationViewModel → updates state to success
10. NavigationStack → pushes ThankYouView
```

#### Verification
| KPI | Description |
|---|---|
| KPI-001 | Payment flow works end-to-end in test mode |
| KPI-007 | Payment signature verified server-side |
| KPI-008 | Webhook updates donation status correctly |
| KPI-014 | API response < 500ms |

---

### Module 5: Thank-You Screen

| Item | Detail | Source |
|---|---|---|
| **View** | `ThankYouView.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **Features** | US-03.1 through US-03.3 | [features.mdc](../extended/features/features.mdc) |

#### Components
| Component | File | Purpose |
|---|---|---|
| SuccessCard | `SuccessCard.swift` | Checkmark icon, donation summary |

#### Verification
| KPI | Description |
|---|---|
| KPI-002 | Thank-you screen displays after donation |

---

### Module 6: Admin Authentication

| Item | Detail | Source |
|---|---|---|
| **View** | `AdminLoginView.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **ViewModel** | `AdminAuthViewModel.swift` | [frontend_persona.mdc](../persona/frontend_persona.mdc) |
| **Service** | `AuthService.swift` | [backend_persona.mdc](../persona/backend_persona.mdc) |
| **Session** | iOS Keychain | [security.mdc](../extended/security.mdc) |

#### Verification
| KPI | Description |
|---|---|
| KPI-009 | Admin login works, session persists in Keychain |
| KPI-021 | Unauthenticated access prevented |

---

### Module 7: Admin Dashboard

| Item | Detail | Source |
|---|---|---|
| **View** | `AdminDashboardView.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **ViewModel** | `DashboardViewModel.swift` | [frontend_persona.mdc](../persona/frontend_persona.mdc) |
| **Features** | US-05.1 through US-05.3 | [features.mdc](../extended/features/features.mdc) |
| **Data** | `supabase.rpc("get_donation_stats")` | [ERD.mdc](../extended/ERD.mdc) |

#### Verification
| KPI | Description |
|---|---|
| KPI-012 | Dashboard stats aggregated correctly |
| KPI-015 | Admin dashboard loads < 1.5 seconds |

---

### Module 8: Donor Log

| Item | Detail | Source |
|---|---|---|
| **View** | `DonorLogView.swift` | [architecture.mdc](../extended/architecture.mdc) |
| **Features** | US-06.1 through US-06.3 | [features.mdc](../extended/features/features.mdc) |
| **Data** | `supabase.from("donations").select()` | [ERD.mdc](../extended/ERD.mdc) |

#### Verification
| KPI | Description |
|---|---|
| KPI-003 | Admin can view donor log |
| KPI-010 | Search by name/email works |
| KPI-011 | Date range filter works |
| KPI-016 | Table rendering / scrolling smooth (60fps) |

---

## 2. Implementation Order

```
Phase 1: Foundation
  ├── 1.1 Xcode Project setup
  ├── 1.2 Environment configuration (.xcconfig)
  ├── 1.3 Supabase setup (tables, RLS, seed data)
  ├── 1.4 Global styles (Theme, ViewModifiers)
  └── 1.5 Utility libraries (SupabaseManager, formatters)

Phase 2: Backend (Edge Functions)
  ├── 2.1 create-order
  ├── 2.2 verify-payment
  └── 2.3 razorpay-webhook

Phase 3: Donation Flow (iOS)
  ├── 3.1 DonationView + ViewModel
  ├── 3.2 PaymentService (Razorpay integration)
  └── 3.3 ThankYouView

Phase 4: Admin Panel (iOS)
  ├── 4.1 AuthService + AdminLoginView
  ├── 4.2 AdminDashboardView + ViewModel
  └── 4.3 DonorLogView + search/filter logic

Phase 5: Polish & Verify
  ├── 5.1 Error handling (Alerts mapping)
  ├── 5.2 Loading states (ProgressViews)
  ├── 5.3 Universal layout testing (iPad Simulator)
  └── 5.4 KPI verification (XCTest, XCUITest)
```

---

## 3. Complete File Manifest (iOS)

```
DonateNow/
├── DonateNowApp.swift
├── Configuration/
│   ├── Config.xcconfig
│   ├── Config.example.xcconfig
│   └── Info.plist
├── Models/
│   ├── Cause.swift
│   ├── Donation.swift
│   └── AppError.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Public/
│   │   ├── DonationView.swift
│   │   └── ThankYouView.swift
│   ├── Admin/
│   │   ├── AdminLoginView.swift
│   │   ├── AdminDashboardView.swift
│   │   └── DonorLogView.swift
│   └── Components/
│       ├── CauseCardView.swift
│       ├── AmountPill.swift
│       ├── CustomTextField.swift
│       └── PrimaryButton.swift
├── ViewModels/
│   ├── DonationViewModel.swift
│   ├── AdminAuthViewModel.swift
│   ├── DashboardViewModel.swift
│   └── DonorLogViewModel.swift
├── Services/
│   ├── SupabaseManager.swift
│   ├── PaymentService.swift
│   ├── AuthService.swift
│   └── Repositories/
│       ├── CauseRepository.swift
│       └── DonationRepository.swift
├── Utils/
│   ├── Constants.swift
│   ├── Formatters.swift
│   └── Validators.swift
└── Theme/
    ├── Color+Extensions.swift
    ├── Typography.swift
    └── ViewModifiers.swift
```

**Total Files: 32 Swift files**
**Total Context Files: 19**
**Total KPIs: 25**

---

## 4. Cross-Reference Summary

| Module | PRD Section | Features | KPIs | Persona |
|---|---|---|---|---|
| Setup | — | — | — | All 3 |
| Database/Functions | §4 | — | KPI-018, 019, 020 | Database/Services |
| Donation View | §3.1 | F01 | KPI-004–006, 009, 013, 023 | iOS/UI |
| Payment SDK | §3.1, §4.2 | F02 | KPI-001, 007–008, 014 | Services |
| Thank-You | §3.1 | F03 | KPI-002 | iOS/UI |
| Admin Auth | §3.4 | F04 | KPI-009, 021 | Services/UI |
| Dashboard | §3.4 | F05 | KPI-012, 015 | iOS/UI |
| Donor Log | §3.4 | F06 | KPI-003, 010–011, 016 | iOS/UI |
