---
id: "DOC-ONBOARD-001"
title: "Getting Started Guide"
status: "active"
owner: "Documentation Team"
last_updated: "2025-11-30"
---

# Getting Started with Agency Platform Documentation

**Welcome to the Agency Platform Docs-as-Code Framework**

This guide will help you navigate the documentation structure and contribute effectively.

---

## What is Docs-as-Code?

This documentation framework treats documentation like code:
- **Version controlled** in Git
- **Reviewed** via pull requests
- **Tested** via CI/CD quality gates
- **Deployed** automatically

Every document follows strict standards ensuring traceability, consistency, and quality.

---

## The Golden Thread

The core principle of this documentation is **traceability**. Every feature can be traced from:

```
Business Requirement → Architecture Decision → Implementation → Testing
```

This is called the **Golden Thread**. It ensures:
- Every feature has a documented business need
- Every technical decision is justified
- Every implementation can be verified
- Every test validates a requirement

---

## Documentation Structure

```
docs/
├── 00-governance/     # SOPs, standards, and processes
├── 01-requirements/   # 101 requirements across 13 domains
├── 02-architecture/   # arc42 architecture specification
├── 03-decisions/      # 20 Architecture Decision Records
├── 04-development/    # Developer guides and standards
├── 05-api/            # API specification and OpenAPI
├── 06-testing/        # Testing strategy and templates
├── 07-operations/     # Runbooks and operational docs
├── 08-security/       # Security policies
├── 09-releases/       # Release process
├── templates/         # Document templates
├── GLOSSARY.md        # Terminology reference
└── GETTING-STARTED.md # This file
```

---

## Quick Start by Role

### For Developers

1. Start with [Development Standards](./04-development/dev-standards.md)
2. Set up your environment with [Setup Guide](./04-development/setup-guide.md)
3. Review [Git Workflow](./04-development/git-workflow.md)
4. Check the [API Specification](./05-api/api-specification.md)

### For Product/Business

1. Browse [Requirements](./01-requirements/README.md) by domain
2. Understand trade-offs in [Architecture Decisions](./03-decisions/README.md)
3. Review [Release Process](./09-releases/release-process.md)

### For Operations/DevOps

1. Review [Deployment Runbook](./07-operations/runbook-deployment.md)
2. Familiarize with [Incident Response](./07-operations/runbook-incidents.md)
3. Understand [Data Management](./07-operations/data-management.md)

### For QA/Testing

1. Start with [Testing Strategy](./06-testing/testing-strategy.md)
2. Use [Test Templates](./06-testing/test-templates.md)
3. Review [E2E Scenarios](./06-testing/e2e-scenarios.md)

---

## Understanding Requirements

Requirements are organized by domain:

| Code | Domain | Example |
|------|--------|---------|
| AUTH | Authentication | Login, MFA, SSO |
| USER | User Management | Profiles, roles |
| PROJ | Projects | Project CRUD, milestones |
| TASK | Tasks | Task management |
| TIME | Time Tracking | Timers, entries |
| BILL | Billing | Invoices, payments |
| PORT | Client Portal | Client-facing features |
| NOTIF | Notifications | Emails, alerts |
| INTG | Integrations | Third-party connections |
| SEC | Security | Access control, audit |
| ANLY | Analytics | Reports, dashboards |
| SYS | System | Infrastructure |
| WF | Workflow | Automation |

### Reading a Requirement

Each requirement has:
- **ID**: `REQ-DOMAIN-NNN` (e.g., REQ-PROJ-001)
- **Fit Criterion**: Measurable success criteria
- **Dependencies**: What it needs/blocks
- **Satisfied By**: Links to implementing ADR
- **Acceptance Criteria**: Specific verification steps

---

## Understanding ADRs

Architecture Decision Records capture significant technical decisions.

### When to Create an ADR

Create an ADR when:
- Choosing between technology options
- Making irreversible decisions
- Decisions affect multiple components
- The decision has trade-offs worth documenting

### ADR Structure

Each ADR includes:
- **Context**: Why the decision is needed
- **Options Considered**: At least 3 alternatives
- **Decision**: What was chosen and why
- **Consequences**: Pros, cons, and risks
- **Validation**: How to verify the decision worked

---

## Contributing Documentation

### Creating a New Requirement

1. Copy template: `cp templates/req-volere.md 01-requirements/req-domain-nnn.md`
2. Fill in all sections (no TBD allowed)
3. Link to relevant ADRs in "Satisfied By"
4. Submit PR with `[DOCS]` prefix

### Creating a New ADR

1. Copy template: `cp templates/adr-madr.md 03-decisions/adr-00nn-title.md`
2. Document at least 3 options
3. Complete all consequence sections
4. Link to requirements in frontmatter
5. Submit PR with `[ADR]` prefix

### Quality Gates

Your PR must pass:

| Gate | Check |
|------|-------|
| Completeness | All sections filled |
| Traceability | Links to related docs |
| Accuracy | Technically correct |
| Clarity | Clear language |
| Consistency | Follows templates |

See [SOP-002: Quality Gates](./00-governance/sop-002-quality-gates.md) for details.

---

## Common Tasks

### Find a Requirement

```bash
# By domain
ls docs/01-requirements/req-proj-*

# By keyword
grep -r "authentication" docs/01-requirements/
```

### Find an ADR

```bash
# By topic
grep -l "invoicing" docs/03-decisions/

# By requirement
grep -r "REQ-BILL-001" docs/03-decisions/
```

### Check Document Status

```bash
# Find drafts
grep -r "status: draft" docs/01-requirements/

# Find proposed ADRs
grep -r "status: proposed" docs/03-decisions/
```

### Validate Links

```bash
# Find broken links
grep -r "](../" docs/ | grep -v ".md)"
```

---

## Document Lifecycle

Documents progress through stages:

```
Draft → Review → Approved → Active → Superseded/Retired
```

See [SOP-003: Documentation Lifecycle](./00-governance/sop-003-documentation-lifecycle.md) for details.

---

## Getting Help

### Questions About Documentation

1. Check [GLOSSARY.md](./GLOSSARY.md) for terminology
2. Review related README files
3. Search existing documents

### Questions About the Platform

1. Check [Architecture](./02-architecture/arch-agency-platform.md) for system overview
2. Review relevant ADRs for technical decisions
3. Consult [API Specification](./05-api/api-specification.md) for API questions

### Questions About Processes

1. Check [Governance SOPs](./00-governance/README.md)
2. Review [Development Standards](./04-development/README.md)
3. Consult [Operations Runbooks](./07-operations/README.md)

---

## Key Documents

| Purpose | Document |
|---------|----------|
| System Overview | [Architecture](./02-architecture/arch-agency-platform.md) |
| All Requirements | [Requirements README](./01-requirements/README.md) |
| All ADRs | [Decisions README](./03-decisions/README.md) |
| API Reference | [API Specification](./05-api/api-specification.md) |
| Development Setup | [Setup Guide](./04-development/setup-guide.md) |
| Terminology | [Glossary](./GLOSSARY.md) |

---

## Next Steps

1. **Read** the Golden Thread governance: [SOP-000](./00-governance/sop-000-master.md)
2. **Browse** requirements in your domain of interest
3. **Review** key ADRs for context on technical decisions
4. **Set up** your development environment

Welcome to the team!

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial getting started guide |
