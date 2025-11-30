# Architecture Specification: Agency Platform

**Template Version:** arc42 v8.0
**System:** Agency Platform
**Version:** v1.0.0
**Last Updated:** 2025-11-29

---

## 1. Introduction and Goals

### 1.1 Requirements Overview

The Agency Platform is a comprehensive web application for managing agency operations including:

**Core Functionality:**
- Client portal for project visibility, invoicing, and communication
- Staff admin panel for project management, billing, and analytics
- Marketing site with blog, services, and portfolio
- Time tracking, invoicing, and payment processing

**Key Requirements by Domain:**
- **Authentication:** [REQ-AUTH-001](../01-requirements/req-auth-001.md) through [REQ-AUTH-008](../01-requirements/req-auth-008.md)
- **Projects:** [REQ-PROJ-001](../01-requirements/req-proj-001.md) through [REQ-PROJ-010](../01-requirements/req-proj-010.md)
- **Billing:** [REQ-BILL-001](../01-requirements/req-bill-001.md) through [REQ-BILL-009](../01-requirements/req-bill-009.md)
- **Portal:** [REQ-PORT-001](../01-requirements/req-port-001.md) through [REQ-PORT-009](../01-requirements/req-port-009.md)
- **Marketing:** [REQ-MKTG-001](../01-requirements/req-mktg-001.md) through [REQ-MKTG-009](../01-requirements/req-mktg-009.md)

Total: 101 requirements across 13 domains.

### 1.2 Quality Goals

| Priority | Quality Attribute | Specific Goal |
|----------|-------------------|---------------|
| 1 | Performance | Page load < 3 seconds, API response < 500ms (REQ-PERF-001, REQ-PERF-002) |
| 2 | Availability | 99.9% uptime (8.76 hours max downtime/year) (REQ-PERF-003) |
| 3 | Security | Zero high-severity vulnerabilities, GDPR compliant (REQ-SEC-*) |
| 4 | Usability | Client and staff interfaces intuitive, minimal training required |
| 5 | Maintainability | Modular architecture, comprehensive documentation |

### 1.3 Stakeholders

| Role | Expectations |
|------|--------------|
| Agency Owner | Business insights, client management, revenue tracking |
| Project Managers | Task management, time tracking, client communication |
| Developers | Clean codebase, clear documentation, maintainability |
| Clients | Easy access to project status, invoices, deliverables |
| Finance | Invoice management, payment tracking, financial reports |
| Marketing | Content management, lead capture, SEO control |

---

## 2. Architecture Constraints

### 2.1 Technical Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| Framework | Laravel 11 with PHP 8.3 | All backend code follows Laravel conventions |
| Frontend | Livewire 3 + Alpine.js | Reactive UI without SPA complexity |
| Database | MySQL 8 (DigitalOcean Managed) | SQL queries, Eloquent ORM |
| Hosting | DigitalOcean + Laravel Forge | Must use DO services (ADR-0011) |
| Payments | Stripe only | Payment processing via Laravel Cashier (ADR-0014) |

### 2.2 Organizational Constraints

| Constraint | Description |
|------------|-------------|
| Budget | Infrastructure < $200/month at launch |
| Buy vs Build | Prefer SaaS for non-core functionality (ADR decisions) |
| Team | Small team, minimize operational overhead |
| Timeline | MVP with critical requirements first |

### 2.3 Conventions

- **API Design:** Follow [SOP-004](../00-governance/sop-004-api-guidelines.md) (Zalando guidelines)
- **Code Style:** PSR-12 (enforced via Laravel Pint)
- **Git Workflow:** [SOP-001](../00-governance/sop-001-git-standards.md) (Conventional Commits)
- **Documentation:** All decisions require ADRs per [SOP-000](../00-governance/sop-000-master.md)

---

## 3. System Scope and Context

### 3.1 Business Context

