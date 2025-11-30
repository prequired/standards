# API Specification

**Version:** 1.0.0
**Base URL:** `https://api.agency-platform.com/v1`
**Last Updated:** 2025-11-29

---

## 1. Overview

The Agency Platform API provides RESTful endpoints for managing projects, clients, invoices, and time tracking. The API is designed for both internal use (admin panel, client portal) and external integrations.

### 1.1 API Design Principles

- **RESTful** - Resource-based URLs, HTTP methods for actions
- **JSON** - Request and response bodies in JSON format
- **Versioned** - API version in URL path (`/v1/`)
- **Paginated** - List endpoints return paginated results
- **Consistent** - Standard error format and response structure

### 1.2 Related Documents

- [ADR-0001: Project Management](../03-decisions/adr-0001-project-management-tool.md)
- [ADR-0002: Invoicing Solution](../03-decisions/adr-0002-invoicing-solution.md)
- [ADR-0012: Security](../03-decisions/adr-0012-security-data-protection.md)

---

## 2. Authentication

### 2.1 Token-Based Authentication

The API uses Laravel Sanctum for token authentication.

**Obtaining a Token:**

```http
POST /v1/auth/token
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "password",
    "device_name": "api-client"
}
```

**Response:**

```json
{
    "token": "1|abc123...",
    "expires_at": "2025-12-29T00:00:00Z"
}
```

**Using the Token:**

```http
GET /v1/projects
Authorization: Bearer 1|abc123...
```

### 2.2 Token Scopes

| Scope | Description |
|-------|-------------|
| `read` | Read-only access |
| `write` | Create and update resources |
| `delete` | Delete resources |
| `admin` | Full administrative access |

**Requesting Scopes:**

```json
{
    "email": "user@example.com",
    "password": "password",
    "device_name": "api-client",
    "scopes": ["read", "write"]
}
```

### 2.3 Token Revocation

```http
DELETE /v1/auth/token
Authorization: Bearer 1|abc123...
```

---

## 3. Request Format

### 3.1 Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token |
| `Content-Type` | Yes* | `application/json` for POST/PUT/PATCH |
| `Accept` | Recommended | `application/json` |
| `X-Request-ID` | Optional | Client-generated request ID for tracing |

### 3.2 Query Parameters

**Pagination:**

| Parameter | Default | Max | Description |
|-----------|---------|-----|-------------|
| `page` | 1 | - | Page number |
| `per_page` | 15 | 100 | Items per page |

**Filtering:**

```http
GET /v1/projects?status=active&client_id=123
```

**Sorting:**

```http
GET /v1/projects?sort=-created_at
# Prefix with - for descending
```

**Including Relations:**

```http
GET /v1/projects?include=client,tasks
```

**Sparse Fieldsets:**

```http
GET /v1/projects?fields[projects]=id,name,status
```

---

## 4. Response Format

### 4.1 Success Response

**Single Resource:**

```json
{
    "data": {
        "id": 1,
        "type": "projects",
        "attributes": {
            "name": "Website Redesign",
            "status": "active",
            "created_at": "2025-11-29T10:00:00Z"
        },
        "relationships": {
            "client": {
                "data": { "id": 5, "type": "clients" }
            }
        },
        "links": {
            "self": "/v1/projects/1"
        }
    }
}
```

**Collection:**

```json
{
    "data": [
        { "id": 1, "type": "projects", ... },
        { "id": 2, "type": "projects", ... }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 15,
        "total": 42,
        "last_page": 3
    },
    "links": {
        "first": "/v1/projects?page=1",
        "last": "/v1/projects?page=3",
        "prev": null,
        "next": "/v1/projects?page=2"
    }
}
```

### 4.2 Error Response

```json
{
    "error": {
        "code": "validation_error",
        "message": "The given data was invalid.",
        "details": [
            {
                "field": "name",
                "message": "The name field is required."
            },
            {
                "field": "client_id",
                "message": "The selected client is invalid."
            }
        ]
    }
}
```

### 4.3 HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

---

## 5. Rate Limiting

### 5.1 Limits

