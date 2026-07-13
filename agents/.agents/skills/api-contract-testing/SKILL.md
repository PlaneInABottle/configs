---
name: api-contract-testing
description: Validate REST API behavior against an OpenAPI 3.x contract. Use when linting or bundling a specification, checking implementation responses against documented schemas, testing negative cases and authentication, or detecting drift between an API and its OpenAPI document.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# API Contract Testing

Separate specification validity from running implementation conformance. A valid OpenAPI file does not prove the API follows it, and hand-written field assertions do not prove the complete schema.

## Preflight

- Locate the authoritative OpenAPI document, base URL, server environment, auth mechanism, and repository-native contract tooling.
- Start the API through canonical runtime instructions and prove readiness with a bounded health check.
- Use disposable identities/data and keep credentials in the repository's secret mechanism.

## Discovery

Inspect CI, package scripts, test directories, generated clients, and OpenAPI configuration before selecting a tool. Prefer the project's configured linter/conformance engine. Verify the tool can validate response schemas, not merely send requests.

If no specification exists, stop OpenAPI conformance work and report that boundary; run focused behavioral API tests only if they still satisfy the user's criterion.

## Execute

1. Lint and bundle/resolve the specification with the configured validator.
2. Start from documented operation IDs and run implementation conformance for statuses, headers, media types, and complete response schemas.
3. Add focused Hurl or native tests for auth, workflows, and negative behavior the schema cannot express:

   ```hurl
   GET {{base_url}}/users/1
   HTTP 200
   [Asserts]
   header "Content-Type" contains "application/json"
   jsonpath "$.id" isInteger
   jsonpath "$.email" exists
   ```

4. Cover documented success, request validation, unauthenticated/unauthorized, not-found, nullable/optional/empty/paginated responses, and undocumented statuses/fields where forbidden.
5. Derive rate-limit expectations from configured policy and response headers; never assume a fixed request count must yield `429`.

## Evidence

Record specification path/digest, tool/version/config, server revision/base environment, operation ID, request case, expected contract fragment, observed status/media/schema result, exact mismatch path, and cleanup result. Hurl success is behavioral evidence, not by itself full OpenAPI conformance.

## Recovery

- Classify failures as missing/invalid spec, unresolved reference, runtime unavailable, auth/fixture, request mismatch, response mismatch, or tool limitation.
- Make at most two focused attempts per class. Re-run one failing operation before the broader suite.
- Fix the implementation or contract according to product truth; do not weaken schemas automatically to match observed output.

## Cleanup

Delete disposable records and identities, stop only runtime processes started for the test, and remove temporary bundles/reports unless requested as evidence. Confirm no secret variables were written to artifacts.

## Stop Conditions

Stop when the authoritative specification cannot be identified, the API cannot be started after two focused recovery attempts, testing would target destructive production endpoints, or contract truth requires a product decision.

## Destructive Boundaries

Do not exercise destructive production operations, disable TLS verification outside an isolated local environment, publish a changed API contract, or regenerate public clients outside the requested scope.
