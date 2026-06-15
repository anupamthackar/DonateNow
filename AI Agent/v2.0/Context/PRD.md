# Product Requirements Document (PRD) — DonateNow v2.0

> Version: 2.0 — Multi-Cause Donation Platform
> Previous Version: [v1.0 PRD](../../v1.0/PRD.md)
> Phase: 02 — Requirements
> Next: [KPI.mdc](./KPI.mdc) | [Personas.mdc](./Personas.mdc)

---

## 1. Problem Statement

### 1.1 Current System Limitations (v1.0)

DonateNow v1.0 serves a **single NGO** with a **single, hardcoded donation cause**. While it successfully digitized donation collection and eliminated manual tracking, it has fundamental limitations that prevent platform growth:

| # | Limitation | Business Impact |
|---|---|---|
| 1 | Single donation cause/profile | Cannot support multiple fundraising campaigns |
| 2 | No campaign discovery | Donors cannot browse or search for causes |
| 3 | No creator ecosystem | Only the platform owner can create donation profiles |
| 4 | No verification system | Cannot establish trust for user-created campaigns |
| 5 | No tax receipts | Donors cannot claim 80G tax deductions |
| 6 | No recurring donations | Missed opportunity for sustained giving |
| 7 | No transparency tools | No impact reports, progress tracking, or donor walls |
| 8 | No campaign analytics | Campaign creators have no visibility into performance |

### 1.2 Market Gap

- Donors want to discover causes, not just donate to a single hardcoded one.
- Individuals and NGOs want to create their own fundraising campaigns.
- Trust is the #1 barrier — donors need verified, transparent campaigns.
- Tax receipts (80G) are a legal requirement for Indian NGO donations.

### 1.3 Impact on Stakeholders

| Stakeholder | Current Pain (v1.0) | Desired State (v2.0) |
|---|---|---|
| Donors | Single cause, no choice, no receipts | Browse campaigns, get tax receipts, track impact |
| Campaign Creators | Cannot exist | Create campaigns, receive donations, view analytics |
| NGO Admin | Manages one cause | Verifies campaigns, monitors platform, ensures compliance |
| Platform | Static, single-purpose | Scalable multi-cause donation marketplace |

---

## 2. Solution Overview

### 2.1 Product Vision

Transform DonateNow from a **single-cause donation app** into a **multi-cause donation platform** where:

1. **Donors** discover, browse, and donate to verified campaigns.
2. **Campaign Creators** create fundraising profiles, submit verification, and manage donations.
3. **Admins** verify campaigns, monitor transactions, and maintain platform integrity.
4. **The Platform** generates tax receipts, provides AI impact reports, and supports recurring donations.

### 2.2 Core Features (v2.0)

| # | Feature | ID | Description | Priority |
|---|---|---|---|---|
| 1 | Auto-Generate Tax Receipt PDF (80G) | F2-01 | Generate and store downloadable 80G tax receipts | P0 |
| 2 | Recurring Monthly Donation | F2-02 | Subscription-based monthly donations with scheduling | P0 |
| 3 | Campaign Progress Bar | F2-03 | Visual progress toward campaign goal, auto-updating | P0 |
| 4 | Donor Wall | F2-04 | Public contributor list with privacy controls | P1 |
| 5 | AI-Written Impact Report | F2-05 | AI-generated reports from donation/campaign data | P1 |
| 6 | User-Created Donation Profiles | F2-06 | Users create, submit, and manage fundraising campaigns | P0 |
| 7 | Donation Discovery Marketplace | F2-07 | Browse, search, and filter active campaigns | P0 |
| 8 | Campaign Verification System | F2-08 | Admin review and approval workflow for campaigns | P0 |
| 9 | Donation Management Dashboard | F2-09 | Creator dashboard with analytics, logs, and reports | P1 |

### 2.3 Expected Business Impact

