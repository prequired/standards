---
id: "ADR-0009"
title: "Proposal/Quote Generation Solution Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-BILL-009"
decision_makers: "Platform Team"
consulted: "Sales Team, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0009: Proposal/Quote Generation Solution Selection

## Context and Problem Statement

[REQ-BILL-009](../01-requirements/req-bill-009.md) requires the ability to create and send proposals/quotes to potential clients with line items, terms, and acceptance workflow. Proposals should convert to projects and invoices upon acceptance.

The sales process needs professional proposal generation that integrates with project creation and client onboarding.

## Decision Drivers

- **Professionalism:** Branded, professional-looking proposals
- **Conversion:** Easy client acceptance (e-signature or click-to-accept)
- **Integration:** Accepted proposals should create projects automatically
- **Templates:** Reusable templates for common service offerings
- **Tracking:** Know when proposals are viewed and accepted
- **Cost:** Balance features vs subscription costs

## Considered Options

1. **Option A:** Build custom proposal system in Laravel
2. **Option B:** Integrate PandaDoc
3. **Option C:** Integrate Proposify
4. **Option D:** Integrate Better Proposals
5. **Option E:** Use PDF generation with e-signature (DocuSign/HelloSign)

## Decision Outcome

**Chosen Option:** Option C - Proposify

**Justification:** Given the preference to buy over build for sales/marketing tools, Proposify offers:
- Purpose-built for service businesses and agencies
- Professional proposal templates
- E-signature built-in
- Proposal analytics (views, time spent)
- Content library for reusable sections
- Integrations available (Stripe, CRM)
- Reasonable pricing ($49/user/month)

Building custom would require significant effort for e-signatures, PDF generation, and tracking - complexity better handled by a specialized tool.

### Consequences

#### Positive

- Professional proposals without development effort
- E-signature legally binding and built-in
- Analytics show client engagement
- Template library speeds creation
- Reduces sales cycle friction
- Mobile-optimized for client viewing

#### Negative

- Per-user monthly cost
- Proposal data lives in Proposify
- Manual or webhook-based project creation on acceptance
- Another tool for sales team to learn
- Limited customization vs custom build

#### Risks

- **Risk:** Disconnect between Proposify and platform data
  - **Mitigation:** Use Proposify webhooks to trigger project creation on acceptance
- **Risk:** Cost scales with sales team size
  - **Mitigation:** Limit seats to active proposal creators; viewers don't need seats
- **Risk:** Proposal style doesn't match brand perfectly
  - **Mitigation:** Proposify allows CSS customization; templates are flexible

## Validation

- **Metric 1:** Proposal creation time under 30 minutes
- **Metric 2:** Client signature completion rate >80%
- **Metric 3:** Proposal to project conversion automated (no manual steps)
- **Metric 4:** Average proposal view-to-sign time under 48 hours

## Pros and Cons of the Options

### Option A: Build Custom

**Pros:**
- Full integration with projects/invoices
- No per-user fees
- Exactly matches needs

**Cons:**
- E-signature compliance is complex
- PDF generation effort
- Must build analytics/tracking
- Significant development time

### Option B: PandaDoc

**Pros:**
- Feature-rich
- Good integrations
- Document automation

**Cons:**
- Expensive ($35-65/user/month)
- Complex for simple proposals
- Overkill for agency needs

### Option C: Proposify

**Pros:**
- Agency-focused
- Clean interface
- Good templates
- E-signature included
- Proposal analytics

**Cons:**
- Per-user cost ($49/user)
- Data in external system
- API integration needed

### Option D: Better Proposals

**Pros:**
- Similar to Proposify
- Clean designs
- Good pricing ($19-49/user)

**Cons:**
- Fewer integrations
- Smaller company
- Less feature-rich

### Option E: PDF + DocuSign

**Pros:**
- Industry-standard e-signature
- Works with any PDF

**Cons:**
- Two systems (PDF gen + signing)
- No proposal analytics
- More manual workflow
- DocuSign expensive ($10-40/envelope)

## Implementation Notes

- Create Proposify account with team seats as needed
- Set up brand kit (colors, fonts, logo)
- Create templates for common proposal types (web, design, retainer)
- Build content library sections (about us, process, terms)
- Configure webhook for "proposal accepted" event
- Create Laravel job to process webhook:
  - Create client account (if new)
  - Create project from proposal line items
  - Send welcome email
- Link accepted proposals to projects for reference
- Set up Stripe integration in Proposify for deposits

## Links

- [REQ-BILL-009](../01-requirements/req-bill-009.md) - Proposal/Quote Generation
- [REQ-PROJ-001](../01-requirements/req-proj-001.md) - Create and Manage Projects
- [REQ-USER-004](../01-requirements/req-user-004.md) - Client Company Accounts
- [REQ-BILL-001](../01-requirements/req-bill-001.md) - Invoice Generation
- [Proposify API Documentation](https://developers.proposify.com)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