```mermaid
C4Context
  title System Context Diagram - Agency Platform

  Person(staff, "Staff User", "Agency employees managing projects")
  Person(client, "Client User", "Clients viewing projects and paying invoices")
  Person(visitor, "Public Visitor", "Marketing site visitors")

  System(platform, "Agency Platform", "Core application for agency operations")

  System_Ext(stripe, "Stripe", "Payment processing")
  System_Ext(postmark, "Postmark", "Transactional email")
  System_Ext(convertkit, "ConvertKit", "Email marketing")
  System_Ext(proposify, "Proposify", "Proposal generation")
  System_Ext(pusher, "Pusher", "Real-time messaging")
  System_Ext(spaces, "DO Spaces", "File storage + CDN")
  System_Ext(flare, "Flare", "Error monitoring")

  Rel(staff, platform, "Manages projects, invoices, content", "HTTPS")
  Rel(client, platform, "Views projects, pays invoices", "HTTPS")
  Rel(visitor, platform, "Browses marketing site", "HTTPS")

  Rel(platform, stripe, "Processes payments", "REST API")
  Rel(platform, postmark, "Sends emails", "REST API")
  Rel(platform, convertkit, "Marketing automation", "REST API")
  Rel(platform, proposify, "Creates proposals", "Webhooks")
  Rel(platform, pusher, "Real-time events", "WebSocket")
  Rel(platform, spaces, "Stores files", "S3 API")
  Rel(platform, flare, "Reports errors", "REST API")
```

**External Entities:**

| Entity | Purpose | ADR |
|--------|---------|-----|
| Stripe | Payment processing | [ADR-0014](../03-decisions/adr-0014-payment-processing.md) |
| Postmark | Transactional email | [ADR-0008](../03-decisions/adr-0008-transactional-email.md) |
| ConvertKit | Email marketing | [ADR-0007](../03-decisions/adr-0007-email-marketing.md) |
| Proposify | Proposals | [ADR-0009](../03-decisions/adr-0009-proposal-quotes.md) |
| Pusher | Real-time | [ADR-0004](../03-decisions/adr-0004-messaging-chat.md) |
| DO Spaces | File storage | [ADR-0015](../03-decisions/adr-0015-file-storage-cdn.md) |
| Flare | Error monitoring | [ADR-0016](../03-decisions/adr-0016-error-monitoring-logging.md) |

### 3.2 Technical Context

| Interface | Protocol | Data Format | Authentication |
|-----------|----------|-------------|----------------|
| Staff Admin | HTTPS | HTML/JSON | Session (Sanctum) |
| Client Portal | HTTPS | HTML/JSON | Session (Client Guard) |
| Marketing Site | HTTPS | HTML | Public (cached) |
| Internal API | HTTPS | JSON | Sanctum Token |
| Stripe Webhooks | HTTPS | JSON | Signature verification |
| Pusher | WSS | JSON | Channel auth |

---

## 4. Solution Strategy

### 4.1 Technology Decisions

| Decision | Rationale | Reference |
|----------|-----------|-----------|
| Laravel 11 Monolith | Team expertise, rapid development, integrated ecosystem | ADR-0001 |
| Livewire 3 | Reactive UI without SPA complexity, server-side rendering | ADR-0010, ADR-0018 |
| Filament 3 | Rapid admin panel development, rich component library | [ADR-0010](../03-decisions/adr-0010-admin-panel.md) |
| Statamic | Laravel-native CMS, flat-file or database | [ADR-0003](../03-decisions/adr-0003-cms-approach.md) |
| MySQL 8 | Reliable, managed by DigitalOcean, familiar to team | ADR-0011 |
| Redis | Caching, sessions, queues, real-time | [ADR-0020](../03-decisions/adr-0020-performance-optimization.md) |

### 4.2 Architecture Patterns

