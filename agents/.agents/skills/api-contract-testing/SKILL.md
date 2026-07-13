---
name: api-contract-testing
description: Validate REST API behavior against an OpenAPI 3.x contract. Use when linting or bundling a specification, checking implementation responses against documented schemas, testing negative cases and authentication, or detecting drift between an API and its OpenAPI document.
---

# API Contract Testing

Separate specification validation from implementation conformance. A valid OpenAPI file does not prove the running API follows it, and a few hand-written field assertions do not validate the full response schema.

## Workflow

1. Locate the repository's OpenAPI document and existing contract-test tooling.
2. Lint and bundle the specification with the project's configured validator. For new Redocly usage, prefer the current `@redocly/cli` package.
3. Start the API through the repository's normal runtime.
4. Run a contract-aware tool that sends requests and validates status, headers, and bodies against OpenAPI, or validate captured responses with schemas generated from the relevant operation.
5. Add focused Hurl cases for workflows, auth, and negative behavior that the schema alone cannot express.
6. Report operation IDs and exact schema mismatches.

## Hurl Example

```hurl
GET {{base_url}}/users/1
HTTP 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.id" isInteger
jsonpath "$.email" exists
```

Hurl is useful for explicit behavioral assertions but is not, by itself, an OpenAPI conformance engine.

## Required Cases

- Documented success statuses and media types
- Request validation failures
- Authentication and authorization failures
- Not-found behavior where documented
- Nullable, optional, empty, and paginated responses
- Undocumented statuses or fields when additional properties are forbidden

Rate-limit tests must derive expectations from the API's configured policy and headers. Never assume a fixed request number must return `429`.

## Guardrails

- Use disposable test identities and data.
- Keep secrets in Hurl secret variables or the repository's secret mechanism.
- Do not test destructive production endpoints.
- Prefer the repository's existing contract tool over adding a parallel one.
