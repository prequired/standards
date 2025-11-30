# Documentation Templates

**Last Updated:** 2025-11-30

---

## Overview

This directory contains templates for creating new documentation following established standards.

## Templates

| Template | File | Purpose |
|----------|------|---------|
| Requirement | [req-volere.md](./req-volere.md) | Volere-style requirement specification |
| ADR | [adr-madr.md](./adr-madr.md) | MADR Architecture Decision Record |
| Architecture | [arch-arc42.md](./arch-arc42.md) | arc42 architecture documentation |
| Changelog | [CHANGELOG.md](./CHANGELOG.md) | Release notes following Keep a Changelog |

## Guides

| Guide | Description |
|-------|-------------|
| [TEMPLATE_GUIDE.md](./TEMPLATE_GUIDE.md) | When and how to use each template |

## Quick Start

### Create a New Requirement

```bash
cp docs/templates/req-volere.md docs/01-requirements/req-domain-nnn.md
```

### Create a New ADR

```bash
cp docs/templates/adr-madr.md docs/03-decisions/adr-00nn-title.md
```

### Create Architecture Documentation

```bash
cp docs/templates/arch-arc42.md docs/02-architecture/arch-component.md
```

## Template Standards

All templates follow:
- Consistent YAML frontmatter structure
- Required sections that must be completed
- Placeholders marked with `[brackets]` or `YYYY-MM-DD`
- Examples and guidance in comments

## Related Documentation

- [Getting Started](../GETTING-STARTED.md) - Onboarding guide
- [Quality Gates](../00-governance/sop-002-quality-gates.md) - Review criteria
- [Documentation Lifecycle](../00-governance/sop-003-documentation-lifecycle.md) - Status transitions

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-30 | Initial templates README |
