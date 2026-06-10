# Master Prompts — DonateNow

> Purpose: Catalog of prompts used to generate each project artifact.
> Note: Only prompt definitions exist here. No project content is stored in this file.
> Reference: [context_map.mdc](./extended/context_map.mdc)

---

## Prompt 01 → Business Analysis

**Input**: Problem statement from stakeholder
**Output**: [business_idea.mdc](./business_idea.mdc)
**Prompt**:
```
Analyze the given problem statement. Identify the business problem, pain points, target users, proposed solution, core features, and success criteria. Create a business_idea.mdc document.
```

---

## Prompt 02 → PRD Creation

**Input**: [business_idea.mdc](./business_idea.mdc)
**Output**: [PRD.mdc](./PRD.mdc)
**Prompt**:
```
Based on business_idea.mdc, create a Product Requirements Document covering: problem statement, solution overview, user flows (happy + alternative paths), API design with request/response contracts, edge cases, KPI summary table, and limitations. Reference business_idea.mdc.
```

---

## Prompt 03 → KPI Definition

**Input**: [PRD.mdc](./PRD.mdc) + [business_idea.mdc](./business_idea.mdc)
**Output**: [KPI.mdc](./KPI.mdc)
**Prompt**:
```
Based on PRD.mdc, define measurable KPIs covering: core success criteria, functional metrics, performance targets, security requirements, and UX standards. Use table format with KPI number, name, description, verification method, target value, and status. Include acceptance criteria gates.
```

---

## Prompt 04 → Persona Generation

**Input**: [PRD.mdc](./PRD.mdc) + [KPI.mdc](./KPI.mdc) + [business_idea.mdc](./business_idea.mdc)
**Output**: [persona/frontend_persona.mdc](./persona/frontend_persona.mdc) | [persona/backend_persona.mdc](./persona/backend_persona.mdc) | [persona/database_persona.mdc](./persona/database_persona.mdc)
**Prompt**:
```
Based on PRD.mdc and KPI.mdc, create three implementation personas (Frontend, Backend, Database). For each: define tech stack with justification, responsibilities, coding standards, rules, and deliverables. Reference PRD and KPI for decisions.
```

---

## Prompt 05 → Project Scope Creation

**Input**: [PRD.mdc](./PRD.mdc) + [KPI.mdc](./KPI.mdc) + [Personas](./persona/)
**Output**: [Project_Scope.mdc](./Project_Scope.mdc)
**Prompt**:
```
Based on PRD.mdc, KPI.mdc, and Personas, create a Project Scope document covering: executive summary, business context, goals, objectives, stakeholders, target users, in-scope/out-of-scope items, assumptions, constraints, risks, dependencies, success criteria, non-functional expectations, future scope, governance, and open questions.
```

---

## Prompt 06 → Project Boundaries Creation

**Input**: [Project_Scope.mdc](./Project_Scope.mdc) + [Personas](./persona/) + [PRD.mdc](./PRD.mdc)
**Output**: [Project_Boundaries.mdc](./Project_Boundaries.mdc)
**Prompt**:
```
Based on Project_Scope.mdc and Personas, create strict development rules covering: coding standards, AI agent decision order, file modification rules, communication rules, quality gates, and prohibited actions. Reference all context files.
```

---

## Prompt 07 → Technical Architecture

**Input**: [PRD.mdc](./PRD.mdc) + [Personas](./persona/) + [business_idea.mdc](./business_idea.mdc)
**Output**: [extended/architecture.mdc](./extended/architecture.mdc)
**Prompt**:
```
Based on PRD.mdc and Personas, design the system architecture covering: architecture overview, tech stack mapping, page architecture, API route architecture, data flow diagrams, component/folder structure, integration points, and performance considerations.
```

---

## Prompt 08 → Database Design

**Input**: [PRD.mdc](./PRD.mdc) + [persona/database_persona.mdc](./persona/database_persona.mdc) + [extended/architecture.mdc](./extended/architecture.mdc)
**Output**: [extended/ERD.mdc](./extended/ERD.mdc)
**Prompt**:
```
Based on PRD.mdc, Database Persona, and Architecture, design the database schema covering: ER diagram, table definitions with column types/constraints, status enums, indexes, full SQL migration script, seed data, and database rules.
```

---

## Prompt 09 → API Design

**Input**: [PRD.mdc](./PRD.mdc) → Section 4
**Output**: Embedded in PRD.mdc and architecture.mdc
**Prompt**:
```
API design is embedded in PRD.mdc Section 4 (request/response contracts) and architecture.mdc Section 4 (API route architecture). No separate file needed for this project scale.
```

---

## Prompt 10 → Implementation Planning

**Input**: All above files
**Output**: [Detailed_Project_Scope.mdc](./Detailed_Project_Scope.mdc)
**Prompt**:
```
Consolidate all context files into an implementation-ready Detailed Project Scope. Map every feature to: technical implementation, source context files, KPIs, acceptance criteria. Define implementation order (phases), complete file manifest, and cross-reference summary.
```

---

## Prompt 11 → Risk Assessment

**Input**: [Project_Scope.mdc](./Project_Scope.mdc) + [security.mdc](./extended/security.mdc)
**Output**: Embedded in Project_Scope.mdc → Risks section
**Prompt**:
```
Risk assessment is embedded in Project_Scope.mdc (Section: Risks) covering payment, security, infrastructure, and data risks with probability, impact, and mitigation strategies.
```

---

## Prompt 12 → Final Review & Gap Analysis

**Input**: All context files
**Output**: Gap analysis report (during review phase)
**Prompt**:
```
Review all context engineering files for DonateNow. Identify: missing requirements, contradictions between files, unverified KPIs, unaddressed edge cases, security gaps, and incomplete cross-references. Generate a gap analysis report.
```

---

## Prompt Execution Order

```
Prompt 01 → business_idea.mdc
Prompt 02 → PRD.mdc (references Prompt 01)
Prompt 03 → KPI.mdc (references Prompt 02)
Prompt 04 → Personas (references Prompts 02 + 03)
Prompt 05 → Project_Scope.mdc (references Prompts 02-04)
Prompt 06 → Project_Boundaries.mdc (references Prompt 05)
Prompt 07 → architecture.mdc (references Prompts 02 + 04)
Prompt 08 → ERD.mdc (references Prompts 02 + 04 + 07)
Prompt 09 → API Design (embedded in Prompts 02 + 07)
Prompt 10 → Detailed_Project_Scope.mdc (references ALL)
Prompt 11 → Risk Assessment (embedded in Prompt 05)
Prompt 12 → Gap Analysis (references ALL)
```
