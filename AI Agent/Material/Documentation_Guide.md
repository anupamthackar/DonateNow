# Documentation Guide — DonateNow

> Purpose: Explains every context engineering file, its purpose, who uses it, interview relevance, and industry standards.
> Reference: [context_map.mdc](./extended/context_map.mdc) | [Prompts.mdc](./Prompts.mdc)

---

## File 1: business_idea.mdc

### What is it?
A document capturing the initial business concept — the problem, proposed solution, target users, and high-level features before formal requirements are written.

### Why do we need it?
It establishes the **foundation context** from which all other documents are derived. Without it, requirements lack business justification.

### Who uses it?
| Role | Usage |
|---|---|
| Product Manager | Validates business viability |
| Business Analyst | Extracts requirements |
| Stakeholders | Approves direction |
| AI Agent | Understands project purpose |

### What does it contain?
- Problem identified + pain points
- Proposed solution (As-Is vs. To-Be)
- Target users and their needs
- Business goals with measurable outcomes
- Core features (high-level)
- Suggested tech stack
- Demo scenario
- Success criteria + constraints

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "How do you start a new project?" | Business idea analysis → problem identification → solution proposal |
| "What's the difference between business idea and PRD?" | Business idea = why we build; PRD = what we build in detail |
| "How do you validate a business idea?" | Stakeholder interviews, pain point analysis, competitive analysis |

---

## File 2: PRD.mdc (Product Requirements Document)

### What is it?
A formal document defining **what** needs to be built, **why** it's needed, and **how** success will be measured. It's the single source of truth for requirements.

### Why do we need it?
- Prevents scope creep by documenting exact requirements
- Aligns all stakeholders on expected deliverables
- Provides API contracts for parallel frontend/backend development
- Defines edge cases to prevent production bugs

### Who uses it?
| Role | Usage |
|---|---|
| Product Manager | Owns and maintains |
| Developer | Implements features |
| QA/Tester | Validates against requirements |
| Designer | Designs UI for user flows |
| AI Agent | Primary reference for implementation |

### What does it contain?
- Problem statement (current state + pain points)
- Solution overview (features + business impact)
- User flows (happy path + alternative paths)
- API design (endpoints + request/response contracts)
- Edge cases (failure scenarios + invalid inputs)
- KPI summary (success metrics table)
- Limitations (technical + business constraints)
- Dependencies and future enhancements

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "What is a PRD?" | Document defining what to build, why, and success criteria |
| "Who writes the PRD?" | Product Manager, with input from engineering and stakeholders |
| "What's the difference between PRD and SRS?" | PRD = product-focused (why + what); SRS = technical spec (how) |
| "How do you handle changing requirements?" | Version control, change request process, impact analysis |
| "What makes a good PRD?" | Clear user flows, measurable KPIs, defined edge cases, no ambiguity |

### Industry Standards
- **Agile**: PRD as living document, updated per sprint
- **SAFe**: PRD maps to Feature/Capability level
- **IEEE 830**: SRS standard for formal requirements (enterprise)
- **Product Management**: PRD is PM's primary deliverable

---

## File 3: KPI.mdc

### What is it?
A document tracking measurable success criteria — Key Performance Indicators that determine if the project meets its goals.

### Why do we need it?
- Objective measurement of project success (not subjective opinion)
- Links requirements to verification methods
- Provides acceptance gates for deployment
- Enables data-driven decision making

### Who uses it?
| Role | Usage |
|---|---|
| Product Manager | Defines and tracks KPIs |
| QA/Tester | Verifies KPIs pass |
| Developer | Knows what "done" looks like |
| Stakeholder | Reviews success metrics |

