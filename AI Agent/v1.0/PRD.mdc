# Product Requirements Document (PRD) — DonateNow

> Phase: 02 — Requirements
> Previous: [business_idea.mdc](./business_idea.mdc)
> Next: [KPI.mdc](./KPI.mdc)
> Extended: [architecture.mdc](./extended/architecture.mdc) | [ERD.mdc](./extended/ERD.mdc) | [security.mdc](./extended/security.mdc)

---

## 1. Problem Statement

### Current Business Problem
A local NGO receives donations through bank transfers and has no system to track donor information. The team manually reconciles bank statements and records donor data in spreadsheets.

### Existing Pain Points
- No centralized donation collection mechanism
- No real-time tracking of donor names, amounts, or dates
- No instant confirmation or acknowledgment to donors
- Manual data entry leads to errors and lost records
- No reporting or dashboard for the NGO team

### Impact on Users and Stakeholders
| Stakeholder | Impact |
|---|---|
| Donors | Poor giving experience, no confirmation, no trust |
| NGO Team | Hours spent on manual reconciliation weekly |
| NGO Management | No visibility into donation trends or totals |
| Auditors | Incomplete records, compliance risks |

---

## 2. Solution Overview

### Proposed Solution
A native iOS app built with Swift/SwiftUI, Supabase, and Razorpay iOS SDK that enables:
- Donors to give via a clean native app experience
- Instant payment processing via Razorpay iOS SDK
- Automatic donor record creation in Supabase
- In-app admin dashboard for the NGO team

### Core Features
| # | Feature | Description |
|---|---|---|
| F01 | Donation Screen | Displays cause, predefined amounts, donor form |
| F02 | Razorpay Payment Integration | Secure payment via Razorpay iOS SDK (card/UPI/netbanking) |
| F03 | Thank-You Screen | Confirmation shown after successful donation |
| F04 | Admin Authentication | Email/password login within the app |
| F05 | Admin Dashboard | Total donations, total amount, recent activity |
| F06 | Donor Log | Searchable list of all donations |

### Expected Business Impact
- 100% donations digitized
- Zero manual reconciliation
- Real-time donor visibility
- Native iOS experience on iPhone + iPad

---

## 3. User Flow

### 3.1 Happy Path — Donor Makes Donation
```
Donor opens app
  → Views cause title, description, and progress
  → Selects predefined amount (₹100/₹500/₹1000/₹2000) OR enters custom amount
  → Fills donor info (name, email, phone[optional])
  → Taps "Donate Now"
  → Razorpay Checkout (iOS) presents payment sheet
  → Donor completes payment
  → NavigationStack pushes ThankYouView
  → Thank-you screen shows donation summary
```

### 3.2 Alternative Path — Payment Cancelled
```
Donor opens Razorpay Checkout
  → Donor taps cancel or swipes to dismiss
  → Returns to donation screen
  → No error shown, form preserved
  → Donor can retry
```

### 3.3 Alternative Path — Payment Failed
```
Donor completes payment attempt
  → Razorpay reports failure via delegate callback
  → Error alert: "Payment could not be processed. No amount deducted."
  → Donor stays on donation screen
  → Donor can retry with different method
```

### 3.4 Admin Flow — View Donor Log
```
Admin taps "Admin" tab in TabView
  → Enters email + password
  → Supabase Auth validates credentials
  → Admin dashboard view loads
  → Views total donations count + total amount
  → Navigates to Donor Log
  → Views searchable donor list
  → Filters by date range
  → Taps "Logout" when done
```

---

## 4. Data Layer Design

### 4.1 Supabase Swift SDK Operations

Since this is a native iOS app, there are **no API routes**. The app communicates directly with Supabase via the Swift SDK and Razorpay via the iOS SDK.

| Operation | Method | Auth | Purpose |
|---|---|---|---|
| Fetch active cause | `supabase.from("causes").select()` | Anon (public, RLS) | Load cause on donation screen |
| Create Razorpay order | Supabase Edge Function: `create-order` | Anon | Create order server-side (keeps key_secret safe) |
| Save donation record | Supabase Edge Function: `verify-payment` | Anon | Verify signature + insert donation |
| Webhook handler | Supabase Edge Function: `razorpay-webhook` | Razorpay Signature | Handle payment events |
| Fetch donations (admin) | `supabase.from("donations").select()` | Authenticated (admin) | Donor log |
| Fetch stats (admin) | `supabase.rpc("get_donation_stats")` | Authenticated (admin) | Dashboard stats |
| Admin login | `supabase.auth.signIn()` | — | Email/password auth |
| Admin logout | `supabase.auth.signOut()` | Authenticated | End session |

### 4.2 Supabase Edge Functions (Server-Side Logic)

> These run server-side on Supabase infrastructure to keep `key_secret` off the iOS device.

#### `create-order` (Edge Function)
```json
// Request
{ "amount": 500, "currency": "INR" }

// Response — Success (200)
{ "order_id": "order_xxxxxxxxx", "amount": 50000, "currency": "INR", "key_id": "rzp_test_xxxxxxxxx" }

// Response — Error (400)
{ "error": "Invalid donation amount. Must be between ₹1 and ₹1,00,000." }
```

