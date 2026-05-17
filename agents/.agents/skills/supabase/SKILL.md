---
name: supabase
description: "Integrate Supabase backend services — authentication, database, storage, realtime, edge functions, and local dev via Supabase CLI. Use when: setting up Supabase client, configuring auth providers (email, OAuth, magic link), writing database queries, creating RLS policies, handling file uploads, subscribing to realtime changes, deploying Edge Functions, running local dev with migrations, calling Postgres RPC functions, querying via GraphQL, managing secrets via Vault, or using the Admin API. Triggers on 'setup supabase', 'add auth', 'configure login', 'supabase query', 'RLS policy', 'edge function', 'supabase migrate', 'supabase local', 'gen types', 'rpc call', 'storage bucket', 'signed url', or any Supabase integration task."
---

# Supabase

## Overview

Supabase is an open-source backend-as-a-service providing auth, Postgres database, file storage, realtime subscriptions, and edge functions. All functionality is designed for AI-agent execution: verify via Hurl, curl, psql, and agent-browser instead of language-specific test frameworks.

**Base directory:** `~/.agents/skills/supabase/`

## Quick Start

### Client Setup

```bash
npm install @supabase/supabase-js
```

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import { Database } from './database.types'

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: { autoRefreshToken: true, persistSession: true, detectSessionInUrl: false },
})
```

**Environment variables** (`.env`):
```
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```
For web projects, use `NEXT_PUBLIC_` prefix instead of `EXPO_PUBLIC_`.

### CLI Setup (Local Development)

```bash
supabase init          # create supabase/config.toml
supabase start         # start Postgres + GoTrue + Realtime + Storage + Functions
supabase status        # show local service URLs
```

See `references/supabase-local-dev.md` for full CLI workflow.

## Authentication

### Email / Password

```typescript
const { data, error } = await supabase.auth.signUp({ email, password, options: { data: { full_name } } })
const { data, error } = await supabase.auth.signInWithPassword({ email, password })
await supabase.auth.signOut({ scope: 'local' })  // local | global
```

### OAuth Providers

```typescript
await supabase.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: 'myapp://auth/callback' } })
```

Mobile redirect requires `deep-linking` skill. See `references/supabase-auth-guide.md` for full OAuth setup (Google, Apple, mobile redirects).

### Auth State Listener

```typescript
supabase.auth.onAuthStateChange((event, session) => { /* INITIAL_SESSION | SIGNED_IN | SIGNED_OUT | TOKEN_REFRESHED | USER_UPDATED */ })
```

### Admin API (Service Role)

Server-side only. Requires service_role key:

```typescript
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, { auth: { autoRefreshToken: false, persistSession: false } })
await supabaseAdmin.auth.admin.createUser({ email, password, email_confirm: true, user_metadata: { role: 'premium' } })
await supabaseAdmin.auth.admin.listUsers({ page: 1, perPage: 50 })
await supabaseAdmin.auth.admin.updateUserById(userId, { user_metadata: { ... } })
await supabaseAdmin.auth.admin.deleteUser(userId)
await supabaseAdmin.auth.admin.generateLink({ type: 'magiclink', email })
```

See `references/supabase-auth-guide.md` for Admin API details (CRUD, impersonation, generate links).

## Database Queries

### CRUD + Filters

```typescript
await supabase.from('todos').insert({ title: 'Buy milk', user_id: userId }).select()
await supabase.from('todos').select('id, title, completed, profiles(name)').eq('user_id', userId).order('created_at', { ascending: false }).limit(10)
await supabase.from('todos').update({ completed: true }).eq('id', todoId)
await supabase.from('todos').delete().eq('id', todoId)
```

**Common filters:** `.eq()`, `.neq()`, `.gt()`, `.gte()`, `.lt()`, `.lte()`, `.like()`, `.ilike()`, `.in()`, `.is()`, `.or()`, `.textSearch()`, `.range()` for pagination.

### Row Level Security (RLS)

```sql
CREATE POLICY "select_own" ON todos FOR SELECT USING ((select auth.uid()) = user_id);
CREATE POLICY "insert_own" ON todos FOR INSERT WITH CHECK ((select auth.uid()) = user_id);
```

Never disable RLS for client access. See `references/supabase-data-guide.md` for full filter, join, RLS, and RPC sections.

### Database Functions (RPC)

```sql
CREATE FUNCTION get_top_scores(min_score integer) RETURNS TABLE(player text, score integer)
LANGUAGE sql SECURITY DEFINER AS $$
  SELECT player, score FROM leaderboard WHERE score >= min_score ORDER BY score DESC LIMIT 10;
$$;
```

```typescript
const { data } = await supabase.rpc('get_top_scores', { min_score: 5000 })
```

### GraphQL (pg_graphql)

```bash
curl -X POST https://<project>.supabase.co/graphql/v1 \
  -H "apiKey: <ANON_KEY>" -H "Content-Type: application/json" \
  -d '{"query":"{ profileCollection(first: 3) { edges { node { id username } } } }"}'
