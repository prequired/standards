---
id: SOP-000
title: The Golden Thread - Traceability Standard
version: 1.0.0
status: active
owner: CTO Office
last_updated: 2025-11-29
---

# SOP-000: The Golden Thread - Documentation Traceability

## Purpose

Establish a rigid, auditable chain of traceability from business requirements through architectural decisions to implementation artifacts. Every technical artifact must be justified by a requirement and every requirement must be satisfied by an architectural decision.

## Scope

This SOP applies to all technical documentation produced during the SDLC: Requirements (Volere), Architectural Decision Records (MADR), Architecture Specifications (arc42), and API Contracts (OpenAPI).

## Linking Strategy

### Mandatory Relationship Chain

```
[Business Requirement] → [Architectural Decision] → [Architecture Artifact] → [Implementation]
```

### Syntax Standards

#### 1. Requirement Identifiers

Requirements use the format `REQ-{domain}-{sequence}`:

- **Example:** `REQ-AUTH-101` (Authentication domain, requirement 101)
- **Example:** `REQ-DATA-042` (Data domain, requirement 42)

Requirement files are stored as: `docs/01-requirements/req-{domain}-{sequence}.md`

#### 2. ADR Identifiers

Architectural Decision Records use the format `ADR-{sequence}`:

- **Example:** `ADR-0001` (First architectural decision)
- **Example:** `ADR-0023` (23rd architectural decision)

ADR files are stored as: `docs/03-decisions/adr-{sequence}.md`

#### 3. Architecture Document Identifiers

Architecture specifications use the format `ARCH-{system}-{version}`:

- **Example:** `ARCH-USER-SERVICE-v1` (User Service architecture, version 1)
- **Example:** `ARCH-API-GATEWAY-v2` (API Gateway architecture, version 2)

Architecture files are stored as: `docs/02-architecture/arch-{system}.md`

### Explicit Linking Example

#### Requirement Document (`docs/01-requirements/req-auth-101.md`)

```yaml
---
id: REQ-AUTH-101
title: Multi-Factor Authentication for Admin Users
domain: Authentication
status: active
---

## Description
All administrative users must authenticate using multi-factor authentication (MFA).

## Rationale
Administrative accounts have elevated privileges. MFA reduces the risk of account compromise.

## Satisfied By
- [ADR-0008](../03-decisions/adr-0008.md) - Selection of TOTP-based MFA Provider
```

#### ADR Document (`docs/03-decisions/adr-0008.md`)

```yaml
---
id: ADR-0008
title: Selection of TOTP-based MFA Provider
status: accepted
date: 2025-11-15
implements_requirement: REQ-AUTH-101
---

# ADR-0008: Selection of TOTP-based MFA Provider

## Context
[REQ-AUTH-101](../01-requirements/req-auth-101.md) mandates MFA for administrative users.

## Decision
We will use Google Authenticator-compatible TOTP (RFC 6238) via the `pragmarx/google2fa` library.

## Consequences
- Architects must document TOTP integration in [ARCH-USER-SERVICE-v1](../02-architecture/arch-user-service.md) Section 5 (Building Blocks).
- API team must add `/auth/mfa/verify` endpoint per [SOP-004](./sop-004-api-guidelines.md).
```

#### Architecture Document (`docs/02-architecture/arch-user-service.md`)

```markdown
## 5. Building Block View (Level 2)

### Authentication Module

**Implements:** [ADR-0008](../03-decisions/adr-0008.md)

```mermaid
graph LR
    A[User] -->|POST /auth/mfa/verify| B[MFA Controller]
    B --> C[Google2FA Service]
    C --> D[User Repository]
```
```

### Validation Rules

Before a document is considered "done," it must satisfy:

1. **Linting:** Pass `make lint` with zero errors.
2. **Diagrams:** Contain at least one Mermaid diagram (for architecture/ADRs).
3. **Traceability:**
   - Requirements must list "Satisfied By" ADRs.
   - ADRs must reference "Implements Requirement" via frontmatter.
   - Architecture documents must cite ADRs in relevant sections.
4. **Review:** Approved by domain owner (specified in YAML frontmatter).

## Definition of Done (Documentation)

| Artifact Type | DoD Criteria |
|---------------|--------------|
| Requirement   | Has unique ID, rationale, fit criterion, linked ADR |
| ADR           | Has context, decision, consequences, linked requirement |
| Architecture  | Has C4 diagram, references ADRs, passes Vale lint |
| API Spec      | OpenAPI 3.x, validates via Spectral, linked ADR |

## Enforcement

Pull requests modifying documentation must include a traceability matrix (manually generated or automated via tooling) demonstrating the requirement → ADR → architecture chain.

## References

- [SOP-004: API Guidelines](./sop-004-api-guidelines.md)
- [Volere Template](../../templates/req-volere.md)
- [MADR Template](../../templates/adr-madr.md)
- [arc42 Template](../../templates/arch-arc42.md)