### What does it contain?
- KPI tables (number, name, description, verification method, target, status)
- Categories: Core, Functional, Performance, Security, UX
- Acceptance criteria gates (MVP, Quality, Security)
- Verification schedule
- KPI dashboard summary

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "What are KPIs in software projects?" | Measurable indicators of project success |
| "Difference between KPI and acceptance criteria?" | KPI = measurable metric; AC = pass/fail condition for a feature |
| "How do you track KPIs?" | Dashboard, automated tests, manual verification |
| "What happens if a KPI fails?" | Block deployment, investigate, fix, re-verify |

---

## File 4: Personas (Frontend, Backend, Database)

### What is it?
Implementation personas that define **who** builds **what** using **which** technology, and the **rules** they follow. Not user personas — these are developer/architect personas.

### Why do we need it?
- Establishes tech stack decisions with justification
- Defines coding standards per layer
- Prevents inconsistent technology choices
- Provides clear responsibility boundaries

### Who uses it?
| Role | Usage |
|---|---|
| Architect | Defines personas |
| Frontend Developer | Follows frontend persona |
| Backend Developer | Follows backend persona |
| DBA | Follows database persona |
| AI Agent | Follows all three based on task |

### What does it contain?
Per persona:
- Tech stack with versions
- Why this stack was chosen (justification)
- Responsibilities (10 items)
- Standards/rules (coding, security, performance)
- Deliverables (specific files to create)

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "How do you choose a tech stack?" | Requirements analysis → persona definition → stack selection with justification |
| "Why separate personas per layer?" | Different concerns: UX vs. security vs. data integrity |
| "What if a developer disagrees with the persona?" | Change request → impact analysis → team decision |

---

## File 5: Project_Scope.mdc

### What is it?
A comprehensive document defining the boundaries of the project — what's included, what's excluded, and the constraints under which the project operates.

