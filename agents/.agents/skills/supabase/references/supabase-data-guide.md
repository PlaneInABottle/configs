# Supabase Data Guide

## CRUD Operations

```typescript
// Insert single row
const { data, error } = await supabase
  .from('posts')
  .insert({ title: 'Hello', body: 'World', user_id: userId })
  .select('id, title, created_at'); // return specific columns

// Insert multiple rows
await supabase.from('posts').insert([
  { title: 'Post 1', body: 'Body 1', user_id: userId },
  { title: 'Post 2', body: 'Body 2', user_id: userId },
]);

// Select
const { data, error } = await supabase
  .from('posts')
  .select('id, title, created_at')
  .eq('user_id', userId);

// Update
await supabase
  .from('posts')
  .update({ title: 'Updated' })
  .eq('id', postId);

// Delete
await supabase
  .from('posts')
  .delete()
  .eq('id', postId);
```

## Filters

```typescript
// Equality
.eq('status', 'active')
.neq('status', 'deleted')

// Comparison
.gt('views', 100)
.gte('views', 100)
.lt('views', 1000)
.lte('views', 1000)

// Pattern matching
.like('title', '%TypeScript%')       // case-sensitive
.ilike('title', '%typescript%')      // case-insensitive

// List membership
.in('role', ['admin', 'editor', 'moderator'])

// NULL checks
.is('deleted_at', null)

// Range
.gte('created_at', '2025-01-01')
.lte('created_at', '2025-12-31')

// Logical OR
.or('status.eq.draft,status.eq.published')

// Full-text search (requires tsvector column)
.textSearch('title', "'hello' & 'world'", { type: 'plain' })
```

## Pagination

```typescript
// Using range
const PAGE = 2;
const PER_PAGE = 20;
const { data } = await supabase
  .from('posts')
  .select('*')
  .order('created_at', { ascending: false })
  .range(PAGE * PER_PAGE, (PAGE + 1) * PER_PAGE - 1);
```

## Joins (Embedded Relations)

```typescript
// Single foreign key
.select('*, author:profiles(name, avatar_url)')

// One-to-many
.select('*, comments(*)')

// Many-to-many via junction table
.select('*, post_tags(tag:tags(name))')

// Deep nesting
.select(`
  id, title,
  author:profiles(name, email),
  comments(id, body, author:profiles(name))
`)
```

Foreign keys are auto-detected. Use `!inner` to exclude rows with no match:
```typescript
.select('*, comments!inner(id)') // only posts with comments
```

## Row Level Security (RLS) Policies

Enable RLS on all tables accessed from the client:

```sql
-- Enable
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Users can only select their own rows
CREATE POLICY "select_own_todos" ON todos
  FOR SELECT USING ((select auth.uid()) = user_id);

-- Users can only insert rows where user_id matches them
CREATE POLICY "insert_own_todos" ON todos
  FOR INSERT WITH CHECK ((select auth.uid()) = user_id);

-- Users can only update their own rows
CREATE POLICY "update_own_todos" ON todos
  FOR UPDATE USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

-- Users can only delete their own rows
CREATE POLICY "delete_own_todos" ON todos
  FOR DELETE USING ((select auth.uid()) = user_id);

-- Public read, authenticated write
CREATE POLICY "public_read" ON posts
  FOR SELECT USING (true);
CREATE POLICY "auth_insert" ON posts
  FOR INSERT WITH CHECK ((select auth.uid()) IS NOT NULL);

-- Role-based access
CREATE POLICY "admin_all" ON posts
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

**Key functions in policies:**
- `auth.uid()` — current user ID
- `auth.role()` — current user role (usually `authenticated` or `anon`)
- `auth.email()` — current user email

## TypeScript Types from Schema

Generate types from your project:
```bash
npx supabase gen types typescript --project-id <ref> > lib/database.types.ts
```

Use with client:
```typescript
import { Database } from './database.types';
const supabase = createClient<Database>(url, key);

// Typed queries — data and error are fully typed
const { data } = await supabase.from('posts').select('id, title');
// data type: { id: number; title: string }[] | null
```

## Error Handling Pattern

```typescript
const { data, error } = await supabase.from('posts').select('*');

if (error) {
  console.error('Supabase error:', error.message, error.code);
  // 'PGRST116' = not found, '23505' = unique violation
  throw error;
}
```

## Row Count (no data returned)

```typescript
const { count } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true })
  .eq('status', 'published');
