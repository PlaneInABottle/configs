# Registry Setup

## Table of Contents
- [Core Files](#core-files)
- [Registry Index Structure](#registry-index-structure)
- [Registry Item Types](#registry-item-types)
- [Custom Style Definitions](#custom-style-definitions)
- [Multi-file Component Templates](#multi-file-component-templates)
- [Universal Files and Target Mapping](#universal-files-and-target-mapping)
- [Plugin and CSS Configuration](#plugin-and-css-configuration)
- [components.json Schema Patterns](#componentsjson-schema-patterns)
- [Secure Multi-registry Authentication](#secure-multi-registry-authentication)
- [Build and Serve Commands](#build-and-serve-commands)

## Core Files

Registry workflows typically involve:
- `registry.json` (index of items),
- `registry-item.json`-shaped entries (per resource),
- `components.json` (consumer-side install/auth config),
- generated `/public/r/*.json` outputs (served resources).

## Registry Index Structure

Minimal `registry.json`:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry.json",
  "name": "acme",
  "homepage": "https://acme.com",
  "items": []
}
```

Expanded example with multiple components:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry.json",
  "name": "acme",
  "homepage": "https://acme.com",
  "items": [
    {
      "name": "login-form",
      "type": "registry:component",
      "title": "Login Form",
      "description": "A login form component.",
      "files": [
        {
          "path": "registry/new-york/auth/login-form.tsx",
          "type": "registry:component"
        }
      ]
    }
  ]
}
```

## Registry Item Types

Common item types:
- `registry:component`
- `registry:block`
- `registry:style`
- `registry:item`

Each item can define:
- `dependencies` (npm packages),
- `registryDependencies` (other registry resources),
- `files` (paths, types, optional targets/content),
- `cssVars` or `css` configuration (when applicable).

## Custom Style Definitions

Define an installable style package that extends shadcn defaults:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "example-style",
  "type": "registry:style",
  "dependencies": ["@tabler/icons-react"],
  "registryDependencies": [
    "login-01",
    "calendar",
    "https://example.com/r/editor.json"
  ],
  "cssVars": {
    "theme": {
      "font-sans": "Inter, sans-serif"
    },
    "light": {
      "brand": "20 14.3% 4.1%"
    },
    "dark": {
      "brand": "20 14.3% 4.1%"
    }
  }
}
```

Use style items to standardize:
- brand primitives,
- typography defaults,
- dependency presets for reusable blocks.

## Multi-file Component Templates

`registry:block` can bundle pages + components together:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "login-01",
  "type": "registry:block",
  "description": "A simple login form.",
  "registryDependencies": ["button", "card", "input", "label"],
  "files": [
    {
      "path": "blocks/login-01/page.tsx",
      "content": "import { LoginForm } from '@/components/login-form'",
      "type": "registry:page",
      "target": "app/login/page.tsx"
    },
    {
      "path": "blocks/login-01/components/login-form.tsx",
      "content": "export function LoginForm() { return null }",
      "type": "registry:component"
    }
  ]
}
```

This is the best pattern for complete feature templates.

## Universal Files and Target Mapping

Use `registry:item` for cross-project files with explicit target paths:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "my-eslint-config",
  "type": "registry:item",
  "files": [
    {
      "path": "/path/to/registry/default/custom-eslint.json",
      "type": "registry:file",
      "target": "~/.eslintrc.json",
      "content": "{ \"extends\": \"eslint:recommended\" }"
    }
  ]
}
```

Use this sparingly for controlled tooling distribution.

## Plugin and CSS Configuration

Declare npm dependencies required by plugin-backed CSS:

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "typography-component",
  "type": "registry:item",
  "dependencies": ["@tailwindcss/typography"],
  "css": {
    "@plugin \"@tailwindcss/typography\"": {},
    "@layer components": {
      ".prose": {
        "max-width": "65ch"
      }
    }
  }
}
```

Keep plugin declarations co-located with the registry item that needs them.

## components.json Schema Patterns

Minimal baseline:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/styles/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "iconLibrary": "lucide"
}
```

Multiple registry configuration:

```json
{
  "registries": {
    "@shadcn": "https://ui.shadcn.com/r/{name}.json",
    "@company-ui": {
      "url": "https://registry.company.com/ui/{name}.json",
      "headers": {
        "Authorization": "Bearer ${COMPANY_TOKEN}"
      }
    },
    "@team": {
      "url": "https://team.company.com/{name}.json",
      "params": {
        "team": "frontend",
        "version": "${REGISTRY_VERSION}"
      }
    }
  }
}
```

## Secure Multi-registry Authentication

Private registry shape with custom headers:

```json
{
  "@company": {
    "url": "https://registry.company.com/v1/{name}.json",
    "headers": {
      "Authorization": "Bearer ${COMPANY_TOKEN}",
      "X-Registry-Version": "1.0"
    }
  }
}
```

Authentication practices:
1. Use env variables (`${TOKEN}`) instead of hardcoded secrets.
2. Keep token scope minimal (read-only where possible).
3. Validate missing env failures early in local + CI.

## Build and Serve Commands

Install CLI once in the project:

```bash
npm install shadcn@latest
```

Configure build script:

```json
{
  "scripts": {
    "registry:build": "shadcn build"
  }
}
```

Run build and serve flows:

```bash
# generate registry artifacts
npm run registry:build

# serve in Next.js app context
npm run dev
```

For MCP-compatible registry bootstrapping:

```bash
npx shadcn@latest mcp init
```

