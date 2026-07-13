---
name: security-baseline-verifier
description: Run deterministic repository security baseline checks for exposed secrets, dependency advisories, public environment variables, authorization negatives, Supabase RLS, CORS and JWT configuration, container settings, and CI permissions. Use for security baseline requests, pre-release security checks, auth or configuration changes, or focused verification after a security-sensitive implementation.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# Security Baseline Verifier

Verify a bounded baseline with repository-native and established scanners. This is not a substitute for threat modeling or a full penetration test.

## Preflight

- Define repository, revision, environment, trust boundary, affected auth roles, and allowed active tests.
- Keep output redacted. Never paste discovered secret values, tokens, private keys, complete JWTs, or protected records.
- Use test identities and disposable local data for authorization checks.

## Discovery

Inspect existing security scripts, dependency manager, secret-scanner config, public environment conventions, auth middleware, OpenAPI tests, Supabase migrations/policies, CORS/JWT settings, Dockerfiles, Compose, and CI workflow permissions. Load `api-contract-testing` for auth negatives and `supabase` plus `native-datastore-verifier` for RLS evidence.

## Execute

Run only tools already configured or clearly required by the task. Typical checks include:

```bash
gitleaks git --redact .
npm audit
pnpm audit
pip-audit
cargo audit
```

Then verify the affected baseline:

1. Scan tracked history/worktree as configured and report only location/fingerprint metadata.
2. Review dependency advisories and reachable direct parents.
3. Enumerate browser/mobile-public environment prefixes and confirm no server secret is exposed in built artifacts or config.
4. Exercise unauthenticated, wrong-role, cross-tenant, object-ownership, and expired/invalid-token negatives where affected.
5. Verify RLS/policies with separate role identities when Supabase/Postgres authorization is in scope.
6. Check CORS origins/credentials, JWT issuer/audience/algorithm/expiry validation, container user/capabilities, and CI `permissions` for unsafe broad defaults.

## Evidence

Record revision, tool/version/config, scope, sanitized finding ID and location, auth role/action/expected denial/observed status, policy name, configuration source, severity, and result. Distinguish confirmed vulnerability, configuration risk, false positive, accepted risk, and unverified boundary.

## Recovery

- Reproduce scanner findings from the cited source without revealing the value.
- Classify failures as tool/config, false positive, dependency reachability, authentication, authorization, policy, or environment exposure.
- Make at most two focused attempts per class. Do not weaken checks to obtain a pass.

## Cleanup

Delete disposable identities/data and sensitive temporary reports, revoke only credentials created for the test, and confirm no debug auth bypass or permissive config remains. Preserve sanitized evidence required by policy.

## Stop Conditions

Stop active testing when it would target production without authorization, access another tenant's real data, expose secrets in output, require credential rotation, or exceed the agreed baseline scope.

## Destructive Boundaries

Do not rotate/revoke existing credentials, change production auth or RLS policies, exploit destructive endpoints, disable CI protections, or auto-fix dependency majors unless separately authorized.
