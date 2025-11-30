# Release Process

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

This document defines the release process for the Agency Platform, ensuring consistent, reliable deployments.

### 1.1 Release Types

| Type | Version Bump | Frequency | Testing |
|------|--------------|-----------|---------|
| Major | X.0.0 | Quarterly | Full regression |
| Minor | 0.X.0 | Bi-weekly | Feature + regression |
| Patch | 0.0.X | As needed | Focused testing |
| Hotfix | 0.0.X | Emergency | Critical path only |

### 1.2 Version Format

Following [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0 - Initial release
1.1.0 - New feature (backward compatible)
1.1.1 - Bug fix
2.0.0 - Breaking change
```

---

## 2. Release Schedule

### 2.1 Regular Releases

| Day | Activity |
|-----|----------|
| Monday | Feature freeze (sprint end) |
| Tuesday | QA testing on staging |
| Wednesday | Bug fixes, release candidate |
| Thursday | Final QA, release preparation |
| Friday | Production release (morning) |

### 2.2 Release Windows

**Preferred:** Tuesday-Thursday, 10:00-14:00 UTC
**Avoid:** Fridays, weekends, holidays

### 2.3 Blackout Periods

No releases during:
- Month-end (billing cycles)
- Major client deliveries
- Holiday weekends
- Company events

---

## 3. Pre-Release Checklist

### 3.1 Code Readiness

- [ ] All planned features merged to main
- [ ] All tests passing in CI
- [ ] No critical bugs open
- [ ] Code review completed for all PRs
- [ ] Static analysis passing (PHPStan level 8)

### 3.2 Documentation

- [ ] Changelog updated
- [ ] API documentation current
- [ ] Release notes drafted
- [ ] Migration guide (if breaking changes)

### 3.3 Testing

- [ ] Feature testing complete
- [ ] Regression testing complete
- [ ] Performance testing (if applicable)
- [ ] Security review (if applicable)
- [ ] Staging deployment verified

### 3.4 Stakeholders

- [ ] Product owner approval
- [ ] Tech lead approval
- [ ] Support team briefed
- [ ] Customer communication prepared (major releases)

---

## 4. Release Procedure

### 4.1 Create Release Branch (Optional for Major)

```bash
# For major releases, create release branch
git checkout main
git pull origin main
git checkout -b release/v2.0.0
```

### 4.2 Update Version

```bash
# Update version in files
# composer.json, package.json, config/app.php
```

### 4.3 Generate Changelog

```bash
# Generate changelog from commits
git log v1.0.0..HEAD --oneline > CHANGELOG.md

# Or use conventional-changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

### 4.4 Create Git Tag

```bash
git checkout main
git pull origin main

git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Added time tracking (#45)
- Client portal dashboard (#52)

Fixes:
- Invoice PDF generation (#61)
- Login redirect loop (#63)

Breaking Changes:
- None"

git push origin v1.2.0
```

### 4.5 Create GitHub Release

```bash
gh release create v1.2.0 \
  --title "v1.2.0 - Time Tracking & Dashboard" \
  --notes-file release-notes.md
```

### 4.6 Deploy to Production

Follow [Deployment Runbook](../07-operations/runbook-deployment.md):

1. Enable maintenance mode
2. Deploy via Forge
3. Run migrations
4. Clear caches
5. Verify deployment
6. Disable maintenance mode

### 4.7 Post-Release Verification

- [ ] Application accessible
- [ ] Health check passing
- [ ] Critical features working
- [ ] No new errors in Flare
- [ ] Queue workers processing
- [ ] Scheduled tasks running

---

## 5. Changelog Format

### 5.1 CHANGELOG.md Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New feature description

### Changed
- Updated behavior

### Fixed
- Bug fix description

### Removed
- Deprecated feature removed

## [1.2.0] - 2025-11-29

### Added
- Time tracking with real-time timer (#45)
- Client portal dashboard widgets (#52)

### Fixed
- Invoice PDF generation fails for large invoices (#61)
- Login redirect loop on expired session (#63)

### Changed
- Improved project list loading performance

## [1.1.0] - 2025-11-15

...
```

### 5.2 Commit to Changelog Mapping

| Commit Prefix | Changelog Section |
|---------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `change:` | Changed |
| `remove:` | Removed |
| `deprecate:` | Deprecated |
| `security:` | Security |

---

## 6. Release Notes

### 6.1 Template

```markdown
# Release v1.2.0

**Release Date:** November 29, 2025

## Highlights

Brief summary of most important changes.

## New Features

### Time Tracking
Added real-time time tracking with...

### Client Dashboard
New dashboard with widgets for...

## Bug Fixes

- Fixed invoice PDF generation for large invoices (#61)
- Resolved login redirect loop (#63)

## Breaking Changes

None in this release.

## Upgrade Instructions

1. Run `composer update`
2. Run `php artisan migrate`
3. Clear caches: `php artisan optimize:clear`

## Known Issues

- Issue description and workaround

## Contributors

Thanks to everyone who contributed to this release!
```

---

## 7. Hotfix Process

### 7.1 When to Hotfix

- Critical bug affecting production
- Security vulnerability
- Data corruption risk
- Revenue-impacting issues

### 7.2 Hotfix Procedure

```bash
# 1. Create hotfix branch from main (or tag)
git checkout main
git checkout -b hotfix/v1.2.1

# 2. Make minimal fix
git add .
git commit -m "fix: critical payment webhook failure"

# 3. Test thoroughly

# 4. Merge to main
git checkout main
git merge hotfix/v1.2.1

# 5. Tag the release
git tag -a v1.2.1 -m "Hotfix: payment webhook"
git push origin main --tags

# 6. Deploy immediately
# Follow deployment runbook

# 7. Clean up
git branch -d hotfix/v1.2.1
```

---

## 8. Rollback Procedure

### 8.1 When to Rollback

- Critical functionality broken
- Data integrity issues
- Severe performance degradation
- Security vulnerability introduced

### 8.2 Rollback Steps

1. **Assess** - Confirm rollback is necessary
2. **Communicate** - Notify team and stakeholders
3. **Enable maintenance mode**
4. **Revert code** (Forge: select previous release)
5. **Rollback migrations** (if applicable)
6. **Clear caches**
7. **Verify functionality**
8. **Disable maintenance mode**
9. **Post-mortem** - Analyze what went wrong

See [Deployment Runbook](../07-operations/runbook-deployment.md) for details.

---

## 9. Communication

### 9.1 Internal Notifications

| Audience | Channel | Timing |
|----------|---------|--------|
| Engineering | Slack #engineering | 24h before |
| Product | Slack #product | 24h before |
| Support | Slack #support | 4h before |
| All hands | Email | After release |

### 9.2 External Notifications

For major releases or breaking changes:

| Audience | Channel | Timing |
|----------|---------|--------|
| Customers | Email | 1 week before |
| Status page | Status update | During release |
| Blog | Blog post | After release |

### 9.3 Status Page Updates

```
[Scheduled] v1.2.0 Release
We will be releasing version 1.2.0 on November 29, 2025 at 10:00 UTC.
Expected duration: 15 minutes.
The platform will remain accessible during the update.
```

---

## 10. Metrics & Success Criteria

### 10.1 Release Metrics

| Metric | Target |
|--------|--------|
| Deployment time | < 15 minutes |
| Rollback rate | < 5% |
| Post-release bugs (P1) | 0 |
| Post-release bugs (P2) | < 2 |
| Customer complaints | < 5 |

### 10.2 Release Success Criteria

A release is successful when:
- All planned features deployed
- No critical bugs reported within 24h
- Performance metrics unchanged
- Error rate unchanged
- No rollback required

---

## 11. Release Roles

### 11.1 Release Manager

- Coordinates release activities
- Ensures checklist completion
- Makes go/no-go decision
- Communicates status

### 11.2 On-Call Engineer

- Executes deployment
- Monitors post-release
- Handles immediate issues
- Initiates rollback if needed

### 11.3 QA Lead

- Approves test completion
- Verifies staging deployment
- Signs off on release readiness

---

## Links

- [Deployment Runbook](../07-operations/runbook-deployment.md)
- [Git Workflow](../04-development/git-workflow.md)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial release process |
