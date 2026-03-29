---
name: react-native-expo
description: "Scaffold and build React Native apps with Expo, Expo Router, NativeWind, and MobX. Use when: creating a new React Native project, adding screens/routes, setting up navigation, configuring NativeWind/Tailwind styling, building MobX stores, or structuring a mobile app. Triggers on 'create react native app', 'add screen', 'set up navigation', 'configure tailwind for mobile', 'build mobile app', or any Expo/React Native development task."
---

# React Native Expo

## Overview

Scaffold production-ready React Native apps using Expo (managed), Expo Router (file-based routing), NativeWind (Tailwind CSS), and MobX (state). Provides copy-ready templates and composes with domain skills (`supabase`, `deep-linking`, `react-native-push`) for backend, auth, and notifications.

## Quick Start — Scaffold a Project

Copy the template, install deps, start dev server:

```bash
# 1. Copy template
cp -r <skill-dir>/assets/template-bare <project-name>

# 2. Install dependencies
cd <project-name> && npm install

# 3. Start dev server (use PM2 for persistent process)
pm2 start npx --name "myapp" -- expo start
```

Replace `<skill-dir>` with the path to this skill's directory (where `assets/template-bare` lives).

## Project Structure

```
<project>/
├── app/                    # Expo Router — file = route
│   ├── _layout.tsx         # Root layout (Stack + MobX provider)
│   ├── index.tsx           # Entry → redirects to /(tabs)
│   └── (tabs)/
│       ├── _layout.tsx     # Tab navigator
│       ├── index.tsx       # Home tab
│       └── explore.tsx     # Explore tab
├── stores/                 # MobX stores
│   ├── RootStore.ts        # Root store + React context + hooks
│   └── UserStore.ts        # User state (observable)
├── components/             # Reusable UI components
│   ├── ThemedText.tsx      # Text with NativeWind dark/light
│   └── ThemedView.tsx      # View with NativeWind dark/light
├── lib/
│   └── constants.ts        # Colors, spacing, font sizes
├── app.json                # Expo config
├── babel.config.js         # Babel + NativeWind plugin
├── metro.config.js         # Metro + NativeWind wrapper
├── tailwind.config.js      # Tailwind content paths
├── tsconfig.json           # TypeScript config
└── global.css              # Tailwind directives
```

## Adding Screens

Expo Router = file-based routing. Every file in `app/` becomes a route.

### Route Patterns

| File | Route | Usage |
|------|-------|-------|
| `app/index.tsx` | `/` | Entry point |
| `app/settings.tsx` | `/settings` | Simple screen |
| `app/(tabs)/profile.tsx` | `/profile` | Inside tab navigator |
| `app/(auth)/login.tsx` | `/login` | Auth group (no tab bar) |
| `app/user/[id].tsx` | `/user/123` | Dynamic segment |

### Adding a Screen

1. Create file in `app/` (e.g., `app/profile.tsx`)
2. Default export a React component
3. Use `useRouter()` from `expo-router` to navigate:

```tsx
import { useRouter } from "expo-router";
import { Pressable, Text } from "react-native";

export default function ProfileScreen() {
  const router = useRouter();
  return (
    <Pressable onPress={() => router.push("/settings")}>
      <Text>Go to Settings</Text>
    </Pressable>
  );
}
```

### Adding a Tab

1. Create file in `app/(tabs)/` (e.g., `app/(tabs)/profile.tsx`)
2. Update `app/(tabs)/_layout.tsx` to add the tab:

```tsx
<Tabs.Screen name="profile" options={{ title: "Profile", tabBarIcon: ... }} />
```

### Route Groups (Auth Flow)

Use parenthesized directories for grouping without URL segments:

```
app/
├── (auth)/           # No tab bar, separate stack
│   ├── _layout.tsx   # Stack layout for auth screens
│   ├── login.tsx
│   └── register.tsx
└── (tabs)/           # Tab navigator, auth required
    ├── _layout.tsx
    └── ...
```

To redirect unauthenticated users, check auth state in root `_layout.tsx`:

```tsx
import { useUserStore } from "@/stores/RootStore";
import { Redirect } from "expo-router";
import { observer } from "mobx-react-lite";

export default observer(function RootLayout() {
  const { isLoggedIn } = useUserStore();
  if (!isLoggedIn) return <Redirect href="/(auth)/login" />;
  // ... render app
});
```

## MobX Stores

### Pattern: RootStore + Context

All stores live under a single `RootStore`, provided via React context.

```tsx
// stores/RootStore.ts
import { createContext, useContext } from "react";
import { UserStore } from "./UserStore";

export class RootStore {
  userStore = new UserStore();
}

const rootStore = new RootStore();
const RootStoreContext = createContext<RootStore>(rootStore);

export const RootStoreProvider = ({ children }: { children: React.ReactNode }) => (
  <RootStoreContext.Provider value={rootStore}>{children}</RootStoreContext.Provider>
);

export const useRootStore = () => useContext(RootStoreContext);
export const useUserStore = () => useContext(RootStoreContext).userStore;
```

### Adding a New Store

1. Create `stores/MyStore.ts` with `makeAutoObservable`
2. Add to `RootStore.ts`: `myStore = new MyStore()`
3. Export hook: `export const useMyStore = () => useContext(RootStoreContext).myStore`

### Store Rules

- Always use `makeAutoObservable(this)` in constructor
- Wrap components with `observer()` from `mobx-react-lite`
- Actions mutate state directly (MobX tracks reactivity)
- Async actions: set loading state, try/catch, update store

## NativeWind Styling

Use `className` prop with Tailwind classes on any React Native component.

```tsx
<View className="flex-1 bg-white dark:bg-gray-900 p-4">
  <Text className="text-xl font-bold text-gray-900 dark:text-white">
    Hello World
  </Text>
</View>
```

### Dark Mode

NativeWind v4 supports `dark:` prefix automatically. Configure in `tailwind.config.js`:

```js
module.exports = {
  darkMode: "class", // or "media" for system preference
  // ...
};
```

### Custom Styles

For styles not expressible via Tailwind, use `styled()` wrapper or inline styles alongside `className`.

## Composing with Other Skills

| Need | Load Skill |
|------|-----------|
| Supabase auth/DB | `supabase` |
| Deep linking / OAuth redirects | `deep-linking` |
| Push notifications | `react-native-push` |
| E2E mobile testing | `maestro-testing` |
| Build + deploy | `expo-eas-build` |
| Dev server management | `pm2-runtime-operator` |
| Verify DB state | `native-datastore-verifier` |
| Test API contracts | `api-contract-testing` |

## Verification

### Dev Server (PM2)

```bash
pm2 start npx --name "myapp" -- expo start
pm2 logs myapp  # Check for errors
```

### Visual Check

```bash
# If testing web target
agent-browser open http://localhost:8081
agent-browser snapshot -i
agent-browser screenshot
```

### Mobile Simulator

Load `maestro-testing` skill for simulator management and E2E flows.

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Create `App.tsx` entry point | Use `app/_layout.tsx` (Expo Router) |
| Use React Navigation directly | Use Expo Router file-based routing |
| Inline all styles | Use NativeWind `className` |
| Create stores without MobX | Use RootStore pattern with `makeAutoObservable` |
| One monolithic store | Split into domain stores (UserStore, ItemStore, etc.) |

## References

Load on demand:

- `references/expo-router-patterns.md` — Advanced routing, layouts, navigation guards
- `references/nativewind-setup.md` — Configuration, dark mode, custom themes
- `references/mobx-in-expo.md` — Store patterns, async actions, computed values
