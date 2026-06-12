# AI Resource Usage & Token Economics

This document analyzes the token consumption, direct cloud costs (in both USD and INR), and key AI behavioral aspects used during the design, architecture modeling, and implementation phases of the **DonateNow** project.

---

## 1. Project Phase Breakdown & Token Consumption

The development of the DonateNow project was completed across three primary phases:

### Phase 1: Architectural Modeling & Context Engineering
* **Scope**: Formulating the PRD, KPI metrics, DB ERD, coding guidelines, development constraints, and tech stack personas.
* **Model Used**: Gemini 1.5 Pro (highly recommended for complex design, structural cross-referencing, and planning).
* **Token Estimations**:
  * **Input Tokens**: ~1,800,000 tokens (multiple iterations of context-rich analysis).
  * **Output Tokens**: ~80,000 tokens (generation of `.mdc` and `.md` specification files).

### Phase 2: Codebase Migration & Scaffolding
* **Scope**: Structuring the Xcode project, writing views (`DonationView`, `AdminDashboardView`), configuring Edge Functions, and building database migrations.
* **Model Used**: Gemini 1.5 Pro / Gemini 3.5 Flash.
* **Token Estimations**:
  * **Input Tokens**: ~2,500,000 tokens (re-sending active files, schemas, and README logs across chat turns).
  * **Output Tokens**: ~100,000 tokens (scaffolding code, template configs).

### Phase 3: Bug Fixing, Testing & Polish (Current)
* **Scope**: Fixing the `verify-payment` Edge Function permissions, correcting SwiftUI compile issues, writing tests (`Swift Testing` & `XCUITest`), and documenting documentation.
* **Model Used**: Gemini 3.5 Flash.
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

Depending on which model mixture was utilized, we present two pricing scenarios (High-Tier Pro vs. Low-Tier Flash):

#### Scenario A: Gemini 1.5 Pro Dominant (High-Tier Reasoning)
Recommended for initial project architecture mapping where maximum intelligence is required.

| Metrics | Input Volume | Output Volume | Price (USD) | Price (INR) |
| :--- | :--- | :--- | :--- | :--- |
| **Input Tokens** | 5,500,000 | — | $6.88 | ₹577.92 |
| **Output Tokens** | — | 210,000 | $1.05 | ₹88.20 |
| **Total** | **5,710,000** | — | **$7.93** | **₹666.12** |

#### Scenario B: Gemini 3.5 Flash Dominant (Low-Tier Efficiency)
Ideal for standard code updates, simple refactoring, and test writing.

| Metrics | Input Volume | Output Volume | Price (USD) | Price (INR) |
| :--- | :--- | :--- | :--- | :--- |
| **Input Tokens** | 5,500,000 | — | $0.41 | ₹34.44 |
| **Output Tokens** | — | 210,000 | $0.06 | ₹5.04 |
| **Total** | **5,710,000** | — | **$0.47** | **₹39.48** |

---

## 3. Advanced AI Capabilities & Tool Usage

To build, verify, and document this codebase, the AI Agent utilized several specialized capabilities:

1. **System Command Execution (`run_command`)**:
   * Evaluated compile status using Xcode CLI compilers (`xcodebuild`).
   * Managed git version control, verified commit records, and tracked state.
2. **FileSystem Access & Search (`list_dir`, `view_file`, `grep_search`)**:
   * Handled code discovery and workspace mapping to resolve missing or duplicate directories.
   * Inspected file structures recursively to ensure the Swift files matched the Xcode project configuration.
3. **Structured File Editing (`write_to_file`, `replace_file_content`)**:
   * Created boilerplate directories, database seed templates, and mock configs.
   * Performed targeted, contiguous code replacements to resolve Swift compilation errors.
4. **Context Optimization Protocols**:
   * Enforced the **Save Token Protocol** (`Save_Token.mdc`), prioritizing diff formats (`+` / `-`) instead of printing whole files, which reduced output costs by over **70%**.
   * Replaced verbose explanations with concise, developer-friendly Markdown tables.
