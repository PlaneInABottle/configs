# Supabase Storage Guide

> Advanced reference for Supabase Storage features — buckets, uploads, signed URLs, TUS resumable uploads, RLS, and error handling.

## Table of Contents

- [Create buckets with constraints](#create-buckets-with-constraints)
- [Upload options](#upload-options)
- [Signed URLs (download)](#signed-urls-download)
- [Signed Upload URLs](#signed-upload-urls)
- [Resumable uploads (TUS protocol)](#resumable-uploads-tus-protocol)
- [List files](#list-files)
- [Move & Copy](#move--copy)
- [Delete](#delete)
- [Public vs Private buckets](#public-vs-private-buckets)
- [Bucket-level RLS policies](#bucket-level-rls-policies)
- [Error handling](#error-handling)

---

## Create buckets with constraints

```typescript
const { data, error } = await supabase.storage.createBucket('avatars', {
  public: false,
  allowedMimeTypes: ['image/png', 'image/jpeg'],
  fileSizeLimit: 1024 * 1024 * 2, // 2 MB
});

// Public bucket (no constraints)
const { data, error } = await supabase.storage.createBucket('public-assets', {
  public: true,
});
```

**Parameters:**

| Option            | Type      | Default   | Description                        |
| ----------------- | --------- | --------- | ---------------------------------- |
| `public`          | `boolean` | `false`   | Whether files are publicly served  |
| `allowedMimeTypes`| `string[]`| `null`    | Allowed MIME types (`null` = any)  |
| `fileSizeLimit`   | `number`  | `null`    | Max file size in bytes             |

Update an existing bucket:

```typescript
await supabase.storage.updateBucket('avatars', {
  public: true,
  fileSizeLimit: 50 * 1024 * 1024,
});
```

---

## Upload options

```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${userId}/photo.png`, file, {
    cacheControl: '3600',
    upsert: true,
    contentType: 'image/png',
  });
// data → { path: `${userId}/photo.png` }
```

| Option          | Type      | Default          | Description                                |
| --------------- | --------- | ---------------- | ------------------------------------------ |
| `cacheControl`  | `string`  | —                | `Cache-Control` header value (seconds)     |
| `contentType`   | `string`  | inferred         | MIME type override                         |
| `upsert`        | `boolean` | `false`          | Overwrite file if it already exists        |

The `file` argument accepts `File | Blob | ArrayBuffer | ArrayBufferView`.

Check `error` for upload failures — a `409` status means the key already exists (use `upsert: true` to overwrite).

---

## Signed URLs (download)

Generate a time-limited download URL for files in **private** buckets:

```typescript
const { data, error } = await supabase.storage
  .from('private-docs')
  .createSignedUrl('reports/q1-2024.pdf', 3600);
// data → { signedUrl: 'https://<project>.supabase.co/storage/v1/object/sign/private-docs/reports/q1-2024.pdf?token=...' }

// Use the URL (e.g., in an <img> tag or fetch)
const img = document.createElement('img');
img.src = data.signedUrl;
```

**Parameters:**

- `path` — full path within the bucket
- `expiresIn` — seconds until the URL expires (max 7 days / 604800)

**Multiple signed URLs** (batch):

```typescript
const { data, error } = await supabase.storage
  .from('private-docs')
  .createSignedUrls(['doc1.pdf', 'doc2.pdf'], 3600);
// data → [{ signedUrl: string }, { signedUrl: string }]
```

---

## Signed Upload URLs

Two-step flow for uploading to private buckets without exposing the client to the anon key (commonly used in server-backed uploads):

**Step 1 — Create the signed upload URL:**

```typescript
const { data, error } = await supabase.storage
  .from('uploads')
  .createSignedUploadUrl('user-123/report.pdf', {
    upsert: true,
  });
// data → { path: 'user-123/report.pdf', token: '...', url: '.../upload/sign/...' }
```

**Step 2 — Upload directly using the token:**

```typescript
const { data, error } = await supabase.storage
  .from('uploads')
  .uploadToSignedUrl('user-123/report.pdf', data.token, file, {
    upsert: true,
    contentType: 'application/pdf',
  });
// data → { path: 'user-123/report.pdf' }
```

Use case: Server creates a time-limited signed upload URL and shares the `token` with an end-client, avoiding exposure of Supabase credentials.

---

## Resumable uploads (TUS protocol)

For large files (>6 MB) or unstable network connections. Implements the [TUS protocol](https://tus.io/).

### Uppy.js + TUS plugin

```typescript
import Uppy from '@uppy/core';
import Tus from '@uppy/tus';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const projectId = SUPABASE_URL.match(/https:\/\/(.+)\.supabase\.co/)[1];

const uppy = new Uppy();

async function initUploader(bucketName: string) {
  const { data: { session } } = await supabase.auth.getSession();

  uppy.use(Tus, {
    // Use direct storage hostname for optimal performance
    endpoint: `https://${projectId}.storage.supabase.co/storage/v1/upload/resumable`,
    retryDelays: [0, 3000, 5000, 10000, 20000],
    headers: {
      authorization: `Bearer ${session!.access_token}`,
      apikey: SUPABASE_ANON_KEY,
      // For signed uploads, include: 'x-signature': token
    },
    uploadDataDuringCreation: true,
    removeFingerprintOnSuccess: true,
    chunkSize: 6 * 1024 * 1024, // 6 MB — do not change
    allowedMetaFields: [
      'bucketName',
      'objectName',
      'contentType',
      'cacheControl',
      'metadata',
    ],
  });

  uppy.on('file-added', (file) => {
    file.meta = {
      ...file.meta,
      bucketName,
      objectName: file.name,
      contentType: file.type,
      cacheControl: '3600',
      // metadata: JSON.stringify({ customKey: 'value' }), // optional
    };
  });

  uppy.on('upload-success', (file, response) => {
    console.log('Upload complete:', response.uploadURL);
  });

  uppy.on('progress', (bytesUploaded: number, bytesTotal: number) => {
    const pct = ((bytesUploaded / bytesTotal) * 100).toFixed(2);
    console.log(`${pct}%`);
  });
}
```

### Key rules

| Rule | Value |
| --- | --- |
| Chunk size | **6 MB** (must not change) |
| Upload URL expiry | 24 hours |
| Endpoint | `https://<project>.storage.supabase.co/storage/v1/upload/resumable` |
| Concurrency | Only 1 client per upload URL; 409 Conflict otherwise |
| `x-upsert` | Header to overwrite existing files |
| `x-signature` | Header for signed uploads (from `createSignedUploadUrl`) |

### Using signed tokens with TUS

```typescript
const { data } = await supabase.storage
  .from('bucket-name')
  .createSignedUploadUrl('file_path', { upsert: true });

// Pass data.token as the x-signature header
uppy.use(Tus, {
  endpoint: `https://${projectId}.storage.supabase.co/storage/v1/upload/resumable`,
  headers: {
    apikey: SUPABASE_ANON_KEY,
    'x-signature': data.token,
  },
  // ...
});
```

---

## List files

### SDK method

```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .list(`${userId}/`, {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' },
  });
// data → Array<{ name: string, id: string, updated_at: string, created_at: string, last_accessed_at: string, metadata: object }>
```

**Parameters:**

| Option   | Type     | Default               | Description              |
| -------- | -------- | --------------------- | ------------------------ |
| `limit`  | `number` | `10`                  | Max items to return      |
| `offset` | `number` | `0`                   | Pagination offset        |
| `sortBy` | `object` | `{ column: 'name', order: 'asc' }` | Sort configuration |

### Optimized listing for large buckets (direct Postgres query)

For buckets with millions of objects, the SDK `list()` can be slow. Query `storage.objects` directly with a custom Postgres function:

```sql
CREATE OR REPLACE FUNCTION list_storage_objects(
  bucket_id text,
  folder_path text,
  max_results int DEFAULT 100,
  result_offset int DEFAULT 0
)
RETURNS SETOF storage.objects
LANGUAGE sql
STABLE
AS $$
  SELECT *
  FROM storage.objects
  WHERE list_storage_objects.bucket_id = bucket_id
    AND (storage.foldername(name))[1] = folder_path
  ORDER BY name ASC
  LIMIT max_results
  OFFSET result_offset;
$$;
```

Call via Supabase RPC:

```typescript
const { data, error } = await supabase.rpc('list_storage_objects', {
  bucket_id: 'avatars',
  folder_path: userId,
  max_results: 100,
  result_offset: 0,
});
```

**Note:** The `storage.foldername(name)` function returns the folder path as a `text[]` array (e.g., `{users,abc123}`). Index `[1]` gives the top-level folder.

---

## Move & Copy

```typescript
// Move (rename / relocate)
const { data, error } = await supabase.storage
  .from('uploads')
  .move('old/path/file.jpg', 'new/path/file.jpg');

// Copy
const { data, error } = await supabase.storage
  .from('uploads')
  .copy('source/path/file.jpg', 'dest/path/file.jpg');
```

Both return `{ data: { path: string } | null; error: Error | null }`.

---

## Delete

```typescript
// Takes an array of paths (always an array, even for a single file)
const { data, error } = await supabase.storage
  .from('avatars')
  .remove(['user-uuid/old-avatar.png', 'user-uuid/temp.jpg']);

// data → Array<{ bucket_id: string, name: string, id: string, updated_at: string, created_at: string, last_accessed_at: string, metadata: object }>
```

**Important:** `remove()` always accepts an **array** of paths. Passing a single string will silently fail type-checking in older SDK versions.

---

## Public vs Private buckets

| Aspect | Public bucket | Private bucket |
|--------|--------------|----------------|
| `createBucket` | `{ public: true }` | `{ public: false }` (default) |
| File access | CDN URL, no auth required | Requires signed URL or auth |
| URL method | `getPublicUrl(path)` | `createSignedUrl(path, expiresIn)` |
| RLS required? | Optional (open access) | Required (restrict access) |

**Public bucket — get CDN URL:**

```typescript
const { data } = supabase.storage
  .from('public-assets')
  .getPublicUrl('images/logo.png');
// data → { publicUrl: 'https://<project>.supabase.co/storage/v1/object/public/public-assets/images/logo.png' }

// With custom transformations (if enabled)
const { data } = supabase.storage
  .from('public-assets')
  .getPublicUrl('images/logo.png', {
    transform: { width: 200, height: 200, resize: 'contain' },
  });
```

**Private bucket — generate signed URL:**

```typescript
const { data } = await supabase.storage
  .from('private-docs')
  .createSignedUrl('report.pdf', 3600);

// Use data.signedUrl directly in fetch/XMLHttpRequest/<img>
```

---

## Bucket-level RLS policies

Policies are defined on the `storage.objects` table. `bucket_id` matches the bucket name.

### Common patterns

```sql
-- Allow authenticated users to access files in their own folder
CREATE POLICY "user_own_folder" ON storage.objects
  FOR ALL
  USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow anyone to upload (public bucket)
CREATE POLICY "public_insert" ON storage.objects
  FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'public-assets');

-- Allow authenticated users to upload to a specific bucket
CREATE POLICY "auth_insert" ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'uploads');

-- Allow reading objects in a specific bucket
CREATE POLICY "select_bucket" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'public-assets');

-- Allow users to delete their own files
CREATE POLICY "delete_own" ON storage.objects
  FOR DELETE
  USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow update on own files
CREATE POLICY "update_own" ON storage.objects
  FOR UPDATE
  USING (auth.uid()::text = (storage.foldername(name))[1]);
```

### Important SQL functions

| Function | Returns | Description |
|----------|---------|-------------|
| `storage.foldername(name)` | `text[]` | Folder path as array — e.g., `{users,abc123}` |
| `storage.filename(name)` | `text` | File name portion of the path |
| `auth.uid()` | `uuid` | Current authenticated user's ID |
| `auth.role()` | `text` | Current user's role (`authenticated` / `anon`) |

### Example: Folder-based ownership

If files are stored as `{userId}/{fileName}`, this policy grants full access:

```sql
CREATE POLICY "own_folder_all" ON storage.objects
  FOR ALL
  USING (auth.uid()::text = (storage.foldername(name))[1]);
```

For nested folders like `{userId}/photos/{fileName}`, adjust the index:

```sql
-- User owns everything under their ID folder
USING (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## Error handling

### Common storage error codes

| Code | HTTP Status | Meaning | Fix |
| --- | --- | --- | --- |
| `NoSuchBucket` | 404 | Bucket doesn't exist or no permission | Check bucket name; add RLS policy |
| `NoSuchKey` | 404 | File path doesn't exist or no permission | Verify path; add RLS policy |
| `KeyAlreadyExists` | 409 | File already exists at path | Use `upsert: true` or different name |
| `BucketAlreadyExists` | 409 | Bucket name already taken | Choose a unique name |
| `ResourceAlreadyExists` | 409 | Resource conflict | Use `x-upsert: true` header |
| `InvalidJWT` | 401 | Token is expired or malformed | Refresh session; re-authenticate |
| `AccessDenied` | 403 | RLS policy blocks the operation | Add or fix RLS policy |
| `InvalidSignature` | 403 | Signed URL signature mismatch | Check signature format |
| `EntityTooLarge` | 413 | File exceeds bucket size limit | Increase `fileSizeLimit` in bucket config |
| `InvalidMimeType` | 400 | File type not in `allowedMimeTypes` | Add MIME type to bucket settings |
| `DatabaseTimeout` | 504 | Postgres connection pool saturated | Upgrade compute; increase pool size |
| `SlowDown` | 503 | Rate limit hit | Implement exponential backoff |
| `InternalError` | 500 | Server error | Check server logs; contact support |

### Legacy error codes (still returned)

| `httpStatusCode` | Legacy `code` | Meaning |
|-----------------|---------------|---------|
| 404 | `not_found` | Resource missing or no permission |
| 409 | `already_exists` | File exists (use `upsert`) |
| 403 | `unauthorized` | RLS or JWT issue |
| 429 | `too many requests` | Rate limit / pooler saturation |
| 544 | `database_timeout` | Postgres timeout |
| 500 | `internal_server_error` | Unhandled server error |

### Handling in code

```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('user/photo.png', file, { upsert: true });

if (error) {
  console.error('Error code:', error instanceof StorageError ? error.name : error.message);
  console.error('HTTP status:', error.statusCode ?? error.status);
  // Respond accordingly
  if (error.statusCode === 409) {
    // File exists — handle gracefully
  }
  if (error.statusCode === 413) {
    // File too large — inform user
  }
}
```

The `StorageError` object includes:

- `message` — human-readable description
- `statusCode` / `status` — HTTP status
- `error` — the error code string (e.g., `'KeyAlreadyExists'`)
