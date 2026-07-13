---
name: project-onboarding
description: Prepare a repository for reliable AI operation by discovering and verifying canonical runtime, test, build, datastore, service, teardown, and safety facts, then minimally creating or updating project-local agent instructions or an optional capability profile. Use only for explicit requests to make a project AI-ready, create or update AGENTS.md, document agent operations, or generate project capabilities.
metadata:
  mode: operator
  risk: low
  evidence: required
  cleanup: required
---

# Project Onboarding

Create a durable operational contract from verified repository facts. Keep normal feature discovery read-only under `ai-native-workflow`; persist knowledge only because onboarding is explicitly in scope.

## Preflight

- Read every applicable existing agent instruction file before editing one.
- Inspect the worktree and preserve unrelated human-authored content and changes.
- Decide whether a concise instruction section is sufficient. Add `.agents/project-capabilities.yaml` only for topology that needs machine-readable reuse.
- Do not read or persist secret values. Environment variable names may be documented only when needed and non-sensitive.

## Discovery

Run the read-only discovery script shipped by `ai-native-workflow`:

```bash
python3 <ai-native-workflow-skill-dir>/scripts/discover_project.py . --pretty
```

Trace every candidate back to its cited `package.json`, Makefile, Compose, CI, migration, or instruction source. Inspect framework config, health routes, test directories, mobile app identifiers, and deployment runbooks only when relevant to the requested contract.

## Execute

1. Verify canonical commands through bounded real execution when safe: affected tests/lint/typecheck/build, targeted service start and readiness, then targeted teardown.
2. Mark commands that cannot safely run as unverified; do not publish them as facts.
3. Apply the smallest patch to the nearest project instruction file. Preserve prose outside an existing managed block.
4. Store only durable facts under a compact contract such as:

   ```markdown
   <!-- agent-runtime:start -->
   ## Agent Runtime Contract
   - Start: `pnpm dev`
   - Verify: `pnpm test`; `pnpm lint`; `pnpm typecheck`
   - Readiness: `http://localhost:3000/health`
   - Teardown: `pm2 delete project-web`
   - Safety: database reset is allowed only for the disposable local database.
   <!-- agent-runtime:end -->
   ```

5. For a complex project, create `.agents/project-capabilities.yaml` from reviewed discovery output. Retain `source_fingerprint`, verification status, service ownership, and destructive boundaries. Do not copy the raw candidate output unchanged.

## Evidence

For every persisted fact, record during the task:

```text
Fact: <command, service, URL, or safety boundary>
Source: <repository file>
Verification: <bounded command and observed result>
Persisted at: <instruction/profile section>
Result: VERIFIED | UNVERIFIED-NOT-PERSISTED
```

Re-run discovery with `--check-profile .agents/project-capabilities.yaml` when a profile exists and report whether its fingerprint is fresh.

## Recovery

- If a documented command fails, inspect its executable source and make at most two focused attempts to resolve configuration or runtime prerequisites.
- If two sources conflict, prefer the command proven by current executable configuration and CI, then minimally correct stale instructions.
- If a command cannot be verified safely, omit it or label it explicitly as unresolved outside the durable contract.

## Cleanup

- Stop only named processes and project-scoped services started for verification.
- Remove disposable fixtures and temporary discovery output.
- Confirm the final diff contains no secrets, transient identifiers, raw environment dumps, or unrelated instruction rewrites.

## Stop Conditions

Stop persistence when verification would require production access, destructive data changes, unavailable credentials, or a material maintainer choice. Report candidate facts without presenting them as canonical.

## Destructive Boundaries

Never reset production data, deploy, rotate credentials, delete all PM2 processes, run repository-wide container cleanup, or overwrite human-authored instruction sections. Require explicit scope and a project runbook for any destructive verification.
