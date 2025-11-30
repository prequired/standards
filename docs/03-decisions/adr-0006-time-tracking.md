---
id: "ADR-0006"
title: "Time Tracking Solution Selection"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-PROJ-005"
decision_makers: "Platform Team"
consulted: "Development Team, Project Managers"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0006: Time Tracking Solution Selection

## Context and Problem Statement

[REQ-PROJ-005](../01-requirements/req-proj-005.md) requires time tracking per project and task with timer functionality, manual entry, and reporting. Time entries must integrate with invoicing for billable hour calculations.

Accurate time tracking is essential for agency profitability, project estimation, and transparent client billing.

## Decision Drivers

- **Billing Integration:** Time entries must flow to invoices seamlessly
- **Project Context:** Track time against projects, tasks, and clients
- **Ease of Use:** Staff must track time with minimal friction
- **Reporting:** Utilization reports, project profitability analysis
- **Flexibility:** Support both timer and manual entry
- **Cost:** Per-user pricing impacts growing teams

## Considered Options

1. **Option A:** Build custom time tracking in Laravel
2. **Option B:** Integrate Toggl Track
3. **Option C:** Integrate Harvest
4. **Option D:** Integrate Clockify
5. **Option E:** Use built-in Teamwork time tracking

## Decision Outcome

**Chosen Option:** Option A - Build custom time tracking in Laravel

**Justification:** Time tracking is core to agency operations and must integrate deeply with:
- Project management (ADR-0001: custom built)
- Invoicing (ADR-0002: Laravel Cashier based)
- Reporting (REQ-ANLY-003)

Building custom ensures:
- Direct database relationships (time entries → tasks → projects → invoices)
- No sync delays or API complexity
- No per-user monthly costs
- Full control over billable rate logic and approval workflows

Given projects and invoicing are already custom-built, time tracking completes the integrated workflow.

### Consequences

#### Positive

- Seamless project/invoice integration
- No per-user fees
- Full control over billable logic (rates, rounding, minimums)
- Time data directly available for profitability reports
- Single interface for staff (no context switching)

#### Negative

- Must build timer UI and functionality
- Must implement reporting from scratch
- No mobile app (initially; web-responsive only)
- No integrations with browser extensions or desktop apps

#### Risks

- **Risk:** Staff prefer dedicated time tracking tools
  - **Mitigation:** Focus on UX; make tracking frictionless; allow bulk entry
- **Risk:** Timer accuracy on page refresh/close
  - **Mitigation:** Save timer state to database; resume on return
- **Risk:** Complex billable rate scenarios
  - **Mitigation:** Start with simple rates; add complexity as needed

## Validation

- **Metric 1:** Time entry created in under 30 seconds
- **Metric 2:** Timer starts/stops with single click
- **Metric 3:** Weekly time report generated in under 2 seconds
- **Metric 4:** 90%+ staff compliance with daily time tracking

## Pros and Cons of the Options

### Option A: Build Custom

**Pros:**
- Deep integration with projects/invoices
- No per-user costs
- Full control over features
- Single system for staff

**Cons:**
- Development effort required
- No mobile app initially
- Must build reporting

### Option B: Toggl Track

**Pros:**
- Excellent UX
- Powerful reporting
- Mobile apps
- Browser extensions

**Cons:**
- $10-20/user/month
- Requires API sync to projects
- Separate system/login
- Invoice integration needs custom work

### Option C: Harvest

**Pros:**
- Time + invoicing combined
- Project budgets
- Good integrations

**Cons:**
- $12/user/month
- Would duplicate invoicing (ADR-0002)
- Data lives in Harvest

### Option D: Clockify

**Pros:**
- Free tier available
- Clean interface
- Good reporting

**Cons:**
- Per-user pricing for features ($4-14/user)
- API sync needed
- Separate from portal

### Option E: Teamwork Time Tracking

**Pros:**
- Integrated with Teamwork PM
- Per-seat included

**Cons:**
- Only works with Teamwork (not chosen in ADR-0001)
- Per-seat costs
- Vendor lock-in

## Implementation Notes

- Create `time_entries` table: user_id, project_id, task_id, date, duration, description, billable, rate
- Create `timers` table for active timers: user_id, project_id, task_id, started_at
- Implement timer widget (Livewire component, persistent across pages)
- Support both timer-based and manual duration entry
- Add billable toggle with project-default rates
- Create approval workflow for time entries (optional)
- Generate reports: by user, project, client, date range
- Link time entries to invoice line items when generating invoices

## Links

- [REQ-PROJ-005](../01-requirements/req-proj-005.md) - Time Tracking
- [REQ-PROJ-001](../01-requirements/req-proj-001.md) - Project Management
- [REQ-BILL-001](../01-requirements/req-bill-001.md) - Invoice Generation
- [REQ-ANLY-003](../01-requirements/req-anly-003.md) - Revenue & Financial Reports
- [ADR-0001](./adr-0001-project-management-tool.md) - Project Management Tool
- [ADR-0002](./adr-0002-invoicing-solution.md) - Invoicing Solution
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