| Metric | v1.0 | v2.0 Target |
|---|---|---|
| Active Campaigns | 1 (hardcoded) | Unlimited (user-created) |
| User Roles | Donor + Admin | Donor + Creator + Admin |
| Payment Types | One-time only | One-time + Recurring |
| Tax Compliance | None | Auto 80G receipts |
| Transparency | Basic admin log | AI reports + donor wall + progress bar |
| Discovery | None | Search + filter marketplace |

---

## 3. User Flows

### 3.1 Donor Flow — Discover and Donate

```
Donor opens app
  → Marketplace screen loads with verified campaigns
  → Donor browses / searches / filters campaigns
  → Selects a campaign
  → Views campaign details (description, progress bar, donor wall)
  → Chooses one-time or recurring donation
  → Enters donation amount + donor info
  → Taps "Donate Now"
  → Razorpay Checkout presents payment sheet
  → Payment succeeds
  → Thank-you screen with receipt download option
  → Donation history updated
  → Tax receipt auto-generated and stored
```

### 3.2 Donor Flow — Recurring Donation

```
Donor opens campaign detail
  → Selects "Monthly Donation"
  → Enters monthly amount
  → Fills donor info
  → Authorizes Razorpay subscription
  → Subscription created
  → First payment processed
  → Thank-you screen displayed
  → Monthly charge scheduled
  → Failure handling: retry → notify → pause after 3 failures
```

### 3.3 Campaign Creator Flow

```
User registers / logs in
  → Navigates to "Create Campaign"
  → Fills campaign form:
     - Title
     - Description
     - Donation goal (₹)
     - Campaign category
     - Campaign end date (optional)
  → Uploads verification documents (ID proof, NGO registration, etc.)
  → Submits for verification
  → Status: "Pending Verification"
  → Admin reviews documents
  → Admin approves → Status: "Verified" → Campaign published on marketplace
  → OR Admin rejects → Status: "Rejected" → Creator notified with reason
  → Creator manages live campaign via dashboard
```

### 3.4 Admin Flow — Verification and Monitoring

```
Admin logs in
  → Views verification queue (pending campaigns)
  → Opens campaign details + documents
  → Reviews and either:
     → Approves → Campaign goes live
     → Rejects → Creator notified
  → Monitors platform analytics:
     - Total donations
     - Active campaigns
     - Flagged transactions
     - Subscription health
```

### 3.5 Tax Receipt Flow

```
Donation completed successfully
  → System generates 80G tax receipt PDF:
     - Donor name
     - Amount
     - Date
     - NGO details
     - 80G registration number
     - Unique receipt number
  → Receipt stored in database
  → Donor can download from donation history
```

### 3.6 AI Impact Report Flow

```
Campaign creator requests impact report
  → System collects:
     - Total donations
     - Number of donors
     - Campaign timeline
     - Fund utilization data (if provided)
  → AI generates report:
     - Impact summary
     - Key statistics
     - Visual data points
     - Suggested improvements
  → Report stored and available for download
```

---

## 4. Data Layer Design

### 4.1 Supabase Operations (v2.0 Additions)

| Operation | Method | Auth | Purpose |
|---|---|---|---|
| Fetch all verified campaigns | `supabase.from("donation_profiles").select()` | Anon (RLS) | Marketplace listing |
| Search campaigns | `supabase.from("donation_profiles").select().ilike()` | Anon (RLS) | Search + filter |
| Fetch campaign detail | `supabase.from("donation_profiles").select().eq("id")` | Anon (RLS) | Campaign detail view |
| Create campaign | `supabase.from("donation_profiles").insert()` | Authenticated (Creator) | New campaign |
| Update campaign | `supabase.from("donation_profiles").update()` | Authenticated (Creator) | Edit campaign |
| Submit verification | `supabase.from("verification_requests").insert()` | Authenticated (Creator) | Submit docs |
| Fetch verification queue | `supabase.from("verification_requests").select()` | Authenticated (Admin) | Admin queue |
| Approve/Reject campaign | `supabase.from("verification_requests").update()` | Authenticated (Admin) | Verification |
| Create subscription | Edge Function: `create-subscription` | Authenticated | Recurring setup |
| Cancel subscription | Edge Function: `cancel-subscription` | Authenticated | Cancel recurring |
| Generate tax receipt | Edge Function: `generate-receipt` | System | Auto after payment |
| Generate AI report | Edge Function: `generate-impact-report` | Authenticated (Creator) | AI report |
| Fetch donor wall | `supabase.from("donations").select()` | Anon (RLS) | Public donor list |
| Fetch donation history | `supabase.from("donations").select()` | Authenticated | Donor history |
| Fetch receipts | `supabase.from("tax_receipts").select()` | Authenticated | Receipt history |
| Dashboard stats | `supabase.rpc("get_campaign_stats")` | Authenticated (Creator) | Creator dashboard |
| Platform stats | `supabase.rpc("get_platform_stats")` | Authenticated (Admin) | Admin dashboard |