- **Modular Monolith:** Single deployable with domain-organized code
- **MVC + Service Layer:** Controllers → Services → Models
- **Repository Pattern:** Data access abstraction for testability
- **Event-Driven:** Domain events for cross-cutting concerns
- **Multi-Guard Auth:** Separate authentication for staff vs clients

### 4.3 Key Architectural Principles

1. **Convention over Configuration:** Follow Laravel conventions
2. **Single Responsibility:** Each class has one reason to change
3. **Dependency Injection:** Constructor injection, interface binding
4. **Fail Fast:** Validate early, throw exceptions for invalid states
5. **Defense in Depth:** Multiple security layers

---

## 5. Building Block View

### 5.1 Level 1: System Decomposition

```mermaid
C4Container
  title Container Diagram - Agency Platform

  Person(staff, "Staff User")
  Person(client, "Client User")
  Person(visitor, "Visitor")

  System_Boundary(platform, "Agency Platform") {
    Container(web, "Web Application", "Laravel 11", "Handles all HTTP requests")
    Container(admin, "Admin Panel", "Filament", "Staff administration interface")
    Container(portal, "Client Portal", "Livewire", "Client-facing interface")
    Container(marketing, "Marketing Site", "Statamic", "Public website and blog")
    Container(worker, "Queue Worker", "Laravel Horizon", "Background job processing")
    ContainerDb(db, "Database", "MySQL 8", "Primary data store")
    ContainerDb(redis, "Cache/Queue", "Redis", "Caching, sessions, queues")
    ContainerDb(files, "File Storage", "DO Spaces", "Uploaded files and media")
  }

  Rel(staff, admin, "Uses", "HTTPS")
  Rel(client, portal, "Uses", "HTTPS")
  Rel(visitor, marketing, "Browses", "HTTPS")

  Rel(web, db, "Reads/Writes", "TCP")
  Rel(web, redis, "Caches", "TCP")
  Rel(web, files, "Stores", "HTTPS")
  Rel(worker, db, "Processes", "TCP")
  Rel(worker, redis, "Consumes", "TCP")
```

**Containers:**

| Container | Technology | Responsibility |
|-----------|------------|----------------|
| Web Application | Laravel 11 | HTTP routing, business logic, API |
| Admin Panel | Filament 3 | Staff CRUD operations, dashboards |
| Client Portal | Livewire 3 | Client project view, payments, communication |
| Marketing Site | Statamic 4 | Blog, pages, contact forms |
| Queue Worker | Laravel Horizon | Background jobs, notifications, reports |
| Database | MySQL 8 | Persistent data storage |
| Cache/Queue | Redis 7 | Performance optimization, job queues |
| File Storage | DO Spaces | User uploads, deliverables, media |

### 5.2 Level 2: Domain Model

```mermaid
erDiagram
    User ||--o{ Project : "manages"
    User ||--o{ TimeEntry : "logs"
    Client ||--o{ Project : "owns"
    Client ||--o{ Invoice : "receives"
    Client ||--o{ ClientUser : "has"
    Project ||--o{ Task : "contains"
    Project ||--o{ Milestone : "has"
    Project ||--o{ Deliverable : "produces"
    Project ||--o{ TimeEntry : "tracks"
    Invoice ||--o{ InvoiceItem : "contains"
    Invoice ||--o{ Payment : "receives"
    Conversation ||--o{ Message : "contains"
    Project ||--o{ Comment : "has"
    Ticket ||--o{ TicketReply : "has"

    User {
        uuid id PK
        string name
        string email
        string role
        timestamp created_at
    }

    Client {
        uuid id PK
        string company_name
        string email
        string stripe_id
        timestamp created_at
    }

    Project {
        uuid id PK
        uuid client_id FK
        string name
        string status
        decimal budget
        date due_date
    }

    Invoice {
        uuid id PK
        uuid client_id FK
        string number
        decimal amount
        string status
        date due_date
    }

    Task {
        uuid id PK
        uuid project_id FK
        uuid assignee_id FK
        string title
        string status
        date due_date
    }
```

