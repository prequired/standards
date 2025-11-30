# Release Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains release processes, versioning guidelines, and changelog templates.

## Documents

| Document | Description |
|----------|-------------|
| [release-process.md](./release-process.md) | Complete release workflow and procedures |

## Quick Reference

### Version Format

```
MAJOR.MINOR.PATCH
1.0.0 → 1.1.0 (feature) → 1.1.1 (fix) → 2.0.0 (breaking)
```

### Release Types

| Type | Timing | Example |
|------|--------|---------|
| Major | Quarterly | Breaking changes |
| Minor | Bi-weekly | New features |
| Patch | As needed | Bug fixes |
| Hotfix | Emergency | Critical fixes |

### Release Commands

```bash
# Tag release
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Create GitHub release
gh release create v1.2.0 --generate-notes
```

### Pre-Release Checklist

- [ ] Tests passing
- [ ] Code reviewed
- [ ] Changelog updated
- [ ] Stakeholders notified

### Release Schedule

| Day | Activity |
|-----|----------|
| Mon | Feature freeze |
| Tue | QA testing |
| Wed | Bug fixes |
| Thu | Final QA |
| Fri | Release (AM) |

### Release Windows

**Preferred:** Tue-Thu, 10:00-14:00 UTC
**Avoid:** Fridays, weekends, month-end

## Related Documentation

- [Deployment Runbook](../07-operations/runbook-deployment.md)
- [Git Workflow](../04-development/git-workflow.md)

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial release documentation |