```

## Database Functions (RPC)

Define Postgres functions, then call them with `supabase.rpc()`.

```sql
-- Scalar return
CREATE FUNCTION hello_world() RETURNS text
LANGUAGE sql AS $$ SELECT 'Hello, World!'::text $$;

-- Table return with parameter
CREATE FUNCTION get_top_scores(min_score integer)
RETURNS TABLE(player text, score integer)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT player, score FROM leaderboard
  WHERE score >= min_score
  ORDER BY score DESC LIMIT 10;
$$;

-- PL/pgSQL with error handling
CREATE FUNCTION calculate_discount(customer_id uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  discount numeric;
BEGIN
  SELECT SUM(amount) * 0.1 INTO discount
  FROM orders WHERE customer_id = calculate_discount.customer_id;
  RETURN discount;
END;
$$;
```

Call from client:

```typescript
const { data, error } = await supabase.rpc('get_top_scores', {
  min_score: 5000,
})
// data = [{ player: 'alice', score: 9001 }, ...]
```

Via REST (useful for AI-native Hurl verification):

```bash
curl -X POST 'https://<project>.supabase.co/rest/v1/rpc/get_top_scores' \
  -H "apikey: sb_publishable_..." \
  -H "Content-Type: application/json" \
  -d '{"min_score": 5000}'
```

**Best practices:**
- `SECURITY DEFINER` runs as the function owner (bypasses RLS — use with caution)
- `SECURITY INVOKER` runs as the calling user (respects RLS)
- Always validate inputs inside the function
- Use `RAISE EXCEPTION` for error cases

## GraphQL (pg_graphql)

Supabase exposes Postgres tables via GraphQL using the `pg_graphql` extension.

**Enable (one-time):**
```sql
CREATE EXTENSION pg_graphql;
```

**Query endpoint:** `POST https://<project>.supabase.co/graphql/v1`

**Query example:**
```graphql
query {
  profileCollection(first: 10) {
    edges {
      node {
        id
        username
        bio
        avatarUrl
      }
    }
  }
}
```

**Using curl (AI-native verification):**
```bash
curl -X POST https://<project>.supabase.co/graphql/v1 \
  -H "apiKey: <ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ profileCollection(first: 3) { edges { node { id username } } } }"}'
```

The schema is auto-generated from Postgres tables, foreign keys, and views. Follows the Relay Connection specification for pagination.

## Vault (Secrets Management)

The Vault extension stores encrypted secrets that only the database can decrypt.

**Enable (one-time):**
```sql
CREATE EXTENSION IF NOT EXISTS "vault";
```

**Create a secret:**
```sql
SELECT vault.create_secret('sk-api-key-xxx', 'stripe_secret_key', 'Stripe key for webhooks');
-- Returns UUID: "c9b00867-ca8b-44fc-a81d-d20b8169be17"
```

**Read a decrypted secret:**
```sql
SELECT name, decrypted_secret FROM vault.decrypted_secrets
WHERE name = 'stripe_secret_key';
```

**Use in a database function:**
```sql
CREATE FUNCTION call_stripe_api(payload jsonb) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  api_key text;
  result jsonb;
BEGIN
  SELECT decrypted_secret INTO api_key
  FROM vault.decrypted_secrets WHERE name = 'stripe_secret_key';

  SELECT net.http_post(
    url := 'https://api.stripe.com/v1/charges',
    headers := jsonb_build_object('Authorization', 'Bearer ' || api_key),
    body := payload
  ) INTO result;

  RETURN result;
END;
$$;
```

**Update a secret:**
```sql
SELECT vault.update_secret('<uuid>', 'new-key-value', 'stripe_secret_key');
```

**AI-native verification with psql:**
```bash
psql "$SUPABASE_DB_URL" -c "SELECT name, decrypted_secret FROM vault.decrypted_secrets;"
```

## Common Error Codes

| Code | Meaning | Mitigation |
|------|---------|-----------|
| `PGRST116` | Not found (empty result) | Check filter conditions |
| `PGRST200` | Requested range not satisfiable | Adjust `Range` header values |
| `PGRST204` | No content (successful insert/update without `.select()`) | Add `.select()` to return values |
| `23505` | Unique violation (duplicate key) | Use `ON CONFLICT` or upsert |
| `23503` | Foreign key violation | Ensure referenced record exists |
| `42P01` | Relation does not exist | Check table name and schema |
| `42501` | Permission denied (RLS blocked) | Check RLS policies |
| `25P02` | Transaction aborted | Catch and handle previous error |
| `42703` | Column does not exist | Check column spelling and schema
