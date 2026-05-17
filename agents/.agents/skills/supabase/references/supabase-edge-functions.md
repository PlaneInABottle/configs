# Supabase Edge Functions

- [Function anatomy](#function-anatomy)
- [Shared libraries](#shared-libraries)
- [Local development](#local-development)
- [Deploy](#deploy)
- [Secrets management](#secrets-management)
- [JWT verification](#jwt-verification)
- [Using @supabase/server](#using-supabaseserver)
- [Response helpers](#response-helpers)
- [CORS headers](#cors-headers)

## Function anatomy

Basic Deno serverless function under `supabase/functions/`:

```typescript
// supabase/functions/hello-world/index.ts
Deno.serve(async (req) => {
  const { name } = await req.json();
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

Each function lives in its own directory (`supabase/functions/<name>/index.ts`) and gets deployed independently.

## Shared libraries

Place common code in `supabase/functions/_shared/` and import via relative paths:

```typescript
// supabase/functions/_shared/transform.ts
export function validate(data: any): boolean {
  return data !== null && typeof data === "object";
}
```

```typescript
// supabase/functions/process-data/index.ts
import { validate } from "../_shared/transform.ts";

Deno.serve(async (req) => {
  const body = await req.json();
  if (!validate(body)) {
    return new Response(JSON.stringify({ error: "Invalid payload" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  return new Response(JSON.stringify({ ok: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

The `_shared/` directory is not deployed as a function — it is only available as an import target. Keep shared types, validators, and utilities here.

## Local development

```bash
supabase functions serve                                 # serve all functions
supabase functions serve hello-world                     # serve a single function
supabase functions serve --env-file .env.local           # load environment variables
supabase functions serve --no-verify-jwt                 # disable JWT verification
supabase functions serve --inspect                       # debug with Chrome DevTools
```

Make sure the local Supabase stack is started first: `supabase start`.

## Deploy

```bash
supabase functions deploy hello-world                    # deploy a single function
supabase functions deploy hello-world --no-verify-jwt    # skip JWT for webhooks
```

Deployments are linked to the linked Supabase project. Use `supabase link --project-ref <ref>` first if not already linked.

## Secrets management

Secrets are environment variables injected into every function at runtime:

```bash
supabase secrets set MY_API_KEY=value                    # set a single secret
supabase secrets set --env-file ./supabase/.env.local    # bulk from file
supabase secrets list                                    # list all secret names
supabase secrets delete MY_API_KEY                       # delete a secret
```

All secrets are exposed to all functions in the project. Use `--env-file` for local overrides without deploying secrets.

## JWT verification

By default, every function verifies the incoming JWT. The platform validates the token before the handler runs.

```typescript
Deno.serve(async (req) => {
  // Authorization: Bearer <token>
  const authHeader = req.headers.get("Authorization");

  // JWT is verified automatically — handler only reaches here for valid tokens
  // Use @supabase/server to extract the authenticated user
});
```

Pass `--no-verify-jwt` during deploy for webhook endpoints (Stripe, Clerk, etc.) where the caller provides its own signature instead of a Supabase JWT:

```bash
supabase functions deploy stripe-webhook --no-verify-jwt
```

## Using @supabase/server

`npm:@supabase/server` provides a `withSupabase` wrapper for database access with service-role privileges:

```typescript
import { withSupabase } from "npm:@supabase/server";

interface Row {
  id: string;
  title: string;
}

export const fetch = withSupabase(
  { auth: "secret:my-secret" },
  async (_req: Request, ctx) => {
    const { data } = await ctx.supabaseAdmin
      .from("posts")
      .select("*")
      .returns<Row[]>();

    return Response.json(data);
  },
);
```

The `auth` option accepts:
- `secret:<name>` — uses a secret stored via `supabase secrets set` as the Supabase service-role key
- `service-role` — uses the project's built-in `service_role` key (set during `supabase link`)

`ctx.supabaseAdmin` is a pre-authenticated Supabase client with full row-level access (bypasses RLS). Use it sparingly and never expose it to end users.

## Response helpers

```typescript
// JSON success
return new Response(JSON.stringify({ data: results }), {
  status: 200,
  headers: { "Content-Type": "application/json" },
});

// JSON error
return new Response(JSON.stringify({ error: "Not found" }), {
  status: 404,
  headers: { "Content-Type": "application/json" },
});

// No content
return new Response(null, { status: 204 });
```

Always set `Content-Type: application/json` for JSON responses. Always return a meaningful HTTP status code.

## CORS headers

For functions called from browser clients, set CORS headers in every response:

```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
};

Deno.serve(async (req) => {
  // Handle preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const data = { ok: true };
  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
```

Centralize `corsHeaders` in a `_shared/cors.ts` file when multiple functions need it.
