---
name: database-migration-testing
description: Validate database schema migrations and data backfills in disposable environments, including clean apply, upgrade from the prior schema, before/after schema and data evidence, expand-contract safety, repeatability, rollback feasibility, and production-risk classification. Use whenever migrations, backfills, constraints, indexes, RLS, or schema-changing releases are added or changed.
metadata:
  mode: operator
  risk: high
  evidence: required
  cleanup: required
---

# Database Migration Testing

Prove the migration against a disposable database that represents both a clean install and the real upgrade path. Load the datastore/domain skill for engine-specific commands.

## Preflight

- Confirm the database is disposable and local/test-only. Identify the migration tool, current deployed baseline, backup/restore path, and application versions that overlap the migration.
- Inspect the worktree for existing migrations and ordering conventions. Never rewrite an already-applied migration unless project policy explicitly permits it.
- Classify locks, table rewrites, destructive DDL, backfill size, transaction behavior, and RLS/auth impact before running.

## Discovery

Use Phase 0 migration paths, Compose services, CI workflows, and project instructions to find canonical reset, migrate, status, seed, schema dump, and rollback commands. Inspect the migration source directly; do not infer reversibility from a filename.

## Execute

1. Capture the baseline migration status, schema signature, and representative invariant counts without sensitive row data.
2. Apply the full migration chain to a clean disposable database.
3. Restore or construct the prior-version schema plus representative edge-case data, then apply only the new migrations.
4. Verify constraints, indexes, defaults, RLS/policies, generated values, backfill correctness, null/duplicate edge cases, and application compatibility.
5. Re-run the migration command to prove the tool reaches a no-op state.
6. Exercise rollback only when the project provides a supported rollback and data loss is acceptable in the disposable environment. Otherwise document forward-fix recovery.
7. For expand-contract changes, verify the old application works after expand and the new application works before contract.

Use native schema tools (`pg_dump --schema-only`, migration status commands, catalog queries) through `native-datastore-verifier` rather than comparing ORM assumptions alone.

## Evidence

Record engine/tool versions, baseline revision, migration identifiers/order, clean-apply result, upgrade-path result, before/after schema signature, invariant queries, backfill counts, lock/runtime observations, repeat-run result, rollback or forward-fix result, and production-risk classification.

## Recovery

- Classify failures as ordering, syntax/transaction, lock/timeout, dirty baseline, constraint/data, RLS/auth, application compatibility, or rollback.
- Make at most two focused recovery attempts per class on a freshly reset disposable database.
- Do not weaken constraints or delete representative data merely to make the migration pass.

## Cleanup

Remove only the disposable database/container and migration fixtures created for the test. Restore temporary application versions or flags. Confirm no generated schema dump or credentials were left unintentionally.

## Stop Conditions

Stop when the database cannot be proven disposable, the migration targets production, rollback/data-loss policy is unclear, required prior-version state is unavailable, or the next test would lock or expose shared data.

## Destructive Boundaries

Never reset, truncate, restore over, or roll back a shared or production database. Never run destructive DDL merely to test it without explicit environment proof and authorization.
