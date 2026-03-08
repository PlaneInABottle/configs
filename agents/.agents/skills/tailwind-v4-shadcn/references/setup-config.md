# Setup & Configuration Guide

## Table of Contents
- [Install](#install)
- [Minimal Required Files](#minimal-required-files)
- [CSS Architecture Reference](#css-architecture-reference)
- [Dark Mode Wiring](#dark-mode-wiring)
- [Verification](#verification)

## Install

```bash
pnpm add tailwindcss @tailwindcss/vite
pnpm add -D @types/node tw-animate-css
pnpm dlx shadcn@latest init
rm tailwind.config.ts
```

## Minimal Required Files

### `vite.config.ts`
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

### `components.json`
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

## CSS Architecture Reference

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

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
}

@layer base {
  body {
    background-color: var(--background);
    color: var(--foreground);
  }
}
```

## Dark Mode Wiring

1. Add `ThemeProvider` from `templates/theme-provider.tsx`
2. Wrap app root in `main.tsx`
3. Add toggle (`dropdown-menu`) if needed
4. Verify `.dark` class is applied on `<html>`

## Verification

- `bg-primary`, `bg-background`, `text-foreground` render correctly
- Theme persists across reloads
- No `tailwind.config.ts` remains
- No `tailwindcss-animate` dependency remains
- `@theme inline` contains complete variable mapping
