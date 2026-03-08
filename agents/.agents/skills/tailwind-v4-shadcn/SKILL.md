---
name: tailwind-v4-shadcn
description: |
  Set up Tailwind v4 with shadcn/ui using @theme inline pattern and CSS variable architecture. Four-step pattern: CSS variables, Tailwind mapping, base styles, automatic dark mode. Prevents 8 documented errors.

  Use when initializing React projects with Tailwind v4, or fixing colors not working, tw-animate-css errors, @theme inline dark mode conflicts, @apply breaking, v3 migration issues.
---

# Tailwind v4 + shadcn/ui Production Stack

**Production-tested**: WordPress Auditor (https://wordpress-auditor.webfonts.workers.dev)  
**Last Updated**: 2026-01-20  
**Versions**: tailwindcss@4.1.18, @tailwindcss/vite@4.1.18  
**Status**: Production Ready ✅

## Quick Start (Exact Order)

```bash
# 1) Install dependencies
pnpm add tailwindcss @tailwindcss/vite
pnpm add -D @types/node tw-animate-css
pnpm dlx shadcn@latest init

# 2) Remove v3 config if present
rm tailwind.config.ts
```

**vite.config.ts**
```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } }
})
```

**components.json (critical for v4)**
```json
{
  "tailwind": {
    "config": "",
    "css": "src/index.css",
    "baseColor": "slate",
    "cssVariables": true
  }
}
```

## The Four-Step Architecture (Mandatory)

### 1) Define CSS variables at root
```css
@import "tailwindcss";
@import "tw-animate-css";

:root {
  --background: hsl(0 0% 100%);
  --foreground: hsl(222.2 84% 4.9%);
  --primary: hsl(221.2 83.2% 53.3%);
}

.dark {
  --background: hsl(222.2 84% 4.9%);
  --foreground: hsl(210 40% 98%);
  --primary: hsl(217.2 91.2% 59.8%);
}
```

### 2) Map variables to Tailwind utilities
```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
}
```

### 3) Apply base styles
```css
@layer base {
  body {
    background-color: var(--background);
    color: var(--foreground);
  }
}
```

### 4) Use semantic utilities
```tsx
<div className="bg-background text-foreground" />
```

## Dark Mode Essentials

1. Add `ThemeProvider` (template: `templates/theme-provider.tsx`)  
2. Wrap app in `src/main.tsx`  
3. Verify `.dark` toggles on `<html>`  
4. Add toggle UI (`pnpm dlx shadcn@latest add dropdown-menu`)

## Critical Rules

### Always
1. Keep `:root` and `.dark` at root level (not nested in `@layer base`)  
2. Wrap root/dark color values with `hsl(...)`  
3. Keep `components.json` tailwind config empty (`"config": ""`)  
4. Use `@tailwindcss/vite` plugin for Vite projects  
5. Remove `tailwind.config.ts` in v4 setups

### Never
1. Use nested `@theme` (`.dark { @theme { ... } }`)  
2. Double-wrap colors (`hsl(var(--background))`)  
3. Depend on v3 config/theme patterns for colors  
4. Use `@apply` with classes defined only in `@layer base/components` (v4 breaking change)  
5. Assume `@layer base` order is safe without understanding native CSS layer precedence

## `@theme inline` vs `@theme`

- Use `@theme inline` for standard shadcn light/dark setups (default case) ✅
- Use `@theme` (without inline) for multi-theme/custom-variant systems (`data-mode`, theme palettes) ✅

See `references/troubleshooting.md` (Error #6) for full rationale and examples.

## Setup Checklist

- [ ] `@tailwindcss/vite` installed and used in `vite.config.ts`
- [ ] `components.json` has `"config": ""`
- [ ] `tailwind.config.ts` removed
- [ ] `src/index.css` follows all 4 steps
- [ ] ThemeProvider wraps app
- [ ] Dark mode toggle works

## Templates

- `templates/index.css` - complete CSS variables + mapping
- `templates/components.json` - shadcn v4 config
- `templates/vite.config.ts` - Vite plugin setup
- `templates/theme-provider.tsx` - ThemeProvider
- `templates/utils.ts` - `cn()` utility

## Supporting References (Read As Needed)

- `references/setup-config.md` - expanded setup/config patterns, plugin setup, file-by-file checks
- `references/troubleshooting.md` - full 8 documented errors and fixes
- `references/v4-updates-and-plugins.md` - OKLCH updates, built-ins, plugin syntax, migration gotchas
- `references/architecture.md` - deeper architecture explanation
- `references/dark-mode.md` - full ThemeProvider and toggle implementation
- `references/migration-guide.md` - hardcoded-color to semantic-token migration workflow
- `references/common-gotchas.md` - additional practical pitfalls

## Official Docs

- https://ui.shadcn.com/docs/installation/vite
- https://ui.shadcn.com/docs/tailwind-v4
- https://tailwindcss.com/docs

---

**Skill Version**: 3.1.0  
**Tailwind v4**: 4.1.18
