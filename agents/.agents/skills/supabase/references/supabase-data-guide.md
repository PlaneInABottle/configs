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
