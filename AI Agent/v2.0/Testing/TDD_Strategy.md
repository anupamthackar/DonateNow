# TDD Strategy — DonateNow v2.0

> Version: 2.0 — Multi-Cause Donation Platform
> Reference: [PRD.mdc](../Context/PRD.mdc) | [KPI.mdc](../Context/KPI.mdc) | [Project_Boundaries.mdc](../Context/Project_Boundaries.mdc)

---

## 1. TDD Methodology

### Red-Green-Refactor Cycle

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│    ┌─────────┐     ┌─────────┐     ┌──────────┐     │
│    │  RED    │────►│  GREEN  │────►│ REFACTOR │     │
│    │         │     │         │     │          │     │
│    │ Write   │     │ Write   │     │ Improve  │     │
│    │ failing │     │ minimum │     │ design   │     │
│    │ test    │     │ code to │     │ without  │     │
│    │ first   │     │ pass    │     │ breaking │     │
│    │         │     │         │     │ tests    │     │
│    └─────────┘     └─────────┘     └────┬─────┘     │
│         ▲                               │           │
│         └───────────────────────────────┘           │
│                    Repeat                            │
└──────────────────────────────────────────────────────┘
```

### Step 1: RED — Write a Failing Test
- Write a test that describes the expected behavior.
- Run the test — it MUST fail (because the feature doesn't exist yet).
- If it passes, the test is wrong or the feature already exists.

### Step 2: GREEN — Write Minimum Code
- Write the simplest code to make the failing test pass.
- Do NOT over-engineer. Only implement what the test requires.
- Run all tests — the new test must pass, and no existing tests break.

### Step 3: REFACTOR — Improve Design
- Clean up the code without changing behavior.
- Extract functions, rename variables, improve structure.
- Run all tests — they must still pass.

---

## 2. Testing Pyramid

```
                    ┌───────────────┐
                    │   UI Tests    │     ← Fewest (expensive, slow)
                    │   (XCUITest)  │        End-to-end flows
                    ├───────────────┤
                    │  Integration  │     ← Middle layer
                    │   Tests      │        Edge Functions + DB
                    ├───────────────┤
                    │  Unit Tests   │     ← Most (cheap, fast)
                    │  (XCTest)     │        ViewModels, Services, Utils
                    └───────────────┘
```

| Level | Tool | Scope | Target | v2.0 Count |
|---|---|---|---|---|
| Unit Tests | XCTest | ViewModels, Services, Validators, Models | Logic correctness | ~80 tests |
| Integration Tests | XCTest + Supabase | Edge Functions, DB operations, RLS | Data flow | ~30 tests |
| UI Tests | XCUITest | End-to-end user flows | User experience | ~15 tests |

---

## 3. Testing Tools & Framework

| Tool | Purpose | Usage |
|---|---|---|
| XCTest | Unit and integration testing framework | ViewModels, Services, Repositories |
| XCUITest | UI automation testing | User flows, navigation, form validation |
| Xcode Instruments | Performance profiling | Memory, CPU, rendering |
| Network Link Conditioner | Network condition simulation | Offline handling, slow networks |
| Supabase CLI | Local Edge Function testing | `supabase functions serve` |

---

## 4. TDD Rules for v2.0

### Mandatory TDD Features
All v2.0 features MUST follow TDD:

1. **Campaign Creation** — Validate form inputs, status transitions
2. **Verification System** — State machine transitions, admin actions
3. **Donation Flow** — Amount validation, campaign validation
4. **Receipt Generation** — Receipt number generation, field validation
5. **Subscription Management** — Create, cancel, status transitions
6. **AI Report** — Data aggregation, error handling
7. **Marketplace Search** — Query construction, filter logic
8. **Progress Bar** — Calculation accuracy
9. **Donor Wall** — Privacy filter logic

### TDD Workflow Per Feature

```
1. Read feature requirements from PRD.mdc
2. Identify KPIs from KPI.mdc
3. Write test cases (from Test_Cases.mdc)
4. Create test file: DonateNowTests/<Feature>Tests.swift
5. Write first failing test (RED)
6. Implement in ViewModel/Service (GREEN)
7. Refactor (REFACTOR)
8. Repeat for next test case
9. Run full test suite
10. Verify KPIs
```

---

## 5. Test Organization

### File Structure
```
DonateNowTests/
├── Unit/
│   ├── ViewModels/
│   │   ├── MarketplaceViewModelTests.swift
│   │   ├── CreateCampaignViewModelTests.swift
│   │   ├── CampaignDetailViewModelTests.swift
│   │   ├── CreatorDashboardViewModelTests.swift
│   │   ├── VerificationViewModelTests.swift
│   │   ├── ReceiptViewModelTests.swift
│   │   ├── SubscriptionViewModelTests.swift
│   │   └── ImpactReportViewModelTests.swift
│   ├── Services/
│   │   ├── CampaignSearchServiceTests.swift
│   │   ├── ReceiptServiceTests.swift
│   │   ├── SubscriptionServiceTests.swift
│   │   └── AnalyticsServiceTests.swift
│   ├── Models/
│   │   ├── DonationProfileTests.swift
│   │   ├── SubscriptionTests.swift
│   │   └── TaxReceiptTests.swift
│   └── Utils/
│       ├── ValidatorsTests.swift
│       └── FormattersTests.swift
├── Integration/
│   ├── CampaignRepositoryTests.swift
│   ├── VerificationRepositoryTests.swift
│   ├── DonationRepositoryTests.swift
│   └── EdgeFunctionTests.swift
└── UI/
    ├── MarketplaceFlowTests.swift
    ├── CampaignCreationFlowTests.swift
    ├── DonationFlowTests.swift
    ├── VerificationFlowTests.swift
    └── ReceiptDownloadFlowTests.swift
