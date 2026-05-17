# Supabase Local Development

## Table of Contents

- [Init](#init)
- [Start / Stop](#start--stop)
- [Status](#status)
- [Link](#link)
- [Migrations](#migrations)
- [Diff](#diff)
- [Seed Data](#seed-data)
- [Type Generation](#type-generation)
- [Complete Workflow](#complete-workflow)

## Init

Create a new Supabase project in the current directory:

```bash
supabase init
```

Creates a `supabase/` directory with a `config.toml` file and the standard folder structure (`migrations/`, `seed.sql`, etc.).

## Start / Stop

Start all local Supabase services:

```bash
supabase start
```

On first run, pulls Docker images and initializes databases. Starts the following services locally:

- Postgres
- GoTrue (auth)
- Realtime
- Storage
- Edge Functions

Stop all services:

```bash
supabase stop
```

## Status

Check what services are running and their connection details:

```bash
supabase status
```

Output includes local URLs for each service:

- API URL: `http://localhost:54321`
- DB URL: `postgresql://postgres:postgres@localhost:54322/postgres`
- Studio URL: `http://localhost:54323`
- Inbucket (email): `http://localhost:54324`
- Storage API: `http://localhost:54321/storage/v1`
- Edge Functions: `http://localhost:54321/functions/v1`
- anon key
- service_role key

## Link

Link a local project to a remote Supabase project:

```bash
supabase login
supabase link --project-id <project-ref>
```

The project reference (`<project-ref>`) is the string under **Settings → General → Reference** in the Supabase dashboard.

Linking enables `supabase db push`, `supabase db diff --linked`, and `supabase gen types --linked` to work against the remote project.

## Migrations

Database change management:

```bash
# Create a new migration file (timestamp-prefixed)
supabase migration new create_profiles
# Edit: supabase/migrations/<timestamp>_create_profiles.sql

# Apply pending migrations to the local database
supabase migration up

# Reset the local database — drops all data, re-runs all migrations,
# and applies seed data
supabase db reset

# Push local migrations to the linked remote project
supabase db push

# Preview changes without applying them
supabase db push --dry-run

# Include seed data when pushing to remote
supabase db push --include-seed
```

## Diff

Auto-generate migration files by comparing the current local database state against the migration history:

```bash
# Compare local DB to migrations, save diff as a new migration file
supabase db diff -f add_user_roles

# Diff against the linked remote project
supabase db diff --linked

# Diff using the default Python engine (migra)
supabase db diff --use-migra

# Diff using the experimental Go-based engine
supabase db diff --use-pg-delta
```

Use `supabase db diff` when you've made schema changes directly in the Studio or via SQL editor and want to capture them as a migration file.

## Seed Data

Populate the local database with test data on startup:

Create `supabase/seed.sql` with INSERT statements. Seed runs automatically on `supabase start` and `supabase db reset`.

```bash
# Skip seed during a database reset
supabase db reset --no-seed

# Push seed data to the remote project
supabase db push --include-seed
```

## Type Generation

Generate typed language bindings from your database schema:

```bash
# TypeScript from local database
supabase gen types --local > lib/database.types.ts

# TypeScript from the linked remote project
supabase gen types --linked > lib/database.types.ts

# TypeScript from a specific project reference
supabase gen types --project-id <ref> > types.ts

# Python from local database
supabase gen types --local --lang=python > types.py

# Specific schemas only (comma-separated)
supabase gen types --local -s public,auth > types.ts
```

## Complete Workflow

Day-one setup for a new project:

```bash
supabase login
supabase init
supabase start
supabase migration new initial_schema
# write SQL in the migration file
supabase migration up
supabase gen types --local > lib/database.types.ts
# develop with local API at http://localhost:54321
```
