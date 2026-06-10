# Master Prompts — DonateNow

> Purpose: Catalog of prompts used to generate each project artifact.
> Note: Only prompt definitions exist here. No project content is stored in this file.
> Reference: [context_map.mdc](../extended/context_map.mdc)

---

## Prompt 01 → Business Analysis

**Input**: Problem statement from stakeholder
**Output**: [business_idea.mdc](../business_idea.mdc)
**Prompt**:
```
Analyze the given problem statement for the native iOS application. Identify the business problem, pain points, target users, proposed solution, core features, and success criteria. Create a business_idea.mdc document.
```

---

## Prompt 02 → PRD Creation

**Input**: [business_idea.mdc](../business_idea.mdc)
**Output**: [PRD.mdc](../PRD.mdc)
**Prompt**:
```
Based on business_idea.mdc, create a Product Requirements Document covering: problem statement, solution overview, user flows (happy + alternative paths for iOS), Edge Function API design, edge cases, KPI summary table, and limitations. Reference business_idea.mdc.
```

---

## Prompt 03 → KPI Definition

**Input**: [PRD.mdc](../PRD.mdc) + [business_idea.mdc](../business_idea.mdc)
**Output**: [KPI.mdc](../KPI.mdc)
**Prompt**:
```
Based on PRD.mdc, define measurable iOS KPIs covering: core success criteria, functional metrics (XCTest), performance targets (Xcode Instruments), security requirements, and UX standards. Use table format.
```

---

## Prompt 04 → Persona Generation

**Input**: [PRD.mdc](../PRD.mdc) + [KPI.mdc](../KPI.mdc)
**Output**: [persona/frontend_persona.mdc](../persona/frontend_persona.mdc) | [persona/backend_persona.mdc](../persona/backend_persona.mdc) | [persona/database_persona.mdc](../persona/database_persona.mdc)
**Prompt**:
```
Based on PRD.mdc and KPI.mdc, create three implementation personas (iOS/UI, Services, Database). For each: define tech stack with justification (SwiftUI, MVVM, Supabase Swift SDK, Edge Functions), responsibilities, coding standards, rules, and deliverables.
```

---

## Prompt 05 → Project Scope Creation

**Input**: [PRD.mdc](../PRD.mdc) + [KPI.mdc](../KPI.mdc) + [Personas](../persona/)
**Output**: [Project_Scope.mdc](../Project_Scope.mdc)
**Prompt**:
```
Based on PRD.mdc, KPI.mdc, and Personas, create a Project Scope document for the native iOS app covering: executive summary, business context, goals, objectives, stakeholders, target users, in-scope/out-of-scope items, assumptions, constraints, risks, dependencies, success criteria.
```

---

## Prompt 06 → Project Boundaries Creation

**Input**: [Project_Scope.mdc](../Project_Scope.mdc) + [Personas](../persona/)
**Output**: [Project_Boundaries.mdc](../Project_Boundaries.mdc)
**Prompt**:
```
Based on Project_Scope.mdc and Personas, create strict development rules for Xcode/Swift development covering: coding standards, MVVM constraints, AI agent decision order, file modification rules, communication rules, quality gates, and prohibited actions (e.g. no hardcoded secrets).
```

---

## Prompt 07 → Technical Architecture

**Input**: [PRD.mdc](../PRD.mdc) + [Personas](../persona/)
**Output**: [extended/architecture.mdc](../extended/architecture.mdc)
**Prompt**:
```
Based on PRD.mdc and Personas, design the system architecture covering: MVVM architecture overview, tech stack mapping, Xcode project folder structure, Edge Function architecture, data flow diagrams, security architecture, and deployment architecture.
```

---

## Prompt 08 → Database Design

**Input**: [PRD.mdc](../PRD.mdc) + [persona/database_persona.mdc](../persona/database_persona.mdc)
**Output**: [extended/ERD.mdc](../extended/ERD.mdc)
**Prompt**:
```
Based on PRD.mdc, Database Persona, and Architecture, design the database schema covering: ER diagram, table definitions with column types/constraints, status enums, indexes, full SQL migration script, seed data, and RLS rules.
```

---

## Prompt 09 → Implementation Planning

**Input**: All above files
**Output**: [Detailed_Project_Scope.md](./Detailed_Project_Scope.md)
**Prompt**:
```
Consolidate all context files into an implementation-ready Detailed Project Scope for iOS. Map every feature to: SwiftUI View, ViewModel, Edge Function, KPIs. Define implementation order (phases), complete Xcode file manifest, and cross-reference summary.
```

---

## Prompt 10 → Final Review & Gap Analysis

**Input**: All context files
**Output**: Gap analysis report
**Prompt**:
```
Review all iOS context engineering files for DonateNow. Identify: missing requirements, contradictions between files, unverified KPIs, unaddressed edge cases, security gaps, and incomplete cross-references. Generate a gap analysis report.
```
