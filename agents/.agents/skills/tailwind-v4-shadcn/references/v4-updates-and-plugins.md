# Tailwind v4 Updates, Plugins, and Migration Notes

## Table of Contents
- [What changed in v4](#what-changed-in-v4)
- [Plugin syntax in v4](#plugin-syntax-in-v4)
- [Migration gotchas](#migration-gotchas)

## What changed in v4

### OKLCH default palette

Tailwind v4 moved default colors to OKLCH for better perceptual consistency and smoother gradients.

- Modern browsers support OKLCH broadly.
- Tailwind still generates practical fallbacks.
- Custom colors can be defined in OKLCH or HSL.

```css
@theme {
  --color-brand: oklch(0.7 0.15 250);
}
```

### Built-ins (no plugin needed)

- Container Queries (`@container`, `@md:*`)
- Line Clamp (`line-clamp-*`)

## Plugin syntax in v4

Use `@plugin` in CSS (not v3 import/require patterns).

### Typography
```bash
pnpm add -D @tailwindcss/typography
```

```css
@import "tailwindcss";
@plugin "@tailwindcss/typography";
```

### Forms
```bash
pnpm add -D @tailwindcss/forms
```

```css
@import "tailwindcss";
@plugin "@tailwindcss/forms";
```

## Migration gotchas

1. Automated migration utilities can miss complex setups (plugins/theme extensions).
2. Preflight defaults changed (headings/lists/buttons may look different).
3. Prefer `@tailwindcss/vite` in Vite projects over PostCSS complexity.
4. Ring default changed (`ring` appears thinner vs v3; use `ring-3` when needed).

## References

- Tailwind v4 docs: https://tailwindcss.com/docs
- Tailwind v4 release: https://tailwindcss.com/blog/tailwindcss-v4
- shadcn Tailwind v4 docs: https://ui.shadcn.com/docs/tailwind-v4
