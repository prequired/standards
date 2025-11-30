---
id: "ADR-0010"
title: "Admin Panel Framework Selection"
status: "proposed"
date: 2025-11-29
implements_requirement: "Multiple (AUTH, USER, PROJ, BILL, CMS)"
decision_makers: "Platform Team"
consulted: "Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0010: Admin Panel Framework Selection

## Context and Problem Statement

The platform requires a comprehensive admin panel for staff to manage:
- Users and organizations (REQ-USER-001 through REQ-USER-008)
- Projects and tasks (REQ-PROJ-001 through REQ-PROJ-010)
- Invoices and payments (REQ-BILL-001 through REQ-BILL-009)
- Content (if not using Statamic admin - see ADR-0003)
- Analytics and reports (REQ-ANLY-001 through REQ-ANLY-007)
- System configuration

The admin panel is the primary interface for agency staff and must be efficient, intuitive, and comprehensive.

## Decision Drivers

- **Laravel Native:** Must work seamlessly with Laravel/Eloquent
- **Customization:** Support complex business logic, not just CRUD
- **Performance:** Handle large data sets efficiently
- **Developer Experience:** Easy to extend and maintain
- **UI Quality:** Modern, professional interface
- **Component Library:** Rich set of form inputs, tables, widgets

## Considered Options

1. **Option A:** Build custom admin with Blade/Livewire
2. **Option B:** Filament Admin Panel
3. **Option C:** Laravel Nova
4. **Option D:** Backpack for Laravel
5. **Option E:** Voyager

## Decision Outcome

**Chosen Option:** Option B - Filament Admin Panel

**Justification:** Filament is a modern, TALL-stack admin panel that provides:
- Beautiful, modern UI out of the box
- Livewire-based (real-time, no page refreshes)
- Highly customizable resources and pages
- Built-in form builder with 50+ field types
- Table builder with filters, search, bulk actions
- Widget system for dashboards
- Relation managers for complex data
- Free and open source
- Active development and community

Filament aligns perfectly with the Laravel ecosystem and provides the flexibility needed for agency-specific workflows.

### Consequences

#### Positive

- Rapid admin development (resources generated from models)
- Modern, polished UI that impresses clients
- Livewire integration means real-time updates
- Extensive plugin ecosystem
- Free (MIT license)
- Excellent documentation
- Active Discord community

#### Negative

- Livewire learning curve for team
- Some advanced customizations require deep Filament knowledge
- Opinionated structure may require adaptation
- Bundle size larger than minimal admin

#### Risks

- **Risk:** Performance with large data sets
  - **Mitigation:** Use Filament's built-in pagination, lazy loading; optimize queries
- **Risk:** Customization hits limitations
  - **Mitigation:** Filament is very extensible; custom pages/components possible
- **Risk:** Breaking changes in major versions
  - **Mitigation:** Lock to specific version; test upgrades in staging

## Validation

- **Metric 1:** Admin page load under 1 second
- **Metric 2:** CRUD operations complete in under 500ms
- **Metric 3:** New resource (model admin) created in under 1 hour
- **Metric 4:** Staff satisfaction score >4/5 for admin usability

## Pros and Cons of the Options

### Option A: Custom Build

**Pros:**
- Maximum flexibility
- Exactly what's needed
- No framework constraints

**Cons:**
- Significant development time
- Must build all components
- Ongoing maintenance burden
- Inconsistent UI without design system

### Option B: Filament

**Pros:**
- Modern, beautiful UI
- Livewire-based (reactive)
- Highly customizable
- Free and open source
- Active community
- Great documentation

**Cons:**
- Learning curve
- Livewire dependency
- Some opinions to work around

### Option C: Laravel Nova

**Pros:**
- Official Laravel product
- Polished, professional
- Good documentation
- Vue-based

**Cons:**
- Paid license ($199/site or $299/unlimited)
- Vue (not Livewire) - different stack
- Less customizable than Filament
- Slower innovation pace

### Option D: Backpack for Laravel

**Pros:**
- Mature, battle-tested
- Good CRUD operations
- jQuery-based (simple)

**Cons:**
- Dated UI design
- jQuery feels legacy
- Paid for advanced features
- Less modern developer experience

### Option E: Voyager

**Pros:**
- Free and open source
- Quick setup
- Media manager included

**Cons:**
- Less actively maintained
- Dated design
- Limited customization
- More CMS than admin framework

## Implementation Notes

- Install Filament: `composer require filament/filament`
- Run installer: `php artisan filament:install --panels`
- Create resources for core models:
  - `php artisan make:filament-resource User`
  - `php artisan make:filament-resource Project`
  - `php artisan make:filament-resource Invoice`
  - `php artisan make:filament-resource Client`
- Configure navigation groups (Users, Projects, Billing, Content, Settings)
- Create dashboard widgets for key metrics
- Implement custom pages for complex workflows (reports, bulk operations)
- Use Filament's notification system for admin alerts
- Configure multi-tenancy if needed (staff sees all, per-org views)
- Set up Filament Shield for granular permissions

## Links

- [REQ-AUTH-004](../01-requirements/req-auth-004.md) - Role-Based Access Control
- [REQ-USER-001](../01-requirements/req-user-001.md) - Staff User Profiles
- [REQ-ANLY-001](../01-requirements/req-anly-001.md) - Admin Analytics Dashboard
- [ADR-0001](./adr-0001-project-management-tool.md) - Project Management (admin interface)
- [ADR-0002](./adr-0002-invoicing-solution.md) - Invoicing (admin interface)
- [Filament Documentation](https://filamentphp.com/docs)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
