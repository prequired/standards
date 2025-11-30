---
id: "ADR-0004"
title: "Messaging/Chat Solution Selection"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-COMM-004"
decision_makers: "Platform Team"
consulted: "Development Team, Support Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0004: Messaging/Chat Solution Selection

## Context and Problem Statement

[REQ-COMM-004](../01-requirements/req-comm-004.md) requires direct messaging between staff and clients for project communication. Messages should be contextual (linked to projects), support file attachments, and provide notification capabilities.

The platform needs a communication channel that keeps client conversations organized, searchable, and integrated with project workflows.

## Decision Drivers

- **Context:** Messages should be linkable to projects and tasks
- **Persistence:** Full message history must be searchable
- **Notifications:** Real-time notifications with email fallback
- **Files:** Support file/image sharing in conversations
- **Simplicity:** Not a full chat platform; focused messaging
- **Privacy:** Client conversations isolated from other clients

## Considered Options

1. **Option A:** Build custom messaging in Laravel
2. **Option B:** Integrate Intercom
3. **Option C:** Integrate Crisp
4. **Option D:** Use Laravel Echo + Pusher for real-time
5. **Option E:** Integrate Twilio Conversations API

## Decision Outcome

**Chosen Option:** Option A - Build custom messaging with Laravel Echo + Pusher

**Justification:** The messaging requirements are relatively simple (1:1 and project-based threads, not full chat rooms). Building custom allows:
- Direct association with projects, tasks, and invoices
- No per-seat or per-conversation costs
- Full control over notification logic
- Integration with existing permission system
- Message data available for analytics

Laravel Echo with Pusher (or Soketi for self-hosted) provides real-time capabilities without building WebSocket infrastructure.

### Consequences

#### Positive

- Messages stored in same database as projects (easy querying)
- No third-party widget styling conflicts
- Full control over notification timing and channels
- Can implement @mentions, reactions, threading later
- No ongoing SaaS costs (Pusher free tier: 200k messages/day)

#### Negative

- Must build UI for message threads
- Must implement file upload handling
- Must build notification logic (in-app + email)
- No built-in typing indicators, read receipts (unless built)

#### Risks

- **Risk:** Real-time scaling issues at high volume
  - **Mitigation:** Pusher handles scaling; can migrate to Soketi if costs grow
- **Risk:** UI/UX quality compared to polished chat products
  - **Mitigation:** Use proven UI patterns; invest in frontend polish
- **Risk:** Feature creep toward full chat platform
  - **Mitigation:** Scope to project messaging only; defer Slack-like features

## Validation

- **Metric 1:** Message delivered to recipient in under 2 seconds (real-time)
- **Metric 2:** Email notification sent within 5 minutes if recipient offline
- **Metric 3:** Message search returns results in under 1 second
- **Metric 4:** File attachments upload and display in under 5 seconds

## Pros and Cons of the Options

### Option A: Custom + Laravel Echo

**Pros:**
- Full integration with existing data
- No per-message/seat costs
- Complete customization
- Real-time via Pusher/Soketi

**Cons:**
- Development time required
- Must build UI from scratch
- No advanced features (video, screen share)

### Option B: Intercom

**Pros:**
- Polished UI
- Built-in help desk features
- User tracking and analytics
- Mobile SDKs

**Cons:**
- Expensive ($74+/month, per seat pricing)
- Widget-based (less integrated)
- Designed for support, not project messaging
- Data lives in Intercom

### Option C: Crisp

**Pros:**
- More affordable ($25-95/month)
- Live chat + helpdesk
- Chatbot capabilities

**Cons:**
- Still widget-based
- Less project-context integration
- Another system to manage

### Option D: Echo + Pusher (Real-time Only)

**Pros:**
- Proven real-time infrastructure
- Laravel-native integration
- Free tier available
- Easy to implement

**Cons:**
- Still need to build messaging logic
- Pusher costs can grow ($49+/month at scale)

### Option E: Twilio Conversations

**Pros:**
- Multi-channel (SMS, WhatsApp, chat)
- Robust API
- Enterprise reliability

**Cons:**
- Per-message pricing ($0.05/message)
- Overkill for simple messaging
- Complex API for simple use case

## Implementation Notes

- Create `conversations` table (polymorphic: project, invoice, general)
- Create `messages` table with conversation_id, user_id, body, attachments
- Use Laravel Echo for browser real-time updates
- Configure Pusher channels per conversation (private-conversation.{id})
- Implement message notifications via database + email (queued)
- Use Livewire for message composer and thread display
- Store file attachments via S3 (REQ-INTG-003)
- Add full-text search index on messages table

## Links

- [REQ-COMM-004](../01-requirements/req-comm-004.md) - Direct Messaging
- [REQ-COMM-001](../01-requirements/req-comm-001.md) - In-App Notifications
- [REQ-COMM-002](../01-requirements/req-comm-002.md) - Email Notifications
- [REQ-INTG-003](../01-requirements/req-intg-003.md) - Cloud Storage (S3)
- [Laravel Echo Documentation](https://laravel.com/docs/broadcasting)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
