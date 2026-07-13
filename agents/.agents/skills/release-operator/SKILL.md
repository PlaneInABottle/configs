---
name: release-operator
description: Prepare, execute, verify, and if necessary safely roll back a software release using the repository's versioning policy, changelog, build artifacts, migration order, deployment mechanism, health checks, smoke tests, and release evidence. Use when the user asks to cut, deploy, promote, submit, roll back, or validate an actual release; use cicd-pipeline instead for pipeline authoring alone.
metadata:
  mode: operator
  risk: high
  evidence: required
  cleanup: required
---

# Release Operator

Operate the existing release path. Do not invent a deployment mechanism or infer authorization to publish, deploy, promote, or roll back.

## Preflight

- Confirm the requested environment, release scope, authorization, version policy, change freeze, required approvals, and success/rollback criteria.
- Read the canonical release runbook, CI/CD configuration, migration plan, environment protections, and previous release pattern.
- Require a clean, identified revision and record unrelated local changes separately.
- Confirm credentials through a non-secret identity/status command; never print them.

## Discovery

Use Phase 0 plus repository tags, package metadata, changelog policy, CI workflows, artifact configuration, deployment manifests, health/readiness endpoints, smoke tests, migration tooling, and rollback runbook. Treat absent deploy or rollback commands as unknown, not permission to improvise.

## Execute

1. Run required lint, typecheck, tests, security checks, migration tests, and build from the exact release revision.
2. Determine the version from project policy and requested compatibility impact. Update version/changelog only when release preparation is in scope.
3. Build once where the platform supports immutable artifacts; record the artifact digest and promote that artifact rather than rebuilding per environment.
4. Apply expand migrations before code and contract migrations only after compatibility is proven, following the project runbook.
5. Trigger the existing deployment/promotion mechanism for the authorized environment.
6. Observe bounded rollout status, readiness, smoke tests, critical metrics/logs, and user-visible criteria.
7. Roll back or halt only according to the approved runbook and trigger thresholds. Verify rollback health and data compatibility.

## Evidence

Record revision/tag/version, artifact identifier and digest, CI/deployment run ID, environment, approvals, migration IDs/order, rollout status, health and smoke observations, metric guardrails, timestamps, and rollback result if used. Sanitize URLs and identities where needed.

## Recovery

- Classify failures as preflight, build/artifact, migration, deployment transport, readiness, smoke behavior, observability, or rollback.
- Make at most two focused attempts for reversible pre-deploy failures.
- Once deployment begins, follow the runbook's retry/rollback policy; do not repeatedly redeploy an unexplained failing artifact.

## Cleanup

Remove temporary release files and credentials, close local verification runtimes, and retain required immutable evidence in the repository's normal system. Do not delete failed artifacts or logs needed for incident analysis unless policy requires it.

## Stop Conditions

Stop before deployment when authorization, target environment, canonical command, immutable revision, migration safety, health/smoke criteria, or rollback/forward-fix path is missing. During rollout, stop or roll back at the documented guardrail.

## Destructive Boundaries

Never publish packages, push tags, deploy, promote, mutate production data, or roll back external state unless the user request and project controls authorize that exact action. Never bypass protected environments or approvals.
