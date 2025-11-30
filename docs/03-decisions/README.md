# Architecture Decision Records (ADRs)

**Total ADRs:** 10
**Last Updated:** 2025-11-29

---

## Summary

| ADR | Decision | Status | Approach |
|-----|----------|--------|----------|
| [ADR-0001](./adr-0001-project-management-tool.md) | Project Management Tool | Proposed | **Build** - Custom Laravel |
| [ADR-0002](./adr-0002-invoicing-solution.md) | Invoicing Solution | Proposed | **Build** - Laravel Cashier + Custom |
| [ADR-0003](./adr-0003-cms-approach.md) | CMS Approach | Proposed | **Buy** - Statamic |
| [ADR-0004](./adr-0004-messaging-chat.md) | Messaging/Chat | Proposed | **Build** - Custom + Laravel Echo |
| [ADR-0005](./adr-0005-support-tickets.md) | Support Tickets | Proposed | **Build** - Custom Laravel |
| [ADR-0006](./adr-0006-time-tracking.md) | Time Tracking | Proposed | **Build** - Custom Laravel |
| [ADR-0007](./adr-0007-email-marketing.md) | Email Marketing | Proposed | **Buy** - ConvertKit |
| [ADR-0008](./adr-0008-transactional-email.md) | Transactional Email | Proposed | **Buy** - Postmark |
| [ADR-0009](./adr-0009-proposal-quotes.md) | Proposal/Quotes | Proposed | **Buy** - Proposify |
| [ADR-0010](./adr-0010-admin-panel.md) | Admin Panel | Proposed | **Buy** - Filament (free) |

---

## Build vs Buy Summary

### Build (Custom Laravel)
- Project Management (REQ-PROJ-*)
- Invoicing with Cashier (REQ-BILL-*)
- Messaging (REQ-COMM-004)
- Support Tickets (REQ-PORT-007)
- Time Tracking (REQ-PROJ-005)

**Rationale:** Core agency operations requiring deep integration with each other and the client portal. Custom build provides data ownership, no per-seat costs, and seamless workflows.

### Buy (Third-Party Services)
- **Statamic** - CMS ($259 one-time)
- **ConvertKit** - Email Marketing (free up to 1k, then $9-25/mo)
- **Postmark** - Transactional Email ($1.25/1k emails)
- **Proposify** - Proposals ($49/user/mo)
- **Filament** - Admin Panel (free, MIT license)

**Rationale:** Non-core functionality where specialized tools provide better results than custom development. Focus development effort on unique agency platform features.

---

## Technology Stack Summary

Based on these ADRs, the platform technology stack includes:

### Core Framework
- **Laravel** - PHP framework
- **Livewire** - Reactive components
- **Filament** - Admin panel

### Data & Storage
- **MySQL/PostgreSQL** - Primary database
- **Redis** - Caching, queues, sessions
- **S3** - File storage (REQ-INTG-003)

### External Services
- **Stripe** - Payments (via Laravel Cashier)
- **Postmark** - Transactional email
- **ConvertKit** - Email marketing
- **Proposify** - Proposal generation
- **Pusher/Soketi** - Real-time messaging

### Content
- **Statamic** - CMS for blog and marketing pages

---

## Requirement Traceability

| ADR | Implements Requirements |
|-----|------------------------|
| ADR-0001 | REQ-PROJ-001, REQ-PROJ-003, REQ-PROJ-005 |
| ADR-0002 | REQ-BILL-001, REQ-BILL-004 |
| ADR-0003 | REQ-CMS-001, REQ-CMS-008 |
| ADR-0004 | REQ-COMM-004 |
| ADR-0005 | REQ-PORT-007 |
| ADR-0006 | REQ-PROJ-005 |
| ADR-0007 | REQ-MKTG-005, REQ-MKTG-006 |
| ADR-0008 | REQ-INTG-002 |
| ADR-0009 | REQ-BILL-009 |
| ADR-0010 | Multiple (AUTH, USER, PROJ, BILL, CMS) |

---

## Estimated Costs

### One-Time
- Statamic Pro License: $259

### Monthly (Variable)
- ConvertKit: $0-25/mo (based on subscribers)
- Postmark: ~$10-50/mo (based on email volume)
- Proposify: $49/user/mo (sales team only)
- Pusher: $0-49/mo (based on connections)

### Per Transaction
- Stripe: 2.9% + $0.30 per transaction

---

## Next Steps

1. **Review and Approve ADRs** - Team review of each decision
2. **Update Requirements** - Link "Satisfied By" fields to ADRs
3. **Create Architecture Documents** - arc42 documentation citing ADRs
4. **Begin Implementation** - Start with core build components

---

## Change Log

| Date       | Change Description                     |
|------------|----------------------------------------|
| 2025-11-29 | Initial creation of 10 ADRs            |
