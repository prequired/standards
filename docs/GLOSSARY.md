# Agency Platform Glossary

**Last Updated:** 2025-11-29

This glossary provides definitions for domain-specific terms, acronyms, and technical concepts used throughout the Agency Platform documentation.

---

## A

### Acceptance Criteria
Specific conditions that must be met for a requirement or user story to be considered complete. Each requirement should have at least 5 measurable acceptance criteria.

### ADR (Architecture Decision Record)
A document that captures an important architectural decision made along with its context and consequences. Format follows MADR (Markdown Any Decision Record) template.

### Agency
The organization using the platform to manage client work, typically a digital/creative agency, consultancy, or professional services firm.

### arc42
A template for documenting software and system architecture. Consists of 12 sections covering introduction, constraints, context, solutions, and operational aspects.

---

## B

### Billable Hours
Time tracked against client projects that can be invoiced. Contrast with non-billable time (internal meetings, training, etc.).

### Budget (Project)
The financial allocation for a project, typically stored in cents to avoid floating-point precision issues. Example: 100000 cents = $1,000.00.

---

## C

### C4 Model
A hierarchical approach to software architecture diagramming with four levels: Context, Container, Component, and Code. Used for visualizing system architecture.

### Client
An external organization or individual that contracts the agency for services. Clients have associated projects, contacts, and invoices.

### Client Portal
A dedicated interface where clients can view project progress, access files, approve deliverables, and communicate with the agency team.

### CQRS (Command Query Responsibility Segregation)
An architectural pattern that separates read operations (queries) from write operations (commands). Considered but not adopted per ADR-0019.

---

## D

### Deliverable
A tangible output or work product provided to a client, often requiring approval before the project milestone is considered complete.

### Domain (Requirements)
A functional area grouping related requirements. The platform has 13 domains: AUTH, USER, PROJ, TASK, TIME, BILL, PORT, NOTIF, INTG, SEC, ANLY, SYS, WF.

### Draft Status
Initial state for documents under development. Indicates content is incomplete and not yet reviewed.

---

## E

### Event Sourcing
An architectural pattern where state changes are stored as a sequence of events rather than current state. Considered but not adopted per ADR-0019.

---

## F

### Filament
A Laravel admin panel framework used for the platform's administrative interface (per ADR-0010).

### Fit Criterion
Measurable success criteria for a requirement. Defines how to objectively verify the requirement has been satisfied.

### Frontmatter
YAML metadata at the beginning of Markdown files, containing structured information like id, title, status, and dates.

---

## G

### Golden Thread
The traceability chain linking business requirements through architecture decisions to implementation and testing. Ensures every feature can be traced from origin to delivery.

---

## H

### Help Scout
Third-party support ticket system recommended for client support functionality (per ADR-0005).

### Hook (Laravel)
Event listeners that respond to system events. In the platform context, used for triggering notifications, syncing data, and enforcing business rules.

---

## I

### Invoice
A financial document requesting payment from a client for services rendered. Contains line items, amounts, tax calculations, and payment terms.

### Invoice Line Item
Individual entry on an invoice representing a specific service, product, or time block being billed.

---

## J

### JSON:API
A specification for building APIs in JSON format with standardized resource representation. Adopted per ADR-0008 for API design.

---

## K

### Kanban
A visual workflow management method using cards and columns. Used for task management within projects (per ADR-0003).

---

## L

### Laravel
PHP web application framework used as the platform's core backend technology (per ADR-0001).

### Laravel Sanctum
Authentication system for SPAs and simple token-based APIs. Used for API authentication in the platform.

### Livewire
A Laravel framework for building dynamic interfaces without complex JavaScript. Used for reactive UI components (per ADR-0001).

---

## M

### MADR (Markdown Any Decision Record)
Template format for Architecture Decision Records. Provides structured sections for context, options, decision, and consequences.

### Milestone
A significant checkpoint in a project timeline, often associated with deliverables and payment triggers.

### Money (Monetary Values)
Stored as integers in cents (e.g., $100.00 = 10000 cents) to avoid floating-point precision issues. Uses brick/money library for calculations.

---

## N

### Notification
System message delivered to users via in-app display, email, or other channels. Covers project updates, invoice reminders, task assignments, etc.

---

## O

### OAuth
Open Authorization protocol used for third-party integrations (Stripe, Google Workspace, etc.).

### OpenAPI
Specification for describing REST APIs. The platform maintains an OpenAPI 3.1 specification at `docs/05-api/openapi.yaml`.

---

## P

### Postmark
Transactional email service provider chosen for platform email delivery (per ADR-0014).

