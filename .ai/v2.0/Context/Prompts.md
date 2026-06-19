# Master Prompts — DonateNow v2.0

> Purpose: Catalog of prompts used to generate each v2.0 project artifact.
> Version: 2.0
> Previous: [v1.0 Prompts](../../v1.0/Material/Prompts.md)
> Note: Only prompt definitions exist here. No project content is stored in this file.

---

# New Version 2.0 Features

## Feature 1: Auto Generate Tax Receipt PDF (80G Format)

Requirements:

- Generate donation receipt automatically.

- Allow donor to download receipt.

- Store receipt history.

- Maintain receipt records.

---

## Feature 2: Recurring Monthly Donation

Requirements:

- Monthly donation option.

- Subscription management.

- Payment scheduling.

- Failed payment handling.

---

## Feature 3: Campaign Progress Bar

Display:

Example:

₹50,000 collected from ₹1,00,000 goal

Requirements:

- Show campaign target.

- Show collected amount.

- Update automatically after donation.

---

## Feature 4: Donor Wall

Requirements:

- Public contributor list.

- Donor privacy option.

- Hide name option.

---

## Feature 5: AI Written Impact Report

Requirements:

Generate reports using:

- Donation data

- Campaign data

- Usage information

Output:

- Impact summary

- Statistics

- Generated report

---

# Major New Platform Features

## Feature 6: User Created Donation Profiles

Users can create their own fundraising campaigns.

Requirements:

Creator can:

- Create donation profile

- Add title

- Add description

- Set donation goal

- Upload documents

- Submit verification request

- Manage campaign

---

## Feature 7: Donation Discovery Marketplace

Donors can:

- Browse donation causes

- Search campaigns

- Filter campaigns

- View campaign details

- Donate money

---

## Feature 8: Verification System

Purpose:

Maintain trust and prevent fake campaigns.

Requirements:

- Creator submits documents

- Admin reviews

- Approve/reject campaign

- Maintain verification status

---

## Feature 9: Donation Management Dashboard

Campaign creator can see:

- Total donations

- Donor list

- Payment logs

- Campaign progress

- Reports

---

---

## Prompt 01 → Business Analysis

**Input**: v1.0 business_idea.mdc + v2.0 feature requirements
**Output**: Understanding of transformation from single-cause to multi-cause platform
**Prompt**:
```
Analyze the existing DonateNow v1.0 business idea and the proposed v2.0 features. Identify how the product transforms from a single-cause donation app into a multi-cause donation platform. Document the business evolution, new user roles, new revenue opportunities, and platform growth model.
```

---

## Prompt 02 → Existing System Analysis

**Input**: All v1.0 context files (PRD, KPI, Personas, Architecture, ERD)
**Output**: System analysis report identifying extension points and constraints
**Prompt**:
```
Analyze all v1.0 context engineering files for DonateNow. Identify: existing database schema, existing Edge Functions, existing MVVM architecture, tech stack, security model. Document what can be extended vs. what must be replaced for v2.0. Identify backward compatibility requirements.
```

---

## Prompt 03 → Feature Impact Analysis

**Input**: v2.0 feature list + v1.0 system analysis
**Output**: [Feature_Impact_Analysis.mdc](./Feature_Impact_Analysis.mdc)
**Prompt**:
```
For each v2.0 feature (Tax Receipt, Recurring Donation, Progress Bar, Donor Wall, AI Report, Campaign Creation, Marketplace, Verification, Dashboard), analyze the impact across: business value, frontend (new views/components), backend (new services/Edge Functions), database (new tables/columns), API (new endpoints), testing (new test cases), and security (new threats/policies).
```

---

## Prompt 04 → PRD Generation

**Input**: v1.0 PRD + v2.0 feature requirements + Feature Impact Analysis
**Output**: [PRD.mdc](./PRD.mdc)
**Prompt**:
```
Based on v1.0 PRD.mdc and v2.0 feature requirements, create a Product Requirements Document v2.0 covering: problem statement (v1.0 limitations), solution overview (multi-cause platform), user flows (donor, creator, admin), data layer design (new Edge Functions and SDK operations), edge cases (payment, campaign, verification, AI), KPI summary, limitations, dependencies, and backward compatibility.
```

---

## Prompt 05 → KPI Generation

**Input**: PRD v2.0 + v1.0 KPIs
**Output**: [KPI.mdc](./KPI.mdc)
**Prompt**:
```
Based on PRD v2.0, define measurable KPIs for: core platform metrics (donation rate, campaign creation, verification time), feature-level metrics (each of 9 features), performance (load times, API response), security (RLS, data isolation, file upload), UX (universal layout, accessibility), and system reliability (uptime, data consistency, migration). Use table format with ID, metric, description, verification method, target, status.
```

---

## Prompt 06 → Persona Generation

