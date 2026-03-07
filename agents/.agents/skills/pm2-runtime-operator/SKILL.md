---
name: pm2-runtime-operator
description: Manage local application processes with PM2. Use when the task is specifically to start, name, inspect, restart, stop, delete, or debug PM2-managed runtimes, stream or snapshot PM2 logs, or clean up local PM2 process state safely without expanding into broader end-to-end verification work.
---

# PM2 Runtime Operator

Operate local runtimes through PM2 with conservative, target-by-name commands. Keep this skill focused on PM2 lifecycle work; use `ai-native-workflow` for wider system verification, Docker topology, `agent-browser`, or Hurl-based testing.

## Quick start

1. Verify PM2 is available before making claims:
   - `command -v pm2`
   - `pm2 --version`
2. Prefer a stable process name before `start`, `restart`, `stop`, or `delete`.
3. Inspect first:
   - `pm2 list`
   - `pm2 show <name-or-id>`
4. Prefer targeted cleanup:
   - `pm2 stop <name>`
   - `pm2 delete <name>`
5. Confirm teardown with `pm2 list` before leaving the session.

The reference file records what this session checked locally; treat other flags or behaviors as version-sensitive until you verify them on the target install.

## Naming guidance

- Prefer lowercase hyphenated names such as `project-api`, `project-web`, or `project-worker`.
- Keep one durable name per long-lived role so later `logs`, `restart`, `stop`, and `delete` commands stay predictable.
- Add a suffix only when it reduces ambiguity, for example `project-web-3000`.
- Avoid generic names like `app`, `server`, or `dev` when multiple runtimes may exist.

## Safe operating pattern

### Start

Use the smallest command that clearly identifies the entrypoint and process name.

```bash
# Node package script
pm2 start npm --name project-web -- run dev

# Python entrypoint with explicit interpreter
pm2 start main.py --interpreter python3 --name project-api

# Shell command form when the app is normally launched as one command
pm2 start "uvicorn main:app --host 0.0.0.0 --port 8000" --name project-api
```

After `start`, verify readiness with the app's own health check or expected port behavior instead of relying on logs alone.

### Inspect

Use PM2 inspection before changing state:

```bash
pm2 list
pm2 show project-api
pm2 logs project-api --lines 100 --nostream
pm2 logs project-api
```

- Use `pm2 list` for the high-level table.
- Use `pm2 show <name-or-id>` when you need one process's details.
- Use `pm2 logs <name> --nostream` for a bounded snapshot.
- Use `pm2 logs <name>` only when a live stream is useful and you intend to stop it.

### Restart, stop, delete

Escalate in this order:

1. `pm2 restart <name>` when the process should continue existing.
2. `pm2 stop <name>` when you want it quiesced but still listed.
3. `pm2 delete <name>` when you want it removed from the PM2 process table.

Prefer a specific process name over `all`. Use bulk commands only when you have already confirmed the PM2 namespace is disposable for the current task.

## Environment and debugging

- Keep runtime configuration in environment variables or the app's normal startup interface; do not hardcode machine-specific paths into PM2 examples.
- When environment values change, re-check local help and installed-version docs before assuming restart semantics. PM2 documentation indicates `--update-env` can matter on restart; verify on the target install when that detail is important.
- Prefer application health checks, HTTP probes, or direct CLI verification over "logs look fine" conclusions.
- Use `pm2 logs <name> --lines <n> --nostream` for short diagnostics before switching to a live stream.
- If log files become noisy during an investigation, verify local help before using ancillary PM2 log-management commands.

## Cleanup and zombie avoidance

- Stop and delete the exact process you started when the task is done.
- Re-run `pm2 list` to confirm the entry is gone or intentionally stopped.
- If the application spawns children outside PM2's control, verify with normal OS-level process inspection before ending the session.
- Avoid `pm2 delete all` unless you explicitly confirmed the full local PM2 state belongs to the current task.

## Read this next

- Load [references/pm2-operations.md](references/pm2-operations.md) for command patterns, decision rules, and the boundary between this skill and `ai-native-workflow`.