### Why do we need it?
- Prevents scope creep (the #1 cause of project failure)
- Documents assumptions (which can become risks if wrong)
- Identifies risks early with mitigation strategies
- Provides governance rules for scope changes

### Who uses it?
| Role | Usage |
|---|---|
| Project Manager | Owns scope management |
| Product Manager | Defines in/out scope |
| Stakeholder | Signs off on scope |
| Developer | Knows what NOT to build |

### What does it contain?
- Executive summary
- Business context and goals
- Stakeholders and target users
- In-scope / out-of-scope items
- Assumptions, constraints, risks, dependencies
- Success criteria, non-functional requirements
- Future scope (post-MVP roadmap)
- Scope governance (change process)
- Open questions and sign-off

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "What is scope creep?" | Uncontrolled changes/additions to project scope without adjusting time/cost |
| "How do you prevent scope creep?" | Clear scope document, change request process, stakeholder sign-off |
| "In-scope vs. out-of-scope?" | In-scope = committed to deliver; Out-of-scope = explicitly not building |
| "What are project assumptions?" | Things believed true but not verified; become risks if wrong |

---

## File 6: Project_Boundaries.mdc

### What is it?
Strict development rules that define **what the development team (and AI agent) must never do** and the quality gates that must pass before code is considered complete.

### Why do we need it?
- Prevents accidental security breaches
- Enforces consistent code quality
- Establishes decision priority when documents conflict
- Protects against scope creep during implementation

### Who uses it?
| Role | Usage |
|---|---|
| Developer | Must follow all rules |
| AI Agent | Highest-priority reference |
| Code Reviewer | Validates compliance |

### What does it contain?
- 7 strict development rules
- Coding standards (per persona)
- AI agent decision order (priority hierarchy)
- File modification rules
- Communication rules
- Quality gates (before code, before feature complete, before deploy)
- Prohibited actions (10 items)

### Interview Questions
| Question | Key Answer Points |
|---|---|
| "What are coding standards?" | Agreed rules for code consistency: naming, structure, patterns |
| "What are quality gates?" | Checkpoints that must pass before proceeding to the next phase |
| "How do you enforce boundaries in AI-assisted development?" | Context engineering files with priority hierarchy |

---

## File 7: Detailed_Project_Scope.mdc

### What is it?
An implementation-ready document that consolidates ALL context files into technical modules, mapping features to code files, KPIs, and acceptance criteria.

### Why do we need it?
- Bridges the gap between business requirements and code
- Provides a single reference for "what to build next"
- Maps every feature to its verification
- Defines implementation order (phases)

### Who uses it?
| Role | Usage |
|---|---|
| Developer | Primary implementation guide |
| AI Agent | Module-by-module development reference |
| Tech Lead | Review technical completeness |

---

## File 8: Save_Token.mdc

### What is it?
A protocol for optimizing AI-agent communication to minimize token usage and maximize efficiency.

### Why do we need it?
- AI interactions consume tokens (cost)
- Shorter responses are faster and easier to review
- Prevents redundant information in responses
- Enforces disciplined communication

### Industry Relevance
This is specific to **AI-assisted development** and **context engineering** — a new discipline emerging with LLM-based coding assistants.

---

## Common Mistakes in Context Engineering

| # | Mistake | Impact | Prevention |
|---|---|---|---|
| 1 | Missing requirements in PRD | Features missed, rework needed | Thorough PRD with edge cases |
| 2 | Undefined success criteria | No way to know if project is "done" | KPI.mdc with measurable targets |
| 3 | Ambiguous scope | Scope creep, timeline overrun | In-scope/out-of-scope table |
| 4 | Weak acceptance criteria | Subjective quality assessment | Specific, testable acceptance criteria |
| 5 | No cross-references between files | Documents contradict each other | Context map + explicit references |
| 6 | No decision priority | Confusion when documents conflict | AI agent decision order |
| 7 | No security document | Vulnerabilities in production | Security.mdc as mandatory file |
| 8 | No testing strategy | Bugs discovered in production | Testing.mdc with verification matrix |
| 9 | Tech stack chosen without justification | Wrong tool for the job | Personas with "Why Selected" section |
| 10 | No error handling strategy | Poor user experience, data loss | Error_handling.mdc with state machine |

---

## Industry Standards Alignment

| Standard | How DonateNow Aligns |
|---|---|
| **Agile / Scrum** | PRD as product backlog source, KPIs as sprint goals, features as user stories |
| **Product Management** | Business idea → PRD → KPIs → Scope = standard PM workflow |
| **Software Architecture** | Personas define architecture decisions, architecture.mdc documents system design |
| **IEEE 830 (SRS)** | PRD covers functional/non-functional requirements per IEEE 830 structure |
| **TOGAF** | Architecture.mdc aligns with TOGAF application architecture |
| **ISO 25010** | KPIs cover quality characteristics: functionality, performance, security, usability |
| **Context Engineering** | Full file dependency graph, reading order, conflict resolution — modern AI-first practice |

---

## File Map (Quick Reference)

```
AI Agent/
├── business_idea.mdc          → Phase 01: Foundation
├── PRD.mdc                    → Phase 02: Requirements
├── KPI.mdc                    → Phase 03: Success Metrics
├── persona/                   → Phase 04: Tech Decisions
│   ├── frontend_persona.mdc
│   ├── backend_persona.mdc
│   └── database_persona.mdc
├── Project_Scope.mdc          → Phase 05: Scope Definition
├── Project_Boundaries.mdc     → Phase 06: Development Rules
├── Detailed_Project_Scope.mdc → Phase 07: Implementation-Ready
├── Save_Token.mdc             → Cross-cutting: AI Optimization
├── Prompts.mdc                → Process: Prompt Catalog
├── Documentation_Guide.mdc    → Meta: This file
└── extended/                  → Phase 08-11: Deep Technical
    ├── architecture.mdc
    ├── ERD.mdc
    ├── security.mdc
    ├── testing.mdc
    ├── error_handling.mdc
    ├── style-guide.mdc
    ├── deployment.mdc
    ├── observability.mdc
    ├── context_map.mdc
    ├── .env.example
    └── features/
        └── features.mdc
```
