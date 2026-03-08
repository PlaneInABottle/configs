# CLI Advanced

## Table of Contents
- [Install from Namespaced Registries](#install-from-namespaced-registries)
- [Install Multiple Resources](#install-multiple-resources)
- [Monorepo and Workspace Patterns](#monorepo-and-workspace-patterns)
- [Initialize from Local Templates](#initialize-from-local-templates)
- [Inspect Registries Before Install](#inspect-registries-before-install)
- [Advanced CLI Flags](#advanced-cli-flags)
- [Troubleshooting](#troubleshooting)
- [High-Signal Command Recipes](#high-signal-command-recipes)

## Install from Namespaced Registries

Use namespace-aware references when you need resources outside the default shadcn registry.

```bash
# install from configured namespace
npx shadcn@latest add @v0/dashboard

# install from another namespace
npx shadcn@latest add @acme/button
```

This pattern depends on `components.json` registry configuration.

## Install Multiple Resources

Install multiple resources (including mixed namespaces) in one command:

```bash
npx shadcn@latest add @acme/header @internal/auth-utils
```

Also supported with non-component resources:

```bash
npx shadcn@latest add @acme/header @lib/auth-utils @ai/chatbot-rules
```

Bulk install for local bootstrapping:

```bash
npx shadcn@latest add --all
```

Use `--all` only when you intentionally want a full local copy of the catalog.

## Monorepo and Workspace Patterns

Run CLI commands from the target app package (not the monorepo root) unless you intentionally pass `--cwd`.

```bash
cd apps/web
npx shadcn@latest add button input dialog
```

Equivalent root-driven workflow:

```bash
npx shadcn@latest add button input dialog --cwd apps/web
```

Tips:
- Keep a dedicated `components.json` in each app workspace that owns UI.
- Avoid adding UI components to packages that should stay framework-agnostic.

## Initialize from Local Templates

Initialize directly from a local registry/template JSON:

```bash
npx shadcn init ./template.json
```

Use this for:
- local registry testing,
- repeatable team scaffolding,
- pre-approved internal starter definitions.

## Inspect Registries Before Install

List and inspect before writing files:

```bash
# list all resources from a namespace
npx shadcn list @acme

# inspect one resource and dependencies
npx shadcn view @acme/auth-system
```

This prevents accidental installs and makes diffs predictable.

## Advanced CLI Flags

### `shadcn add` flags

```txt
Usage: shadcn add [options] [components...]

-y, --yes              Skip confirmation prompt
-o, --overwrite        Overwrite existing files
-c, --cwd <path>       Set working directory
-a, --all              Add all available components
-p, --path <path>      Override install path
-s, --silent           Mute output
--src-dir              Use src directory
--no-src-dir           Do not use src directory
--css-variables        Enable CSS variables
--no-css-variables     Disable CSS variables
```

Useful combinations:

```bash
# non-interactive CI/local script
npx shadcn@latest add button card -y --silent

# force overwrite during controlled migration
npx shadcn@latest add dialog -o

# install into explicit app path from monorepo root
npx shadcn@latest add input --cwd apps/web --path src/components/ui
```

### `shadcn init` flags

```txt
Usage: shadcn init [options]

-t, --template <name>       Template (next, next-monorepo)
-b, --base-color <name>     Base color theme
-y, --yes                   Skip prompt
-f, --force                 Overwrite existing configuration
-c, --cwd <path>            Set working directory
-s, --silent                Mute output
--src-dir / --no-src-dir
--css-variables / --no-css-variables
--no-base-style             Skip base style install
```

### MCP bootstrap

Initialize MCP metadata for configured registries:

```bash
npx shadcn@latest mcp init
```

## Troubleshooting

### React 19 peer dependency prompt

On some npm setups, init may prompt for conflict strategy:

```txt
It looks like you are using React 19.
Some packages may fail to install due to peer dependency issues.

Use --force
Use --legacy-peer-deps
```

Recommended workflow:
- Prefer default dependency resolution when possible.
- Use `--legacy-peer-deps` only when blocked by temporary ecosystem lag.
- Re-run install cleanly after lockfile updates.

### Missing registry environment variables

Example CLI error:

```txt
Registry "@private" requires the following environment variables:
 • REGISTRY_TOKEN

Set the required environment variables to your .env or .env.local file.
```

Checklist:
1. Define required env vars in `.env.local` (or CI secret store).
2. Ensure shell/session exports are available to CLI.
3. Re-run `shadcn add` after confirming env visibility.

### Registry/auth debugging

If a namespaced install fails:
1. Run `npx shadcn list <namespace>` to verify endpoint access.
2. Run `npx shadcn view <namespace/resource>` to inspect resolution.
3. Validate `components.json` URL placeholders and headers.

## High-Signal Command Recipes

```bash
# install multiple namespaced resources into monorepo app
npx shadcn@latest add @acme/header @internal/auth-utils --cwd apps/web

# inspect before install
npx shadcn view @acme/auth-system && npx shadcn add @acme/auth-system

# scripted, non-interactive installation
npx shadcn@latest add button input form -y --silent

# initialize with explicit options
npx shadcn@latest init --template next-monorepo --base-color zinc --src-dir
```

