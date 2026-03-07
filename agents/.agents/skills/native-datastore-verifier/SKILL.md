---
name: native-datastore-verifier
description: "Companion playbook for direct datastore and state inspection after actions in an AI-native workflow. Use alongside ai-native-workflow when API, worker, or UI actions should be confirmed by querying local or containerized state with native clients such as psql, sqlite3, mongosh, or redis-cli, especially for non-interactive output shaping, before/after diffs, and environment-specific evidence checks."
---

# Native Datastore Verifier

## Overview

Use native datastore clients to inspect state directly after app actions instead of trusting logs, ORM assumptions, or agent guesses.

Keep this skill narrow: load it alongside `../ai-native-workflow/SKILL.md` when you need post-action datastore inspection, and leave broader runtime setup, HTTP verification, UI verification, and non-datastore tooling to that umbrella workflow.

## Post-Action Inspection Loop

1. Confirm the datastore CLI exists locally before relying on memory:
   - `command -v psql sqlite3 mongosh redis-cli`
   - If a tool is missing, say so and verify a different available boundary instead of pretending the client exists.
2. Capture a `before` snapshot whenever the action should mutate state.
3. Trigger the app action through the real boundary that matters: API, UI, worker, or CLI.
4. Query the datastore directly with non-interactive flags and machine-readable output.
5. Normalize the result to stable text or JSON before comparing it.
6. Report the exact state change, including empty-result cases.

## Output Discipline

- Prefer one-liners and stdout pipelines over ad hoc helper programs.
- Keep assertions outside any fallback scripts; scripts may fetch data and print it, but should not decide pass/fail.
- Avoid interactive shells, pagers, and TTY formatting when the output must be diffed or piped.
- Treat local command help and observed output as the best environment-specific evidence for option support.

## Docker and Container Boundaries

When the datastore runs in Docker, keep commands non-interactive:

- Use `docker exec -i CONTAINER ...` when targeting a named container directly.
- Use `docker compose exec -T SERVICE ...` when targeting a Compose service and you need clean machine output.
- Avoid relying on default interactive TTY behavior for captured output.

## References

- Load [references/cli-patterns.md](references/cli-patterns.md) for command patterns with local verification notes, output-shaping options, before/after diffing, and tool-specific cautions.
