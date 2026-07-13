# Supabase Push Delivery

## Contents

- [Boundary](#boundary)
- [Token Table](#token-table)
- [Edge Function](#edge-function)
- [Tickets and Receipts](#tickets-and-receipts)
- [Retries](#retries)

## Boundary

Use a trusted Supabase Edge Function or worker to send notifications. Authenticate the caller or verify the database webhook signature, and keep the Supabase service-role key and optional Expo access token in function secrets.

## Token Table

Store one row per installation with at least user ID, Expo push token, platform, enabled state, and timestamps. Enable RLS so users can manage only their own registrations; reserve bulk reads and cleanup for trusted server code.

Use a uniqueness constraint on the token and update `last_seen_at` when the app confirms registration.

## Edge Function

1. Validate the incoming notification request and authorize its target user or audience.
2. Select enabled tokens through a server-only client.
3. Build payloads with validated data and current Expo limits.
4. Send bounded batches to the Expo Push API.
5. Persist successful ticket IDs with their token mapping.
6. Return a correlation ID rather than logging token values.

If Expo push access-token security is enabled, send the token in the documented authorization header and keep it in Supabase secrets.

## Tickets and Receipts

Push tickets confirm that Expo accepted each message; they do not prove device delivery. Fetch receipts later using successful ticket IDs.

- Handle immediate malformed-message or credential errors from tickets.
- Handle `DeviceNotRegistered` from the authoritative ticket or receipt and disable the mapped token.
- Treat project-level credential errors as configuration failures, not reasons to delete every device token.
- Retain enough ticket-to-token mapping to perform safe receipt cleanup.

## Retries

- Retry only transient network errors, `429`, and documented server failures.
- Use bounded exponential backoff with jitter and honor `Retry-After` when provided.
- Do not retry malformed payloads, invalid credentials, or permanently unregistered devices.
- Make sends idempotent with a notification or delivery ID so worker retries do not create uncontrolled duplicates.

Verify current batch sizes, receipt windows, and error names in Expo's official push-service documentation before implementation.
