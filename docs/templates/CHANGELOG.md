# Changelog

All notable changes to the Agency Platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security-related changes

---

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release of Agency Platform
- Project management with Kanban boards
- Time tracking with timers and manual entry
- Invoice generation and Stripe payments
- Client portal for project visibility
- Admin panel powered by Filament
- Multi-role authentication system

### Security
- Laravel Sanctum API authentication
- Role-based access control
- Audit logging for sensitive operations

---

## Release Template

Copy and paste for new releases:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- [Feature description] (#issue-number)

### Changed
- [Change description] (#issue-number)

### Deprecated
- [Deprecation notice]

### Removed
- [Removed feature] (#issue-number)

### Fixed
- [Bug fix description] (#issue-number)

### Security
- [Security fix description] (#issue-number)
```

---

## Guidelines

### Version Numbers

- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.X.0): New features, backwards compatible
- **PATCH** (0.0.X): Bug fixes, backwards compatible

### What to Include

**DO include:**
- User-facing changes
- API changes
- Security fixes
- Breaking changes
- Deprecations

**DON'T include:**
- Internal refactoring (unless it affects behavior)
- Documentation updates (unless significant)
- Build/CI changes
- Dependency updates (unless security-related)

### Linking

- Link to GitHub issues/PRs where applicable: `(#123)`
- Link to related ADRs for significant changes
- Link to migration guides for breaking changes

---

## Migration Guides

For breaking changes, create a migration guide:

```markdown
## Migrating from 1.x to 2.0

### Breaking Changes

1. **API endpoint renamed**
   - Before: `GET /api/v1/projects/{id}/tasks`
   - After: `GET /api/v2/projects/{id}/tasks`
   - Migration: Update all API clients to use new endpoint

2. **Database schema change**
   - Run migration: `php artisan migrate`
   - Backfill command: `php artisan projects:backfill-status`
```

---

[Unreleased]: https://github.com/agency/platform/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/agency/platform/releases/tag/v1.0.0
