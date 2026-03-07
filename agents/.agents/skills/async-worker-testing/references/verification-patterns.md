# Async Worker Verification Patterns

## Table of contents

- Enqueue or publish verification
- Worker consumption checks
- Retry, backoff, and dead-letter inspection
- Idempotency and duplicate-delivery checks
- Waiting for side effects safely
- Log and state correlation

## Enqueue or publish verification

- Capture the publish input and returned identifier when the producer API exposes one.
- Prefer one probe item at a time before batch tests.
- Verify one of these signals immediately after publish:
  - enqueue API returned success
  - queue depth increased
  - broker metadata shows the new item
  - producer log contains the correlation value
- If none of those signals are observable locally, say the enqueue step is unverified and move to the most reliable downstream signal.

Generic pattern:

```bash
CORRELATION_ID="test-$(date +%s)"
<publish-command-using "$CORRELATION_ID">
<queue-inspect-command> | grep "$CORRELATION_ID"
```

## Worker consumption checks

- Verify consumption with evidence from two sides when possible:
  - broker or queue state changed
  - worker log or durable state changed
- Prefer checking the actual side effect over checking only that the message disappeared from the queue.
- If the worker acknowledges before the side effect is committed, inspect both acknowledgement timing and commit timing separately.

Generic pattern:

```bash
deadline=$((SECONDS + 30))
until <side-effect-check-command>; do
  [ "$SECONDS" -ge "$deadline" ] && break
  sleep 1
done
<worker-log-command> | grep "$CORRELATION_ID"
```

## Retry, backoff, and dead-letter inspection

- Force a known-failing input that is safe and reversible.
- Record:
  - first failure time
  - retry count after each attempt
  - delay or scheduled-next-at timestamp if exposed
  - final terminal state such as discarded, parked, or dead-lettered
- If backoff is configured but not observable directly, compare log timestamps or queue metadata before claiming the delay works.
- For dead-letter checks, confirm both the original work item failed and the terminal copy landed in the expected DLQ or parking area.

Questions to answer:

1. Did the failure increment the retry counter?
2. Was the next attempt delayed instead of retried immediately?
3. After the retry limit, where did the message end up?
4. Is the final state inspectable without reading source code assumptions?

## Idempotency and duplicate-delivery checks

- Re-deliver the same logical message twice with the same idempotency key or business key.
- Confirm the worker either:
  - performs the side effect once, then no-ops duplicates
  - merges duplicates in a documented way
  - emits a detectable duplicate marker without redoing the side effect
- Inspect the real side-effect boundary:
  - duplicate database writes
  - repeated outbound API calls
  - duplicate emails or webhooks
  - repeated file generation

Useful pattern:

```bash
KEY="dup-test-$(date +%s)"
<publish-command-using "$KEY">
<publish-command-using "$KEY">
<side-effect-check-command-for "$KEY">
```