### 5.3 Level 3: Application Structure

```
app/
├── Console/
│   └── Commands/          # Artisan commands
├── Domain/
│   ├── Auth/              # Authentication logic
│   ├── Billing/           # Invoicing, payments
│   ├── Clients/           # Client management
│   ├── Communication/     # Messages, notifications
│   ├── Projects/          # Project & task management
│   └── Reporting/         # Analytics, exports
├── Filament/
│   ├── Resources/         # Admin CRUD resources
│   ├── Pages/             # Custom admin pages
│   └── Widgets/           # Dashboard widgets
├── Http/
│   ├── Controllers/       # HTTP controllers
│   ├── Middleware/        # Request middleware
│   └── Requests/          # Form requests
├── Livewire/
│   ├── Portal/            # Client portal components
│   └── Components/        # Shared components
├── Models/                # Eloquent models
├── Notifications/         # Notification classes
├── Policies/              # Authorization policies
├── Providers/             # Service providers
└── Services/              # Business logic services
```

---

## 6. Runtime View

### 6.1 Scenario: Client Views Project Status

```mermaid
sequenceDiagram
    participant C as Client
    participant P as Portal (Livewire)
    participant A as Auth Middleware
    participant S as ProjectService
    participant D as Database
    participant R as Redis Cache

    C->>P: GET /portal/projects/{id}
    P->>A: Verify client session
    A-->>P: Authenticated (client guard)
    P->>R: Check project cache
    R-->>P: Cache miss
    P->>S: getProject(id)
    S->>D: Query project + relations
    D-->>S: Project data
    S->>R: Cache project (10 min)
    S-->>P: Project DTO
    P-->>C: Render project view
```

### 6.2 Scenario: Staff Creates Invoice

```mermaid
sequenceDiagram
    participant U as Staff User
    participant F as Filament Admin
    participant I as InvoiceService
    participant D as Database
    participant Q as Queue
    participant E as Postmark
    participant S as Stripe

    U->>F: Create invoice form
    F->>I: createInvoice(data)
    I->>D: Insert invoice record
    D-->>I: Invoice created
    I->>D: Insert line items
    I->>Q: Dispatch GenerateInvoicePdf
    I->>Q: Dispatch SendInvoiceEmail
    I-->>F: Invoice created
    F-->>U: Success + redirect

    Note over Q,E: Async processing
    Q->>I: GenerateInvoicePdf
    I->>D: Get invoice data
    I-->>Q: PDF stored in Spaces

    Q->>E: SendInvoiceEmail
    E-->>Q: Email sent
```

### 6.3 Scenario: Client Pays Invoice

```mermaid
sequenceDiagram
    participant C as Client
    participant P as Portal
    participant I as InvoiceService
    participant S as Stripe
    participant W as Webhook Handler
    participant D as Database
    participant N as NotificationService

    C->>P: Click "Pay Invoice"
    P->>I: initiatePayment(invoice)
    I->>S: Create Checkout Session
    S-->>I: Session URL
    I-->>P: Redirect URL
    P-->>C: Redirect to Stripe

    C->>S: Complete payment
    S->>W: webhook: checkout.session.completed
    W->>I: processPayment(session)
    I->>D: Mark invoice paid
    I->>N: Notify staff
    I->>N: Send receipt to client
    W-->>S: 200 OK

    C->>P: Return to success page
    P-->>C: Payment confirmed
```

---

## 7. Deployment View

### 7.1 Production Environment (DigitalOcean)

