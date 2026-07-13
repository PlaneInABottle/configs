---
name: tailwind-v4-shadcn
description: Configure or migrate Tailwind CSS v4 projects that use shadcn/ui. Use for Vite plugin setup, CSS-first theme tokens, @theme and @theme inline behavior, class-based dark mode, legacy config compatibility, or Tailwind v3-to-v4 migration problems.
---

# Tailwind CSS v4 with shadcn/ui

Inspect the existing framework, Tailwind version, `components.json`, CSS entrypoint, aliases, and current shadcn-generated theme before changing configuration. Preserve working project conventions and verify current official Tailwind and shadcn documentation.

## Vite Setup

```bash
pnpm add tailwindcss @tailwindcss/vite
```

```ts
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [tailwindcss()],
});
```

```css
@import "tailwindcss";
```

Do not delete `tailwind.config.*` automatically. Tailwind v4 can load legacy configuration through `@config` during incremental migration, and plugins or project-specific settings may still depend on it.

## Semantic Tokens

Use CSS variables for runtime theme values and map them to Tailwind utilities with `@theme inline` when utilities should reference those variables directly.

```css
:root {
  --app-background: oklch(1 0 0);
  --app-foreground: oklch(0.145 0 0);
}

.dark {
  --app-background: oklch(0.145 0 0);
  --app-foreground: oklch(0.985 0 0);
}

@theme inline {
  --color-background: var(--app-background);
  --color-foreground: var(--app-foreground);
}
```

Color values may use OKLCH, HSL, RGB, or another valid CSS color representation. Do not require `hsl(...)` wrapping or double-wrap variables that already contain complete color values.

## Dark Mode

For class-based dark mode, define the current Tailwind custom variant when the project needs it:

```css
@custom-variant dark (&:where(.dark, .dark *));
```

Match the application's existing theme provider and selector. Data-attribute themes and multi-theme systems may use different variants and `@theme` strategies.

## Migration

1. Run the current official upgrade guidance and inspect its diff.
2. Keep legacy configuration until every required setting has a CSS-first replacement or explicit `@config` bridge.
3. Migrate theme tokens and plugins incrementally.
4. Verify generated utilities, dark mode, animation dependencies, and production builds.
5. Remove obsolete files only after proving they are no longer loaded.

## References

- [references/setup-config.md](references/setup-config.md)
- [references/troubleshooting.md](references/troubleshooting.md)
- [references/v4-updates-and-plugins.md](references/v4-updates-and-plugins.md)
- [references/architecture.md](references/architecture.md)
- [references/dark-mode.md](references/dark-mode.md)
- [references/migration-guide.md](references/migration-guide.md)
- [references/common-gotchas.md](references/common-gotchas.md)

Treat version numbers in references as examples and verify installed behavior before applying them.