#### `verify-payment` (Edge Function)
```json
// Request
{
  "razorpay_order_id": "order_xxxxxxxxx",
  "razorpay_payment_id": "pay_xxxxxxxxx",
  "razorpay_signature": "xxxxxxxxxxxxxxxx",
  "donor_name": "Rahul Sharma",
  "donor_email": "rahul@example.com",
  "donor_phone": "9876543210",
  "amount": 500,
  "cause_id": "uuid-of-cause"
}

// Response — Success (200)
{ "success": true, "donation_id": "uuid-of-donation" }

// Response — Error (400)
{ "error": "Payment verification failed. Invalid signature." }
```

#### `razorpay-webhook` (Edge Function)
```json
// Request (from Razorpay)
{
  "event": "payment.captured",
  "payload": { "payment": { "entity": { "id": "pay_xxx", "order_id": "order_xxx", "amount": 50000, "status": "captured" } } }
}

// Response — 200 OK
```

### 4.3 Authentication
- **Donors**: No auth required (public access to donation screen)
- **Admin**: Supabase Auth (email/password), session stored in Keychain via Supabase Swift SDK
- Admin role check: `supabase.auth.session` + check `admin_users` table

---

## 5. Edge Cases

### Payment Edge Cases
| # | Scenario | Expected Behavior |
|---|---|---|
| EC-01 | App goes to background during payment | Razorpay SDK handles state restoration |
| EC-02 | Network drops after payment | Webhook handles status update; app shows "verifying" |
| EC-03 | Same order_id submitted twice | Return existing donation (idempotent) |
| EC-04 | User donates ₹0 or negative | Validation prevents — button disabled |
| EC-05 | User donates > ₹1,00,000 | Validation prevents — error shown |
| EC-06 | Razorpay SDK initialization fails | Alert: "Payment service unavailable" |
| EC-07 | App killed during payment flow | Webhook handles; user sees status on reopen |
| EC-08 | iPad multitasking during payment | Razorpay SDK handles modal presentation |

### Admin Edge Cases
| # | Scenario | Expected Behavior |
|---|---|---|
| EC-09 | Admin session expires | Redirect to login view with "Session expired" |
| EC-10 | Admin searches for non-existent donor | Empty list with "No results found" |
| EC-11 | Admin filters by future date | Empty results, no error |
| EC-12 | App memory warning during admin view | SwiftUI handles view lifecycle |

### Data Edge Cases
| # | Scenario | Expected Behavior |
|---|---|---|
| EC-13 | Donor name contains emoji | Stored as-is (UTF-8), displayed correctly |
| EC-14 | Donor email with uppercase | Stored lowercase, case-insensitive search |
| EC-15 | Very long donor name (> 255 chars) | TextField maxLength enforced |
| EC-16 | No internet connectivity | Show offline banner, disable donate button |

---

## 6. KPIs (Success Metrics / Acceptance Criteria)

> Detailed in [KPI.mdc](./KPI.mdc)

| KPI Number | KPI Name | Verification Method | Status |
|---|---|---|---|
| KPI-001 | Payment flow works in test mode | XCUITest with test card | Pending |
| KPI-002 | Thank-you screen displayed after donation | XCUITest — verify navigation | Pending |
| KPI-003 | Admin can view donor log | XCUITest — login + verify list | Pending |
| KPI-004 | Donation screen loads < 2 seconds | Xcode Instruments | Pending |
| KPI-005 | Supabase SDK response < 500ms | XCTest + timing | Pending |
| KPI-006 | Zero payment data stored locally | Security audit | Pending |
| KPI-007 | Edge Function verifies payment signature | Integration test | Pending |
| KPI-008 | Admin section protected by auth | XCUITest | Pending |
| KPI-009 | Donor form validates required fields | XCTest | Pending |
| KPI-010 | Universal layout (iPhone + iPad) | Simulator testing | Pending |

---

## 7. Limitations

### Technical Limitations
- **Test Mode Only**: No real money processed; Razorpay test keys
- **No Recurring Donations**: One-time donations only
- **No Receipt/Certificate Generation**: No 80G tax receipt
- **No Push Notifications**: No donation confirmation push
- **No Multi-Cause Support**: Single active cause at launch
- **Xcode Simulator Only**: No Apple Developer Account for TestFlight

### Business Limitations
- **Single NGO**: Platform serves one NGO only
- **Single Currency**: INR only
- **No Donor Accounts**: Donors don't create accounts
- **iOS Only**: No Android or web version
- **No Offline Donations**: Requires internet connectivity

---

## 8. Dependencies

| Dependency | Type | Risk | Mitigation |
|---|---|---|---|
| Razorpay iOS SDK availability | External | Low | CocoaPods/SPM package |
| Supabase Swift SDK | External | Low | SPM package, actively maintained |
| Supabase Edge Functions | External | Medium | Deno-based, deploy via Supabase CLI |
| Supabase availability | External | Low | Managed service, 99.9% SLA |
| Xcode 15+ | Tool | Low | Free on Mac App Store |
| iOS 16+ Simulator | Tool | Low | Included with Xcode |

---

## 9. Future Enhancements (Post-MVP)

| # | Enhancement | Priority |
|---|---|---|
| 1 | Push notification on donation | P1 |
| 2 | 80G tax receipt generation (PDF) | P1 |
| 3 | Multi-cause support | P2 |
| 4 | Recurring donations | P2 |
| 5 | Donor account + donation history | P2 |
| 6 | Share sheet (social sharing) | P3 |
| 7 | Apple Pay integration | P2 |
| 8 | Widget for donation progress | P3 |
| 9 | Android version (Kotlin) | P3 |
| 10 | App Store distribution | P1 |
