---
name: mobile-app-orchestrator
description: "Orchestrate all mobile development skills to build a complete React Native + Expo app end-to-end. Use when: building a full mobile app from scratch, automating the entire mobile dev workflow, or coordinating react-native-expo, supabase, deep-linking, react-native-push, maestro-testing, expo-eas-build, and mobx skills. Takes a JSON spec and executes all phases sequentially."
---

# Mobile App Orchestrator

## Overview

Orchestrates 7 mobile skills to build a complete React Native + Expo app from a single JSON specification. Eliminates manual coordination between skills - AI executes the full pipeline autonomously.

## Required Skills (Must Be Loaded)

| Skill | Purpose |
|-------|---------|
| `react-native-expo` | Scaffold project, screens, navigation |
| `supabase` | Database, auth, RLS policies |
| `deep-linking` | URL schemes, universal links |
| `react-native-push` | Push notifications |
| `maestro-testing` | E2E test flows |
| `expo-eas-build` | Build configuration, OTA |
| `mobx` | State management |

## Input Specification

Accepts a JSON spec defining the app:

```json
{
  "name": "TaskFlow",
  "expoProjectId": "your-expo-project-id",
  "supabase": {
    "url": "https://xxx.supabase.co",
    "anonKey": "your-anon-key",
    "tables": [
      { "name": "tasks", "columns": "id, title, status, user_id" }
    ]
  },
  "features": {
    "auth": true,
    "deepLinks": ["taskflow://task/:id"],
    "push": true,
    "realtime": ["tasks"]
  },
  "screens": [
    { "name": "index", "path": "/" },
    { "name": "login", "path": "/login" },
    { "name": "tasks", "path": "/tasks" }
  ],
  "tests": [
    { "name": "login-flow", "file": "flows/login.yaml" },
    { "name": "create-task", "file": "flows/create-task.yaml" }
  ],
  "build": {
    "profiles": ["development", "preview", "production"]
  }
}
```

## Execution Phases

### Phase 1: Project Scaffold

Call `react-native-expo` skill to:
1. Create project from template
2. Install dependencies (mobx, mobx-react-lite, @react-navigation, etc.)
3. Configure Expo Router, NativeWind, MobX

```bash
# Copy template
cp -r <react-native-expo>/assets/template-bare <app-name>

# Install deps
cd <app-name> && npm install

# Configure - edit app.json with expoProjectId
```

### Phase 2: Backend Setup

Call `supabase` skill to:
1. Create tables
2. Set up RLS policies with `(select auth.uid())` pattern
3. Configure auth (email/password)
4. Set up realtime if needed

```sql
-- Example: Create tasks table with RLS
create table tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  status text default 'pending',
  user_id uuid references auth.users not null,
  created_at timestamptz default now()
);

alter table tasks enable row level security;

create policy "Users can CRUD own tasks"
on tasks for all
using ( (select auth.uid()) = user_id );
```

### Phase 3: Deep Links

Call `deep-linking` skill to:
1. Configure scheme in app.json
2. Set up URL handlers in app/(tabs)/_layout.tsx
3. Configure Android App Links (if domain provided)

```json
{
  "expo": {
    "scheme": "taskflow"
  }
}
```

### Phase 4: Push Notifications

Call `react-native-push` skill to:
1. Install expo-notifications
2. Configure notification handler
3. Create Supabase Edge Function for triggers
4. Set up FCM (requires Firebase project)

### Phase 5: State Management

Call `mobx` skill to:
1. Create store structure
2. Set up RootStore with React context
3. Add reactions for persistence

### Phase 6: Screens Implementation

Use `react-native-expo` to:
1. Create screen components
2. Connect to MobX stores
3. Implement auth flow
4. Add navigation

### Phase 7: E2E Testing

Call `maestro-testing` skill to:
1. Create test flows
2. Run tests against simulator
3. Assert screenshots

```yaml
# flows/login.yaml
appId: com.taskflow.app
---
- runFlow: subflows/launch.yaml
- tapOn: "Login"
- inputText: "test@example.com"
- inputText: "password123"
- tapOn: "Sign In"
- extendedWaitUntil:
    visible: "Tasks"
    timeout: 10000
- assertVisible: "No tasks yet"
```

### Phase 8: Build Configuration

Call `expo-eas-build` skill to:
1. Configure eas.json
2. Set up build profiles
3. Configure OTA updates
4. Prepare for App Store (generates instructions for certificates)

## Output

After all phases complete:

```
<app-name>/
├── app/                    # Expo Router screens
├── stores/                 # MobX stores
├── lib/                    # Supabase client, constants
├── flows/                  # Maestro tests
├── app.json                # Expo config + scheme
├── eas.json               # EAS build config
└── supabase/              # SQL migrations (optional)
```

## Prerequisites Checklist

Before running orchestration, verify:

- [ ] Expo account created
- [ ] Supabase project created with URL/keys
- [ ] For push: Firebase project (FCM credentials)
- [ ] For App Links: Domain with DNS access
- [ ] For iOS builds: Apple Developer Team ID

## Example Prompt to AI

```
Build a complete mobile app called "TaskFlow" using the mobile-app-orchestrator skill.

SPEC:
{
  "name": "TaskFlow",
  "expoProjectId": "my-project-id",
  "supabase": {
    "url": "https://abc123.supabase.co",
    "anonKey": "eyJxxx"
  },
  "features": {
    "auth": true,
    "deepLinks": ["taskflow://task/:id"],
    "push": true
  },
  "screens": [
    { "name": "index", "path": "/" },
    { "name": "login", "path": "/login" },
    { "name": "tasks", "path": "/tasks" },
    { "name": "task-detail", "path": "/task/[id]" }
  ],
  "tests": [
    { "name": "login", "file": "flows/login.yaml" },
    { "name": "create-task", "file": "flows/create-task.yaml" }
  ]
}

Execute all 8 phases in order. Commit after each phase.
```

## Limitations

| Item | Status |
|------|--------|
| Apple Developer certificates | ⚠️ Requires human setup |
| Google Play Console | ⚠️ Requires human signup |
| App Store submission | ⚠️ Requires human review |
| Real device testing | ⚠️ Requires physical device |
| Privacy Policy | ⚠️ Requires hosted URL |

AI handles: Code, Tests, Builds, OTA Deployments

---

## Composition with Other Skills

| Skill | Called During |
|-------|---------------|
| react-native-expo | Phase 1, 6 |
| supabase | Phase 2 |
| deep-linking | Phase 3 |
| react-native-push | Phase 4 |
| mobx | Phase 5 |
| maestro-testing | Phase 7 |
| expo-eas-build | Phase 8 |
