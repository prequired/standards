# Architecture Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains the architecture documentation for the Agency Platform, following the arc42 template (v8.0) and C4 model conventions.

## Documents

| Document | Description | Status |
|----------|-------------|--------|
| [arch-agency-platform.md](./arch-agency-platform.md) | Main architecture specification (arc42) | Active |
| [database-schema.md](./database-schema.md) | Database schema and ER diagrams | Active |

## Architecture Template

The architecture documentation follows the **arc42** template, which provides 12 sections:

1. **Introduction and Goals** - Requirements overview, quality goals, stakeholders
2. **Constraints** - Technical and organizational constraints
3. **System Scope and Context** - Business and technical context boundaries
4. **Solution Strategy** - Fundamental decisions and solution approaches
5. **Building Block View** - Static decomposition of the system
6. **Runtime View** - Dynamic behavior and interactions
7. **Deployment View** - Technical infrastructure and mapping
8. **Cross-Cutting Concepts** - Patterns and structures across the system
9. **Architecture Decisions** - Important decisions with rationale (links to ADRs)
10. **Quality Requirements** - Quality scenarios and metrics
11. **Risks and Technical Debt** - Known issues and mitigation strategies
12. **Glossary** - Domain and technical terminology

## Diagrams

Architecture diagrams use the **C4 model** notation:

| Level | Diagram | Purpose |
|-------|---------|---------|
| C1 | System Context | High-level view of system and external entities |
| C2 | Container | Applications, data stores, and their interactions |
| C3 | Component | Components within each container |
| C4 | Code | Class-level detail (when needed) |

All diagrams are created using **Mermaid** for version-controlled, text-based diagramming.

## Key Architecture Decisions

Architecture is shaped by 20 Architecture Decision Records (ADRs):

### Core Platform
- [ADR-0001](../03-decisions/adr-0001-project-management-tool.md) - Project Management (Build)
- [ADR-0002](../03-decisions/adr-0002-invoicing-solution.md) - Invoicing (Build + Cashier)
- [ADR-0003](../03-decisions/adr-0003-cms-approach.md) - CMS (Buy - Statamic)
- [ADR-0010](../03-decisions/adr-0010-admin-panel.md) - Admin Panel (Buy - Filament)

### Infrastructure
- [ADR-0011](../03-decisions/adr-0011-infrastructure-hosting.md) - Hosting (Laravel Forge + DigitalOcean)
- [ADR-0014](../03-decisions/adr-0014-payment-processing.md) - Payments (Stripe)
- [ADR-0015](../03-decisions/adr-0015-file-storage-cdn.md) - File Storage (DO Spaces)

### Application Architecture
- [ADR-0017](../03-decisions/adr-0017-marketing-site-architecture.md) - Marketing Site
- [ADR-0018](../03-decisions/adr-0018-client-portal-architecture.md) - Client Portal
- [ADR-0019](../03-decisions/adr-0019-notification-system.md) - Notifications
- [ADR-0020](../03-decisions/adr-0020-performance-optimization.md) - Performance

See [ADR README](../03-decisions/README.md) for complete list.

## Technology Stack

Based on architecture decisions:

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND LAYER                           │
├─────────────────────────────────────────────────────────────┤
│  Marketing Site    │  Client Portal    │  Admin Panel       │
│  (Statamic)        │  (Livewire)       │  (Filament)        │
├─────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  Laravel 11  │  Livewire 3  │  Laravel Cashier  │  Echo    │
├─────────────────────────────────────────────────────────────┤
│                    DATA LAYER                               │
├─────────────────────────────────────────────────────────────┤
│  MySQL 8 (Managed)  │  Redis (Managed)  │  DO Spaces (S3)  │
├─────────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE                           │
├─────────────────────────────────────────────────────────────┤
│  DigitalOcean Droplets  │  Laravel Forge  │  Nginx + PHP 8.3│
└─────────────────────────────────────────────────────────────┘
```

## External Services

| Service | Purpose | ADR |
|---------|---------|-----|
| Stripe | Payment processing | ADR-0014 |
| Postmark | Transactional email | ADR-0008 |
| ConvertKit | Email marketing | ADR-0007 |
| Proposify | Proposals/quotes | ADR-0009 |
| Pusher | Real-time messaging | ADR-0004 |
| Flare | Error monitoring | ADR-0016 |

## Traceability

Architecture documentation maintains Golden Thread traceability:

```
Requirements (01-requirements/)
        │
        ▼
ADRs (03-decisions/)
        │
        ▼
Architecture (02-architecture/)  ◄── You are here
        │
        ▼
Implementation (Code)
```

## Quality Attributes

Key non-functional requirements addressed in architecture:

| Quality | Target | How Addressed |
|---------|--------|---------------|
| Performance | < 3s page load | Multi-layer caching (ADR-0020) |
| Availability | 99.9% uptime | Managed services, monitoring (ADR-0011, ADR-0016) |
| Security | GDPR compliant | Encryption, audit logging (ADR-0012) |
| Scalability | 1000+ concurrent | Horizontal scaling, CDN (ADR-0011, ADR-0015) |

## Related Documentation

- [Requirements](../01-requirements/README.md) - 101 requirements across 13 domains
- [Architecture Decisions](../03-decisions/README.md) - 20 ADRs
- [Governance](../00-governance/) - SOPs and quality gates

---

## Change Log

| Date | Change Description |
|------|-------------------|
| 2025-11-29 | Initial architecture documentation |
