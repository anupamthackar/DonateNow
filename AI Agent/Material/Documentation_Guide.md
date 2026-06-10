# Documentation Guide — DonateNow

> Purpose: Explains every context engineering file, its purpose, who uses it, interview relevance, and industry standards (Native iOS Context).
> Reference: [context_map.mdc](../extended/context_map.mdc) | [Prompts.md](./Prompts.md)

---

## File 1: business_idea.mdc

### What is it?
A document capturing the initial business concept — the problem, proposed solution, target users, and high-level features for the native iOS application.

### Why do we need it?
It establishes the **foundation context**. Without it, the iOS app lacks business justification.

### Who uses it?
| Role | Usage |
|---|---|
| Product Manager | Validates business viability |
| Stakeholders | Approves iOS direction |
| AI Agent | Understands project purpose |

---

## File 2: PRD.mdc (Product Requirements Document)

### What is it?
A formal document defining **what** needs to be built natively on iOS, **why** it's needed, and **how** success will be measured. It maps out SDK integrations (Razorpay, Supabase).

### Why do we need it?
- Prevents scope creep.
- Defines iOS-specific edge cases (e.g., app going to background during payment).
- Specifies Supabase Edge Function contracts to keep secrets off the device.

### Who uses it?
| Role | Usage |
|---|---|
| iOS Engineer | Implements native features |
| Services Engineer | Implements Edge Functions |
| AI Agent | Primary reference for implementation |

---

## File 3: KPI.mdc

### What is it?
A document tracking measurable success criteria specific to iOS (e.g., Memory footprint in Instruments, App Launch Time).

### Why do we need it?
- Objective measurement of iOS performance and UX.
- Provides acceptance gates for TestFlight/App Store submission.

---

## File 4: Personas (iOS/UI, Services, Database)

### What is it?
Implementation personas that define the architecture (MVVM, Swift SDKs, Deno Edge Functions).

### Why do we need it?
- Establishes Swift/SwiftUI tech stack.
- Sets hard rules (no network calls in Views, use `@Observable`).

---

## File 5: Project_Scope.mdc

### What is it?
Defines project boundaries — e.g., Universal App (iPhone + iPad), iOS 16 minimum, no Android app, Simulator distribution for MVP.

---

## File 6: Project_Boundaries.mdc

### What is it?
Strict development rules for Xcode and Swift. Prohibits magic strings, forced unwraps (`!`), and exposing `key_secret`.

---

## File 7: Detailed_Project_Scope.md

### What is it?
An implementation-ready document that consolidates ALL context files into technical iOS modules, mapping features to `DonationView.swift`, `DonationViewModel.swift`, etc.

---

## File 8: Save_Token.mdc

### What is it?
A protocol for optimizing AI-agent communication to minimize token usage by focusing on Swift diffs instead of full files.

---

## Common Mistakes in iOS Context Engineering

| # | Mistake | Impact | Prevention |
|---|---|---|---|
| 1 | Assuming a web backend | Security risks if secrets put in iOS app | Explicitly state Edge Functions are needed |
| 2 | Forgetting iPad layout | Rejected by App Store | Add Universal constraint to Scope |
| 3 | Not defining Apple Developer status | Blocks deployment | Explicitly state Simulator/TestFlight limits |
| 4 | No State Management strategy | Spaghetti SwiftUI code | Mandate MVVM and `@Observable` |

---

## File Map (Quick Reference)

```
AI Agent/
├── business_idea.mdc          → Phase 01: Foundation
├── PRD.mdc                    → Phase 02: Requirements
├── KPI.mdc                    → Phase 03: Success Metrics
├── persona/                   → Phase 04: Tech Decisions
│   ├── frontend_persona.mdc     (iOS/UI)
│   ├── backend_persona.mdc      (Services)
│   └── database_persona.mdc     (Database)
├── Project_Scope.mdc          → Phase 05: Scope Definition
├── Project_Boundaries.mdc     → Phase 06: Development Rules
├── Save_Token.mdc             → AI Optimization
├── Material/
│   ├── Detailed_Project_Scope.md
│   ├── Documentation_Guide.md
│   └── Prompts.md
└── extended/                  → Phase 08-11: Deep Technical
    ├── architecture.mdc       (MVVM)
    ├── ERD.mdc                (Supabase)
    ├── security.mdc           (Keychain, ATS)
    ├── testing.md             (XCTest)
    ├── error_handling.mdc     (Swift Errors)
    ├── style-guide.mdc        (SwiftUI Tokens)
    ├── deployment.mdc         (TestFlight)
    ├── observability.mdc      (OSLog)
    ├── context_map.mdc
    ├── Config.example.xcconfig
    └── features/
        └── features.mdc       (User Stories)
```
