# Mailpit API queries

## Preflight and availability

Use a configurable base URL and keep examples override-friendly:

```bash
MAILPIT_BASE_URL="${MAILPIT_BASE_URL:-http://localhost:8025}"
```

Confirm the service before triggering mail flows:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/info" | jq .
```

If that fails, stop and report the missing or unreachable service. In this session, `mailpit` was not on `PATH` and `http://localhost:8025/` was not reachable, so treat localhost examples as defaults to verify, not facts to assume.

Use basic auth only when the local instance requires it:

```bash
curl -fsS -u "$MAILPIT_USER:$MAILPIT_PASSWORD" \
  "$MAILPIT_BASE_URL/api/v1/info" | jq .
```

Mailpit documents the `/api/v1/info` endpoint and notes that API requests must use basic auth when the server is configured that way.

## Inbox state and message selection

List messages newest-first:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/messages?limit=20" | jq .
```

Search by recipient, subject, or attachment presence:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\"" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=subject:\"Reset your password\"" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=has:attachment" | jq .
```

Useful documented Mailpit filters include `to:`, `from:`, `subject:`, `has:attachment`, `has:inline`, `is:read`, `before:`, and `after:`.

Delete all messages only when the test needs a clean inbox:

```bash
curl -fsS -X DELETE "$MAILPIT_BASE_URL/api/v1/messages"
```

Delete only a matching slice when broad cleanup would hide parallel activity:

```bash
curl -fsS -X DELETE \
  "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\""
```