### Priority (Requirements)
Importance level: Critical (must-have for MVP), High (important for launch), Medium (post-launch), Low (future consideration).

### Project
A client engagement with defined scope, timeline, budget, and deliverables. Contains tasks, time entries, and associated invoices.

---

## Q

### Quality Gate
Checkpoint requiring documentation to meet specific criteria before advancing. Defined in SOP-002.

### Queue (Laravel)
Background job processing system. Used for email sending, report generation, and async operations.

---

## R

### RBAC (Role-Based Access Control)
Permission system based on user roles. Platform roles: Admin, Manager, Staff, Client (per ADR-0007).

### Requirement
A documented capability or constraint the system must satisfy. Follows Volere template format with ID pattern REQ-DOMAIN-NNN.

### Retainer
Ongoing client engagement with recurring billing, typically monthly. Handled differently from project-based work in time tracking and invoicing.

---

## S

### Sanctum
See Laravel Sanctum.

### SLA (Service Level Agreement)
Commitment to response/resolution times for support tickets. Tracked for client satisfaction metrics.

### SOP (Standard Operating Procedure)
Documented procedure defining how to perform specific activities. Platform has 4 core SOPs in governance.

### Spatie
Laravel package ecosystem. Multiple Spatie packages used: permission, activitylog, media-library (per ADR decisions).

### Sprint
Time-boxed development iteration, typically 2 weeks. Not directly reflected in platform but relevant to development process.

### Stakeholder
Person or group with interest in the platform's outcome. Includes agency staff, clients, management, and technical team.

### Stripe
Payment processing platform for invoice payments, subscriptions, and financial operations (per ADR-0011).

### Status
Current state of an entity. Requirements: draft/approved/implemented. ADRs: proposed/accepted/deprecated. Projects: draft/active/on_hold/completed/archived.

---

## T

### Task
Work unit within a project, assignable to team members with status tracking (pending, in_progress, completed).

### Tenant
In multi-tenancy context, an isolated organizational unit (agency) with its own data. Single-tenant deployment per agency (per ADR-0015).

### Time Entry
Record of time spent on work, with duration, description, project/task association, and billable flag.

### Timer
Live time tracking feature allowing users to start/stop recording time spent on tasks.

### Traceability Matrix
Document mapping requirements to implementations and tests. Part of Golden Thread governance.

---

## U

### UUID (Universally Unique Identifier)
Unique identifier format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx). Used for some resource identifiers.

---

## V

### Volere
Requirements specification template emphasizing measurable fit criteria. Used for all platform requirements.

---

## W

### Webhook
HTTP callback triggered by system events, allowing external systems to receive real-time notifications.

### Workflow
Automated sequence of actions triggered by events. May include approvals, notifications, and status transitions.

---

## Acronyms Quick Reference

| Acronym | Full Term |
|---------|-----------|
| ADR | Architecture Decision Record |
| API | Application Programming Interface |
| CI/CD | Continuous Integration/Continuous Deployment |
| CQRS | Command Query Responsibility Segregation |
| CRUD | Create, Read, Update, Delete |
| DTO | Data Transfer Object |
| MFA | Multi-Factor Authentication |
| MVP | Minimum Viable Product |
| RBAC | Role-Based Access Control |
| REST | Representational State Transfer |
| SLA | Service Level Agreement |
| SOP | Standard Operating Procedure |
| SPA | Single Page Application |
| SSO | Single Sign-On |
| UUID | Universally Unique Identifier |

---

## Requirement Domain Codes

| Code | Domain | Description |
|------|--------|-------------|
| AUTH | Authentication | Login, SSO, MFA, session management |
| USER | User Management | Profiles, roles, permissions, teams |
| PROJ | Project Management | Projects, milestones, client relationships |
| TASK | Task Management | Tasks, assignments, dependencies |
| TIME | Time Tracking | Timers, entries, reports |
| BILL | Billing & Invoicing | Invoices, payments, financial tracking |
| PORT | Client Portal | Client-facing features |
| NOTIF | Notifications | Alerts, emails, messaging |
| INTG | Integrations | Third-party connections |
| SEC | Security | Access control, audit, compliance |
| ANLY | Analytics & Reporting | Dashboards, reports, metrics |
| SYS | System & Platform | Infrastructure, performance, operations |
| WF | Workflow Automation | Triggers, approvals, automation |

---

## Related Documents

- [Architecture Glossary](./02-architecture/arch-agency-platform.md#12-glossary) - Technical architecture terms
- [API Specification](./05-api/api-specification.md) - API-specific terminology
- [Requirements Overview](./01-requirements/README.md) - Domain explanations

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial glossary with 60+ terms |
