---
id: SOP-003
title: Documentation Lifecycle Management
version: 1.0.0
status: active
owner: Documentation Team
last_updated: 2025-11-29
---

# SOP-003: Documentation Lifecycle Management

## Purpose

Define the lifecycle stages, transitions, and governance for all documentation artifacts. This SOP ensures documents move through a controlled process from creation to retirement.

## Scope

This SOP applies to all documentation types:
- Requirements (REQ-*)
- Architecture Decision Records (ADR-*)
- Architecture Specifications
- SOPs and Governance Documents
- API Specifications
- Testing Documentation
- Operations Runbooks

---

## Document Lifecycle Stages

### Stage Definitions

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌────────────┐    ┌──────────┐
│  Draft  │───▶│  Review  │───▶│ Approved │───▶│   Active   │───▶│ Retired  │
└─────────┘    └──────────┘    └──────────┘    └────────────┘    └──────────┘
     │              │                                │
     │              ▼                                ▼
     │         ┌─────────┐                    ┌────────────┐
     └────────▶│Rejected │                    │ Superseded │
               └─────────┘                    └────────────┘
```

| Stage | Description | Allowed Actions |
|-------|-------------|-----------------|
| **Draft** | Initial creation, incomplete content | Edit, Submit for Review |
| **Review** | Under peer review | Comment, Approve, Reject |
| **Approved** | Reviewed and approved, pending activation | Activate, Revise |
| **Active** | Current, authoritative version | Reference, Revise, Retire |
| **Superseded** | Replaced by newer version | Reference (historical) |
| **Retired** | No longer valid or relevant | Archive access only |
| **Rejected** | Did not pass review | Revise to Draft, Abandon |

---

## Document Type Specific Lifecycles

### Requirements (REQ-*)

| Status Value | Stage | Meaning |
|--------------|-------|---------|
| `draft` | Draft | Initial requirement capture |
| `review` | Review | Stakeholder validation |
| `approved` | Approved/Active | Baselined requirement |
| `implemented` | Active | Requirement satisfied by code |
| `verified` | Active | Requirement tested and confirmed |
| `deprecated` | Superseded | Replaced by other requirement |
| `rejected` | Rejected | Not accepted for implementation |

**Approval Authority:** Product Owner, Technical Lead

**Criteria for Approval:**
- [ ] Clear, unambiguous description
- [ ] Measurable fit criterion
- [ ] Dependencies identified
- [ ] Acceptance criteria defined (min. 5)
- [ ] Priority assigned
- [ ] Stakeholder sign-off

### Architecture Decision Records (ADR-*)

| Status Value | Stage | Meaning |
|--------------|-------|---------|
| `proposed` | Draft/Review | Decision under consideration |
| `accepted` | Active | Decision is binding |
| `deprecated` | Superseded | Decision replaced by newer ADR |
| `superseded` | Superseded | Explicitly replaced (links to new ADR) |
| `rejected` | Rejected | Decision not adopted |

**Approval Authority:** Technical Lead, Architecture Review Board

**Criteria for Acceptance:**
- [ ] Problem statement clear
- [ ] At least 3 options considered
- [ ] Decision rationale documented
- [ ] Consequences (positive/negative) listed
- [ ] Implementation notes provided
- [ ] Validation metrics defined
- [ ] Peer review completed

### Architecture Specifications

| Status Value | Stage | Meaning |
|--------------|-------|---------|
| `draft` | Draft | Architecture in development |
| `review` | Review | Technical review in progress |
| `active` | Active | Current system architecture |
| `deprecated` | Retired | No longer represents system |

**Approval Authority:** Technical Lead, CTO

### Standard Operating Procedures (SOP-*)

| Status Value | Stage | Meaning |
|--------------|-------|---------|
| `draft` | Draft | SOP being written |
| `review` | Review | Stakeholder review |
| `active` | Active | Enforceable procedure |
| `suspended` | Superseded | Temporarily not enforced |
| `retired` | Retired | No longer applicable |

**Approval Authority:** Process Owner, Department Head

---

## Transition Procedures

### Draft → Review

**Trigger:** Author submits for review

**Process:**
1. Author completes self-review checklist (SOP-002)
2. Author creates pull request with `[REVIEW]` prefix
3. System assigns reviewers based on document type
4. Minimum 1 peer reviewer required
5. Review period: 3 business days (standard), 1 day (urgent)

**Artifacts:**
- Pull request created
- Reviewers assigned
- Review deadline set

### Review → Approved

**Trigger:** All reviewers approve

**Process:**
1. All required reviewers mark "Approved"
2. No blocking comments unresolved
3. Quality gates pass (automated checks)
4. Approval authority provides final sign-off
5. PR merged to main branch

**Artifacts:**
- Approval comments documented
- Merge commit with approval reference
- Status field updated in frontmatter

### Approved → Active

**Trigger:** Document becomes effective

**Process:**
1. For requirements: Added to release scope
2. For ADRs: Implementation begins
3. For SOPs: Effective date reached
4. Update status in frontmatter
5. Notify relevant stakeholders

**Artifacts:**
- Status updated to active/accepted/implemented
- Changelog entry added
- Stakeholder notification sent

### Active → Superseded/Retired

**Trigger:** Replacement document created OR document no longer relevant

**Process:**
1. Create superseding document (if applicable)
2. Update original with superseded_by reference
3. Update status to `superseded` or `retired`
4. Add retirement note with reason
5. Maintain document for historical reference

**Artifacts:**
- Superseding document reference added
- Status updated
- Retirement reason documented

---

## Version Control

### Versioning Scheme

Documents use semantic versioning: `MAJOR.MINOR.PATCH`

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking change to meaning/scope | MAJOR | 1.0.0 → 2.0.0 |
| New section or significant addition | MINOR | 1.0.0 → 1.1.0 |
| Typo fix, clarification | PATCH | 1.0.0 → 1.0.1 |

### Version History

All documents maintain a changelog section:

```markdown
## Change Log