```mermaid
C4Deployment
  title Deployment Diagram - Production Environment

  Deployment_Node(do, "DigitalOcean", "NYC3 Region") {
    Deployment_Node(lb, "Load Balancer", "$12/mo") {
      Container(lb_inst, "DO Load Balancer", "TLS termination, health checks")
    }

    Deployment_Node(web1, "Web Droplet 1", "2GB RAM") {
      Container(app1, "Laravel App", "Nginx + PHP-FPM 8.3")
    }

    Deployment_Node(web2, "Web Droplet 2", "2GB RAM") {
      Container(app2, "Laravel App", "Nginx + PHP-FPM 8.3")
    }

    Deployment_Node(worker, "Worker Droplet", "2GB RAM") {
      Container(horizon, "Laravel Horizon", "Queue processing")
    }

    Deployment_Node(db_cluster, "Managed Database") {
      ContainerDb(mysql, "MySQL 8", "Primary + standby")
    }

    Deployment_Node(redis_cluster, "Managed Redis") {
      ContainerDb(redis, "Redis 7", "Cache + sessions")
    }

    Deployment_Node(spaces, "Spaces + CDN") {
      ContainerDb(s3, "Object Storage", "Files + media")
    }
  }

  Rel(lb_inst, app1, "Routes", "HTTP")
  Rel(lb_inst, app2, "Routes", "HTTP")
  Rel(app1, mysql, "Queries", "3306")
  Rel(app2, mysql, "Queries", "3306")
  Rel(horizon, mysql, "Queries", "3306")
  Rel(app1, redis, "Cache", "6379")
  Rel(app2, redis, "Cache", "6379")
  Rel(app1, s3, "Files", "HTTPS")
```

### 7.2 Infrastructure Specifications

| Component | Specification | Monthly Cost |
|-----------|---------------|--------------|
| Load Balancer | DO Load Balancer | $12 |
| Web Server x2 | 2GB RAM, 2 vCPU | $36 |
| Worker Server | 2GB RAM, 2 vCPU | $18 |
| Managed MySQL | 1GB RAM, 10GB storage | $15 |
| Managed Redis | 1GB RAM | $15 |
| Spaces | 250GB storage | $5 |
| Laravel Forge | Server management | $12 |
| **Total** | | **~$113/mo** |

### 7.3 Deployment Pipeline

```mermaid
flowchart LR
    A[Push to main] --> B[GitHub Actions]
    B --> C{Tests Pass?}
    C -->|Yes| D[Laravel Forge Webhook]
    C -->|No| E[Notify Team]
    D --> F[Pull Latest Code]
    F --> G[Composer Install]
    G --> H[Migrate Database]
    H --> I[Cache Config/Routes]
    I --> J[Restart PHP-FPM]
    J --> K[Health Check]
    K -->|Pass| L[Deploy Complete]
    K -->|Fail| M[Rollback]
```

---

## 8. Cross-Cutting Concepts

### 8.1 Authentication & Authorization

**Authentication Strategy:**
- Staff users: Laravel session + Sanctum tokens
- Client users: Separate guard (`client`) with session auth
- API access: Sanctum tokens with abilities

**Authorization Strategy:**
- Laravel Policies for model-level authorization
- Filament Shield for admin panel permissions
- Client scope: Global scope ensures clients only see their data

**Reference:** [ADR-0012](../03-decisions/adr-0012-security-data-protection.md)

### 8.2 Caching Strategy

```
Layer 1: Browser Cache
├── Static assets: 1 year (versioned)
└── API: Cache-Control headers

Layer 2: CDN (Spaces)
├── Static files from /build
└── Media library images

Layer 3: HTTP Response Cache
├── Marketing pages: 1 hour (spatie/laravel-responsecache)
└── Statamic static cache

Layer 4: Application Cache (Redis)
├── Config/route/view cache
├── Query results (model::remember)
└── Computed values (dashboard stats)

Layer 5: Database
├── Optimized indexes
└── Eager loading
```

**Reference:** [ADR-0020](../03-decisions/adr-0020-performance-optimization.md)

### 8.3 Security

