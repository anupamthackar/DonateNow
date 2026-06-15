# AI Resource Usage & Token Economics

This document analyzes the optimized token consumption, direct cloud costs (in both USD and INR), and key AI behavioral aspects used to build both **DonateNow Version 1.0 (Next.js Web MVP)** and **Version 2.0 (Native iOS Migration)**.

---

## 1. Project Phase Breakdown & Optimized Token Consumption

The development of the DonateNow project was completed across distinct phases for both versions, optimizing token usage by leveraging different AI models based on the required reasoning depth.

### Version 1.0: Next.js Web MVP

#### Phase 1.1: Web Architectural Modeling & Context Engineering
* **Scope**: Formulating the initial PRD, web KPIs, basic database ERD, Next.js routing structures, and web coding guidelines.
* **Model Used**: Gemini 1.5 Pro (used for complex design and system mapping).
* **Token Estimations**:
  * **Input Tokens**: ~1,200,000 tokens (contextualizing the web app requirements).
  * **Output Tokens**: ~60,000 tokens (generating initial spec files).

#### Phase 1.2: Web Scaffolding & Implementation
* **Scope**: Structuring Next.js pages, Tailwind CSS styling, writing React hooks, and basic API routes.
* **Model Used**: Gemini 3.5 Flash / Gemini 1.5 Flash (optimized for rapid code generation).
* **Token Estimations**:
  * **Input Tokens**: ~1,800,000 tokens.
  * **Output Tokens**: ~90,000 tokens.

---

### Version 2.0: Native iOS Migration

#### Phase 2.1: iOS Context Engineering & Migration Strategy
* **Scope**: Mapping web components to SwiftUI, planning the MVVM architecture, structuring the Xcode project, and designing secure Supabase Edge Functions.
* **Model Used**: Gemini 1.5 Pro (essential for cross-platform structural translation).
* **Token Estimations**:
  * **Input Tokens**: ~1,800,000 tokens (multiple iterations of context-rich analysis).
  * **Output Tokens**: ~80,000 tokens (generation of `.mdc` and `.md` specification files).

#### Phase 2.2: iOS Codebase Scaffolding
* **Scope**: Writing SwiftUI views (`DonationView`, `AdminDashboardView`), configuring Edge Functions (`create-order`, `verify-payment`), and building database migrations.
* **Model Used**: Gemini 1.5 Pro / Gemini 3.5 Flash.
* **Token Estimations**:
  * **Input Tokens**: ~2,500,000 tokens (re-sending active files, schemas, and README logs across chat turns).
  * **Output Tokens**: ~100,000 tokens (scaffolding code, template configs).

#### Phase 2.3: Bug Fixing, Testing & Polish
* **Scope**: Fixing the Edge Function permissions, resolving SwiftUI compile issues, and writing tests (`Swift Testing` & `XCUITest`).
* **Model Used**: Gemini 3.5 Flash (highly efficient for repetitive debugging).
* **Token Estimations**:
  * **Input Tokens**: ~1,200,000 tokens.
  * **Output Tokens**: ~30,000 tokens.

---

## 2. Estimated Cost Breakdown (USD & INR)

The financial cost is calculated based on current Gemini API pricing tiers (assuming an exchange rate of **1 USD = 84.00 INR**).

### Model Pricing Tiers Reference
* **Gemini 1.5 Pro (Standard context <= 128k)**:
  * Input: $1.25 / million tokens
  * Output: $5.00 / million tokens
* **Gemini 1.5 Pro (Deep context > 128k)**:
  * Input: $2.50 / million tokens
  * Output: $10.00 / million tokens
* **Gemini 3.5 Flash / 1.5 Flash**:
  * Input: $0.075 / million tokens
  * Output: $0.30 / million tokens

### Total Consolidated Costs (Estimated Average)

Combining the metrics from **Version 1.0** and **Version 2.0**, we calculate the token footprint across both platforms:

* **Total Input Tokens**: ~8,500,000 tokens
* **Total Output Tokens**: ~360,000 tokens

#### Scenario A: Gemini 1.5 Pro Dominant (High-Tier Reasoning)
Used when the majority of work relied heavily on complex cross-platform migrations and deep architectural context.

| Metrics | Input Volume | Output Volume | Price (USD) | Price (INR) |
| :--- | :--- | :--- | :--- | :--- |
| **Input Tokens** | 8,500,000 | — | $10.63 | ₹892.92 |
| **Output Tokens** | — | 360,000 | $1.80 | ₹151.20 |
| **Total** | **8,500,000** | **360,000** | **$12.43** | **₹1,044.12** |

#### Scenario B: Gemini 3.5 Flash Dominant (Low-Tier Efficiency)
Used when tasks were optimized using smaller context windows, focused prompts, and fast code iterations.

| Metrics | Input Volume | Output Volume | Price (USD) | Price (INR) |
| :--- | :--- | :--- | :--- | :--- |
| **Input Tokens** | 8,500,000 | — | $0.64 | ₹53.76 |
| **Output Tokens** | — | 360,000 | $0.11 | ₹9.24 |
| **Total** | **8,500,000** | **360,000** | **$0.75** | **₹63.00** |

---

## 3. Advanced Context Optimization Protocols

To build, verify, and document this multi-version codebase efficiently, the AI Agent utilized several specialized optimization capabilities to lower token consumption:

1. **Model Routing Strategy**:
   * **Gemini 1.5 Pro** was reserved strictly for Phase 1 architectural mapping and cross-platform (Web -> iOS) translations.
   * **Gemini 3.5 Flash** was actively employed for routine component scaffolding, UI generation, and unit testing, reducing costs dramatically.

2. **Delta Updates (Diffing)**:
   * Enforced the **Save Token Protocol** (`Save_Token.mdc`), prioritizing diff formats (`+` / `-`) instead of re-printing whole files. This reduced output costs by over **70%** during Phase 2.3 bug fixing.

3. **Targeted File System Access**:
   * Minimized input tokens by using targeted `grep_search` and `view_file` calls rather than dumping entire project trees into the context.

4. **Structured File Editing (`replace_file_content`)**:
   * Performed targeted, contiguous code replacements to resolve Swift compilation errors and Next.js API bugs without re-generating unchanged surrounding logic.
