---
name: mailpit-email-testing
description: "Verify email-driven development and test flows against Mailpit or a similar local inbox capture service. Use when checking signup, password reset, invite, magic-link, or notification emails; inspecting captured inbox state; extracting links or tokens from messages; asserting HTML/text content or attachments; or polling a local email inbox conservatively during development and end-to-end testing."
---

# Mailpit Email Testing

Verify email-driven flows against a local inbox capture service without assuming a specific project setup.

## Run local preflight checks

- Verify the inbox capture base URL from project config or environment before using examples; do not assume `http://localhost:8025` unless you have confirmed it locally.
- Check reachability first with a simple HTTP request such as `curl -fsS "$MAILPIT_BASE_URL/api/v1/info"`.
- Prefer API-based assertions over scraping the Mailpit UI.
- If Mailpit is absent, unreachable, or protected by auth you do not have, stop and report that state instead of inventing setup details.

## Follow the smallest reliable workflow

1. Start from an isolated mailbox state only when the test needs it.
2. Trigger the signup, reset, invite, or other app action that should send mail.
3. Poll conservatively for the expected message instead of sleeping blindly.
4. Select the target message by recipient, subject, or search query.
5. Extract the verification link, OTP, or token from text, HTML, or raw content.
6. Assert the subject, recipients, body content, and attachment presence.
7. Load [references/mailpit-api-queries.md](references/mailpit-api-queries.md) for availability, search, and cleanup commands.
8. Load [references/mailpit-flow-checks.md](references/mailpit-flow-checks.md) for signup/reset/invite recipes, token extraction, and polling patterns.

## Keep the skill conservative

- Use Mailpit-specific endpoints only when you have confirmed Mailpit is the service in use; otherwise adapt the same workflow to the local inbox tool that is actually present.
- Prefer stable text, recipient, and URL assertions over brittle full-HTML snapshots.
- Keep polling loops short and bounded; surface timeout context instead of retrying indefinitely.
