# Technical Documentation Repository

**Version:** 1.0.0
**Status:** Active
**Last Updated:** 2025-11-29

[![Documentation Quality](https://github.com/your-org/your-repo/workflows/Documentation%20Quality%20Gate/badge.svg)](https://github.com/your-org/your-repo/actions)

---

## Overview

This repository implements a "Docs-as-Code" approach to technical documentation, serving as the authoritative source of truth for the entire Software Development Lifecycle (SDLC). It rejects ad-hoc wiki pages in favor of rigorous, version-controlled, and traceable documentation standards.

## Philosophy

1. **Documentation is Code:** All docs are version-controlled, peer-reviewed, and subject to CI/CD quality gates.
2. **Traceability First:** Every architectural decision must trace back to a requirement; every requirement must be satisfied by architecture.
3. **API First:** API specifications (OpenAPI) are the master record; implementation code is derivative.
4. **Standards-Based:** We use industry-standard frameworks, not custom templates.

## Standards Adopted

| Domain | Standard | Purpose |
|--------|----------|---------|
| **Requirements** | [Volere Specification](https://www.volere.org/) | Structured requirement capture with fit criteria |
| **Architecture** | [arc42](https://arc42.org/) | 12-section architecture documentation framework |
| **Decisions** | [MADR](https://adr.github.io/madr/) | Markdown Architectural Decision Records |
| **Git Workflow** | [Conventional Commits](https://www.conventionalcommits.org/) | Standardized commit messages and branching |
| **Versioning** | [Semantic Versioning](https://semver.org/) | MAJOR.MINOR.PATCH release numbering |
| **API Design** | [Zalando RESTful API Guidelines](https://opensource.zalando.com/restful-api-guidelines/) | Rule #100: API First principle |
| **Diagrams** | [C4 Model](https://c4model.com/) | Context, Container, Component, Code diagrams |
| **Quality** | [Google Developer Documentation Style Guide](https://developers.google.com/style) | Writing standards enforced via Vale |
| **Traceability** | SysML-inspired linkage | Requirement → ADR → Architecture chains |

---

## Repository Structure

```
/
├── .github/
│   ├── workflows/
│   │   └── quality.yml        # CI/CD quality gates
│   └── AI_CONTEXT.md          # AI agent governance guide
├── .vale.ini                  # Vale linter configuration
├── Makefile                   # Automation targets
├── README.md                  # This file
├── CONTRIBUTING.md            # Contribution guidelines
├── docs/
│   ├── 00-governance/         # SOPs and process documentation
│   │   ├── sop-000-master.md       # Golden Thread traceability
│   │   ├── sop-001-git-standards.md # Git workflow and conventions
│   │   └── sop-004-api-guidelines.md # API First enforcement
│   ├── 01-requirements/       # Volere requirement specifications
│   ├── 02-architecture/       # arc42 architecture documents
│   ├── 03-decisions/          # Architectural Decision Records
│   ├── 04-development/        # Development guides, coding standards
│   ├── 05-api/                # OpenAPI specifications
│   ├── 06-testing/            # Test strategies, QA documentation
│   ├── 07-operations/         # Runbooks, deployment, monitoring
│   ├── 08-security/           # Security policies, threat models
│   └── 09-releases/           # Release notes, changelogs
└── templates/                 # Copy-paste templates
    ├── req-volere.md          # Requirement template
    ├── adr-madr.md            # ADR template
    └── arch-arc42.md          # Architecture template
```

---

## Quick Start

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd <repository-name>

# Install dependencies
make setup
```

### 2. Create Your First Requirement

```bash
cp templates/req-volere.md docs/01-requirements/req-auth-101.md
# Edit the file (replace placeholders)
make lint
```

### 3. Create an Architectural Decision

```bash
cp templates/adr-madr.md docs/03-decisions/adr-0008.md
# Edit and link to requirement
# implements_requirement: REQ-AUTH-101
make lint
```

### 4. Document Architecture

```bash
cp templates/arch-arc42.md docs/02-architecture/arch-user-service.md
# Include C4 diagrams and ADR references
make lint
```

---

## Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Vale** | Documentation linter | `brew install vale` or [vale.sh](https://vale.sh) |
| **Mermaid CLI** | Diagram rendering | `npm install -g @mermaid-js/mermaid-cli` |
| **Make** | Task automation | Pre-installed on Unix systems |
| **Git** | Version control | Pre-installed on most systems |

### Optional Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Spectral** | OpenAPI linting | `npm install -g @stoplight/spectral-cli` |
| **Prism** | OpenAPI mocking | `npm install -g @stoplight/prism-cli` |

---

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Reference

1. **Read the Standards:** [SOP-000](docs/00-governance/sop-000-master.md), [SOP-001](docs/00-governance/sop-001-git-standards.md), [SOP-004](docs/00-governance/sop-004-api-guidelines.md)
2. **Use the Templates:** `templates/*.md`
3. **Follow Naming Conventions:**
   - Requirements: `req-{domain}-{seq}.md`
   - ADRs: `adr-{seq}.md`
   - Architecture: `arch-{system}.md`
4. **Establish Traceability:** REQ → ADR → ARCH
5. **Validate:** `make lint`
6. **Submit PR:** Include traceability matrix

---

## Makefile Targets

| Command | Description |
|---------|-------------|
| `make help` | Display available targets |
| `make setup` | Install Vale, Mermaid CLI |
| `make lint` | Run Vale linter |
| `make validate-links` | Check relative links |
| `make test` | Run all validation checks |
| `make clean` | Remove artifacts |

---

## Documentation Standards

### Writing Style
- **Audience:** Engineers with domain expertise
- **Tone:** Professional, precise, no fluff
- **Voice:** Active voice preferred
- **Tense:** Present for current state

### Diagram Requirements
- **Format:** Mermaid (text-based, version-controllable)
- **Types:** C4 Model, Sequence, Class diagrams
- **Placement:** Embedded in Markdown

### Linking Rules
- **Use relative paths:** `../01-requirements/req-auth-101.md`
- **No broken links:** Validate via `make validate-links`
- **Bidirectional:** If A references B, B acknowledges A

---

## The Golden Thread

Every technical artifact traces back to a business requirement:

```
[Business Requirement] → [Architectural Decision] → [Architecture] → [Implementation]
```

**Example:**
```
REQ-AUTH-101 (MFA for admins)
    ↓
ADR-0008 (TOTP provider selection)
    ↓
ARCH-USER-SERVICE Section 5.3 (Auth module)
    ↓
/auth/mfa/verify endpoint (OpenAPI)
```

See [SOP-000](docs/00-governance/sop-000-master.md) for complete traceability rules.

---

## AI Agent Integration

This repository is AI-maintainable. The [AI_CONTEXT.md](.github/AI_CONTEXT.md) file provides:
- **Persona:** Principal Staff Architect
- **Prime Directive:** Never code without updating API spec + ADR first
- **Decision Trees:** When to create REQ/ADR/ARCH
- **Rules:** Always `make lint` before completion

---

## Frequently Asked Questions

### Why not Confluence/Notion/SharePoint?
These tools lack:
- Git-based version control
- Automated quality gates
- Traceability enforcement

### How do I enforce API First?
See [SOP-004](docs/00-governance/sop-004-api-guidelines.md). OpenAPI specs must be approved before implementation.

### Can I use draw.io or Lucidchart?
No. All diagrams must be Mermaid (text-based, version-controllable).

### What if I need to document something quickly?
Use the templates. A well-formed requirement takes ~10 minutes.

---

## Governance

### Document Ownership
Each document specifies an `owner` in YAML frontmatter. Owners:
- Review PRs affecting their documents
- Maintain traceability links
- Archive deprecated documents

### Change Process
1. **Minor Changes:** Direct commit after review
2. **Major Changes:** PR with mandatory review
3. **Breaking Changes:** Update ADR status (`superseded_by`)

---

## References

### External Documentation
- [arc42 Template](https://arc42.org/overview)
- [MADR Specification](https://adr.github.io/madr/)
- [Volere Requirements](https://www.volere.org/)
- [Zalando API Guidelines](https://opensource.zalando.com/restful-api-guidelines/)
- [C4 Model](https://c4model.com/)
- [Google Style Guide](https://developers.google.com/style)

### Internal Documentation
- [SOP-000: Golden Thread](docs/00-governance/sop-000-master.md)
- [SOP-001: Git Standards](docs/00-governance/sop-001-git-standards.md)
- [SOP-004: API Guidelines](docs/00-governance/sop-004-api-guidelines.md)
- [AI Context](.github/AI_CONTEXT.md)
- [Contributing Guide](CONTRIBUTING.md)

---

## License

This documentation repository is proprietary. Unauthorized distribution is prohibited.

---

## Support

**Questions?**
1. Check [SOP-000](docs/00-governance/sop-000-master.md) for traceability
2. Review [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
3. Read [templates/](templates/) for examples
4. Contact: CTO Office or Architecture Guild
