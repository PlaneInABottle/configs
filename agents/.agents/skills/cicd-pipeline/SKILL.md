---
name: cicd-pipeline
description: Create, change, review, or debug GitHub Actions and GitLab CI pipelines. Use for automated builds, tests, artifacts, releases, deployments, permissions, caching, environments, concurrency, or failed workflow diagnosis.
---

# CI/CD Pipeline

Extend the repository's existing pipeline and conventions before introducing a new workflow. Check current provider documentation for action versions and syntax because hosted images and actions change independently of this skill.

## Workflow

1. Read existing workflow files, package scripts, deployment docs, and branch protections.
2. Reproduce the failing command locally when feasible.
3. Define the minimum event, permissions, jobs, artifacts, and environment required.
4. Pin runtime versions and third-party dependencies according to repository policy.
5. Add concurrency and cancellation where duplicate runs waste resources or race deployments.
6. Validate syntax, run local commands, and inspect provider logs before retrying.

## Security Defaults

- Declare least-privilege workflow permissions; use `contents: read` unless more is required.
- Keep secrets in provider secret stores and pass them only to the step that needs them.
- Do not expose secrets to untrusted pull-request code or print complete environment values.
- Prefer commit-SHA pinning for third-party actions in security-sensitive repositories; use trusted major tags only when repository policy permits.
- Protect deployment environments with provider approvals and branch rules.
- Use short-lived identity federation instead of long-lived cloud keys when supported.

## Reliability Defaults

- Use lockfile-based installs such as `npm ci` when applicable.
- Key caches from lockfiles and never treat a cache as an artifact.
- Upload diagnostics with bounded retention when failures need investigation.
- Make deployment jobs depend on required build and test jobs.
- Add `timeout-minutes` and provider-equivalent limits to potentially hanging jobs.
- Prefer GitLab `rules` for new pipelines while preserving existing `only/except` usage unless intentionally migrating it.

## Debugging

- Inspect the exact failed step and complete error before changing configuration.
- Check event filters, permissions, environment protection, runner availability, and secret scope.
- Retry only transient failures; fix deterministic failures first.
- Avoid broad pipeline rewrites while diagnosing one broken job.
