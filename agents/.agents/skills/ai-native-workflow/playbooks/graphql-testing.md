# Playbook: GraphQL Testing

**Goal:** Test GraphQL APIs using Hurl, treating the GraphQL endpoint as a black box.

GraphQL uses POST requests with a special query format. Hurl supports GraphQL natively.

Before running these examples, verify Hurl is installed and on `PATH`:

```bash
command -v hurl >/dev/null || { echo "Install hurl before running these examples"; exit 1; }
```

If the command reports `hurl` as missing, stop here and install it with your operating system package manager or the official Hurl installation instructions before continuing.

---

## Basic Query

```hurl
# tests/api/graphql_query.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
{
  "query": "{ user(id: 1) { name email } }"
}

HTTP 200
[Asserts]
jsonpath "$.data.user.name" exists
jsonpath "$.data.user.email" matches "^[\w.-]+@[\w.-]+$"
```

---

## Query with Variables

```hurl
# tests/api/graphql_variables.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
{
  "query": "query GetUser($id: ID!) { user(id: $id) { name email } }",
  "variables": { "id": 1 }
}

HTTP 200
[Asserts]
jsonpath "$.data.user.name" == "John Doe"
```

---

## Mutations

```hurl
# tests/api/graphql_mutation.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
{
  "query": "mutation CreateUser($input: UserInput!) { createUser(input: $input) { id name } }",
  "variables": {
    "input": { "name": "Alice", "email": "alice@example.com" }
  }
}

HTTP 200
[Asserts]
jsonpath "$.data.createUser.id" isInteger
jsonpath "$.data.createUser.name" == "Alice"
```

---

## GraphQL with Authentication

```hurl
# tests/api/graphql_auth.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
Authorization: Bearer {{token}}
{
  "query": "{ me { email subscription } }"
}

HTTP 200
[Asserts]
jsonpath "$.data.me.email" == "user@example.com"
```

---

## Error Handling

```hurl
# tests/api/graphql_error.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
{
  "query": "{ nonexistentField { name } }"
}

HTTP 200
[Asserts]
jsonpath "$.errors[0].message" exists
```

---

## Introspection

```hurl
# tests/api/graphql_introspection.hurl
POST http://localhost:8000/graphql
Content-Type: application/json
{
  "query": "{ __schema { types { name } } }"
}

HTTP 200
[Asserts]
jsonpath "$.data.__schema.types" isArray
```

---

## Quick Reference

| Pattern | Hurl |
|---------|------|
| Query | `POST /graphql` with `{ "query": "..." }` |
| Variables | Add `"variables": { ... }` |
| Auth | `Authorization: Bearer {{token}}` |
