# Architecture Decision Records (ADRs)

**Total ADRs:** 16
**Last Updated:** 2025-11-29

---

## Summary

### Core Platform Decisions (ADR-0001 to ADR-0010)

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

### Infrastructure & Operations (ADR-0011 to ADR-0016)

| ADR | Decision | Status | Approach |
|-----|----------|--------|----------|
| [ADR-0011](./adr-0011-infrastructure-hosting.md) | Infrastructure & Hosting | Proposed | **Buy** - Laravel Forge + DigitalOcean |
| [ADR-0012](./adr-0012-security-data-protection.md) | Security & Data Protection | Proposed | **Build** - Laravel Native + Spatie Packages |
| [ADR-0013](./adr-0013-analytics-reporting.md) | Analytics & Reporting | Proposed | **Build** - Filament Widgets + Laravel Excel |
| [ADR-0014](./adr-0014-payment-processing.md) | Payment Processing | Proposed | **Buy** - Stripe via Laravel Cashier |
| [ADR-0015](./adr-0015-file-storage-cdn.md) | File Storage & CDN | Proposed | **Buy** - DigitalOcean Spaces |
| [ADR-0016](./adr-0016-error-monitoring-logging.md) | Error Monitoring & Logging | Proposed | **Buy** - Flare |

---

## Build vs Buy Summary

### Build (Custom Laravel)
- Project Management (REQ-PROJ-*)
- Invoicing with Cashier (REQ-BILL-*)
- Messaging (REQ-COMM-004)
- Support Tickets (REQ-PORT-007)
- Time Tracking (REQ-PROJ-005)
- Security & Data Protection (REQ-SEC-*)
- Analytics & Reporting (REQ-ANLY-*)

**Rationale:** Core agency operations requiring deep integration with each other and the client portal. Custom build provides data ownership, no per-seat costs, and seamless workflows.

### Buy (Third-Party Services/Packages)
- **Statamic** - CMS ($259 one-time)
- **ConvertKit** - Email Marketing (free up to 1k, then $9-25/mo)
- **Postmark** - Transactional Email ($1.25/1k emails)
- **Proposify** - Proposals ($49/user/mo)
- **Filament** - Admin Panel (free, MIT license)
- **Laravel Forge** - Server Management ($12/mo)
- **DigitalOcean** - Infrastructure ($50-150/mo)
- **DigitalOcean Spaces** - File Storage ($5/mo + bandwidth)
- **Stripe** - Payment Processing (2.9% + $0.30/txn)
- **Flare** - Error Monitoring ($9/mo)
- **Pusher** - Real-time (free tier, then $49/mo)

**Rationale:** Non-core functionality where specialized tools provide better results than custom development. Focus development effort on unique agency platform features.

---

## Technology Stack Summary

Based on these ADRs, the platform technology stack includes:

### Core Framework
- **Laravel 11** - PHP framework
- **Livewire 3** - Reactive components
- **Filament 3** - Admin panel

### Data & Storage
- **MySQL 8** - Primary database (DigitalOcean Managed)
- **Redis** - Caching, queues, sessions (DigitalOcean Managed)
- **DigitalOcean Spaces** - File storage (S3-compatible + CDN)

### Infrastructure
- **DigitalOcean Droplets** - Web/worker servers
- **Laravel Forge** - Server provisioning and deployment
- **Nginx** - Web server
- **PHP 8.3** - Runtime

### External Services
- **Stripe** - Payments (via Laravel Cashier)
- **Postmark** - Transactional email
- **ConvertKit** - Email marketing
- **Proposify** - Proposal generation
- **Pusher** - Real-time messaging
- **Flare** - Error monitoring

### Content
- **Statamic** - CMS for blog and marketing pages

### Security & Monitoring
- **Laravel Sanctum** - API authentication
- **Spatie Activity Log** - Audit logging
- **Spatie Backup** - Automated backups
- **Flare/Ignition** - Error tracking

---

## Requirement Traceability

| ADR | Implements Requirements |
|-----|------------------------|
| ADR-0001 | REQ-PROJ-001, REQ-PROJ-003, REQ-PROJ-005 |
| ADR-0002 | REQ-BILL-001, REQ-BILL-004 |
| ADR-0003 | REQ-CMS-001, REQ-CMS-002, REQ-CMS-003, REQ-CMS-004, REQ-CMS-008 |
| ADR-0004 | REQ-COMM-004 |
| ADR-0005 | REQ-PORT-007 |
| ADR-0006 | REQ-PROJ-005 |
| ADR-0007 | REQ-MKTG-005, REQ-MKTG-006 |
| ADR-0008 | REQ-INTG-002, REQ-COMM-002 |
| ADR-0009 | REQ-BILL-009 |
| ADR-0010 | Multiple (AUTH, USER, PROJ, BILL, CMS) |
| ADR-0011 | REQ-PERF-003, REQ-PERF-007, REQ-PERF-008 |
| ADR-0012 | REQ-SEC-001 through REQ-SEC-008 |
| ADR-0013 | REQ-ANLY-001 through REQ-ANLY-007 |
| ADR-0014 | REQ-INTG-001, REQ-BILL-002 |
| ADR-0015 | REQ-INTG-003, REQ-PERF-004 |
| ADR-0016 | REQ-INTG-010, REQ-SEC-005, REQ-PERF-008 |

---

## Estimated Costs

### One-Time
- Statamic Pro License: $259

### Monthly (Fixed)
- Laravel Forge: $12/mo
- DigitalOcean (base infrastructure): ~$65/mo
  - Web server: $18/mo
  - Managed MySQL: $15/mo
  - Managed Redis: $15/mo
  - Spaces: $5/mo
  - Load balancer (when scaling): $12/mo
- Flare: $9/mo

### Monthly (Variable)
- ConvertKit: $0-25/mo (based on subscribers)
- Postmark: ~$10-50/mo (based on email volume)
- Proposify: $49/user/mo (sales team only)
- Pusher: $0-49/mo (based on connections)
- DigitalOcean bandwidth: ~$10-30/mo

### Per Transaction
- Stripe: 2.9% + $0.30 per transaction

### Estimated Total (Launch)
- **One-time:** ~$260
- **Monthly:** ~$100-200/mo (depending on usage)

---

## ADR Dependencies

```
ADR-0010 (Filament) ─────────────────────────────────┐
                                                      │
ADR-0001 (Projects) ──► ADR-0006 (Time) ──► ADR-0002 (Invoicing)
                                                      │
ADR-0014 (Stripe) ────────────────────────────────────┘

ADR-0011 (Infrastructure) ──► ADR-0015 (Storage)
         │
         └──► ADR-0012 (Security) ──► ADR-0016 (Monitoring)

ADR-0003 (CMS) ──► ADR-0007 (Email Marketing)

ADR-0008 (Transactional Email) ◄── All notification features
```

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
| 2025-11-29 | Added 6 infrastructure/operations ADRs (0011-0016) |