| Layer | Implementation |
|-------|----------------|
| Transport | TLS 1.3, HSTS |
| Authentication | Bcrypt passwords, optional MFA |
| Authorization | Policies, guards, global scopes |
| Input Validation | Form requests, sanitization |
| Output Encoding | Blade auto-escaping |
| CSRF | Laravel CSRF middleware |
| Rate Limiting | Laravel RateLimiter |
| Encryption | AES-256 for sensitive fields |
| Audit | Spatie Activity Log |

**Reference:** [ADR-0012](../03-decisions/adr-0012-security-data-protection.md)

### 8.4 Error Handling

- **Client Errors (4xx):** Validation messages, redirect with errors
- **Server Errors (5xx):** Log to Flare, generic user message
- **External API Failures:** Circuit breaker, retry with backoff
- **Queue Failures:** Retry 3 times, then fail to dead letter

**Reference:** [ADR-0016](../03-decisions/adr-0016-error-monitoring-logging.md)

### 8.5 Notification System

```mermaid
flowchart TB
    E[Event Occurs] --> N[Notification Created]
    N --> C{User Preferences}
    C -->|In-App| D[Database Channel]
    C -->|Email| M[Postmark Channel]
    C -->|Real-time| B[Broadcast Channel]
    D --> UI[Bell Icon Badge]
    M --> EM[Email Delivered]
    B --> P[Pusher → Browser]
```

**Reference:** [ADR-0019](../03-decisions/adr-0019-notification-system.md)

---

## 9. Architecture Decisions

| ADR | Title | Status | Category |
|-----|-------|--------|----------|
| [ADR-0001](../03-decisions/adr-0001-project-management-tool.md) | Project Management Tool | Proposed | Core |
| [ADR-0002](../03-decisions/adr-0002-invoicing-solution.md) | Invoicing Solution | Proposed | Core |
| [ADR-0003](../03-decisions/adr-0003-cms-approach.md) | CMS Approach | Proposed | Core |
| [ADR-0004](../03-decisions/adr-0004-messaging-chat.md) | Messaging/Chat | Proposed | Core |
| [ADR-0005](../03-decisions/adr-0005-support-tickets.md) | Support Tickets | Proposed | Core |
| [ADR-0006](../03-decisions/adr-0006-time-tracking.md) | Time Tracking | Proposed | Core |
| [ADR-0007](../03-decisions/adr-0007-email-marketing.md) | Email Marketing | Proposed | Integration |
| [ADR-0008](../03-decisions/adr-0008-transactional-email.md) | Transactional Email | Proposed | Integration |
| [ADR-0009](../03-decisions/adr-0009-proposal-quotes.md) | Proposal/Quotes | Proposed | Integration |
| [ADR-0010](../03-decisions/adr-0010-admin-panel.md) | Admin Panel | Proposed | Core |
| [ADR-0011](../03-decisions/adr-0011-infrastructure-hosting.md) | Infrastructure & Hosting | Proposed | Ops |
| [ADR-0012](../03-decisions/adr-0012-security-data-protection.md) | Security & Data Protection | Proposed | Ops |
| [ADR-0013](../03-decisions/adr-0013-analytics-reporting.md) | Analytics & Reporting | Proposed | Core |
| [ADR-0014](../03-decisions/adr-0014-payment-processing.md) | Payment Processing | Proposed | Integration |
| [ADR-0015](../03-decisions/adr-0015-file-storage-cdn.md) | File Storage & CDN | Proposed | Ops |
| [ADR-0016](../03-decisions/adr-0016-error-monitoring-logging.md) | Error Monitoring | Proposed | Ops |
| [ADR-0017](../03-decisions/adr-0017-marketing-site-architecture.md) | Marketing Site | Proposed | App |
| [ADR-0018](../03-decisions/adr-0018-client-portal-architecture.md) | Client Portal | Proposed | App |
| [ADR-0019](../03-decisions/adr-0019-notification-system.md) | Notification System | Proposed | App |
| [ADR-0020](../03-decisions/adr-0020-performance-optimization.md) | Performance Optimization | Proposed | Ops |