### 4.2 New Edge Functions (v2.0)

#### `create-subscription` (Edge Function)
```json
// Request
{
  "campaign_id": "uuid",
  "amount": 500,
  "currency": "INR",
  "donor_name": "Rahul Sharma",
  "donor_email": "rahul@example.com",
  "frequency": "monthly"
}

// Response — Success (200)
{
  "subscription_id": "sub_xxxxxxxxx",
  "next_charge_date": "2026-07-12",
  "status": "active"
}

// Response — Error (400)
{ "error": "Subscription creation failed." }
```

#### `cancel-subscription` (Edge Function)
```json
// Request
{ "subscription_id": "sub_xxxxxxxxx" }

// Response — Success (200)
{ "success": true, "cancelled_at": "2026-06-12T14:00:00Z" }
```

#### `generate-receipt` (Edge Function)
```json
// Request (Internal — triggered after verify-payment)
{
  "donation_id": "uuid",
  "donor_name": "Rahul Sharma",
  "donor_email": "rahul@example.com",
  "amount": 500,
  "ngo_name": "Example Foundation",
  "ngo_80g_number": "80G/12345/2025",
  "donation_date": "2026-06-12"
}

// Response — Success (200)
{
  "receipt_id": "uuid",
  "receipt_number": "DN-2026-00001",
  "pdf_url": "https://storage.supabase.co/receipts/DN-2026-00001.pdf"
}
```

#### `generate-impact-report` (Edge Function)
```json
// Request
{
  "campaign_id": "uuid",
  "date_range": { "from": "2026-01-01", "to": "2026-06-12" }
}

// Response — Success (200)
{
  "report_id": "uuid",
  "summary": "Your campaign raised ₹2,50,000 from 150 donors...",
  "statistics": { "total_raised": 250000, "total_donors": 150, "avg_donation": 1667 },
  "generated_at": "2026-06-12T14:00:00Z"
}
```

### 4.3 Authentication (v2.0)

| Role | Auth Method | Access Level |
|---|---|---|
| Donor (Anonymous) | No auth required | Browse campaigns, donate (one-time) |
| Donor (Registered) | Supabase Auth (email/password) | Donation history, receipts, recurring |
| Campaign Creator | Supabase Auth (email/password) | Create campaigns, view dashboard |
| Admin | Supabase Auth (email/password) + admin role | Full platform access |

---

## 5. Edge Cases

### Payment Edge Cases

| # | Scenario | Expected Behavior |
|---|---|---|
| EC-01 | Failed recurring payment | Retry 3 times over 7 days, then pause subscription |
| EC-02 | Duplicate one-time donation submission | Idempotent — return existing donation record |
| EC-03 | Donation to expired campaign | Block with message: "Campaign has ended" |
| EC-04 | Donation exceeds campaign goal | Allow with warning: "Campaign goal already met" |
| EC-05 | Payment succeeds but receipt generation fails | Queue for retry; donor notified when ready |
| EC-06 | Subscription cancelled mid-cycle | No refund for current period; stop future charges |

### Campaign Edge Cases

