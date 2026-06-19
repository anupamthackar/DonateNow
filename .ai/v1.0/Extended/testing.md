# Testing Strategy — DonateNow

> Reference: [PRD.mdc](../PRD.mdc) | [KPI.mdc](../KPI.mdc) | [architecture.mdc](./architecture.mdc) | [ERD.mdc](./ERD.mdc) | [security.mdc](./security.mdc)

---

## 1. Testing Pyramid

```
         ┌─────────┐
         │  UI     │  ← 3 critical flows (XCUITest)
         │ Tests   │
        ┌┴─────────┴┐
        │Integration │  ← Supabase SDK + Edge Functions
        │  Tests     │
       ┌┴────────────┴┐
       │  Unit Tests   │  ← ViewModels, Validators, Logic (XCTest)
       └───────────────┘
```

---

## 2. Unit Tests (XCTest)

### What to Test
| Module | Test Cases |
|---|---|
| Amount Validation | Min ₹1, Max ₹100000, reject negative, reject zero |
| Donor Form Validation | Required name, valid email format, phone format |
| Currency Formatting | ₹500 → "₹500.00", handle decimals, large amounts |
| Edge Function Validation | Validate JSON encoding/decoding of requests/responses |
| ViewModel State | Verify state transitions (idle → loading → success/error) |
| Date Formatting | ISO8601 string to localized Swift Date format |

### Tools
- **Framework**: XCTest
- **Execution**: Run via Xcode (Cmd+U) or `xcodebuild test`

### Example Test (Swift)
```swift
func testAmountValidation() {
    let validator = DonationValidator()
    XCTAssertTrue(validator.isValidAmount(500))
    XCTAssertFalse(validator.isValidAmount(0))
    XCTAssertFalse(validator.isValidAmount(-50))
    XCTAssertFalse(validator.isValidAmount(100001))
}
```

---

## 3. Integration Tests

### What to Test
| Module | Test Cases |
|---|---|
| Supabase Connect | Initialize SDK, test anonymous query to `causes` |
| Create Order | Call `create-order` Edge Function, verify order_id returned |
| Verify Payment | Call `verify-payment` Edge Function with invalid signature (expect failure) |
| Webhook | Send mock payload to webhook URL, verify DB update |

### Notes
- Integration tests that modify the database should run against a **Supabase local development environment** or a dedicated staging project, NOT production.

---

## 4. UI Tests (XCUITest)

### What to Test
| Flow | Test Cases |
|---|---|
| Donation Flow | Launch app → Select ₹500 → Fill Form → Tap Donate → Verify Razorpay opens |
| Admin Flow | Tab Admin → Enter credentials → Verify Dashboard loads → Tap Donor Log → Verify List |
| Form Errors | Tap Donate with empty form → Verify Validation Alerts appear |

### Tools
- **Framework**: XCUITest
- **Execution**: Xcode Simulator (iPhone 15 Pro, iPad Pro)

---

## 5. Manual Testing (Checklist)

Since automated tests cannot easily complete a Razorpay payment flow due to the third-party native sheet, manual testing is required for the final mile.

### Razorpay Test Mode Verification
1. Open app in Simulator.
2. Fill form and tap Donate.
3. In Razorpay Sheet, select Card.
4. Use test card: `4111 1111 1111 1111`, expiry `12/25`, CVV `123`.
5. Enter any OTP.
6. Verify app navigates to `ThankYouView`.
7. Verify donation record exists in Supabase Dashboard.

### Network Testing (Network Link Conditioner)
1. Turn on 100% Loss.
2. Attempt to donate.
3. Verify "No connection" alert appears. App must not crash.

---

## 6. Performance Testing

### Tools
- **Xcode Instruments**: Time Profiler, Allocations.

### Targets
- **App Launch**: < 2 seconds.
- **Memory**: < 150 MB during donation flow.
- **Scroll**: 60 FPS on DonorLogView.

---

## 7. QA Gates Before Launch

- [ ] All XCTests pass.
- [ ] All XCUITests pass on iPhone and iPad simulators.
- [ ] Manual test of Razorpay happy path successful.
- [ ] Manual test of Razorpay cancelled path successful.
- [ ] Memory profile shows no leaks.
- [ ] App builds with zero warnings in Xcode.