---

## 10. Quality Requirements

### 10.1 Quality Scenarios

| ID | Attribute | Scenario | Target |
|----|-----------|----------|--------|
| QA-1 | Performance | Marketing page request | Load < 2s (cached) |
| QA-2 | Performance | Portal dashboard request | Load < 3s |
| QA-3 | Performance | API request | Response < 500ms |
| QA-4 | Availability | System uptime | 99.9% monthly |
| QA-5 | Security | Authentication attempt | Brute force protection |
| QA-6 | Security | Data access | Client isolation enforced |
| QA-7 | Scalability | Concurrent users | 100+ without degradation |
| QA-8 | Maintainability | New feature | Implementation < 1 sprint |

### 10.2 Quality Tree

```
Quality Goals
├── Performance (REQ-PERF-*)
│   ├── Page Load Time (< 3s)
│   ├── API Response Time (< 500ms)
│   └── Cache Hit Rate (> 80%)
├── Reliability (REQ-PERF-003)
│   ├── Uptime (99.9%)
│   ├── Data Durability (backups)
│   └── Error Recovery (auto-restart)
├── Security (REQ-SEC-*)
│   ├── Authentication (MFA option)
│   ├── Authorization (RBAC + policies)
│   ├── Data Protection (encryption)
│   └── Compliance (GDPR)
└── Usability
    ├── Staff Efficiency (Filament)
    ├── Client Experience (Portal)
    └── Public Accessibility (Marketing)
```

---

## 11. Risks and Technical Debt

### 11.1 Identified Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Database performance bottleneck | Medium | High | Read replica, query optimization (ADR-0020) |
| Stripe API downtime | Low | High | Display cached invoice data, retry payments |
| Cache stampede | Low | Medium | Cache locks, staggered expiration |
| Team member unavailable | Medium | Medium | Documentation, pair programming |
| Vendor price increases | Low | Medium | Abstract integrations, monitor alternatives |

### 11.2 Technical Debt

| Debt Item | Impact | Plan |
|-----------|--------|------|
| Monolith may limit scaling | Low (current scale) | Evaluate if >1000 daily users |
| Manual scaling | Low | Implement auto-scaling triggers if needed |
| Single region deployment | Medium | Multi-region if global clients needed |

### 11.3 Assumptions

- Traffic will remain manageable with current infrastructure for 12+ months
- Client base will be primarily English-speaking (no i18n initially)
- Mobile app not required (responsive web sufficient)
- Team will maintain Laravel/PHP expertise

---

## 12. Glossary

| Term | Definition |
|------|------------|
| ADR | Architectural Decision Record - documented decision |
| CRUD | Create, Read, Update, Delete operations |
| DTO | Data Transfer Object |
| Filament | Laravel admin panel framework |
| Guard | Laravel authentication guard (user type separation) |
| Horizon | Laravel queue monitoring dashboard |
| Livewire | Laravel full-stack framework for reactive interfaces |
| MFA | Multi-Factor Authentication |
| Policy | Laravel authorization class |
| Sanctum | Laravel authentication package |
| Statamic | Laravel-based flat-file/database CMS |
| TTL | Time To Live (cache expiration) |

---

## References

- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)
- [SOP-001: Git Standards](../00-governance/sop-001-git-standards.md)
- [SOP-004: API Guidelines](../00-governance/sop-004-api-guidelines.md)
- [Requirements Overview](../01-requirements/README.md)
- [ADR Index](../03-decisions/README.md)
- [arc42 Template Guide](https://arc42.org/overview)
- [C4 Model Documentation](https://c4model.com)
- [Laravel Documentation](https://laravel.com/docs)
- [Filament Documentation](https://filamentphp.com/docs)
- [Statamic Documentation](https://statamic.dev)

---

## Change Log

| Date | Author | Change Description |
|------|--------|-------------------|
| 2025-11-29 | Claude | Initial architecture specification |
