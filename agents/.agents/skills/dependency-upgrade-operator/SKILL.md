---
name: dependency-upgrade-operator
description: Upgrade application dependencies incrementally using the repository's package manager, official changelogs and migration guides, lockfile discipline, security advisories, and rollback-safe verification. Use for routine upgrades, framework or runtime version changes, vulnerable-package remediation, lockfile refreshes, or outdated dependency work.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# Dependency Upgrade Operator

Upgrade the smallest coherent dependency set that satisfies the request. Preserve the repository's package manager, lockfile, and existing test workflow.

## Preflight

- Read project instructions and establish a passing affected test/build baseline.
- Identify runtime constraints, package-manager version, lockfile ownership, workspace boundaries, registries, patches, resolutions/overrides, and native dependencies.
- Preserve unrelated worktree changes. Do not use destructive Git restoration as a rollback mechanism.

## Discovery

Use the repository's native outdated/audit commands and lockfile. Read primary release notes and migration guides for the exact old-to-new range, especially majors. Trace vulnerable transitive packages to their direct parent before changing overrides.

Examples only when matching the project manager:

```bash
npm outdated
pnpm outdated
yarn outdated
```

Verify command availability locally; do not install a new global upgrade tool when native tooling is sufficient.

## Execute

1. Upgrade one direct dependency or tightly coupled framework group at a time.
2. Use the native package-manager command so manifest and lockfile stay consistent.
3. Apply only migration-guide changes required for the selected version range.
4. Review install scripts, new transitive packages, peer-resolution warnings, lockfile source/integrity changes, and unexpected package removals.
5. Run affected tests after each group, then canonical lint/typecheck/build and boundary evidence required by the changed dependency.
6. Run the ecosystem security audit and distinguish unresolved advisories, accepted risk, and false positives.

## Evidence

Record old/new versions, primary release guidance used, manifest/lockfile diff, peer and install warnings, advisory changes, affected test results, build/runtime evidence, and any required configuration or code migration.

## Recovery

- Classify failures as resolver/peer, runtime/toolchain, API migration, native build, test behavior, lockfile drift, or advisory.
- Make at most two focused attempts per class. Revert the specific package-manager change with an inverse native operation or minimal patch, then regenerate the lockfile consistently.
- Split coupled upgrades only when the ecosystem permits independent compatible versions.

## Cleanup

Remove temporary caches or generated reports created for diagnosis, not shared package caches indiscriminately. Confirm no global tool, temporary registry credential, or unrelated lockfile churn remains.

## Stop Conditions

Stop when the requested range has no supported migration path, peer constraints require a broader product decision, a registry or package source is untrusted, required native toolchains are unavailable, or verification cannot cover the affected runtime boundary.

## Destructive Boundaries

Do not bulk-upgrade everything to latest, force incompatible peers, disable integrity checks, run unreviewed automated breaking migrations, publish packages, or change runtime deployment versions outside the requested scope.
