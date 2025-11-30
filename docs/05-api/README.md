# API Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains API specifications and documentation for the Agency Platform REST API.

## Documents

| Document | Description |
|----------|-------------|
| [api-specification.md](./api-specification.md) | Complete API reference with endpoints, authentication, and examples |
| [openapi.yaml](./openapi.yaml) | OpenAPI 3.1 specification for code generation and validation |
| [postman-collection.json](./postman-collection.json) | Postman collection for API testing and exploration |

## Quick Reference

### Base URL

```
Production: https://api.agency-platform.com/v1
Staging:    https://api-staging.agency-platform.com/v1
```

### Authentication

```bash
# Get token
curl -X POST /v1/auth/token \
  -d '{"email":"user@example.com","password":"secret","device_name":"cli"}'

# Use token
curl /v1/projects \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Core Endpoints

| Resource | Endpoints |
|----------|-----------|
| Projects | `GET/POST /v1/projects`, `GET/PUT/DELETE /v1/projects/{id}` |
| Clients | `GET/POST /v1/clients`, `GET/PUT/DELETE /v1/clients/{id}` |
| Tasks | `GET/POST /v1/tasks`, `GET/PUT/DELETE /v1/tasks/{id}` |
| Time Entries | `GET/POST /v1/time-entries`, `GET/PUT/DELETE /v1/time-entries/{id}` |
| Invoices | `GET/POST /v1/invoices`, `GET/PUT/DELETE /v1/invoices/{id}` |

### Response Format

```json
{
    "data": { ... },
    "meta": { "current_page": 1, "total": 42 },
    "links": { "next": "/v1/projects?page=2" }
}
```

### Error Format

```json
{
    "error": {
        "code": "validation_error",
        "message": "The given data was invalid.",
        "details": [...]
    }
}
```

## Rate Limits

| Tier | Requests/Minute |
|------|-----------------|
| Standard | 60 |
| Premium | 300 |

## Webhooks

Available events:
- `project.created`, `project.updated`, `project.completed`
- `invoice.sent`, `invoice.paid`, `invoice.overdue`
- `task.completed`

## Related Documentation

- [ADR-0012: Security](../03-decisions/adr-0012-security-data-protection.md) - Authentication decisions
- [Development Standards](../04-development/dev-standards.md) - API development guidelines
- [Architecture](../02-architecture/arch-agency-platform.md) - System context

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial API documentation |
