---
name: shadcn-ui
description: Provides complete shadcn/ui component library patterns including installation, configuration, and implementation of accessible React components. Use when setting up shadcn/ui, installing components, building forms with React Hook Form and Zod, customizing themes with Tailwind CSS, or implementing UI patterns like buttons, dialogs, dropdowns, tables, and complex form layouts.
allowed-tools: Read, Write, Bash, Edit, Glob
---

# shadcn/ui Component Patterns

## Overview

Use this skill to implement production-ready shadcn/ui interfaces with strong accessibility, predictable theming, and reusable component patterns.

## When to Use

- Setting up a new project with shadcn/ui.
- Installing or configuring individual components.
- Building forms with React Hook Form and Zod validation.
- Implementing accessible UI patterns (dialogs, selects, sheets, navigation).
- Customizing themes with Tailwind and CSS variables.
- Integrating shadcn/ui into Next.js App Router projects.

## Core Workflow

1. Initialize shadcn/ui with `npx shadcn@latest init`.
2. Install only required components with `npx shadcn@latest add <component>`.
3. Import from `@/components/ui/*` and compose using Tailwind utility classes.
4. Build forms with React Hook Form + Zod.
5. Validate keyboard/focus behavior, labels, and ARIA semantics.
6. Customize via your local component files and CSS variables (you own the code).

## Critical Rules

- shadcn/ui is not an npm UI package; components are copied into your project.
- Configure path alias support (`@/*`) before using generated imports.
- Ensure Tailwind CSS and required Radix dependencies are installed.
- Add `"use client"` for interactive components in Next.js App Router.
- Prefer component variant props and utility classes over ad-hoc styling overrides.
- Keep form validation schema-driven (Zod) and connected with resolver-based form state.

## Quick Start Commands

```bash
# New app
npx create-next-app@latest my-app --typescript --tailwind --eslint --app
cd my-app
npx shadcn@latest init
npx shadcn@latest add button input form card dialog select

# Existing app
npm install tailwindcss-animate class-variance-authority clsx tailwind-merge lucide-react
npx shadcn@latest init
```

## Reference Map

Read supporting files based on task scope:

- **Setup and configuration**: [`references/SETUP_AND_CONFIGURATION.md`](references/SETUP_AND_CONFIGURATION.md)
  - Initialization, dependency matrix, tsconfig/Tailwind/CSS variable setup, warnings.
- **Component implementation details**: [`references/COMPONENT_PATTERNS.md`](references/COMPONENT_PATTERNS.md)
  - Buttons, inputs, forms, cards, dialogs, sheets, navigation, table, toast, charts, customization, best practices.
- **Next.js-specific patterns**: [`references/NEXTJS_INTEGRATION.md`](references/NEXTJS_INTEGRATION.md)
  - App Router, layout integration, server components, route handlers, server actions, metadata, fonts.
- **Examples and recipes**: [`references/EXAMPLES_AND_RECIPES.md`](references/EXAMPLES_AND_RECIPES.md)
  - End-to-end examples, multi-field forms, and common composition patterns.
- **Advanced installation patterns**: [`references/CLI_ADVANCED.md`](references/CLI_ADVANCED.md)
  - Multi-namespace installs, monorepo workflows, CLI flags, and troubleshooting.
- **Registry configuration**: [`references/REGISTRY_SETUP.md`](references/REGISTRY_SETUP.md)
  - Registry schemas, custom styles, plugin config, and secure registry auth setup.
- **Supplemental references already in this skill**:
  - [`references/reference.md`](references/reference.md)
  - [`references/ui-reference.md`](references/ui-reference.md)
  - [`references/chart.md`](references/chart.md)
  - [`references/learn.md`](references/learn.md)

## Common Patterns (Fast Paths)

When you have a specific UI pattern in mind, use these guides:

- **Login/Sign-up forms**: Start with [`references/COMPONENT_PATTERNS.md`](references/COMPONENT_PATTERNS.md) (inputs, forms, buttons) → then [`references/EXAMPLES_AND_RECIPES.md`](references/EXAMPLES_AND_RECIPES.md) for complete form examples
- **Data tables**: [`references/COMPONENT_PATTERNS.md`](references/COMPONENT_PATTERNS.md) (table section) → [`references/EXAMPLES_AND_RECIPES.md`](references/EXAMPLES_AND_RECIPES.md) for table patterns
- **Navigation/menus**: [`references/COMPONENT_PATTERNS.md`](references/COMPONENT_PATTERNS.md) (navigation section) → examples
- **Modal dialogs**: [`references/COMPONENT_PATTERNS.md`](references/COMPONENT_PATTERNS.md) (dialogs) → examples
- **Customizing colors/theme**: [`references/SETUP_AND_CONFIGURATION.md`](references/SETUP_AND_CONFIGURATION.md) (CSS variables) → [`references/NEXTJS_INTEGRATION.md`](references/NEXTJS_INTEGRATION.md) if using Next.js
- **Advanced features** (CLI, registries, plugins): [`references/CLI_ADVANCED.md`](references/CLI_ADVANCED.md) or [`references/REGISTRY_SETUP.md`](references/REGISTRY_SETUP.md)

## Minimal Implementation Checklist

- Install required components and dependencies.
- Confirm aliases and styling pipeline compile correctly.
- Build UI with composable primitives from `@/components/ui`.
- Use RHF + Zod for forms and error messages.
- Verify dark mode and CSS variable theme behavior.
- Validate accessibility before completion.

## External References

- Official Docs: https://ui.shadcn.com
- Radix UI: https://www.radix-ui.com
- React Hook Form: https://react-hook-form.com
- Zod: https://zod.dev
- Tailwind CSS: https://tailwindcss.com
- Examples: https://ui.shadcn.com/examples
