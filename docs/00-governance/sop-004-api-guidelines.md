---
id: SOP-004
title: API Design and Governance Standards
version: 1.0.0
status: active
owner: API Guild
last_updated: 2025-11-29
---

# SOP-004: API Design and Governance Standards

## Purpose

Enforce the "API First" principle as defined by Zalando RESTful API Guidelines Rule #100. The API specification is the source of truth; implementation code is a derivative artifact.

## Scope

Applies to all HTTP-based APIs (REST, GraphQL, gRPC-Gateway) exposed to clients, internal services, or third parties.

## Zalando Rule #100: API First

**Definition:** API specifications (OpenAPI 3.x) must be authored, reviewed, and approved before any implementation work begins.

**Rationale:**
- Enables parallel development (frontend/backend teams work from spec).
- Ensures contract stability (breaking changes caught during design).
- Facilitates automated testing (contract testing via Prism/Dredd).

## Mandatory Workflow

### 1. Design Phase

1. **Create ADR:** Document the decision to create/modify an API endpoint.
   - **Example:** `ADR-0042: Add User Profile Retrieval Endpoint`
   - **Must Reference:** Requirement ID (e.g., `REQ-USER-105`)

2. **Author OpenAPI Spec:** Write the contract in `docs/05-api/{service-name}/openapi.yaml`.
   - **Schema:** OpenAPI 3.1.x
   - **Validation:** Must pass `spectral lint openapi.yaml` (zero errors)
   - **Documentation:** Include `description`, `examples`, and error responses (4xx/5xx)

3. **Link to Architecture:** Reference the OpenAPI spec in the relevant arc42 document (Section 8: Cross-Cutting Concepts or Section 9: Architecture Decisions).

### 2. Review Phase

All API changes require approval from the API Guild:

- **Breaking Changes:** Require major version increment and deprecation notice (minimum 6 months).
- **Non-Breaking Changes:** Require minor version increment.
- **Review Checklist:**
  - [ ] Adheres to REST naming conventions (plural nouns, kebab-case).
  - [ ] Uses standard HTTP methods correctly (GET/POST/PUT/PATCH/DELETE).
  - [ ] Defines pagination for collections (`limit`, `offset`, `cursor`).
  - [ ] Includes rate-limiting headers (`X-RateLimit-*`).
  - [ ] Documents authentication requirements (Bearer token, API key).
  - [ ] Provides OpenAPI `examples` for all request/response payloads.

### 3. Implementation Phase

**Constraint:** Code generation is preferred over manual implementation.

- **Server Stubs:** Generate from OpenAPI using `openapi-generator-cli` or Laravel-specific tooling.
- **Client SDKs:** Auto-generate clients for consumers (TypeScript, PHP, Python).
- **Testing:** Contract tests must validate implementation against `openapi.yaml` (e.g., via Spectral or Postman).

### 4. Publication Phase

Approved OpenAPI specs are published to:

1. **Internal Developer Portal:** Rendered via Redoc or Swagger UI.
2. **Git Repository:** Stored in `docs/05-api/{service-name}/openapi.yaml`.
3. **API Gateway:** Automatically synced for request validation and rate limiting.

## API Specification Structure

### File Naming Convention

```
docs/05-api/{service-name}/openapi.yaml
```

**Example:**
```
docs/05-api/user-service/openapi.yaml
docs/05-api/payment-gateway/openapi.yaml
```

### Minimal Valid OpenAPI Example

```yaml
openapi: 3.1.0
info:
  title: User Service API
  version: 1.0.0
  description: |
    Manages user profiles and authentication.
    **Implements:** [ADR-0008](../../03-decisions/adr-0008.md)
  contact:
    name: API Guild
    email: api-guild@example.com

servers:
  - url: https://api.example.com/v1
    description: Production

paths:
  /users/{userId}:
    get:
      summary: Retrieve user profile
      operationId: getUserProfile
      parameters:
        - name: userId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: User profile
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserProfile'
              examples:
                active-user:
                  value:
                    id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
                    email: "user@example.com"
                    status: "active"
        '404':
          description: User not found

components:
  schemas:
    UserProfile:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        status:
          type: string
          enum: [active, suspended, deleted]
```

## Versioning Strategy

- **URI Versioning:** `/v1/users`, `/v2/users`
- **Deprecation Notice:** Add `deprecated: true` to OpenAPI spec and sunset date in response headers.

## Enforcement

Pull requests introducing new API endpoints without an approved OpenAPI spec will be rejected.

## Tooling

- **Linting:** `spectral lint openapi.yaml` (enforces Zalando rules)
- **Mocking:** `prism mock openapi.yaml` (local development server)
- **Validation:** `openapi-generator validate -i openapi.yaml`

## References

- [Zalando RESTful API Guidelines](https://opensource.zalando.com/restful-api-guidelines/)
- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- [SOP-000: Golden Thread](./sop-000-master.md)
- [MADR Template](../../templates/adr-madr.md)