| # | Scenario | Expected Behavior |
|---|---|---|
| EC-07 | Creator uploads invalid documents | Reject with specific reason |
| EC-08 | Creator edits campaign after verification | Reset to "pending re-verification" for material changes |
| EC-09 | Campaign goal reached | Campaign stays active unless creator ends it |
| EC-10 | Campaign with zero donations after 90 days | Auto-flag for admin review |
| EC-11 | Creator account deactivated | Pause all campaigns; hold existing funds |
| EC-12 | Duplicate campaign submission | Detect and warn based on title + description similarity |

### Verification Edge Cases

| # | Scenario | Expected Behavior |
|---|---|---|
| EC-13 | Admin rejects — creator re-submits | New verification request; previous rejection kept in history |
| EC-14 | Verification documents expire | Notify creator to re-submit updated documents |
| EC-15 | Multiple campaigns by same creator | Each campaign verified independently |

### AI Report Edge Cases

| # | Scenario | Expected Behavior |
|---|---|---|
| EC-16 | AI service unavailable | Queue report; notify creator when ready |
| EC-17 | Campaign with < 5 donations | Generate basic report with disclaimer |
| EC-18 | Report requested for unverified campaign | Block: "Campaign must be verified" |

### Data Edge Cases

| # | Scenario | Expected Behavior |
|---|---|---|
| EC-19 | Donor opts for anonymous donation | Name shown as "Anonymous" on donor wall |
| EC-20 | Very long campaign description (> 5000 chars) | Truncate display; full text on detail page |
| EC-21 | Campaign image upload fails | Allow creation without image; use default placeholder |

---

## 6. KPIs (Success Metrics — Summary)

> Detailed in [KPI.mdc](./KPI.mdc)

| KPI ID | KPI Name | Target | Status |
|---|---|---|---|
| KPI-2-001 | Donation completion rate (marketplace) | ≥ 85% | Pending |
| KPI-2-002 | Campaign creation success rate | ≥ 90% | Pending |
| KPI-2-003 | Verification processing time | < 48 hours | Pending |
| KPI-2-004 | Tax receipt generation success rate | 100% | Pending |
| KPI-2-005 | AI report generation success rate | ≥ 95% | Pending |
| KPI-2-006 | Recurring subscription retention (30-day) | ≥ 80% | Pending |
| KPI-2-007 | Marketplace search response time | < 500ms | Pending |
| KPI-2-008 | Platform uptime | 99.9% | Pending |
| KPI-2-009 | Campaign discovery-to-donation conversion | ≥ 10% | Pending |
| KPI-2-010 | Donor wall render time | < 1s | Pending |

---

## 7. Limitations (v2.0)

### Technical Limitations
- **Test Mode Only**: Razorpay test keys for development
- **iOS Only**: No Android or web version in v2.0
- **Single Currency**: INR only
- **AI Reports**: Quality depends on data volume; limited for low-activity campaigns
- **PDF Storage**: Supabase Storage limits on free tier

### Business Limitations
- **India Only**: 80G format specific to Indian tax law
- **No Payout System**: Platform does not handle fund disbursement to creators (manual process)
- **No Chat/Messaging**: No donor-to-creator communication
- **No Social Sharing**: No built-in social media integration in v2.0

---

## 8. Dependencies (v2.0 Additions)

| Dependency | Type | Risk | Mitigation |
|---|---|---|---|
| Razorpay Subscriptions API | External | Medium | Feature-flag; fallback to manual recurring |
| PDF Generation Library (server-side) | External | Low | Use Deno PDF libraries in Edge Functions |
| AI/LLM API (for impact reports) | External | Medium | Graceful degradation; queue-based retry |
| Supabase Storage (receipts, documents) | External | Low | Managed service; monitor storage limits |
| All v1.0 dependencies | External | Low | Already validated |

---

## 9. Backward Compatibility

### v1.0 Preserved Functionality
- ✅ Existing `causes` table mapped to new `donation_profiles`
- ✅ Existing `donations` table extended, not replaced
- ✅ Existing `admin_users` table extended with roles
- ✅ All v1.0 Edge Functions remain operational
- ✅ Existing donor data migrated without loss
- ✅ Admin login and dashboard preserved (enhanced)

> Migration details: [Migration_Plan.mdc](../Implementation/Migration_Plan.mdc)
