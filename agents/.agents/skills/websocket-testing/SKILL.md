---
name: websocket-testing
description: Test WebSocket connection, authentication, framing, messaging, disconnect, reconnection, timeout, ordering, heartbeat, and subscription behavior. Use for bidirectional APIs or clients whose correctness depends on WebSocket lifecycle and delivery semantics.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# WebSocket Testing

Verify observable lifecycle and delivery behavior with bounded commands. A successful handshake alone does not prove messaging, heartbeat, reconnection, or subscription correctness.

## Preflight

- Confirm URL, TLS, subprotocol, authentication method, expected message schema, close codes, heartbeat contract, and delivery guarantees from local sources.
- Prefer headers or cookies for credentials. Use query tokens only when the client protocol requires them and account for URL logging.
- Prove server readiness and verify `websocat`, `wscat`, or the repository-native client is available.

## Discovery

Inspect server/client configuration, tests, reconnect policy, subscription restoration, correlation fields, and broker boundaries. Use a project-native client test when reconnect logic lives in the SDK/application; repeatedly reopening a CLI is not a reconnection test.

## Execute

1. Connect with a bounded timeout and expected subprotocol.
2. Send one uniquely correlated message and assert its response or durable side effect.
3. Test malformed, unauthorized, unsupported, oversized, and timed-out messages required by the contract.
4. Force a disconnect and observe actual client backoff, reconnect limit, auth refresh, subscription restoration, ordering, and duplicate/idempotency handling.
5. Verify heartbeat data and expected close code/reason rather than sleeping and declaring success.

Example when `websocat` matches the protocol:

```bash
printf '%s\n' '{"type":"ping","id":"case-123"}' |
  websocat -n1 -H="Authorization: Bearer ${TEST_TOKEN}" "${WS_URL}"
```

Bound every receive and keep authenticated URLs out of output.

## Evidence

Record revision, client/tool version, subprotocol, sanitized auth mode, correlation ID, sent frame, expected/observed frame or side effect, timing/backoff, ordering, duplicate count, close code/reason, and cleanup status.

## Recovery

- Classify failures as handshake/TLS, auth, framing/schema, timeout/heartbeat, server delivery, client reconnection, subscription restoration, or broker side effect.
- Make at most two focused attempts per class and rerun the smallest correlated case.
- Distinguish WebSocket protocol behavior from downstream broker guarantees; load `async-worker-testing` for the latter.

## Cleanup

Close all client sessions, remove test subscriptions/messages/fixtures, stop only runtime processes started for the test, and confirm no reconnect loop remains active.

## Stop Conditions

Stop when receives cannot be bounded, credentials would be exposed, the target is destructive production, reconnect behavior cannot be exercised through the real client, or delivery truth depends on an unavailable downstream system.

## Destructive Boundaries

Do not disable TLS verification outside an isolated local environment, flood shared channels, force-disconnect unrelated users, purge broker state, or log complete access tokens/authenticated URLs.
