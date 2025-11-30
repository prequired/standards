---
id: "ADR-0007"
title: "Email Marketing Platform Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-MKTG-005, REQ-MKTG-006"
decision_makers: "Platform Team"
consulted: "Marketing Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0007: Email Marketing Platform Selection

## Context and Problem Statement

[REQ-MKTG-005](../01-requirements/req-mktg-005.md) requires lead capture forms with CRM integration. [REQ-MKTG-006](../01-requirements/req-mktg-006.md) requires newsletter signup with subscription management and double opt-in.

The marketing site needs email capture capabilities for lead nurturing, newsletters, and campaign management. This includes forms, list management, automated sequences, and campaign analytics.

## Decision Drivers

- **Lead Capture:** Forms on marketing site that feed into email lists
- **Automation:** Welcome sequences, drip campaigns
- **Analytics:** Open rates, click rates, campaign performance
- **Compliance:** GDPR, CAN-SPAM, double opt-in support
- **Integration:** Connect with CRM (if applicable)
- **Cost:** Pricing based on subscriber count
- **Preference:** Buy over build for marketing automation

## Considered Options

1. **Option A:** Build custom email marketing (Laravel + queue)
2. **Option B:** Mailchimp
3. **Option C:** ConvertKit
4. **Option D:** Mailerlite
5. **Option E:** Resend (API-based email)

## Decision Outcome

**Chosen Option:** Option C - ConvertKit

**Justification:** Given the preference to buy over build for non-core functionality, ConvertKit provides:
- Purpose-built for creators/agencies (not enterprise marketing)
- Visual automation builder
- Landing pages and forms included
- Subscriber tagging and segmentation
- Excellent deliverability
- Fair pricing (free up to 1,000 subscribers, then $9-25/month)

ConvertKit handles the complexity of email marketing (deliverability, unsubscribes, automations) that would be expensive to build and maintain.

### Consequences

#### Positive

- Professional email marketing without development effort
- Built-in deliverability optimization (reputation, SPF/DKIM)
- Visual automation builder for sequences
- GDPR/CAN-SPAM compliant out of box
- Form builder with embed codes
- Landing page builder for campaigns

#### Negative

- Subscriber data lives in ConvertKit (not local database)
- Monthly cost scales with subscriber count
- API integration needed for deep platform integration
- Less control over email templates (their builder)

#### Risks

- **Risk:** Subscriber list out of sync with platform contacts
  - **Mitigation:** Use ConvertKit API to sync key events; accept some separation
- **Risk:** Cost growth with subscriber count
  - **Mitigation:** List hygiene practices; ConvertKit pricing still reasonable
- **Risk:** Vendor dependency for marketing communications
  - **Mitigation:** Export capability exists; migration possible if needed

## Validation

- **Metric 1:** Form submission to welcome email under 5 minutes
- **Metric 2:** Email deliverability rate >95%
- **Metric 3:** Newsletter open rate >25% (industry benchmark)
- **Metric 4:** Unsubscribe process completes in under 2 clicks

## Pros and Cons of the Options

### Option A: Build Custom

**Pros:**
- Full control
- Data stays local
- No monthly fees

**Cons:**
- Deliverability is extremely complex
- Must manage IP reputation, bounce handling
- No visual automation builder
- Significant development and maintenance

### Option B: Mailchimp

**Pros:**
- Industry leader
- Extensive features
- Large template library

**Cons:**
- Complex pricing tiers
- Feature bloat for simple needs
- UI has become cluttered
- Expensive at scale

### Option C: ConvertKit

**Pros:**
- Simple, focused interface
- Visual automations
- Good deliverability
- Creator/agency focused
- Fair pricing

**Cons:**
- Fewer enterprise features
- Limited A/B testing
- Smaller template library

### Option D: Mailerlite

**Pros:**
- Very affordable
- Clean interface
- Good feature set
- Landing page builder

**Cons:**
- Less powerful automations
- Smaller company (support concerns)
- Limited integrations

### Option E: Resend

**Pros:**
- Developer-focused API
- Modern infrastructure
- React email templates
- Pay-per-email pricing

**Cons:**
- Transactional focused (see ADR-0008)
- No visual automation builder
- Must build campaign management
- New platform (less proven)

## Implementation Notes

- Create ConvertKit account and configure sending domain
- Set up SPF, DKIM, DMARC records for deliverability
- Create forms for: newsletter signup, lead magnets, contact
- Embed ConvertKit forms via JavaScript or API
- Create welcome automation sequence
- Tag subscribers by source (which form, page, campaign)
- Set up ConvertKit webhook to notify platform of new subscribers
- Create monthly newsletter template

## Links

- [REQ-MKTG-005](../01-requirements/req-mktg-005.md) - Lead Capture Forms
- [REQ-MKTG-006](../01-requirements/req-mktg-006.md) - Newsletter Signup
- [REQ-INTG-009](../01-requirements/req-intg-009.md) - CRM Integration
- [ConvertKit API Documentation](https://developers.convertkit.com)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
