# Runtime Evidence Practices

## Contents

- [Evidence depth](#evidence-depth)
- [Project knowledge](#project-knowledge)
- [Runtime operations](#runtime-operations)
- [Recovery discipline](#recovery-discipline)
- [Anti-patterns](#anti-patterns)

## Evidence depth

Use the shallowest layer that proves the criterion:

1. Existing unit or component test for local logic.
2. Existing integration test for established boundaries.
3. Protocol or UI operator for externally observable behavior.
4. Direct datastore, log, metric, or trace evidence when the earlier layers cannot prove the side effect or failure cause.

Do not count multiple assertions over the same mocked path as independent evidence. Do not add a new testing framework when the repository already has an adequate one.

## Project knowledge

Treat project instructions as a durable operational contract, not a session notebook. Persist only commands and safety facts that were verified during real work. Never persist secrets, tokens, PIDs, container IDs, temporary ports, or guesses.

Treat executable repository configuration as a correction signal. When an instruction conflicts with a manifest, Compose file, or CI workflow, verify the executable source and update the instruction only if project onboarding is in scope.

Use `.agents/project-capabilities.yaml` only when machine-readable topology pays for its maintenance cost, such as a monorepo, several services/datastores, web plus mobile surfaces, or repeated multi-agent sessions.

## Runtime operations

- Prefer repository health/readiness endpoints over log parsing.
- Bound network calls, receive loops, polling, and log capture.
- Use named PM2 processes for application servers only when PM2 matches project policy.
- Use targeted Docker Compose services and project-scoped teardown.
- Preserve baseline state and use unique fixture identifiers.
- Never dump process environments, authenticated URLs, or complete configuration while diagnosing.

## Recovery discipline

A retry is justified only after changing a hypothesis, configuration, fixture, implementation, or external condition. Record the failure class and the new discriminating check. After two failed focused attempts in one class, stop that branch and report the evidence instead of widening changes blindly.

## Anti-patterns

| Anti-pattern | Replace with |
|---|---|
| Guessing start or test commands | Current verified project instructions; escalate to sourced discovery only when needed |
| Starting every Compose service | Only services required by acceptance evidence |
| Declaring success from exit code alone | Expected-versus-observed evidence |
| Grepping logs as a health check | Bounded readiness boundary |
| Retrying unchanged commands | Classified recovery with a changed hypothesis |
| Rewriting all agent instructions from discovery output | Minimal patch of durable verified facts through `project-onboarding` |
| Loading every related skill | Capability-map selection for affected surfaces |
| Leaving app processes or fixtures behind | Targeted cleanup plus cleanup verification |
| Hiding blocked checks | Explicit `UNVERIFIED` criterion |