| Date       | Version | Author  | Change Description           |
|------------|---------|---------|------------------------------|
| 2025-11-29 | 1.0.0   | J. Doe  | Initial approved version     |
| 2025-12-15 | 1.1.0   | A. Smith| Added section on X           |
| 2025-12-20 | 1.1.1   | J. Doe  | Fixed typo in section 3      |
```

---

## Roles and Responsibilities

### Document Author

- Create initial draft
- Complete self-review checklist
- Address review feedback
- Maintain document accuracy
- Initiate retirement when appropriate

### Peer Reviewer

- Review within assigned timeframe
- Verify quality gate criteria
- Provide constructive feedback
- Approve or request changes

### Approval Authority

- Final approval decision
- Ensure organizational alignment
- Resolve escalated disputes
- Authorize exceptions

### Document Owner

- Accountable for document accuracy
- Schedule periodic reviews
- Ensure updates when related systems change
- Manage document retirement

---

## Periodic Review Requirements

| Document Type | Review Frequency | Review Scope |
|---------------|------------------|--------------|
| Requirements | Per release | Validity, implementation status |
| ADRs | Quarterly | Continued relevance, accuracy |
| Architecture | Quarterly | Alignment with implementation |
| SOPs | Annually | Process effectiveness |
| API Specs | Per release | Accuracy with implementation |
| Runbooks | Semi-annually | Procedure accuracy |

### Review Checklist

- [ ] Content still accurate?
- [ ] Referenced documents still valid?
- [ ] External links working?
- [ ] Status reflects current state?
- [ ] Any updates needed based on changes?

---

## Exception Handling

### Emergency Updates

For critical corrections (security, compliance):

1. Make correction immediately
2. Document as `[EMERGENCY]` in commit
3. Notify stakeholders
4. Complete formal review within 5 days
5. Document exception in changelog

### Temporary Exceptions

For documents that cannot meet all quality gates:

1. Document exception reason
2. Get approval from document owner
3. Set remediation deadline (max 30 days)
4. Track in exception register
5. Review and close exception

---

## Metrics and Reporting

### Document Health Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Draft aging | < 14 days | Time in draft status |
| Review cycle time | < 5 days | Time from review to approved |
| Staleness | < 90 days | Time since last update |
| Orphan rate | 0% | Documents without valid links |
| Rejection rate | < 10% | Reviews resulting in rejection |

### Monthly Report

Generate monthly documentation health report:
- Documents by status
- Aging analysis
- Review cycle times
- Exception summary
- Action items

---

## Related Documents

- [SOP-000: Golden Thread](./sop-000-master.md) - Traceability standard
- [SOP-001: Git Standards](./sop-001-git-standards.md) - Version control
- [SOP-002: Quality Gates](./sop-002-quality-gates.md) - Review criteria

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial documentation lifecycle SOP |
