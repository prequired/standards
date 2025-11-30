# Testing Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains testing strategy, test plans, and quality assurance documentation.

## Documents

| Document | Description |
|----------|-------------|
| [testing-strategy.md](./testing-strategy.md) | Comprehensive testing approach, examples, and coverage requirements |

## Quick Reference

### Running Tests

```bash
# All tests
./vendor/bin/pest

# With coverage
./vendor/bin/pest --coverage --min=80

# Parallel execution
./vendor/bin/pest --parallel

# Specific file
./vendor/bin/pest tests/Feature/ProjectsApiTest.php

# By filter
./vendor/bin/pest --filter="creates project"
```

### Test Pyramid

```
     E2E (5%)      - Critical user journeys
   Integration (25%) - API, database
  Unit Tests (70%)  - Services, models
```

### Coverage Targets

| Area | Minimum |
|------|---------|
| Overall | 80% |
| Critical paths | 95% |
| New code | 90% |

### Test Types

| Type | Database | Browser | Speed |
|------|----------|---------|-------|
| Unit | No | No | Fast |
| Integration | Yes | No | Medium |
| Feature | Yes | No | Medium |
| E2E | Yes | Yes | Slow |

## Critical Paths (95%+ Required)

- Authentication/authorization
- Payment processing
- Invoice generation
- Time calculations
- Status transitions

## Related Documentation

- [Development Standards](../04-development/dev-standards.md)
- [ADR-0020: Performance](../03-decisions/adr-0020-performance-optimization.md)

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial testing documentation |
