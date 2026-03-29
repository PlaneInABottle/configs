# Expo Router Patterns Reference

## File-Based Routing Table

| File | Route | Example |
|------|-------|---------|
| `app/index.tsx` | `/` | Home screen |
| `app/about.tsx` | `/about` | Static route |
| `app/[id].tsx` | `/123`, `/abc` | Dynamic segment |
| `app/[...slug].tsx` | `/a/b/c` | Catch-all |
| `app/[[...id]].tsx` | `/`, `/123`, `/a/b` | Optional catch-all |
| `app/(group)/index.tsx` | `/` | Route group (no URL impact) |
| `app/(tabs)/_layout.tsx` | — | Tab navigator layout |
| `app/_layout.tsx` | — | Root layout |

## Nested Layouts

Layouts compose top-down. Each `_layout.tsx` wraps its sibling screens.

```tsx
// app/_layout.tsx — Root
import { Stack } from "expo-router";

export default function RootLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="modal" options={{ presentation: "modal" }} />
    </Stack>
  );
}
```

```tsx
// app/(tabs)/_layout.tsx — Tabs nested under root
import { Tabs } from "expo-router";
import { Ionicons } from "@expo/vector-icons";

export default function TabsLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "Settings",
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="settings" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

**Composition order:** `RootLayout` → `TabsLayout` → Screen component.

## Navigation API

```tsx
import { router, useLocalSearchParams, useGlobalSearchParams } from "expo-router";

// Navigate
router.push("/details/42");
router.push({ pathname: "/details/[id]", params: { id: "42" } });

// Replace (no back entry)
router.replace("/home");

// Go back
router.back();

// Set params on current screen
router.setParams({ id: "updated" });

// Read params
const { id } = useLocalSearchParams<{ id: string }>();
```

## Route Groups

| Group | Purpose | URL Impact |
|-------|---------|------------|
| `(tabs)` | Tab-based navigation | None — `/` not `/tabs` |
| `(auth)` | Login/signup flow | None — `/login` not `/auth/login` |
| `(stack)` | Isolated stack navigator | None |
| `(drawer)` | Drawer navigation | None |

Groups let you apply a shared `_layout.tsx` without adding a URL segment.

## Deep Linking

```tsx
// app/_layout.tsx
import { useURL } from "expo-linking";

// In Expo Router, deep linking is automatic via app.json scheme:
// { "expo": { "scheme": "myapp" } }
// Links like myapp://details/42 resolve to app/details/[id].tsx

// External linking (web):
// Configure in app.json: { "expo": { "web": { "bundler": "metro" } } }
```

```json
// app.json
{
  "expo": {
    "scheme": "myapp",
    "android": { "package": "com.example.myapp" },
    "ios": { "bundleIdentifier": "com.example.myapp" }
  }
}
```

## Modal Routes

```tsx
// app/_layout.tsx
<Stack>
  <Stack.Screen name="index" />
  <Stack.Screen name="modal" options={{ presentation: "modal" }} />
</Stack>

// Navigate to modal:
router.push("/modal");
```

Presentation options: `"modal"`, `"transparentModal"`, `"containedModal"`, `"fullScreenModal"`.

## Auth Flow Pattern

```tsx
// app/_layout.tsx
import { useAuth } from "@/hooks/useAuth";
import { Redirect } from "expo-router";

export default function RootLayout() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) return null; // or splash screen

  if (!isAuthenticated) {
    return <Redirect href="/(auth)/login" />;
  }

  return (
    <Stack>
      <Stack.Screen name="(tabs)" />
    </Stack>
  );
}
```

```tsx
// app/(auth)/_layout.tsx
import { Stack } from "expo-router";

export default function AuthLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="login" />
      <Stack.Screen name="signup" />
    </Stack>
  );
}
```

## Tab Icons

| Source | Package | Usage |
|--------|---------|-------|
| Expo vector icons | `@expo/vector-icons` | `<Ionicons name="home" />` |
| Custom PNG/SVG | `expo-image` or `Image` | `tabBarIcon: () => <Image />` |
| SF Symbols (iOS) | `react-native-sfsymbols` | iOS-only, native look |

```tsx
// Icon with badge
<Tabs.Screen
  name="notifications"
  options={{
    tabBarBadge: 3,
    tabBarIcon: ({ color, size }) => (
      <Ionicons name="notifications" size={size} color={color} />
    ),
  }}
/>
```
