# NativeWind v4 Setup Reference

## Required Files

| File | Purpose |
|------|---------|
| `global.css` | Tailwind directives (imported in layout) |
| `tailwind.config.js` | Theme, colors, plugins |
| `babel.config.js` | JSX transform for NativeWind |
| `metro.config.js` | Metro bundler integration |
| `nativewind-env.d.ts` | TypeScript type augmentation |

## 1. global.css

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## 2. tailwind.config.js

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: "#6366f1",
        surface: "#1a1a2e",
      },
      spacing: {
        "18": "4.5rem",
      },
    },
  },
  plugins: [],
};
```

## 3. babel.config.js

```js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }],
    ],
    plugins: ["nativewind/babel"],
  };
};
```

## 4. metro.config.js

```js
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");

const config = getDefaultConfig(__dirname);

module.exports = withNativeWind(config, { input: "./global.css" });
```

## 5. nativewind-env.d.ts

```ts
/// <reference types="nativewind/types" />
```

## 6. Root Layout Import

```tsx
// app/_layout.tsx
import "./global.css";
// ... rest of layout
```

## className on RN Components

NativeWind makes `className` work on all React Native components:

```tsx
<View className="flex-1 items-center justify-center bg-white dark:bg-black">
  <Text className="text-2xl font-bold text-gray-900 dark:text-white">
    Hello World
  </Text>
  <TouchableOpacity className="mt-4 rounded-lg bg-primary px-6 py-3 active:opacity-70">
    <Text className="text-white font-semibold">Press Me</Text>
  </TouchableOpacity>
</View>
```

## Dark Mode

```tsx
// Strategy: class-based (default for RN)
// Toggle by adding "dark" class to parent
import { useColorScheme } from "nativewind";

function Toggle() {
  const { colorScheme, setColorScheme } = useColorScheme();
  return (
    <TouchableOpacity onPress={() => setColorScheme(colorScheme === "dark" ? "light" : "dark")}>
      <Text>{colorScheme === "dark" ? "Light" : "Dark"}</Text>
    </TouchableOpacity>
  );
}

// Usage in components
<View className="bg-white dark:bg-gray-900">
  <Text className="text-black dark:text-white">Themed text</Text>
</View>
```

| Strategy | How | Best For |
|----------|-----|----------|
| `class` | Toggle `dark` class on ancestor | Manual user toggle |
| `media` | Follows system preference | System-matched theming |

## Responsive Breakpoints

Limited usefulness on mobile (single viewport), but works for tablets/web:

| Prefix | Min Width | Use Case |
|--------|-----------|----------|
| `sm:` | 640px | Large phones / small tablets |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | iPads landscape |
| `xl:` | 1280px | Large tablets |

```tsx
<View className="flex-col sm:flex-row">
  <View className="w-full sm:w-1/2 p-4">Column 1</View>
  <View className="w-full sm:w-1/2 p-4">Column 2</View>
</View>
```

## State Variants

| Variant | Applies When |
|---------|-------------|
| `active:` | Component is being pressed |
| `disabled:` | `disabled` prop is true |
| `focus:` | Component is focused |
| `hover:` | Component is hovered (web only) |

```tsx
<TouchableOpacity
  className="bg-blue-500 active:bg-blue-700 disabled:opacity-50"
  disabled={!isValid}
>
  <Text className="text-white">Submit</Text>
</TouchableOpacity>

<TextInput className="border border-gray-300 focus:border-blue-500 p-3 rounded" />
```

## Common Mobile Patterns

```tsx
// Safe area + flex layout
<SafeAreaView className="flex-1 bg-white dark:bg-black">
  <View className="flex-1 px-4 py-2">
    {/* Screen content */}
  </View>
</SafeAreaView>

// Card
<View className="mx-4 my-2 rounded-xl bg-white p-4 shadow-sm dark:bg-gray-800">
  <Text className="text-lg font-semibold text-gray-900 dark:text-white">Title</Text>
  <Text className="mt-1 text-sm text-gray-500 dark:text-gray-400">Subtitle</Text>
</View>

// Row with gap
<View className="flex-row items-center gap-3">
  <Image className="h-10 w-10 rounded-full" source={{ uri }} />
  <Text className="flex-1 text-base">Username</Text>
</View>
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `className` not working | Missing babel preset | Add `nativewind/babel` to presets |
| Styles not applied | Missing `global.css` import | Import `./global.css` in root `_layout.tsx` |
| Metro crash | Missing `withNativeWind` | Wrap config in `metro.config.js` |
| Types not found | Missing declaration | Add `nativewind-env.d.ts` with `/// <reference types="nativewind/types" />` |
| Dark mode not toggling | Missing `useColorScheme` | Use `useColorScheme()` from `nativewind` |
| Custom colors ignored | No config purge | Restart Metro: `npx expo start -c` |
