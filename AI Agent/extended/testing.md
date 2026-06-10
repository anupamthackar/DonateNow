# Testing Strategy — DonateNow

> Reference: [PRD.mdc](../PRD.mdc) | [KPI.mdc](../KPI.mdc) | [architecture.mdc](./architecture.mdc) | [ERD.mdc](./ERD.mdc) | [security.mdc](./security.mdc)

---

## 1. Testing Pyramid

```
         ┌─────────┐
         │  E2E    │  ← 3 critical flows
         │ Tests   │
        ┌┴─────────┴┐
        │Integration │  ← API routes + Supabase + Razorpay
        │  Tests     │
       ┌┴────────────┴┐
       │  Unit Tests   │  ← Utility functions, validation, components
       └───────────────┘
```

---

## 2. Unit Tests

### What to Test
| Module | Test Cases |
|---|---|
| Amount Validation | Min ₹1, Max ₹100000, reject negative, reject zero, reject non-numeric |
| Donor Form Validation | Required name, valid email format, optional phone, phone format |
| Currency Formatting | ₹500 → "₹500.00", handle decimals, handle large amounts |
| Razorpay Signature | Valid signature passes, invalid signature fails, empty signature fails |
| Status Mapping | Map Razorpay events to donation statuses correctly |
| Date Formatting | ISO to readable format, timezone handling |

### Tools
- **Framework**: Jest
- **Component Testing**: React Testing Library
- **Command**: `npm run test`

---

## 3. Integration Tests

### API Route Tests
| Endpoint | Test Cases |
|---|---|
| `POST /api/create-order` | Valid amount → returns order_id; Invalid amount → 400; Missing amount → 400 |
| `POST /api/verify-payment` | Valid signature → 200 + donation saved; Invalid signature → 400; Missing fields → 400 |
| `POST /api/webhook/razorpay` | Valid webhook → 200 + status updated; Invalid signature → 401; Duplicate event → 200 (idempotent) |
| `GET /api/admin/donations` | Authenticated → returns donations; Unauthenticated → 401; With filters → filtered results |

### Supabase Integration Tests
| Operation | Test Cases |
|---|---|
| Insert Donation | Valid data → row created; Missing required field → error |
| Read Donations | Admin → returns all; Anon → returns nothing (RLS) |
| Update Status | Valid transition → updated; Invalid ID → no rows affected |
| Read Causes | Anon → returns active causes only; Inactive causes hidden |

### Tools
- **Framework**: Jest + Supertest (for API routes)
- **Database**: Supabase test project (separate from production)
- **Command**: `npm run test:integration`

---

## 4. End-to-End (E2E) Tests

### Critical Flow 1: Successful Donation
```
1. Navigate to / (Donation Page)
2. Verify cause title and description are displayed
3. Select ₹500 predefined amount
4. Fill donor name: "Test Donor"
5. Fill donor email: "test@example.com"
6. Click "Donate Now"
7. Razorpay checkout opens
8. Complete payment with test card: 4111 1111 1111 1111
9. Verify redirect to /thank-you
10. Verify thank-you page shows "₹500" and donation reference
```

### Critical Flow 2: Admin Views Donation
```
1. Navigate to /admin/login
2. Enter admin credentials
3. Verify redirect to /admin dashboard
4. Verify total donations count updated
5. Navigate to /admin/donors
6. Verify "Test Donor" appears in donor log
7. Verify amount shows ₹500
8. Verify date is today
```

### Critical Flow 3: Failed Payment
```
1. Navigate to / (Donation Page)
2. Select ₹500 amount
3. Fill donor info
4. Click "Donate Now"
5. Razorpay checkout opens
6. Cancel/close checkout
7. Verify user stays on donation page
8. Verify error message displayed
9. Verify no donation record created with 'completed' status
```

### Tools
- **Framework**: Playwright or Cypress
- **Command**: `npm run test:e2e`

---

## 5. Razorpay Test Mode Testing

### Test Credentials
| Type | Value | Result |
|---|---|---|
| Test Card (Success) | 4111 1111 1111 1111 | Payment succeeds |
| Test Card (Failure) | Use Razorpay test dashboard to simulate | Payment fails |
| Test UPI (Success) | success@razorpay | Payment succeeds |
| Test UPI (Failure) | failure@razorpay | Payment fails |
| Test Netbanking | Any test bank | Payment succeeds |

### Webhook Testing
- Use Razorpay Dashboard → Webhooks → "Test Webhook" button
- Or use `ngrok` to expose local server for webhook testing
- Verify signature validation works correctly
- Verify idempotent handling (same event sent twice)

---

## 6. Security Tests

| Test | Method | Expected Result |
|---|---|---|
| Access `/api/admin/donations` without auth | Manual / Integration | 401 Unauthorized |
| Access `/admin` without auth | E2E | Redirect to /admin/login |
| Send webhook with invalid signature | Integration | 401 Rejected |
| SQL injection in donor name | Integration | Sanitized, no SQL execution |
| XSS in donor name field | E2E | HTML escaped, no script execution |
| Access donations table as `anon` role | Supabase RLS test | Empty result (blocked) |

---

## 7. Performance Tests

| Metric | Target | Test Method |
|---|---|---|
| Donation page load | < 3 seconds | Lighthouse CI |
| API response (create-order) | < 500ms | Jest + timing |
| API response (verify-payment) | < 500ms | Jest + timing |
| Admin dashboard load | < 3 seconds | Lighthouse CI |
| Donor table (100 records) | < 2 seconds | Manual + timing |

---

## 8. Test Coverage Targets

| Layer | Minimum Coverage |
|---|---|
| Unit Tests | 80% |
| API Routes | 100% (all endpoints) |
| E2E Critical Paths | 100% (3 flows above) |
| Security Tests | 100% (all items above) |

---

## 9. KPI Verification Matrix

> Cross-reference with [KPI.mdc](../KPI.mdc)

| KPI | Test Type | How to Verify |
|---|---|---|
| Payment flow works in test mode | E2E Test (Flow 1) | Complete donation with test card |
| Thank-you page displayed after donation | E2E Test (Flow 1, Step 9-10) | Verify redirect + content |
| Admin can view donor log | E2E Test (Flow 2) | Login + verify donor table |

---

## 10. Test Environment Setup

```
# Install test dependencies
npm install --save-dev jest @testing-library/react @testing-library/jest-dom playwright

# Create test Supabase project (separate from dev)
# Configure test environment variables in .env.test

# Run all tests
npm run test           # Unit tests
npm run test:integration  # Integration tests
npm run test:e2e       # E2E tests
npm run test:all       # All tests
```