**Input**: PRD v2.0 + KPI v2.0
**Output**: [Personas.mdc](./Personas.mdc)
**Prompt**:
```
Based on PRD v2.0 and KPI v2.0, create three implementation personas (Frontend/iOS, Backend/Services, Database). For each: define v2.0-specific tech stack additions (PDFKit, Subscriptions API, LLM, Storage), new responsibilities, new deliverables, v2.0 coding standards, and inter-persona interactions. Preserve v1.0 standards and add v2.0 extensions.
```

---

## Prompt 07 → Architecture Design

**Input**: PRD v2.0 + Personas v2.0 + v1.0 Architecture
**Output**: [System_Architecture.mdc](../Architecture/System_Architecture.mdc)
**Prompt**:
```
Based on PRD v2.0, Personas, and v1.0 architecture, design the v2.0 system architecture covering: architecture evolution (before/after comparison), updated MVVM structure, new Edge Functions, new services, navigation architecture (TabView + NavigationStack for marketplace, creator, admin), role-based access architecture, file storage architecture (Supabase Storage), and deployment architecture.
```

---

## Prompt 08 → Database Design

**Input**: PRD v2.0 + Database Persona v2.0 + v1.0 ERD
**Output**: [Database_Changes.mdc](../Architecture/Database_Changes.mdc)
**Prompt**:
```
Based on PRD v2.0, Database Persona, and v1.0 ERD, design the v2.0 database schema evolution covering: existing tables to extend, new tables (users, donation_profiles, payment_logs, verification_requests, tax_receipts, subscriptions, campaign_progress, impact_reports), relationships, status enums, indexes, RLS policies (role-based), migration SQL, and seed data.
```

---

## Prompt 09 → API Design

**Input**: PRD v2.0 + Architecture v2.0 + Database v2.0
**Output**: [API_Changes.mdc](../Architecture/API_Changes.mdc)
**Prompt**:
```
Based on PRD v2.0, Architecture, and Database schema, document the v2.0 API evolution covering: existing Edge Functions (preserved), new Edge Functions (create-subscription, cancel-subscription, generate-receipt, generate-impact-report, subscription-webhook), new Supabase SDK operations, request/response contracts, authentication requirements, and error responses.
```

---

## Prompt 10 → TDD Test Generation

**Input**: PRD v2.0 + KPI v2.0 + Features
**Output**: [TDD_Strategy.mdc](../Testing/TDD_Strategy.mdc) + [Test_Cases.mdc](../Testing/Test_Cases.mdc)
**Prompt**:
```
Based on PRD v2.0 and KPI v2.0, create a TDD strategy (Red-Green-Refactor methodology) and comprehensive test cases for all v2.0 features. Test case format: ID, feature, scenario, preconditions, steps, expected result, test type (unit/integration/UI), associated KPIs. Cover: campaign creation, verification, donation, payment logs, receipt generation, subscription, AI report, marketplace, dashboard.
```

---

## Prompt 11 → Implementation Planning

**Input**: All v2.0 context files
**Output**: [Feature_Implementation_Plan.mdc](../Implementation/Feature_Implementation_Plan.mdc)
**Prompt**:
```
Based on all v2.0 context files, create a phased implementation plan: Phase 1 (Architecture + Database), Phase 2 (Campaign Creation), Phase 3 (Marketplace), Phase 4 (Payments + Receipts), Phase 5 (AI Reporting), Phase 6 (Testing + Release). For each phase: deliverables, files, dependencies, KPIs, estimated effort, and acceptance criteria.
```

---

## Prompt 12 → Risk Analysis

**Input**: All v2.0 context files + v1.0 system analysis
**Output**: Risk section in Project_Scope.mdc
**Prompt**:
```
Based on all v2.0 context files and v1.0 system state, identify risks across: technical (SDK compatibility, migration), business (creator adoption, donor trust), security (file uploads, data isolation), performance (marketplace scale), and operational (verification bottleneck, AI reliability). For each: probability, impact, mitigation strategy.
```

---

## Prompt 13 → Migration Planning

**Input**: v1.0 ERD + v2.0 Database Changes + v1.0 Data
**Output**: [Migration_Plan.mdc](../Implementation/Migration_Plan.mdc)
**Prompt**:
```
Based on v1.0 ERD and v2.0 Database Changes, create a migration plan covering: v1.0 data inventory (causes, donations, admin_users), mapping to v2.0 schema (causes → donation_profiles, admin_users → users), migration SQL scripts, rollback plan, data validation checks, zero-downtime strategy, and testing approach.
```

---

## Prompt 14 → Final Review

**Input**: All v2.0 context files
**Output**: Gap analysis report
**Prompt**:
```
Review all v2.0 context engineering files for DonateNow. Identify: missing requirements, contradictions between files, unverified KPIs, unaddressed edge cases, security gaps, incomplete cross-references, migration risks, TDD coverage gaps, and persona deliverable completeness. Generate a gap analysis report with severity ratings.
```
