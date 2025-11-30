# Development Documentation

**Last Updated:** 2025-11-30

---

## Overview

This directory contains development standards, workflows, and guidelines for the Agency Platform.

## Documents

### Core Standards

| Document | Description | Audience |
|----------|-------------|----------|
| [dev-standards.md](./dev-standards.md) | PHP/Laravel coding conventions | All developers |
| [git-workflow.md](./git-workflow.md) | Git branching and commit guidelines | All developers |
| [code-review.md](./code-review.md) | PR process and review guidelines | All developers |
| [setup-guide.md](./setup-guide.md) | Local development environment setup | New developers |
| [configuration-management.md](./configuration-management.md) | Environment and secrets management | All developers |

### Framework-Specific Guides

| Document | Description | Audience |
|----------|-------------|----------|
| [livewire-conventions.md](./livewire-conventions.md) | Livewire 3 component patterns | Frontend developers |
| [filament-conventions.md](./filament-conventions.md) | Filament 3 admin panel guide | Admin developers |
| [statamic-setup.md](./statamic-setup.md) | Statamic 5 CMS integration | CMS developers |

### Architecture & Patterns

| Document | Description | Audience |
|----------|-------------|----------|
| [migration-guide.md](./migration-guide.md) | Database migrations & seeding | All developers |
| [exception-handling.md](./exception-handling.md) | Error handling hierarchy | All developers |
| [queue-jobs-guide.md](./queue-jobs-guide.md) | Background jobs & queues | Backend developers |
| [service-providers.md](./service-providers.md) | Dependency injection & container | Senior developers |
| [auth-guide.md](./auth-guide.md) | Authentication & authorization | All developers |

## Quick Reference

### Code Style

```bash
# Check code style
./vendor/bin/pint --test

# Fix code style
./vendor/bin/pint

# Run static analysis
./vendor/bin/phpstan analyse

# Run tests
./vendor/bin/pest
```

### Git Workflow

```bash
# Start new feature
git checkout main && git pull
git checkout -b feature/my-feature

# Commit with conventional format
git commit -m "feat(scope): description"

# Create PR
gh pr create --title "feat: my feature"
```

### Commit Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Maintenance |

### PR Checklist

- [ ] Self-reviewed the diff
- [ ] Tests pass locally
- [ ] Follows coding standards
- [ ] Documentation updated
- [ ] PR is < 400 lines

## Technology Stack

Based on [Architecture Decisions](../03-decisions/README.md):

| Layer | Technology |
|-------|------------|
| Framework | Laravel 11 |
| Frontend | Livewire 3 |
| Admin | Filament 3 |
| Database | MySQL 8 |
| Cache | Redis |
| Testing | Pest |

## Quality Gates

All PRs must pass:

| Check | Tool | Required |
|-------|------|----------|
| Tests | Pest | 80% coverage |
| Static Analysis | PHPStan | Level 8 |
| Code Style | Pint | Laravel preset |
| Security | Dependabot | No critical |

## IDE Setup

### VS Code Extensions

- PHP Intelephense
- Laravel Blade Snippets
- Laravel Extra Intellisense
- PHP DocBlocker
- EditorConfig

### PHPStorm Plugins

- Laravel Idea
- PHP Annotations
- Pest Support

## Environment Setup

```bash
# Clone repository
git clone git@github.com:org/agency-platform.git
cd agency-platform

# Install dependencies
composer install
npm install

# Configure environment
cp .env.example .env
php artisan key:generate

# Setup database
php artisan migrate --seed

# Start development
php artisan serve
npm run dev
```

## Related Documentation

- [Architecture](../02-architecture/README.md) - System architecture
- [ADRs](../03-decisions/README.md) - Architectural decisions
- [API](../05-api/README.md) - API specifications
- [Testing](../06-testing/README.md) - Testing strategy

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-30 | Added 9 new framework and architecture guides |
| 2025-11-29 | Initial development documentation |
