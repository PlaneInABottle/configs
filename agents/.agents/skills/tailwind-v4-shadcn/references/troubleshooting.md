# Troubleshooting (8 Documented Errors)

## Table of Contents
- [1) tw-animate-css import error](#1-tw-animate-css-import-error)
- [2) Semantic colors not working](#2-semantic-colors-not-working)
- [3) Dark mode not switching](#3-dark-mode-not-switching)
- [4) Duplicate `@layer base`](#4-duplicate-layer-base)
- [5) Build fails with `tailwind.config.ts`](#5-build-fails-with-tailwindconfigts)
- [6) `@theme inline` in multi-theme setups](#6-theme-inline-in-multi-theme-setups)
- [7) `@apply` + `@layer` breaking change](#7-apply--layer-breaking-change)
- [8) `@layer base` precedence issues](#8-layer-base-precedence-issues)
- [Quick symptom map](#quick-symptom-map)

## 1) tw-animate-css import error

**Error**: Missing animation package / wrong package (`tailwindcss-animate`).

**Fix**:
```bash
pnpm add -D tw-animate-css
```

```css
@import "tailwindcss";
@import "tw-animate-css";
```

## 2) Semantic colors not working

**Error**: `bg-primary` or `bg-background` has no effect.

**Cause**: Missing `@theme inline` mapping.

**Fix**:
```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
}
```

## 3) Dark mode not switching

**Cause**: Missing ThemeProvider wiring.

**Fix**:
1. Add ThemeProvider
2. Wrap app in `main.tsx`
3. Confirm `.dark` toggles on `<html>`

## 4) Duplicate `@layer base`

**Error**: Duplicate layer behavior/conflicts.

**Fix**: Keep one consolidated `@layer base` block.

## 5) Build fails with `tailwind.config.ts`

**Cause**: v4 setup still includes v3 config.

**Fix**:
```bash
rm tailwind.config.ts
```

## 6) `@theme inline` in multi-theme setups

**Error**: Dark/custom themes don’t update correctly with custom variants (`data-mode`, multiple palettes).

**Cause**: `@theme inline` can inline values at build time.

**Fix**: Use `@theme` (without inline) for multi-theme systems.

```css
@custom-variant dark (&:where([data-mode=dark], [data-mode=dark] *));

@theme {
  --color-text-primary: var(--color-slate-900);
  --color-bg-primary: var(--color-white);
}

@layer theme {
  [data-mode="dark"] {
    --color-text-primary: var(--color-white);
    --color-bg-primary: var(--color-slate-900);
  }
}
```

**Use inline for**: standard shadcn light/dark only.

## 7) `@apply` + `@layer` breaking change

**Error**: `Cannot apply unknown utility class`.

**Cause**: v4 only exposes `@utility` classes for `@apply`.

**Fix**:
```css
@utility custom-button {
  @apply px-4 py-2 bg-blue-500;
}
```

Or use native CSS in `@layer base`.

## 8) `@layer base` precedence issues

**Error**: Base styles appear ignored.

**Cause**: Native layer ordering and utility precedence.

**Fix option A (explicit layers)**:
```css
@import "tailwindcss/theme.css" layer(theme);
@import "tailwindcss/base.css" layer(base);
@import "tailwindcss/components.css" layer(components);
@import "tailwindcss/utilities.css" layer(utilities);
```

**Fix option B (recommended)**: keep key styles at root level and minimize `@layer base` usage unless ordering is intentional.

## Quick Symptom Map

| Symptom | Likely Cause | Fix |
|---|---|---|
| `bg-primary` not working | Missing `@theme inline` | Add full mapping block |
| Dark mode stuck | Missing provider/wiring | Wrap app with ThemeProvider |
| Build error | `tailwind.config.ts` exists | Remove v3 config file |
| Animation import error | Wrong animation package | Use `tw-animate-css` |
| `@apply` unknown utility | v4 layer behavior change | Define utility in `@utility` |
