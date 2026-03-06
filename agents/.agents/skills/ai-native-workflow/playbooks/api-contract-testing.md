# Playbook: API & Contract Testing

**Goal:** Verify API endpoints and state changes without writing language-specific tests. Treat the application as a black box and interact over HTTP.

---

## 1. Automated Contract Testing with Hurl

Use `.hurl` files to define declarative, language-agnostic API tests.

Before running these examples, verify Hurl is installed and on `PATH`:

```bash
command -v hurl >/dev/null || { echo "Install hurl before running these examples"; exit 1; }
```

If the command reports `hurl` as missing, stop here and install it with your operating system package manager or the official Hurl installation instructions before continuing.

### Creating a Hurl Test

```hurl
# tests/api/create_user.hurl
POST http://localhost:8000/api/users
Content-Type: application/json
{
  "name": "Agent User",
  "email": "agent@test.com"
}

HTTP 201

[Asserts]
jsonpath "$.id" isInteger
jsonpath "$.status" == "pending"
```

### Executing Tests

```bash
# Run a single test
hurl --test tests/api/create_user.hurl

# Run all tests in a directory
hurl --test --variables-file .env.test tests/api/*.hurl
```

---

## 2. Authentication & Token Handling

Extract and reuse tokens across requests using Hurl's variable capture.

### Login and Capture Token
```hurl
POST http://localhost:8000/api/login
Content-Type: application/json
{
  "email": "test@example.com",
  "password": "password123"
}

HTTP 200
[Asserts]
jsonpath "$.token" exists
capturedToken: jsonpath "$.token"
```

### Using Captured Token
```hurl
GET http://localhost:8000/api/profile
Authorization: Bearer {{capturedToken}}

HTTP 200
[Asserts]
jsonpath "$.email" == "test@example.com"
```

### Token Refresh Flow
```hurl
POST http://localhost:8000/api/refresh
Content-Type: application/json
{
  "refresh_token": "{{old_refresh_token}}"
}

HTTP 200
[Asserts]
jsonpath "$.access_token" exists
newAccessToken: jsonpath "$.access_token"
```

---

## 3. File Upload Testing

Use Hurl's `[FormData]` section for multipart/form-data.

### Single File Upload
```hurl
POST http://localhost:8000/api/upload
Content-Type: multipart/form-data
[FormData]
avatar@tests/fixtures/avatar.jpg

HTTP 201
[Asserts]
jsonpath "$.url" exists
```

### Multiple Files
```hurl
POST http://localhost:8000/api/upload
Content-Type: multipart/form-data
[FormData]
files@tests/fixtures/image1.jpg
files@tests/fixtures/image2.jpg

HTTP 201
```

---

## 4. Negative Testing

Test API error handling with invalid inputs.

### Not Found (404)
```hurl
GET http://localhost:8000/api/users/99999

HTTP 404
[Asserts]
jsonpath "$.error" exists
```

### Bad Request (400)
```hurl
POST http://localhost:8000/api/users
Content-Type: application/json
{ "name": "A" }

HTTP 400
[Asserts]
jsonpath "$.errors.name" exists
```

### Unauthorized (401)
```hurl
GET http://localhost:8000/api/profile

HTTP 401
```

### Forbidden (403)
```hurl
GET http://localhost:8000/api/admin/users
Authorization: Bearer {{user_token}}

HTTP 403
```

### Rate Limiting (429)
```hurl
GET http://localhost:8000/api/data
HTTP 200

GET http://localhost:8000/api/data
HTTP 200

GET http://localhost:8000/api/data
HTTP 429
[Asserts]
header "Retry-After" exists
```

---

## 5. Webhook Testing

Test webhook endpoints.

```hurl
POST http://localhost:8000/webhooks/stripe
Content-Type: application/json
{
  "type": "payment_intent.succeeded",
  "data": { "id": "pi_123" }
}

HTTP 200
[Asserts]
jsonpath "$.received" == true
```

Verify side effects:
```bash
curl -sSf http://localhost:8000/api/payments/pi_123 | jq -r '.status'
```

---

## 6. Iterative Bash Verification

For ad-hoc verification during development, construct bash pipelines.

```bash
set -euo pipefail

# Step 1: Fetch data
curl -sSf "http://localhost:8025/api/v1/search?query=to:test@example.com"

# Step 2: Wait for async state
for i in {1..5}; do
  MESSAGE_ID=$(curl -sSf "http://localhost:8025/api/v1/search?query=to:test@example.com" 2>/dev/null | jq -r '.messages[0].ID // empty' || true)
  if [ -n "$MESSAGE_ID" ]; then break; fi
  sleep 2
done

# Step 3: Extract value
curl -sSf "http://localhost:8025/api/v1/message/${MESSAGE_ID}" | jq -r '.Text' | grep -o 'token=[^&]*' | cut -d= -f2
```

---

## Quick Reference

| Pattern | Command |
|---------|---------|
| Run Hurl test | `hurl --test tests/api/mytest.hurl` |
| Capture token | `capturedToken: jsonpath "$.token"` |
| File upload | `[FormData]` with `@filename` |
| 404 test | `GET /nonexistent` → `HTTP 404` |
| Webhook | `POST /webhooks/service` with payload |
