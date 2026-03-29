---
name: api-contract-testing
description: "Validate REST API contracts using OpenAPI specs (OpenAPI 3.0/3.1), test request/response schemas with JSON Schema validation, and verify API behavior. Use when testing REST APIs, validating OpenAPI/JSON Schema, verifying HTTP status codes, testing negative cases (400, 401, 404, 500), or checking API contracts against the spec."
---

# API Contract Testing

Validate REST APIs against their contracts using OpenAPI specifications and JSON Schema validation.

## Quick Start

```bash
# Test an endpoint against OpenAPI spec
hurl --variable "base_url=https://api.example.com" --test test-api.hurl

# Validate OpenAPI spec
npx @redocly/openapi-cli lint openapi.yaml
```

## When to Use This Skill

- **API Contract Validation**: Verify API matches OpenAPI spec
- **Schema Testing**: Test request/response body shapes
- **Negative Testing**: Test invalid inputs and error responses
- **Integration Testing**: End-to-end API workflows

## Tools

| Tool | Purpose |
|------|---------|
| Hurl | HTTP testing with assertion support |
| openapi-cli | OpenAPI spec validation |
| ajv | JSON Schema validation |

## Core Workflow

### 1. Validate OpenAPI Spec

```bash
# Lint OpenAPI spec
npx @redocly/openapi-cli lint openapi.yaml

# Bundle and validate
npx @redocly/openapi-cli bundle openapi.yaml -o dist/openapi.json
```

### 2. Test with Hurl

```bash
# Basic GET test
hurl --test --variable "base_url=https://api.example.com" <<'EOF'
GET {{base_url}}/users/1
[Asserts]
status == 200
json path "$.id" == 1
json path "$.name" exists
EOF
```

### 3. Schema Validation

```bash
# Test response matches schema
hurl --test <<'EOF'
GET https://api.example.com/users/1
[Asserts]
status == 200
header "Content-Type" == "application/json"
json path "$.id" is_integer
json path "$.email" matches "^[a-z]+@[a-z]+\\.[a-z]+$"
EOF
```

### 4. Negative Testing

```bash
# Test 404
hurl --test <<'EOF'
GET https://api.example.com/users/99999
[Asserts]
status == 404
json path "$.error" exists
EOF

# Test 400 - validation error
hurl --test <<'EOF'
POST https://api.example.com/users
{"email": "invalid"}
[Asserts]
status == 400
json path "$.message" contains "email"
EOF
```

## Advanced Patterns

### Authentication Flow

```bash
# Login and use token
hurl --test <<'EOF'
POST https://api.example.com/auth/login
{"email": "test@example.com", "password": "secret"}
[Asserts]
status == 200
json path "$.token" exists
[Captures]
token: jsonpath "$.token"

GET https://api.example.com/users
[Headers]
Authorization: "Bearer {{token}}"
[Asserts]
status == 200
EOF
```

### API Versioning

```bash
hurl --test --variable "base_url=https://api.example.com/v2" <<'EOF'
GET {{base_url}}/users
[Asserts]
header "Content-Type" contains "application/json"
json path "$[0].id" exists
EOF
```

### Rate Limiting

```bash
hurl --test <<'EOF'
# Make 3 rapid requests
GET https://api.example.com/users
GET https://api.example.com/users
GET https://api.example.com/users
[Asserts]
status >= 200
status < 500

# Should eventually get rate limited
GET https://api.example.com/users
[Asserts]
status == 429
EOF
```

## Testing Strategy

| Test Type | What to Test |
|-----------|--------------|
| Happy Path | Valid inputs, expected responses |
| Schema | Response shape matches spec |
| Negative | Invalid inputs, error codes |
| Edge Cases | Empty arrays, null values, limits |
| Auth | Token expiration, invalid tokens |

## References

- [Hurl Documentation](https://hurl.dev/)
- [OpenAPI Specification](https://spec.openapis.org/)
- [JSON Schema](https://json-schema.org/)

## See Also

- [ai-native-workflow](./ai-native-workflow) - General API testing guidance
- [native-datastore-verifier](./native-datastore-verifier) - Database verification