---
name: runtime-observability
description: Collect bounded, sanitized runtime evidence from health checks, PM2 or Docker logs, process and container resources, metrics, correlation IDs, and targeted CPU or memory profiles. Use to diagnose unavailable services, crashes, latency, resource regressions, leaks, or behavior that requires runtime logs, metrics, or profiling.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# Runtime Observability

Capture the minimum diagnostic evidence needed to distinguish the current hypotheses. Prefer health, metrics, and correlation over large log dumps.

## Preflight

- Identify runtime ownership, target process/service, expected health boundary, time window, and correlation identifier.
- Define capture limits and redact secrets, personal data, cookies, tokens, authenticated URLs, and process environments.
- Record an idle or pre-change baseline when comparing resources.

## Discovery

Use project runtime instructions first. For PM2, load `pm2-runtime-operator`; for containers inspect the current Compose project. Discover available health/readiness endpoints, structured log fields, metrics endpoints, trace IDs, and language-native profilers before choosing a tool.

Bounded inventory examples:

```bash
pm2 list
docker compose ps
docker stats --no-stream
curl --retry 5 --retry-connrefused --retry-delay 1 --retry-max-time 15 -sSf http://127.0.0.1:3000/health
```

## Execute

1. Reproduce one request/job with a unique non-secret correlation value.
2. Capture only the relevant window:

   ```bash
   pm2 logs <name> --lines 200 --nostream
   docker compose logs --tail 200 <service>
   ```

3. Compare health, resource, metric, and latency observations with baseline.
4. Add a bounded CPU profile, heap snapshot, query plan, or trace only when logs/metrics identify that layer. Use the project's language profiler and document its overhead.
5. Reproduce once after the fix using the same inputs and capture limits.

Do not expose debugger ports on `0.0.0.0` by default. Do not enable database-wide verbose logging merely to inspect one query.

## Evidence

Record revision, process/service name, time window, correlation ID, health observation, bounded log event, relevant metrics/resources, profiler settings, expected versus observed behavior, and pre/post comparison. Reference artifact paths without pasting sensitive payloads.

## Recovery

- Classify missing evidence as wrong process, wrong time window, missing correlation, unavailable health/metrics boundary, profiler incompatibility, or reproduction failure.
- Make at most two focused attempts per class. Narrow or change the capture source rather than increasing every limit.
- If instrumentation changes behavior materially, remove it and use a lower-overhead signal.

## Cleanup

Disable temporary debug flags and instrumentation, close local-only profiler ports, delete sensitive captures that are not required artifacts, and restore the named process through its canonical runtime operator. Confirm application health afterward.

## Stop Conditions

Stop when capture requires production-wide verbose logging, an exposed remote debugger, unbounded logs/traces, privileged host inspection outside scope, or evidence cannot be sanitized safely.

## Destructive Boundaries

Do not restart unrelated processes, delete all PM2 entries, prune containers, alter database-wide logging, kill production traffic, or upload raw diagnostic captures without explicit authorization.
