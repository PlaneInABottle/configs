---
name: websocket-testing
description: Test WebSocket connection, authentication, framing, messaging, disconnect, reconnection, timeout, ordering, and subscription behavior. Use for bidirectional APIs or clients whose correctness depends on WebSocket lifecycle and delivery semantics.
---

# WebSocket Testing

Verify observable protocol behavior with bounded commands. A successful connection alone does not prove messaging, heartbeat, or reconnection correctness.

## Preflight

- Confirm the URL, subprotocol, authentication method, and expected message schema from local configuration.
- Prefer headers or cookies for credentials. Use query tokens only when the client protocol requires them, and account for URL logging.
- Verify `wscat` or `websocat` is installed before selecting examples.

## Workflow

1. Connect with a bounded timeout and expected subprotocol.
2. Send one uniquely correlated message.
3. Assert the corresponding response or durable side effect.
4. Test malformed, unauthorized, and unsupported messages.
5. Force a disconnect and observe the actual application client's reconnect delay, subscription restoration, and duplicate handling.
6. Verify close codes, ordering guarantees, heartbeat behavior, and cleanup.

```bash
printf '%s\n' '{"type":"ping","id":"case-123"}' |
  websocat -n1 -H="Authorization: Bearer ${TEST_TOKEN}" "${WS_URL}"
```

Use a project-native test when reconnect logic lives inside an SDK or application client. Reopening a CLI connection repeatedly is not a reconnection test.

## Assertions

- Bound every receive with a timeout.
- Correlate request and response IDs.
- Verify pong or application heartbeat data rather than sleeping and declaring success.
- Check duplicate delivery and idempotency after reconnect.
- Confirm subscriptions are restored once, not multiplied.
- Inspect close code and reason for expected server shutdowns.

## Guardrails

- Never print access tokens or complete authenticated URLs.
- Do not disable TLS verification outside an explicitly isolated local environment.
- Distinguish WebSocket protocol behavior from broker delivery guarantees.
