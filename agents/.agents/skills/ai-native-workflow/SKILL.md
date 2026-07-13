---
name: ai-native-workflow
description: Coordinate project discovery, runtime setup, bounded recovery, and evidence-based completion across application processes, APIs, databases, UI, queues, containers, releases, migrations, or multiple verification layers. Use when work requires fresh runtime knowledge, process or service coordination, cross-boundary verification, or evidence beyond a self-contained repository-native test loop; do not load for routine scoped changes with current canonical commands.
license: MIT
metadata:
  mode: orchestrator
  evidence: required
---

# AI-Native Workflow

Own the runtime and evidence control loop. Let project instructions define durable local facts, domain skills define technology-specific implementation, and operator skills execute boundary checks.

## Phase 0: Discover Before Changing Code

1. Read the nearest applicable project instruction files. Prefer the most local file for scoped work.
2. Decide whether those verified local facts are sufficient for the scoped task. If canonical commands are current and the change is self-contained, use them directly and skip repository-wide discovery.
3. Run [`scripts/discover_project.py`](scripts/discover_project.py) only when runtime knowledge is missing, stale, or contradictory; a documented command fails; topology changed; the task crosses services/boundaries; or runtime evidence genuinely requires fresh discovery. The script is read-only and reports sourced but unverified candidates:

   ```bash
   python3 <ai-native-workflow-skill-dir>/scripts/discover_project.py . --pretty
   ```

4. If `.agents/project-capabilities.yaml` is relevant, treat it as a cache, not unquestioned truth. Compare its `source_fingerprint` only when discovery runs.
5. Verify only the commands and services needed by the task against their cited manifest, Compose, CI, or instruction source.
6. Identify affected surfaces and load the smallest matching set from the capability map below.

Do not persist discovery output during normal feature work. Use `project-onboarding` only when the task explicitly asks to make the repository agent-ready, create/update agent instructions, or create a durable capability profile.

Phase 0 may end after reading current scoped instructions. Do not run repository-wide heuristics merely because a code change is substantial.

## Capability Map

| Detected work or surface | Load |
|---|---|
| REST/OpenAPI behavior | `api-contract-testing` |
| GraphQL behavior | [GraphQL playbook](playbooks/graphql-testing.md) |
| WebSocket lifecycle | `websocket-testing` |
| Queue or background worker | `async-worker-testing` |
| Direct persisted-state evidence | `native-datastore-verifier` |
| Schema migration or data backfill | `database-migration-testing` plus the datastore/domain skill |
| Captured email | `mailpit-email-testing` |
| Web UI interaction | `agent-browser` |
| Web or mobile screenshot comparison | `visual-regression-testing` plus `agent-browser` or `maestro-testing` |
| Mobile UI interaction | `maestro-testing` |
| Supabase boundary | `supabase` and the matching operator skill |
| Expo implementation | `react-native-expo`; add `expo-eas-build`, `deep-linking`, or `react-native-push` only when affected |
| Runtime logs, health, metrics, or profiling | `runtime-observability`; add `pm2-runtime-operator` for PM2 process operations |
| Load or performance criteria | `load-testing` |
| Dependency upgrade | `dependency-upgrade-operator` |
| Release, deployment, or rollback | `release-operator`; add `cicd-pipeline` only for pipeline work |
| Deterministic security checks | `security-baseline-verifier` plus boundary-specific skills |
| External public API selection | `api-discovery` |
| External dependency fake | [Dependency mocking playbook](playbooks/mocking-dependencies.md) |
| Generated fixture data | [Data generation playbook](playbooks/universal-data-generation.md) |
| Binary media fixture | [Media handling playbook](playbooks/media-file-handling.md) |

Do not load every possible skill. Load only those needed to implement or verify an affected acceptance criterion.

## Define Evidence

Before implementation, translate each acceptance criterion into a checkable evidence row:

| Criterion | Evidence source | Expected observation | Cleanup | Status |
|---|---|---|---|---|
| Concrete user-visible or system behavior | Native test, API, UI, datastore, worker, log, or artifact | Exact status/state/threshold | Fixture/process cleanup | Pending |

Use repository-native tests first for logic and established integration behavior. Add a boundary check only when it resolves a real remaining uncertainty. Record an explicit `UNVERIFIED` status when a criterion cannot be observed.

## Closed Control Loop

1. **Discover** — Read current scoped facts, run discovery only under the Phase 0 conditions, and select skills.
2. **Define evidence** — Build the criterion-to-evidence matrix and note destructive boundaries.
3. **Prepare runtime** — Start only required services using canonical commands; use PM2 for application servers and Docker for stateful infrastructure when those match project instructions. Prove readiness with a bounded health check.
4. **Execute** — Make the smallest change for the active criterion. Preserve unrelated worktree state.
5. **Verify** — Run affected native tests, then the selected boundary operators. Capture expected versus observed behavior.
6. **Recover** — Classify the failure and make at most two focused recovery attempts for that failure class. Re-run the smallest discriminating check after each attempt.
7. **Review** — Inspect the diff, security impact, migrations, logs, generated artifacts, and cleanup status. Run broader canonical checks proportional to risk.
8. **Close** — Remove only processes and fixtures created for the task. Report verified, failed, and unverified criteria separately.

## Recovery and Stop Rules

Classify failures as discovery/configuration, runtime unavailable, fixture/state, implementation, assertion/contract, environment/tooling, or external dependency. Do not spend a recovery attempt repeating the same command without a changed hypothesis or condition.

Stop and report the last evidence when:

- two focused recovery attempts for the same failure class have failed;
- the next action would cross an unapproved production or destructive boundary;
- required credentials, external access, or a material product decision is missing;
- repository instructions conflict and local executable configuration cannot resolve the conflict safely;
- cleanup ownership is unclear and continuing could damage unrelated state.

## Evidence Result

Return operator evidence in this shape:

```text
Criterion: <acceptance criterion>
Surface: <native test | API | UI | datastore | worker | runtime | artifact>
Action: <bounded command or interaction>
Expected: <specific observation>
Observed: <specific observation, sanitized>
Recovery: <0/2, 1/2, or 2/2 and failure class>
Cleanup: <completed | not needed | blocked>
Result: VERIFIED | FAILED | UNVERIFIED
```

Completion requires evidence for every requested criterion, successful proportional repository checks, no unresolved unsafe side effects, and explicit disclosure of anything not verified.

Read [phase checklists](references/phase-checklists.md) while executing the loop. Read [best practices](references/best-practices.md) when choosing evidence depth or diagnosing workflow anti-patterns.