```

---

## 6. Mocking Strategy

### Protocol-Based Mocking

All services use protocols for testability:

```swift
// Protocol
protocol CampaignRepositoryProtocol {
    func fetchVerifiedCampaigns() async throws -> [DonationProfile]
    func createCampaign(_ campaign: CreateCampaignRequest) async throws -> DonationProfile
    func searchCampaigns(query: String, category: String?) async throws -> [DonationProfile]
}

// Mock for testing
class MockCampaignRepository: CampaignRepositoryProtocol {
    var campaignsToReturn: [DonationProfile] = []
    var shouldThrowError: Bool = false
    var createCampaignCalled = false

    func fetchVerifiedCampaigns() async throws -> [DonationProfile] {
        if shouldThrowError { throw TestError.mockError }
        return campaignsToReturn
    }
    // ... etc
}
```

### What to Mock
- Supabase SDK operations → `MockSupabaseClient`
- Razorpay SDK → `MockPaymentService`
- Edge Function calls → `MockEdgeFunctionClient`
- File storage → `MockStorageService`
- AI API → `MockAIService`

### What NOT to Mock
- Business logic in ViewModels (test the real logic)
- Validators and formatters (test the real implementation)
- Model encoding/decoding (test with real data)

---

## 7. Test Naming Convention

```swift
func test_<what>_<condition>_<expectedResult>()

// Examples:
func test_createCampaign_withValidData_returnsCampaign()
func test_createCampaign_withEmptyTitle_throwsValidationError()
func test_searchCampaigns_withQuery_returnsFilteredResults()
func test_verifyPayment_withInvalidSignature_throwsVerificationError()
func test_generateReceipt_afterPayment_returnsReceiptWithPDF()
func test_cancelSubscription_withActiveSubscription_updatesStatus()
func test_progressBar_afterDonation_updatesPercentage()
func test_donorWall_withAnonymousDonor_hidesName()
```

---

## 8. Code Coverage Targets

| Component | Coverage Target | Priority |
|---|---|---|
| ViewModels | ≥ 90% | Critical |
| Services / Repositories | ≥ 85% | Critical |
| Models (Codable) | ≥ 80% | High |
| Validators / Formatters | ≥ 95% | Critical |
| Views (SwiftUI) | Visual only — no coverage metric | Medium |
| Edge Functions | ≥ 80% (Deno tests) | High |

---

## 9. Continuous Integration

### Test Execution Schedule
| Trigger | Tests Run | Max Duration |
|---|---|---|
| Every commit | Unit tests only | < 60 seconds |
| Pull request | Unit + Integration | < 5 minutes |
| Pre-release | Unit + Integration + UI | < 15 minutes |
| Nightly | Full suite + performance | < 30 minutes |

### Test Quality Rules
1. No test should depend on another test's execution.
2. Tests must be deterministic (no random failures).
3. Each test tests ONE thing.
4. Test data created in `setUp()`, cleaned in `tearDown()`.
5. No network calls in unit tests — mock everything external.