| Tier | Requests/Minute | Requests/Day |
|------|-----------------|--------------|
| Standard | 60 | 10,000 |
| Premium | 300 | 100,000 |

### 5.2 Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1701234567
```

### 5.3 Rate Limit Exceeded

```json
{
    "error": {
        "code": "rate_limit_exceeded",
        "message": "Too many requests. Please retry after 45 seconds.",
        "retry_after": 45
    }
}
```

---

## 6. Endpoints

### 6.1 Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/auth/token` | Obtain access token |
| DELETE | `/v1/auth/token` | Revoke current token |
| GET | `/v1/auth/user` | Get authenticated user |

### 6.2 Projects

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/projects` | List projects |
| POST | `/v1/projects` | Create project |
| GET | `/v1/projects/{id}` | Get project |
| PUT | `/v1/projects/{id}` | Update project |
| DELETE | `/v1/projects/{id}` | Delete project |
| GET | `/v1/projects/{id}/tasks` | List project tasks |
| GET | `/v1/projects/{id}/time-entries` | List project time entries |
| GET | `/v1/projects/{id}/invoices` | List project invoices |

**Create Project:**

```http
POST /v1/projects
Content-Type: application/json
Authorization: Bearer token

{
    "name": "Website Redesign",
    "client_id": 5,
    "description": "Complete website overhaul",
    "budget_cents": 500000,
    "due_date": "2025-03-15"
}
```

**Response (201 Created):**

```json
{
    "data": {
        "id": 42,
        "type": "projects",
        "attributes": {
            "name": "Website Redesign",
            "description": "Complete website overhaul",
            "status": "draft",
            "budget_cents": 500000,
            "due_date": "2025-03-15",
            "created_at": "2025-11-29T10:00:00Z",
            "updated_at": "2025-11-29T10:00:00Z"
        },
        "relationships": {
            "client": {
                "data": { "id": 5, "type": "clients" }
            }
        }
    }
}
```

### 6.3 Clients

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/clients` | List clients |
| POST | `/v1/clients` | Create client |
| GET | `/v1/clients/{id}` | Get client |
| PUT | `/v1/clients/{id}` | Update client |
| DELETE | `/v1/clients/{id}` | Delete client |
| GET | `/v1/clients/{id}/projects` | List client projects |
| GET | `/v1/clients/{id}/invoices` | List client invoices |

### 6.4 Tasks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/tasks` | List all tasks |
| POST | `/v1/tasks` | Create task |
| GET | `/v1/tasks/{id}` | Get task |
| PUT | `/v1/tasks/{id}` | Update task |
| DELETE | `/v1/tasks/{id}` | Delete task |
| POST | `/v1/tasks/{id}/complete` | Mark task complete |
| POST | `/v1/tasks/{id}/reopen` | Reopen task |

### 6.5 Time Entries

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/time-entries` | List time entries |
| POST | `/v1/time-entries` | Create time entry |
| GET | `/v1/time-entries/{id}` | Get time entry |
| PUT | `/v1/time-entries/{id}` | Update time entry |
| DELETE | `/v1/time-entries/{id}` | Delete time entry |
| POST | `/v1/time-entries/start` | Start timer |
| POST | `/v1/time-entries/{id}/stop` | Stop timer |

**Start Timer:**

```http
POST /v1/time-entries/start
Content-Type: application/json

{
    "project_id": 42,
    "task_id": 100,
    "description": "Working on homepage design"
}
```

**Stop Timer:**

```http
POST /v1/time-entries/123/stop
```

### 6.6 Invoices

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/invoices` | List invoices |
| POST | `/v1/invoices` | Create invoice |
| GET | `/v1/invoices/{id}` | Get invoice |
| PUT | `/v1/invoices/{id}` | Update invoice |
| DELETE | `/v1/invoices/{id}` | Delete invoice (draft only) |
| POST | `/v1/invoices/{id}/send` | Send invoice to client |
| POST | `/v1/invoices/{id}/mark-paid` | Mark invoice as paid |
| GET | `/v1/invoices/{id}/pdf` | Download invoice PDF |

**Create Invoice:**

