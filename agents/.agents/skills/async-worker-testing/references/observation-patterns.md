# Async Worker Observation Patterns

## Table of contents

- Waiting for side effects safely
- Log and state correlation

## Waiting for side effects safely

- Prefer polling for a concrete state transition over fixed sleeps.
- Keep waits bounded and report timeout context.
- Poll the narrowest reliable interface:
  - HTTP read model
  - database query
  - filesystem check
  - queue or DLQ inspection
  - webhook sink or mail sink
- If you must use logs during the wait, treat them as progress signals and still finish with a durable assertion.

Minimal polling shape:

```bash
deadline=$((SECONDS + 30))
until <side-effect-check-command>; do
  [ "$SECONDS" -ge "$deadline" ] && break
  sleep 1
done
```

## Log and state correlation

- Use the same correlation value everywhere you can: producer payload, worker log, database row, outbound request, and dead-letter record.
- When multiple workers can race, capture worker identity, partition, queue shard, or consumer group details if exposed.
- Build a short failure report containing:
  - correlation value
  - enqueue outcome
  - last observed queue state
  - last observed worker log line
  - side-effect status
  - retry or DLQ status
- If any link in the chain cannot be observed, label that boundary unverified instead of filling gaps from assumptions.
