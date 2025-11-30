# Governance Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains Standard Operating Procedures (SOPs) that define governance policies, quality standards, and processes for the Agency Platform documentation and development.

## Documents

| Document | Description | Status |
|----------|-------------|--------|
| [sop-000-master.md](./sop-000-master.md) | Golden Thread Traceability Standard | Active |
| [sop-001-git-standards.md](./sop-001-git-standards.md) | Git Repository Standards and Workflow | Active |
| [sop-002-quality-gates.md](./sop-002-quality-gates.md) | Documentation Quality Gates | Active |
| [sop-003-documentation-lifecycle.md](./sop-003-documentation-lifecycle.md) | Document Lifecycle Management | Active |
| [sop-004-api-guidelines.md](./sop-004-api-guidelines.md) | API Design and Governance Standards | Active |

## Golden Thread Principle

All documentation follows the **Golden Thread** traceability model:

```
Requirements (01-requirements/)
        ↓
Architecture Decisions (03-decisions/)
        ↓
Architecture Specification (02-architecture/)
        ↓
Implementation (Code)
        ↓
Testing (06-testing/)
```

Every feature must be traceable from business requirement through implementation to verification.

## Quality Gates

Documentation must pass quality gates before approval:

| Gate | Criteria |
|------|----------|
| Completeness | All required sections filled |
| Traceability | Links to related documents |
| Accuracy | Technically correct |
| Clarity | Clear, unambiguous language |
| Consistency | Follows templates and standards |

See [SOP-002: Quality Gates](./sop-002-quality-gates.md) for details.

## SOP Numbering

| Range | Category | Status |
|-------|----------|--------|
| 000-009 | Core governance and traceability | **Active** (000-004) |
| 010-019 | Documentation standards | Reserved for future use |
| 020-029 | Development processes | Reserved for future use |
| 030-039 | Quality assurance | Reserved for future use |
| 040-049 | Security and compliance | Reserved for future use |

**Note:** Ranges 010-049 are reserved for future SOPs. Current core governance (000-004) covers essential standards. Additional SOPs will be created as needs arise.

## Governance Hierarchy

```
SOP-000 (Golden Thread)
    ├── Requirements Standards
    ├── ADR Standards
    ├── Architecture Standards
    └── Implementation Standards

SOP-001 (Git Standards)
    ├── Branching Strategy
    ├── Commit Conventions
    └── PR Requirements

SOP-002 (Quality Gates)
    ├── Review Criteria
    ├── Approval Process
    └── Metrics

SOP-003 (Documentation Lifecycle)
    ├── Lifecycle Stages
    ├── Transition Procedures
    └── Version Control

SOP-004 (API Guidelines)
    ├── API First Principle
    ├── Design Standards
    └── Versioning
```

## Related Documentation

- [Requirements](../01-requirements/README.md) - 101 requirements across 13 domains
- [Architecture Decisions](../03-decisions/README.md) - 20 ADRs
- [Architecture](../02-architecture/README.md) - System architecture
- [Development Standards](../04-development/README.md) - Coding conventions

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial governance README |