```

See `references/supabase-data-guide.md` for RPC, GraphQL, Vault secrets, and error codes.

## Storage

```typescript
// Upload
await supabase.storage.from('avatars').upload(`${userId}/photo.png`, file, { cacheControl: '3600', upsert: true })

// Signed URL (private bucket)
const { data: { signedUrl } } = await supabase.storage.from('avatars').createSignedUrl(filePath, 60)

// Public URL (public bucket)
const { data: { publicUrl } } = supabase.storage.from('public-avatars').getPublicUrl('shared/banner.png')

// Signed Upload URL (two-step)
const { data: { token } } = await supabase.storage.from('uploads').createSignedUploadUrl(filePath)
await supabase.storage.from('uploads').uploadToSignedUrl(filePath, token, file)

// List / Move / Copy / Delete
await supabase.storage.from('avatars').list(userId, { limit: 100, offset: 0 })
await supabase.storage.from('avatars').move('old/path', 'new/path')
await supabase.storage.from('avatars').copy('source/path', 'dest/path')
await supabase.storage.from('avatars').remove([filePath])
```

**Create bucket with constraints:**
```typescript
await supabase.storage.createBucket('avatars', { public: false, allowedMimeTypes: ['image/png'], fileSizeLimit: 2 * 1024 * 1024 })
```

See `references/supabase-storage-guide.md` for signed URLs, resumable TUS uploads, bucket policies, and optimized listing.

## Realtime

### postgres_changes (database change streaming)

```typescript
const channel = supabase.channel('todos-changes')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'todos', filter: `user_id=eq.${userId}` }, (payload) => {})
  .subscribe()
