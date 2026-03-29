---
name: supabase
description: "Integrate Supabase backend services — authentication, database, storage, and realtime subscriptions. Use when: setting up Supabase client, configuring auth providers (email, OAuth, magic link), writing database queries, creating RLS policies, handling file uploads, or subscribing to realtime changes. Triggers on 'setup supabase', 'add auth', 'configure login', 'supabase query', 'RLS policy', or any Supabase integration task."
---

# Supabase

## Overview

Supabase is an open-source backend-as-a-service providing auth, Postgres database, file storage, and realtime subscriptions. Composes with `react-native-expo` for mobile projects — Expo handles the native shell while Supabase provides the cloud backend.

## Quick Start

```bash
npm install @supabase/supabase-js
```

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import { Database } from './database.types';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
```

**Environment variables** (`.env`):
```
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

For web projects, use `NEXT_PUBLIC_` prefix instead of `EXPO_PUBLIC_`.

## Authentication

### Email / Password

```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: { data: { full_name: 'Jane Doe' } }, // metadata stored in user.user_metadata
});

// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password',
});

// Logout
await supabase.auth.signOut();

// Current session (persisted across restarts)
const { data: { session } } = await supabase.auth.getSession();
const user = session?.user;
```

### OAuth Providers (Google)

```typescript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'myapp://auth/callback', // deep link for mobile
  },
});
```

Mobile redirect requires deep-linking skill (`expo-linking`). See `references/supabase-auth-guide.md` for full OAuth setup.

### Auth State Listener

```typescript
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') console.log('User:', session?.user.id);
  if (event === 'SIGNED_OUT') console.log('User signed out');
  if (event === 'TOKEN_REFRESHED') console.log('Token refreshed');
});
```

## Database Queries

### CRUD

```typescript
// Insert
const { data, error } = await supabase
  .from('todos')
  .insert({ title: 'Buy milk', user_id: userId })
  .select();

// Select with filter
const { data } = await supabase
  .from('todos')
  .select('id, title, completed, profiles(name)')
  .eq('user_id', userId)
  .eq('completed', false)
  .order('created_at', { ascending: false })
  .limit(10);

// Update
await supabase
  .from('todos')
  .update({ completed: true })
  .eq('id', todoId);

// Delete
await supabase
  .from('todos')
  .delete()
  .eq('id', todoId);
```

### Common Filters

| Method | Description | Example |
|--------|-------------|---------|
| `.eq()` | Equals | `.eq('status', 'active')` |
| `.gt()` / `.lt()` | Greater / Less than | `.gt('age', 18)` |
| `.like()` | Pattern match | `.like('name', '%smith%')` |
| `.in()` | In list | `.in('role', ['admin','editor'])` |
| `.or()` | Logical OR | `.or('status.eq.active,status.eq.pending')` |
| `.is()` | NULL check | `.is('deleted_at', null)` |

### Pagination

```typescript
const PAGE_SIZE = 20;
const { data } = await supabase
  .from('posts')
  .select('*')
  .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);
```

### Row Level Security (RLS)

Always enable RLS on tables. Policies filter rows per authenticated user:

```sql
-- Users can only see their own todos
CREATE POLICY "select_own" ON todos FOR SELECT
  USING ((select auth.uid()) = user_id);

CREATE POLICY "insert_own" ON todos FOR INSERT
  WITH CHECK ((select auth.uid()) = user_id);
```

Never disable RLS for client access. Use service role key server-side only.

See `references/supabase-data-guide.md` for full filter, join, and RLS patterns.

## Storage

```typescript
// Upload
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${userId}/photo.png`, file, { upsert: true });

// Download
const { data } = await supabase.storage
  .from('avatars')
  .download(`${userId}/photo.png`);

// Get public URL
const { data } = supabase.storage
  .from('public-bucket')
  .getPublicUrl('path/to/file.png');

// List files
const { data } = await supabase.storage
  .from('avatars')
  .list(userId, { limit: 10, offset: 0 });
```

**Public vs Private buckets**: Public buckets serve files via CDN URL without signing. Private buckets require `createSignedUrl()` with an expiry.

## Realtime Subscriptions

```typescript
const channel = supabase
  .channel('todos-changes')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'todos', filter: `user_id=eq.${userId}` },
    (payload) => {
      console.log('Change:', payload.eventType, payload.new);
    }
  )
  .subscribe();

// Cleanup
supabase.removeChannel(channel);
```

Realtime requires the table to be in the `supabase_realtime` publication:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE todos;
```

## Composing with Other Skills

| Skill | Composition |
|-------|-------------|
| `react-native-expo` | Expo provides native shell; Supabase provides backend. Use `expo-secure-store` for session storage. |
| `deep-linking` | OAuth and magic-link flows require custom URL scheme redirect (e.g., `myapp://auth/callback`). |
| `native-datastore-verifier` | Verify Supabase data changes by querying via `supabase.rest` or direct Postgres client. |
| `mailpit-email-testing` | Capture Supabase auth emails (confirmation, password reset) in local dev without real SMTP. |

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Disable RLS for client queries | Write proper RLS policies per table |
| Store `SUPABASE_SERVICE_ROLE_KEY` in client code | Keep service role key on server only |
| Use `select('*')` on large tables | Select only needed columns |
| Forget to handle `error` from queries | Always destructure and check `{ data, error }` |
| Create a new client per component | Export a singleton client from `lib/supabase.ts` |
| Use `localStorage` for session on native | Use `expo-secure-store` via custom storage adapter |
| Skip `autoRefreshToken` option | Always enable auto-refresh to prevent expired tokens |

## References

- `references/supabase-auth-guide.md` — Auth flows: email, OAuth, magic link, session management
- `references/supabase-data-guide.md` — Query patterns, filters, joins, RLS policies, TypeScript types
- `assets/config-templates/supabase-client.ts` — Client initialization with typed database
- `assets/config-templates/auth-middleware.ts` — Auth state hook/provider for React
- `scripts/verify-connection.sh` — Test Supabase connectivity
