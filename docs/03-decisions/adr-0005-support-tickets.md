---
id: "ADR-0005"
title: "Support Ticket System Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-PORT-007"
decision_makers: "Platform Team"
consulted: "Support Team, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0005: Support Ticket System Selection

## Context and Problem Statement

[REQ-PORT-007](../01-requirements/req-port-007.md) requires clients to create support tickets from the portal for technical issues, questions, and service requests. Tickets need status tracking, priority assignment, and staff assignment capabilities.

The support system must integrate with the client portal and provide visibility into ticket status while enabling efficient staff workflows.

## Decision Drivers

- **Integration:** Tickets linked to client accounts and projects
- **Simplicity:** Basic ticketing, not enterprise service desk
- **Portal Access:** Clients manage tickets from their portal
- **Workflow:** Assignment, status tracking, priority management
- **History:** Full ticket history for client context
- **Cost:** Minimize per-agent licensing

## Considered Options

1. **Option A:** Build custom ticketing in Laravel
2. **Option B:** Integrate Zendesk
3. **Option C:** Integrate Freshdesk
4. **Option D:** Integrate Help Scout
5. **Option E:** Use open-source (osTicket, Zammad)

## Decision Outcome

**Chosen Option:** Option A - Build custom ticketing in Laravel

**Justification:** Support ticketing for an agency is relatively straightforward:
- Client submits ticket (category, priority, description)
- Staff receives notification, assigns, responds
- Client gets updates, can reply
- Ticket closes when resolved

This is simpler than full ITSM and integrates naturally with the client portal. Third-party tools would:
- Require separate client authentication
- Add per-agent monthly costs
- Create data silos (tickets separate from projects)
- Offer features beyond agency needs

### Consequences

#### Positive

- Unified client experience (portal login for everything)
- Tickets linked to projects, invoices, and client history
- No per-agent costs
- Full control over workflow and automation
- Ticket data available for analytics and reporting

#### Negative

- Must build ticket UI and workflow
- Must implement email parsing for ticket replies
- No built-in SLA management or automation rules
- Limited compared to dedicated help desk features

#### Risks

- **Risk:** Email reply parsing complexity
  - **Mitigation:** Use simple reply-by-email with unique ticket addresses; or portal-only replies initially
- **Risk:** Missing help desk features (macros, automations)
  - **Mitigation:** Start simple; add features based on actual support volume
- **Risk:** Scale limitations with high ticket volume
  - **Mitigation:** Agency ticket volume typically manageable; migrate if >1000/month

## Validation

- **Metric 1:** Ticket creation under 2 minutes from portal
- **Metric 2:** Staff notification within 1 minute of new ticket
- **Metric 3:** First response time trackable and reportable
- **Metric 4:** 95% of tickets resolved without escalation

## Pros and Cons of the Options

### Option A: Build Custom

**Pros:**
- Portal integration (single login)
- No per-agent costs
- Linked to client/project data
- Simple to customize

**Cons:**
- Development time
- Basic features only initially
- Must build reporting

### Option B: Zendesk

**Pros:**
- Industry leader
- Extensive features and integrations
- Professional interface

**Cons:**
- Expensive ($55-115/agent/month)
- Overkill for small agency
- Separate system from portal
- Complex setup

### Option C: Freshdesk

**Pros:**
- Affordable ($15-79/agent/month)
- Good feature set
- Free tier available (limited)

**Cons:**
- Still separate from portal
- Per-agent pricing grows with team
- Widget integration less seamless

### Option D: Help Scout

**Pros:**
- Clean, simple interface
- Email-centric approach
- Good for small teams ($20/user/month)

**Cons:**
- Per-user pricing
- Less portal integration
- Limited customization

### Option E: Open Source (osTicket)

**Pros:**
- Free
- Self-hosted (data control)
- Decent feature set

**Cons:**
- Separate installation/maintenance
- Dated UI/UX
- Integration requires custom development
- PHP but not Laravel

## Implementation Notes

- Create `tickets` table: client_id, project_id (optional), category, priority, status, subject
- Create `ticket_replies` table: ticket_id, user_id, body, is_internal
- Implement status workflow: open → in_progress → waiting → resolved → closed
- Use notifications for new tickets and replies
- Create portal views for client ticket management
- Create staff views with assignment, filtering, bulk actions
- Consider email notifications with reply-to tracking (later phase)
- Add canned responses/templates for common issues

## Links

- [REQ-PORT-007](../01-requirements/req-port-007.md) - Support Ticket Creation
- [REQ-COMM-001](../01-requirements/req-comm-001.md) - In-App Notifications
- [REQ-COMM-002](../01-requirements/req-comm-002.md) - Email Notifications
- [REQ-PORT-001](../01-requirements/req-port-001.md) - Client Dashboard
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
