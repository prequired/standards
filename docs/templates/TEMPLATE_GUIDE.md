# Documentation Template Guide

This guide explains when and how to use each documentation template.

---

## Available Templates

| Template | File | When to Use |
|----------|------|-------------|
| Requirement | `req-volere.md` | Capturing a business/technical requirement |
| ADR | `adr-madr.md` | Documenting an architectural decision |
| Architecture | `arch-arc42.md` | Comprehensive system architecture |

---

## Requirement Template (Volere)

### When to Use

Create a new requirement document when:
- A stakeholder requests a new capability
- A business need must be documented
- A constraint or regulation must be captured
- A feature needs formal specification

### How to Use

1. Copy the template:
   ```bash
   cp templates/req-volere.md 01-requirements/req-domain-nnn.md
   ```

2. Choose the correct domain code:
   - AUTH = Authentication
   - USER = User Management
   - PROJ = Project Management
   - TASK = Task Management
   - TIME = Time Tracking
   - BILL = Billing/Invoicing
   - PORT = Client Portal
   - NOTIF = Notifications
   - INTG = Integrations
   - SEC = Security
   - ANLY = Analytics
   - SYS = System/Infrastructure
   - WF = Workflow Automation

3. Assign the next available number in that domain

4. Complete ALL sections:
   - Description (what the system shall do)
   - Rationale (why it's needed)
   - Fit Criterion (measurable success criteria)
   - Dependencies (what it needs/blocks)
   - Acceptance Criteria (minimum 5)
   - Satisfied By (link to ADR when created)

### Common Mistakes

- **Missing fit criterion**: Every requirement must be measurable
- **Too broad**: Split into multiple requirements if needed
- **Missing dependencies**: Document all related requirements
- **Placeholder ADR links**: Fill in when ADR is created

---

## ADR Template (MADR)

### When to Use

Create an ADR when:
- Choosing between technology options
- Making a build vs. buy decision
- Establishing a pattern or convention
- Making an irreversible or costly-to-change decision
- The decision affects multiple components

### When NOT to Use

Don't create an ADR for:
- Trivial implementation details
- Decisions easily reversible
- One-off coding choices
- Bug fixes

### How to Use

1. Copy the template:
   ```bash
   cp templates/adr-madr.md 03-decisions/adr-00nn-descriptive-title.md
   ```

2. Use the next available number (check existing ADRs)

3. Complete ALL sections:
   - Context and Problem Statement
   - Decision Drivers (list key factors)
   - Options Considered (minimum 3)
   - Decision Outcome (with clear justification)
   - Consequences (positive, negative, risks)
   - Validation (how to verify it worked)
   - Implementation Notes

4. Link to implementing requirements in frontmatter

### Common Mistakes

- **Only 2 options**: Always consider at least 3 alternatives
- **Missing consequences**: Document downsides honestly
- **No validation plan**: Define how to measure success
- **Missing requirement links**: Trace back to requirements

---

## Architecture Template (arc42)

### When to Use

Create architecture documentation when:
- Documenting a new system or major component
- Onboarding requires system understanding
- External audit or review is needed
- System is complex enough to warrant documentation

### How to Use

1. Copy the template:
   ```bash
   cp templates/arch-arc42.md 02-architecture/arch-system-name.md
   ```

2. Complete all 12 sections (can be brief for simpler systems):
   1. Introduction and Goals
   2. Constraints
   3. Context and Scope
   4. Solution Strategy
   5. Building Block View
   6. Runtime View
   7. Deployment View
   8. Cross-cutting Concepts
   9. Architecture Decisions
   10. Quality Requirements
   11. Risks and Technical Debt
   12. Glossary

3. Use C4 model for diagrams:
   - Level 1: System Context
   - Level 2: Container
   - Level 3: Component
   - Level 4: Code (when needed)

4. Use Mermaid for diagrams (version-controlled)

### Common Mistakes

- **Too detailed initially**: Start high-level, add detail as needed
- **Missing diagrams**: Visuals are essential
- **Outdated decisions**: Link to ADRs, don't duplicate
- **Missing quality attributes**: Document NFRs explicitly

---

## Template Checklist

Before submitting any document:

### Requirement Checklist
- [ ] ID follows REQ-DOMAIN-NNN format
- [ ] All frontmatter fields complete
- [ ] Description uses "shall" language
- [ ] Fit criterion is measurable
- [ ] At least 5 acceptance criteria
- [ ] Dependencies documented
- [ ] Priority assigned

### ADR Checklist
- [ ] ID follows ADR-NNNN format
- [ ] All frontmatter fields complete
- [ ] Problem statement is clear
- [ ] At least 3 options considered
- [ ] Decision rationale is clear
- [ ] Positive consequences listed
- [ ] Negative consequences listed
- [ ] Risks identified
- [ ] Validation metrics defined
- [ ] Requirements linked

### Architecture Checklist
- [ ] All 12 arc42 sections addressed
- [ ] Context diagram included
- [ ] Container diagram included
- [ ] Quality attributes mapped
- [ ] ADRs referenced (not duplicated)
- [ ] Risks documented
- [ ] Glossary complete

---

## Quality Gates

All documents must pass quality gates before merge:

| Gate | Criteria |
|------|----------|
| **Completeness** | All required sections filled |
| **Traceability** | Links to related documents |
| **Accuracy** | Technically correct |
| **Clarity** | Clear, unambiguous language |
| **Consistency** | Follows template structure |

See [SOP-002: Quality Gates](../00-governance/sop-002-quality-gates.md) for details.

---

## Getting Help

- Check [GLOSSARY.md](../GLOSSARY.md) for terminology
- Review similar existing documents for examples
- Ask in team Slack channel
- Consult [GETTING-STARTED.md](../GETTING-STARTED.md)

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial template guide |
