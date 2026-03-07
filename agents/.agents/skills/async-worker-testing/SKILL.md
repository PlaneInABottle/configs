---
name: async-worker-testing
description: "Validate async queue and worker delivery semantics without assuming broker-specific tooling. Use when verifying publish or enqueue confirmation, worker consumption outcomes, retry or backoff behavior, dead-letter routing, or duplicate-delivery and idempotency handling for background jobs."
---

# Async Worker Testing

Validate async queue and worker behavior by following a bounded, observable workflow: publish work, confirm worker pickup, correlate logs and durable state, and inspect retry or dead-letter outcomes without assuming broker-specific tooling.

## Run local preflight checks

- Verify the application process, worker process, and queue or broker dependency can all be observed before injecting work.
- Confirm only the local binaries your chosen verification path actually needs: container tools such as `docker`, shell helpers such as `jq`, and any broker CLI you plan to use. If a broker-specific CLI is missing, keep commands generic or use another locally verified inspection path instead of inventing support.
- Prefer test data with a unique correlation value such as `job_id`, `message_id`, or `trace_id` so logs, queue state, and side effects can be joined later.
- Define the expected observable outcome before publishing work: database row, API-visible status change, emitted event, file creation, email, webhook, or dead-letter entry.

## Use a bounded verification loop

1. Publish or enqueue one controlled item with a correlation value.
2. Verify the enqueue step returned success or that the queue depth changed in the expected direction.
3. Start a bounded wait loop that polls for the worker outcome or durable side effect instead of sleeping blindly.
4. Correlate worker logs, message metadata, and durable state using the same correlation value.
5. If the item fails, inspect retry counters, next-attempt timing, and dead-letter routing before re-running the case.
6. Clean up test data, reset offsets or queue fixtures only when needed, and record any unverified assumptions.

## Guardrails

- Treat broker-specific commands as patterns unless you verified them locally for the current environment.
- Do not assume exactly-once delivery. Exercise duplicate delivery and confirm idempotency at the side-effect boundary.
- Prefer asserting durable state or externally visible behavior over asserting log lines alone.
- Use bounded polling with explicit timeout and interval values. When the timeout expires, report the last observed queue state, worker log, and side-effect status for that work item.
- When retries use time-based backoff, capture timestamps from logs or metadata so you can distinguish "still waiting" from "stuck."

## Load this reference as needed

- Load [references/verification-patterns.md](references/verification-patterns.md) for enqueue, consumption, retry, and duplicate-delivery checks.
- Load [references/observation-patterns.md](references/observation-patterns.md) for bounded waiting and log or state correlation patterns.
