---
name: supabase
description: Integrate and verify Supabase authentication, Postgres data and RLS, Storage, Realtime, Edge Functions, local development, migrations, and server-side administration. Use when a project already uses Supabase or the user explicitly chooses it; verify fast-moving SDK and CLI details against current official documentation.
---

# Supabase

Inspect the project SDK version, generated types, migrations, RLS policies, and local configuration before adding new patterns. Keep anonymous/publishable keys client-side and service-role or secret keys server-only.

## Client Setup

Use the platform-appropriate client configuration:

- Web: configure the framework's supported cookie/session integration.
- React Native: provide a supported storage adapter, enable refresh and persistence, disable URL auto-detection, and manage foreground/background refresh when required by the current SDK docs.
- Server: create a request-scoped or server-only client and never expose service-role credentials.

Load [assets/config-templates/supabase-client.ts](assets/config-templates/supabase-client.ts) only for Expo/React Native projects. Use [assets/config-templates/auth-middleware.tsx](assets/config-templates/auth-middleware.tsx) as a provider starting point after connecting it to the project's router and error handling.

## Authentication

- Use PKCE for native OAuth flows.
- Build the redirect URL with the platform's linking utility and allowlist it in Supabase Auth settings.
- Exchange the returned authorization code exactly once and handle both cold-start and already-running callbacks.
- Do not mix implicit fragment-token examples with PKCE code exchange.
- Test email flows with a confirmed local inbox service when available.

Load [references/supabase-auth-guide.md](references/supabase-auth-guide.md) for current project-specific patterns.

## Data and RLS

- Enable RLS before granting client access.
- Test policies as anonymous and authenticated users, not only as the database owner.
- Keep `SECURITY DEFINER` functions exceptional: set a safe `search_path`, schema-qualify objects, and restrict execute privileges.
- Prefer migrations for schema changes and inspect generated diffs before applying them.
- Run `supabase db reset` only against a confirmed disposable local database.

Load [references/supabase-data-guide.md](references/supabase-data-guide.md) for query, policy, RPC, GraphQL, and Vault details.

## Storage

- Define bucket and object policies before client uploads.
- Use authenticated user tokens for user-scoped operations.
- Use service-role credentials only in trusted server code.
- Use `createSignedUploadUrl` with `uploadToSignedUrl`; do not describe that token as a generic TUS credential unless current docs explicitly support that flow.
- Validate object paths, MIME type, and size server-side.

Load [references/supabase-storage-guide.md](references/supabase-storage-guide.md).

## Realtime

Use `supabase-js` channels for Broadcast, Presence, and Postgres Changes unless the task specifically requires implementing the raw Phoenix protocol. Verify subscription status, remove channels during cleanup, and test reconnection through the actual application client.

Load [references/supabase-realtime-guide.md](references/supabase-realtime-guide.md).

## Edge Functions

- Keep JWT verification enabled by default.
- Disable gateway verification only for endpoints that implement and test another authentication mechanism, such as a verified webhook signature.
- Handle CORS preflight and return CORS headers on error responses when browsers call the function.
- Read secrets from environment variables; never print values.
- Test locally before deployment.

Load [references/supabase-edge-functions.md](references/supabase-edge-functions.md).

## Secret Safety

- Never select or print `vault.decrypted_secrets` as a verification step.
- Verify secret presence with metadata such as name and ID, or exercise the function that consumes the secret while redacting output.
- Avoid putting secret values directly in shell history. Prefer an environment file accepted by the CLI, an interactive prompt, or the platform dashboard.
- Do not include service-role keys in Hurl files, logs, screenshots, or generated artifacts.

## Local Workflow

```bash
supabase init
supabase start
supabase status
supabase migration new <name>
supabase gen types --local > lib/database.types.ts
```

Confirm whether each destructive or remote-affecting command targets local, linked, or hosted state before running it. Load [references/supabase-local-dev.md](references/supabase-local-dev.md) for details.

## Verification

- Extend existing project tests first.
- Use Hurl for explicit API workflows, native datastore inspection for state changes, Mailpit for local auth email, and the application client for Realtime behavior.
- Treat [playbooks/](playbooks/) as examples requiring a disposable environment and explicit user credentials.
- Use [scripts/verify-connection.sh](scripts/verify-connection.sh) for non-destructive reachability only.
- Use [scripts/verify-storage.sh](scripts/verify-storage.sh) only with an existing disposable bucket and authenticated user token.
