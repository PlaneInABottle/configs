# Supabase Edge Functions

## Contents

- [Structure](#structure)
- [Local Development](#local-development)
- [Authentication](#authentication)
- [Database Access](#database-access)
- [CORS](#cors)
- [Secrets](#secrets)
- [Deployment](#deployment)

## Structure

Keep each function under `supabase/functions/<name>/index.ts` and reusable code under `_shared/`.

```typescript
Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const body = await req.json();
  return Response.json({ received: body });
});
```

Validate input before using it and avoid returning raw internal errors.

## Local Development

```bash
supabase start
supabase functions serve hello-world --env-file ./supabase/.env.local
```

Keep JWT verification enabled unless the handler implements and tests an alternative authentication mechanism. Test through the same headers and payload shape used in production.

## Authentication

For user-authenticated functions, read the bearer token and ask Supabase Auth for the user:

```typescript
import { createClient } from 'jsr:@supabase/supabase-js@2';

const authHeader = req.headers.get('Authorization');
if (!authHeader?.startsWith('Bearer ')) {
  return Response.json({ error: 'Unauthorized' }, { status: 401 });
}

const admin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);
const { data: { user }, error } = await admin.auth.getUser(
  authHeader.slice('Bearer '.length),
);
if (error || !user) return Response.json({ error: 'Unauthorized' }, { status: 401 });
```

Webhook endpoints may disable gateway JWT verification only when they verify the provider signature before processing the body. Record that decision in `supabase/config.toml` or the reviewed deployment configuration rather than relying on an ad hoc command flag.

## Database Access

- Use a user-scoped client when RLS should apply.
- Use the service-role key only in trusted server code after explicit authorization.
- Select only required columns and handle Supabase errors before returning.
- Do not use undocumented wrapper packages as a default pattern.

## CORS

Browser-callable functions must handle `OPTIONS` and include CORS headers on success and error responses.

```typescript
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
```

Restrict origins when the deployment has a known browser origin.

## Secrets

```bash
supabase secrets set --env-file ./supabase/.env.production
supabase secrets list
```

- Ensure the environment file is ignored and access-controlled.
- Do not place values directly in examples, shell history, logs, or error responses.
- `secrets list` should be used only to verify names and metadata, not values.

## Deployment

```bash
supabase functions deploy hello-world
```

Before deployment, confirm the linked project, authentication mode, environment variables, and local test result. Verify current CLI flags with `supabase functions deploy --help` instead of copying version-sensitive flags.
