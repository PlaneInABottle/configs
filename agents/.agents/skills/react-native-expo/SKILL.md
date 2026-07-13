---
name: react-native-expo
description: Build and maintain applications that use Expo or Expo Router. Use when creating an Expo project, adding routes or layouts, configuring Expo app metadata, integrating native modules through Expo, or debugging Expo runtime behavior. Do not load for generic React Native performance review alone.
---

# React Native with Expo

Preserve the project's current router, state manager, styling system, package manager, and SDK version. Do not introduce MobX, NativeWind, Expo Router, or another architecture unless the project already uses it or the user chooses it.

## New Projects

Create projects from the current official template instead of copying a pinned skill asset:

```bash
npx create-expo-app@latest --template default@sdk-55
```

Before running the command, verify the current supported SDK and template in Expo documentation. Use the user's package manager and avoid globally installing the Expo CLI.

## Existing Projects

1. Read `package.json`, `app.json` or `app.config.*`, router entrypoint, and existing native directories.
2. Use `npx expo install <package>` for Expo-compatible package versions.
3. Follow the existing file layout and configuration plugins.
4. Run the project's lint, type-check, and test commands.
5. Verify mobile UI with the connected Maestro workflow when a simulator or device is available.

## Expo Router

Expo Router derives routes from the `app/` directory. Keep route groups, layouts, typed routes, and auth guards consistent with the installed router version.

```tsx
import { Stack } from 'expo-router';

export default function Layout() {
  return <Stack />;
}
```

- Use route groups for organization without adding URL segments.
- Put navigator configuration in `_layout.tsx`.
- Use `Redirect` or the installed router's supported protection mechanism after auth state finishes loading.
- Verify linking and navigation APIs against the installed Expo Router version.

Load [references/expo-router-patterns.md](references/expo-router-patterns.md) for route patterns, then check current Expo docs for version-sensitive APIs.

## Styling and State

- Keep React Native `StyleSheet`, NativeWind, Tamagui, a design system, or another established styling approach already present in the app.
- Load [references/nativewind-setup.md](references/nativewind-setup.md) only when the project explicitly uses NativeWind.
- Load the `mobx` skill only when MobX is selected or already installed.
- Apply `vercel-react-native-skills` for targeted performance work, not routine screen creation.

## Runtime

Use the project's normal start command. If a persistent process is useful, manage only that named process through `pm2-runtime-operator`. Do not assume every Expo project should run through PM2.

## Composition

- `deep-linking`: schemes, universal links, app links, OAuth callbacks
- `react-native-push`: Expo notifications
- `expo-eas-build`: cloud builds, updates, and submissions
- `maestro-testing`: device inspection and UI flows
- `supabase`: only when the project uses Supabase
