---
name: load-testing
description: Design, execute, and interpret bounded HTTP or service load tests with explicit traffic models, performance thresholds, error budgets, and runtime evidence. Use for latency, throughput, concurrency, soak, spike, capacity, or regression questions when a safe non-production target and measurable criteria are available.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# Load Testing

Measure a stated performance criterion against a controlled target. Do not convert ordinary functional verification into load testing without a performance requirement.

## Preflight

- Confirm the target environment is disposable or explicitly approved for the planned load.
- Define request mix, concurrency or arrival rate, duration, test data, warm-up, latency percentiles, throughput, and allowed error rate before execution.
- Establish a functional baseline and health check first.
- Confirm observability and a stop mechanism are available. Load `runtime-observability` for server-side evidence.

## Discovery

Reuse the repository's existing k6, Gatling, Locust, Artillery, JMeter, `hey`, or `wrk` suite. Inspect CI and package scripts for the canonical invocation. Verify the selected binary with `command -v` and its local `--help`; do not install a second framework merely for preference.

## Execute

1. Run a one-user smoke iteration and validate payloads, auth, response assertions, and fixture isolation.
2. Capture idle/baseline health and resource observations.
3. Run the smallest traffic model that answers the criterion. Examples when those tools already exist:

   ```bash
   k6 run tests/load/smoke.js
   hey -n 200 -c 5 http://127.0.0.1:3000/health
   wrk -t2 -c10 -d15s http://127.0.0.1:3000/api/items
   ```

4. Stop immediately on the predeclared server-error, saturation, or environment-safety threshold.
5. Repeat only to distinguish noise from a reproducible regression; keep the traffic model unchanged for comparisons.

Avoid unbounded shell background loops. Keep credentials out of command history and reports; use the project's secret input mechanism.

## Evidence

Record tool/version, target environment, revision, dataset, traffic model, duration, completed requests, error rate, throughput, configured latency percentiles, server resource observations, and threshold results. A passing command without explicit thresholds is a measurement, not verification.

## Recovery

- Classify failures as target unavailable, invalid scenario, fixture/auth, load-generator saturation, server saturation, or assertion failure.
- Make at most two focused recovery attempts per class and rerun the smoke case before returning to load.
- If the generator is saturated, reduce generator contention or distribute it; do not misreport client limits as server capacity.

## Cleanup

Stop the load generator, delete load-specific fixtures, restore temporary rate-limit or observability configuration, and confirm target health returns to baseline. Retain only sanitized summaries and requested artifacts.

## Stop Conditions

Stop when the target is production without explicit authorization, error/saturation guardrails fire, traffic affects unrelated users, monitoring is unavailable, or results cannot be correlated to the tested revision.

## Destructive Boundaries

Do not load-test destructive endpoints, paid third-party APIs, shared production dependencies, or unbounded data creation without explicit approval and a tested cleanup plan.
