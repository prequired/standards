---
id: SOP-002
title: Documentation Quality Gates
version: 1.0.0
status: active
owner: Documentation Team
last_updated: 2025-11-29
---

# SOP-002: Documentation Quality Gates

## Purpose

Define quality gates that all documentation must pass before being approved and merged. These gates ensure consistency, completeness, and traceability across the documentation framework.

## Scope

This SOP applies to all documentation in the `docs/` directory:
- Requirements (01-requirements/)
- Architecture (02-architecture/)
- Architecture Decision Records (03-decisions/)
- Development Standards (04-development/)
- API Specifications (05-api/)
- Testing Documentation (06-testing/)
- Operations Runbooks (07-operations/)
- Security Policies (08-security/)
- Release Documentation (09-releases/)

---

## Quality Gates

### Gate 1: Completeness

All required sections must be filled with meaningful content.

**Requirements Documents:**
- [ ] YAML frontmatter complete (id, title, domain, status, priority, dates)
- [ ] Description section explains the requirement
- [ ] Rationale provides business justification
- [ ] Fit Criterion defines measurable success criteria
- [ ] Dependencies documented
- [ ] Acceptance Criteria listed (minimum 5)
- [ ] Satisfied By links to relevant ADR(s)

**ADR Documents:**
- [ ] YAML frontmatter complete (id, title, status, date, implements_requirement)
- [ ] Context and Problem Statement explains the need
- [ ] Decision Drivers listed
- [ ] At least 3 options considered
- [ ] Decision Outcome with justification
- [ ] Consequences documented (positive, negative, risks)
- [ ] Validation metrics defined
- [ ] Implementation notes provided
- [ ] Links section complete

**Architecture Documents:**
- [ ] All 12 arc42 sections addressed
- [ ] Diagrams use C4 model notation
- [ ] Quality attributes mapped to requirements
- [ ] Decisions reference ADRs
- [ ] Risks and mitigations documented

### Gate 2: Traceability

Documents must link to related artifacts following the Golden Thread.

**Forward Traceability:**
```
Requirement → ADR → Architecture → Implementation
```

**Backward Traceability:**
```
Implementation → Architecture → ADR → Requirement
```

**Checklist:**
- [ ] Requirements link to satisfying ADR(s)
- [ ] ADRs link to implementing requirements
- [ ] Architecture references both requirements and ADRs
- [ ] No orphan documents (all linked from README or parent)
- [ ] All internal links resolve to existing files

### Gate 3: Accuracy

Content must be technically correct and current.

**Checklist:**
- [ ] Technical details verified by subject matter expert
- [ ] Code examples compile/run successfully
- [ ] Configuration values are correct
- [ ] External links are valid
- [ ] Version numbers are current
- [ ] No contradictions with other documents

### Gate 4: Clarity

Documentation must be clear and unambiguous.

**Checklist:**
- [ ] Uses active voice
- [ ] Sentences are concise (< 25 words average)
- [ ] Technical jargon explained or linked to glossary
- [ ] Examples provided for complex concepts
- [ ] Diagrams supplement text where helpful
- [ ] No ambiguous pronouns ("it", "this", "that")

### Gate 5: Consistency

Documentation follows established templates and conventions.

**Checklist:**
- [ ] Follows appropriate template (Volere, MADR, arc42)
- [ ] Naming convention followed (REQ-DOMAIN-NNN, ADR-NNNN)
- [ ] Date format consistent (YYYY-MM-DD)
- [ ] Header hierarchy correct (# > ## > ### > ####)
- [ ] Code blocks use appropriate language tags
- [ ] Tables properly formatted

---

## Review Process

### 1. Self-Review

Author completes all quality gate checklists before requesting review.

### 2. Peer Review

At least one team member reviews against quality gates:
- Completeness check
- Traceability verification
- Technical accuracy review
- Clarity assessment
- Consistency check

### 3. Approval

Reviewer approves when all gates pass:
- [ ] All 5 quality gates satisfied
- [ ] No blocking comments unresolved
- [ ] Changes implement review feedback

### 4. Merge

Documentation merged to main branch:
- Squash merge for clean history
- Commit message follows convention
- CI checks pass

---

## Quality Metrics

### Documentation Health Score

Calculate monthly:

| Metric | Target | Weight |
|--------|--------|--------|
| Completeness | 100% of sections filled | 25% |
| Traceability | 100% of links valid | 25% |
| Freshness | Updated within 90 days | 20% |
| Review coverage | 100% peer reviewed | 15% |
| Consistency | 100% template compliance | 15% |

### Tracking

- Monthly documentation audit
- Broken link detection (automated)
- Staleness alerts (> 90 days without update)
- Coverage reports per domain

---

## Exception Handling

### Temporary Exceptions

For urgent documentation needs:
1. Create document with `status: draft`
2. Add note explaining incomplete sections
3. Create follow-up task to complete
4. Maximum 2-week exception period

### Permanent Exceptions

Requires documented justification:
1. Document reason for exception
2. Approval from documentation owner
3. Add exception note to document
4. Review quarterly

---

## Tools

### Validation

```bash
# Check for broken internal links
grep -r "\](\.\./" docs/ | grep -v "\.md)"

# Find incomplete sections
grep -r "TBD\|TODO\|FIXME" docs/

# Verify frontmatter
for f in docs/**/*.md; do head -20 "$f" | grep -q "^---" || echo "Missing frontmatter: $f"; done
```

### Templates

- [Volere Template](../templates/req-volere.md) - Requirements
- [MADR Template](../templates/adr-madr.md) - ADRs
- [arc42 Template](../templates/arch-arc42.md) - Architecture

---

## Related Documents

- [SOP-000: Golden Thread](./sop-000-master.md) - Traceability standard
- [SOP-001: Git Standards](./sop-001-git-standards.md) - Version control
- [Development Standards](../04-development/dev-standards.md) - Code documentation

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial quality gates SOP |