```http
POST /v1/invoices
Content-Type: application/json

{
    "client_id": 5,
    "project_id": 42,
    "due_date": "2025-12-15",
    "line_items": [
        {
            "description": "Website Design",
            "quantity": 1,
            "unit_price_cents": 250000
        },
        {
            "description": "Development Hours",
            "quantity": 40,
            "unit_price_cents": 10000
        }
    ],
    "notes": "Thank you for your business!"
}
```

### 6.7 Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/users` | List users (admin only) |
| POST | `/v1/users` | Create user (admin only) |
| GET | `/v1/users/{id}` | Get user |
| PUT | `/v1/users/{id}` | Update user |
| DELETE | `/v1/users/{id}` | Delete user (admin only) |

---

## 7. Webhooks

### 7.1 Available Events

| Event | Description |
|-------|-------------|
| `project.created` | New project created |
| `project.updated` | Project updated |
| `project.completed` | Project marked complete |
| `invoice.sent` | Invoice sent to client |
| `invoice.paid` | Invoice payment received |
| `invoice.overdue` | Invoice past due date |
| `task.completed` | Task marked complete |

### 7.2 Webhook Payload

```json
{
    "id": "evt_abc123",
    "type": "invoice.paid",
    "created_at": "2025-11-29T10:00:00Z",
    "data": {
        "invoice": {
            "id": 100,
            "number": "INV-2025-0042",
            "amount_cents": 500000,
            "paid_at": "2025-11-29T10:00:00Z"
        },
        "client": {
            "id": 5,
            "name": "Acme Corp"
        }
    }
}
```

### 7.3 Webhook Security

Verify webhook signatures:

```php
$signature = $request->header('X-Signature');
$payload = $request->getContent();
$secret = config('services.webhook.secret');

$expected = hash_hmac('sha256', $payload, $secret);

if (! hash_equals($expected, $signature)) {
    abort(401, 'Invalid signature');
}
```

### 7.4 Webhook Configuration

```http
POST /v1/webhooks
Content-Type: application/json

{
    "url": "https://example.com/webhooks",
    "events": ["invoice.paid", "project.completed"],
    "secret": "whsec_abc123..."
}
```

---

## 8. SDKs and Examples

### 8.1 PHP SDK

```php
use AgencyPlatform\Client;

$client = new Client('your-api-token');

// List projects
$projects = $client->projects()->list([
    'status' => 'active',
    'per_page' => 25,
]);

// Create project
$project = $client->projects()->create([
    'name' => 'New Website',
    'client_id' => 5,
]);

// Start time tracking
$entry = $client->timeEntries()->start([
    'project_id' => $project->id,
    'description' => 'Initial setup',
]);
```

### 8.2 JavaScript Example

```javascript
const API_BASE = 'https://api.agency-platform.com/v1';
const token = 'your-api-token';

// Fetch projects
const response = await fetch(`${API_BASE}/projects`, {
    headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json',
    },
});

const { data, meta } = await response.json();

// Create invoice
const invoice = await fetch(`${API_BASE}/invoices`, {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({
        client_id: 5,
        project_id: 42,
        due_date: '2025-12-15',
        line_items: [
            { description: 'Consulting', quantity: 10, unit_price_cents: 15000 }
        ],
    }),
});
```

### 8.3 cURL Examples

```bash
# Authenticate
curl -X POST https://api.agency-platform.com/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret","device_name":"cli"}'

# List projects
curl https://api.agency-platform.com/v1/projects \
  -H "Authorization: Bearer $TOKEN"

# Create project
curl -X POST https://api.agency-platform.com/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"New Project","client_id":5}'
```

---

## 9. Changelog

### v1.0.0 (2025-11-29)

- Initial API release
- Authentication endpoints
- Projects, Clients, Tasks, Time Entries, Invoices, Users
- Webhook support
- Rate limiting

---

## Links

- [OpenAPI Specification](./openapi.yaml)
- [Postman Collection](./postman-collection.json)
- [Authentication Guide](../03-decisions/adr-0012-security-data-protection.md)
- [Development Standards](../04-development/dev-standards.md)
