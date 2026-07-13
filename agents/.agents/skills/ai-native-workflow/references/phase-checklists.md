# Phase Checklists

## Contents

- [Discover](#discover)
- [Define evidence](#define-evidence)
- [Prepare runtime](#prepare-runtime)
- [Execute and verify](#execute-and-verify)
- [Recover](#recover)
- [Review and close](#review-and-close)

## Discover

- [ ] Read the nearest applicable agent instructions.
- [ ] Decide whether current canonical commands and project facts are sufficient for the scoped task.
- [ ] Run `scripts/discover_project.py` only for missing, stale, contradictory, cross-service, or runtime-evidence gaps; otherwise skip repository-wide discovery.
- [ ] When discovery runs, retain its source fingerprint and treat every discovered command as a candidate until its cited source and execution are checked.
- [ ] Check an existing capability profile for staleness only when it is relevant to the task and fresh discovery is warranted.
- [ ] Identify application, worker, datastore, queue, mail, web, mobile, and deployment surfaces affected by the task.
- [ ] Load only matching operator and domain skills.
- [ ] Keep self-contained work on current project instructions and directly matching skills.

## Define evidence

- [ ] Rewrite each user requirement as an observable acceptance criterion.
- [ ] Choose the smallest evidence source that can prove it.
- [ ] Prefer existing repository tests before adding boundary tooling.
- [ ] Record expected status, state, threshold, UI observation, or artifact.
- [ ] Plan fixture, process, container, and temporary-file cleanup.
- [ ] Identify production and destructive boundaries before execution.

## Prepare runtime

- [ ] Start only services required for the selected criteria.
- [ ] Use the project's canonical package manager and start commands.
- [ ] Keep application servers under a named process manager when the project uses PM2; keep stateful services under Docker when Compose is canonical.
- [ ] Use a bounded readiness probe such as `curl --retry ... -sSf`, a datastore-native readiness command, or the repository's health script.
- [ ] Capture baseline state needed for comparison.
- [ ] Inspect logs only after a readiness check fails; do not treat a log string as readiness evidence when a health boundary exists.

## Execute and verify

- [ ] Make one coherent change for the active criterion.
- [ ] Run the smallest affected repository-native test set.
- [ ] Add boundary evidence only for remaining uncertainty.
- [ ] Correlate requests, jobs, logs, and state with a unique non-secret identifier where possible.
- [ ] Compare expected and observed results rather than reporting command success alone.
- [ ] Sanitize logs and outputs before retaining evidence.

## Recover

- [ ] Capture the full bounded error and identify its layer.
- [ ] Classify the failure: discovery/configuration, runtime, fixture/state, implementation, assertion/contract, environment/tooling, or external dependency.
- [ ] Change one hypothesis or condition, then rerun the smallest discriminating check.
- [ ] Spend no more than two focused attempts on the same failure class.
- [ ] Stop before production, destructive, or ambiguous ownership boundaries.

## Review and close

- [ ] Inspect the scoped diff and unrelated worktree changes separately.
- [ ] Run broader canonical lint, typecheck, test, and build checks proportional to risk.
- [ ] Review migrations, authorization, dependency, release, and log impacts when affected.
- [ ] Delete only named PM2 processes, containers, fixtures, and temporary artifacts created for the task.
- [ ] Confirm cleanup rather than assuming commands succeeded.
- [ ] Report each criterion as `VERIFIED`, `FAILED`, or `UNVERIFIED` with its evidence and recovery count.
