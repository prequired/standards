---
id: "ADR-0001"
title: "Project Management Tool Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-PROJ-001, REQ-PROJ-003, REQ-PROJ-005"
decision_makers: "Platform Team"
consulted: "Development Team, Operations"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0001: Project Management Tool Selection

## Context and Problem Statement

[REQ-PROJ-001](../01-requirements/req-proj-001.md) mandates the ability to create and manage projects with full lifecycle tracking. [REQ-PROJ-003](../01-requirements/req-proj-003.md) requires task management with assignments, due dates, and status tracking. [REQ-PROJ-005](../01-requirements/req-proj-005.md) requires time tracking per task/project.

The agency platform needs robust project management capabilities that integrate seamlessly with the client portal, billing system, and internal workflows. The decision centers on whether to build custom PM functionality, integrate an existing tool, or use a hybrid approach.

## Decision Drivers

- **Integration Depth:** Must integrate with client portal for status visibility (REQ-PORT-002)
- **Time Tracking:** Built-in time tracking for billing integration (REQ-PROJ-005, REQ-BILL-001)
- **Customization:** Agency-specific workflows (proposals → projects → deliverables)
- **Cost:** Minimize per-seat licensing for growing team
- **Client Experience:** Clients should not need separate PM tool accounts
- **Data Ownership:** Project data must be accessible for reporting and analytics

## Considered Options

1. **Option A:** Build custom project management within Laravel
2. **Option B:** Integrate Asana via API
3. **Option C:** Integrate Monday.com via API
4. **Option D:** Integrate Teamwork via API
5. **Option E:** Use Laravel package (e.g., custom Kanban + task system)

## Decision Outcome

**Chosen Option:** Option A - Build custom project management within Laravel

**Justification:** Given the deep integration requirements with client portal, billing, and the need for agency-specific workflows, a custom solution provides the most flexibility. Third-party tools would require:
- Syncing data bidirectionally (complexity, latency)
- Managing separate authentication/permissions
- Per-seat costs that scale with team size
- Limited customization of client-facing views

Building within Laravel allows:
- Single database for projects, invoices, and client data
- Real-time updates without sync delays
- Custom permission model aligned with REQ-AUTH-005
- No per-seat licensing costs
- Full control over client portal experience

### Consequences

#### Positive

- Complete control over data model and workflows
- Seamless integration with billing, portal, and notifications
- No recurring SaaS costs for PM functionality
- Custom reporting and analytics without API limitations
- Single authentication system for staff and clients

#### Negative

- Higher initial development effort (estimated 3-4 weeks for MVP)
- Ongoing maintenance burden for PM features
- No access to advanced PM features (Gantt charts, resource leveling) without building them
- Team loses familiarity benefits of known PM tools

#### Risks

- **Risk:** Scope creep in PM feature development
  - **Mitigation:** Define MVP feature set strictly from requirements; defer advanced features
- **Risk:** Reinventing solved problems (drag-drop, notifications, etc.)
  - **Mitigation:** Use established Laravel packages (Livewire for UI, Spatie packages for permissions/activity)
- **Risk:** Staff resistance to unfamiliar tool
  - **Mitigation:** Involve staff in UI/UX design; prioritize usability

## Validation

- **Metric 1:** Project creation to first task assignment under 2 minutes
- **Metric 2:** Client can view project status within 1 second of staff update (real-time)
- **Metric 3:** Time entries automatically appear on invoices without manual sync
- **Metric 4:** Staff adoption rate >90% within 30 days of launch

## Pros and Cons of the Options

### Option A: Build Custom (Laravel)

**Pros:**
- Full control and customization
- Deep integration with existing systems
- No per-seat costs
- Data stays in single database

**Cons:**
- Development time and cost
- Maintenance burden
- Must build features that exist elsewhere

### Option B: Asana Integration

**Pros:**
- Mature, feature-rich platform
- Excellent API documentation
- Team may have existing familiarity

**Cons:**
- Per-user pricing ($10.99-24.99/user/month)
- Bidirectional sync complexity
- Clients need Asana accounts or limited guest access
- Time tracking requires additional integration (Harvest)

### Option C: Monday.com Integration

**Pros:**
- Highly customizable boards
- Built-in time tracking
- Visual workflow builder

**Cons:**
- Higher per-seat cost ($9-19/seat/month)
- API rate limits for sync operations
- Heavy UI may overwhelm simple use cases
- Limited offline capability

### Option D: Teamwork Integration

**Pros:**
- Agency-focused features (client access, time tracking, invoicing)
- White-label client portal option
- Built specifically for agencies

**Cons:**
- Per-user pricing ($5.99-18/user/month)
- Still requires sync layer for deep integration
- Less flexible than custom solution
- Vendor lock-in for agency workflow

### Option E: Laravel Package Approach

**Pros:**
- Faster development using existing packages
- Community-maintained code
- Best of both: customization + pre-built components

**Cons:**
- Package quality varies
- May require significant customization anyway
- Dependency management overhead

## Implementation Notes

- Use Livewire for real-time task updates without page refresh
- Implement Kanban board view with drag-drop (SortableJS or Livewire Sortable)
- Use Spatie Laravel-Permission for project-level roles
- Use Spatie Laravel-Activitylog for project activity tracking
- Create polymorphic `tasks` table supporting projects, milestones, and subtasks
- Implement WebSocket broadcasting for real-time client portal updates

## Links

- [REQ-PROJ-001](../01-requirements/req-proj-001.md) - Create and Manage Projects
- [REQ-PROJ-003](../01-requirements/req-proj-003.md) - Task Management
- [REQ-PROJ-005](../01-requirements/req-proj-005.md) - Time Tracking
- [REQ-PORT-002](../01-requirements/req-port-002.md) - Project Status Visibility
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