supabase.removeChannel(channel)
```

Requires table in publication: `ALTER PUBLICATION supabase_realtime ADD TABLE todos;`

### Broadcast (arbitrary messages)

```typescript
channel.on('broadcast', { event: 'message_sent' }, (payload) => console.log(payload))
channel.send({ type: 'broadcast', event: 'message_sent', payload: { text: 'Hello' } })
```

### Presence (online user tracking)

```typescript
channel.on('presence', { event: 'sync' }, () => { const state = channel.presenceState() })
await channel.track({ user_id: userId, online_at: new Date().toISOString() })
await channel.untrack()
```

### Private Channels (RLS-protected)

```typescript
// Private channels: the client auto-sends the session JWT via accessToken callback.
// Use setAuth(customJwt) only for non-Supabase tokens. No need to call it for standard auth.
const channel = supabase.channel('room-1', { config: { private: true } })
await channel.subscribe()
```

See `references/supabase-realtime-guide.md` for broadcast, presence, private channel auth, RLS policies, and REST API broadcast.

## Edge Functions

**Function anatomy** (`supabase/functions/hello-world/index.ts`):
```typescript
Deno.serve(async (req) => {
  const { name } = await req.json()
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

**Shared libraries** (`supabase/functions/_shared/`):
```typescript
// supabase/functions/_shared/transform.ts
export function validate(data: any) { ... }

// supabase/functions/process-data/index.ts
import { validate } from '../_shared/transform.ts'
```

**Serve locally:**
```bash
supabase functions serve --env-file .env.local --no-verify-jwt
```

**Deploy:**
```bash
supabase functions deploy hello-world
supabase functions deploy stripe-webhooks --no-verify-jwt   # skip JWT for webhooks
```

**Secrets:**
```bash
supabase secrets set STRIPE_KEY=sk_xxx
supabase secrets set --env-file ./supabase/.env.local
supabase secrets list
```

**Using @supabase/server** (database access with service role):
```typescript
import { withSupabase } from 'npm:@supabase/server'
export const fetch = withSupabase({ auth: 'secret:my-secret' }, async (_req, ctx) => {
  const { data } = await ctx.supabaseAdmin.from('posts').select('*')
  return Response.json(data)
})
```

See `references/supabase-edge-functions.md` for full reference (serve flags, CORS, JWT, @supabase/server patterns).

## Vault (Secrets Management)

```sql
-- Create a secret
SELECT vault.create_secret('sk-api-key-xxx', 'stripe_secret_key', 'Stripe key for webhooks');

-- Read decrypted
SELECT name, decrypted_secret FROM vault.decrypted_secrets WHERE name = 'stripe_secret_key';

-- Update
SELECT vault.update_secret('<uuid>', 'new-value', 'stripe_secret_key');
```

**AI-native verification:** `psql "$SUPABASE_DB_URL" -c "SELECT name, decrypted_secret FROM vault.decrypted_secrets;"`

## Local Development (CLI)

**Complete day-one workflow:**
```bash
supabase login && supabase init && supabase start
supabase migration new initial_schema    # creates timestamp-prefixed SQL file
# edit supabase/migrations/<timestamp>_initial_schema.sql
supabase migration up                     # apply migrations to local DB
supabase gen types --local > lib/database.types.ts
```

**Key commands:**

| Command | Purpose |
|---------|---------|
| `supabase start` / `supabase stop` | Start/stop local stack |
| `supabase status` | Show local service URLs |
| `supabase link --project-id <ref>` | Link to remote project |
| `supabase migration new <name>` | Create migration file |
| `supabase migration up` | Apply pending migrations |
| `supabase db reset` | Reset + re-run all migrations & seed |
| `supabase db diff -f <name>` | Auto-generate migration from changes |
| `supabase db push` | Push migrations to remote |
| `supabase gen types --local` | Generate TypeScript types |

See `references/supabase-local-dev.md` for detailed CLI reference (diff engines, seed data, type gen with lang flags).

## AI-Native Verification

All Supabase features should be verified using the universal toolkit, not language-specific test frameworks:

| Feature | Tool | Playbook |
|---------|------|----------|
| Auth flows | `hurl` | `playbooks/auth-flow.hurl` |
| Storage operations | `hurl` | `playbooks/storage-crud.hurl` |
| GraphQL queries | `hurl` / `curl` | `playbooks/graphql-query.hurl` |
| Realtime presence | `wscat` | `playbooks/presence-subscribe.sh` |
| Database state | `psql` | Direct `psql -c "SELECT ..."` |
| Storage E2E | shell script | `scripts/verify-storage.sh` |
| Connection | shell script | `scripts/verify-connection.sh` |
| Edge Functions | `hurl` / `curl` | Test via `supabase functions serve` then `hurl` |
| Auth UI | `agent-browser` | Navigate signup/login forms |

**Verification pattern:**
```bash
# API: hurl playbook
hurl --variable SUPABASE_URL=$SUPABASE_URL --variable SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY playbooks/auth-flow.hurl

# Database: psql pipe to jq
psql "$SUPABASE_DB_URL" -c "SELECT json_agg(t) FROM (SELECT id, email FROM auth.users LIMIT 5) t;" | jq

# Storage: shell script
SUPABASE_URL=$SUPABASE_URL SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY scripts/verify-storage.sh
```

## Composing with Other Skills

| Skill | Composition |
|-------|-------------|
| `react-native-expo` | Expo provides native shell; Supabase provides backend. Use `expo-secure-store` for session storage. |
| `deep-linking` | OAuth and magic-link flows require custom URL scheme redirect (e.g., `myapp://auth/callback`). |
| `native-datastore-verifier` | Verify Supabase data changes by querying via `psql` or Supabase REST API. |
| `mailpit-email-testing` | Capture Supabase auth emails (confirmation, password reset) in local dev without real SMTP. |
| `ai-native-workflow` | Use Hurl, agent-browser, psql, and shell scripts for all verification. Never Jest/pytest for integration tests. |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Disable RLS for client queries | Write proper RLS policies per table |
| Store `SUPABASE_SERVICE_ROLE_KEY` in client code | Keep service role key on server-only (Edge Functions, backend) |
| Use `select('*')` on large tables | Select only needed columns |
| Forget to handle `error` from queries | Always destructure and check `{ data, error }` |
| Create a new client per component | Export a singleton client from `lib/supabase.ts` |
| Use `localStorage` for session on native | Use `expo-secure-store` via custom storage adapter |
| Skip `autoRefreshToken` option | Always enable auto-refresh to prevent expired tokens |
| Deploy Edge Functions without local test | `supabase functions serve` first, test with `hurl` |
| Store secrets in Edge Function code | Use `supabase secrets set` or Vault extension |
| Poll for real-time updates | Use Realtime Broadcast + Presence |
| Use `offset`-based pagination for large datasets | Use cursor-based pagination (GraphQL) or custom RPC |
| Skip local dev setup | Always `supabase start` + `supabase db reset` for reproducible state |
| Write Jest/pytest for integration tests | Use Hurl (API), psql (DB), agent-browser (UI), shell scripts (E2E) |

## References

- `references/supabase-auth-guide.md` — Auth flows: email, OAuth, magic link, session management, Admin API
- `references/supabase-data-guide.md` — Query patterns, filters, joins, RLS, RPC functions, GraphQL, Vault secrets, error codes
- `references/supabase-storage-guide.md` — Signed URLs, resumable TUS uploads, bucket management, RLS policies, optimized listing
- `references/supabase-realtime-guide.md` — Broadcast, presence, private channels, RLS authorization, REST API broadcast
- `references/supabase-edge-functions.md` — Function anatomy, shared libs, serve, deploy, secrets, @supabase/server, CORS
- `references/supabase-local-dev.md` — CLI init/start/stop, migrations, seed, diff, link, type generation, complete workflow
- `assets/config-templates/supabase-client.ts` — Client initialization with typed database
- `assets/config-templates/auth-middleware.ts` — Auth state hook/provider for React
- `assets/edge-function-templates/create-upload-token/index.ts` — Signed upload token Edge Function
- `scripts/verify-connection.sh` — Test Supabase connectivity
- `scripts/verify-storage.sh` — E2E storage operations verification
- `playbooks/auth-flow.hurl` — Hurl playbook: signup → login → user → logout
- `playbooks/storage-crud.hurl` — Hurl playbook: create bucket → upload → list → signed URL → delete
- `playbooks/graphql-query.hurl` — Hurl playbook: GraphQL query via pg_graphql
- `playbooks/presence-subscribe.sh` — Shell script: WebSocket presence verification via wscat
