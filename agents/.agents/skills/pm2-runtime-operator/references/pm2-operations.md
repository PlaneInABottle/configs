# PM2 Operations Reference

Use these patterns as conservative defaults and re-check local help when version-specific behavior matters.

## Command patterns

### Start

```bash
pm2 start npm --name project-web -- run dev
pm2 start main.py --interpreter python3 --name project-api
pm2 start "uvicorn main:app --host 0.0.0.0 --port 8000" --name project-api
```

Prefer the command form the app already uses and always supply a stable process name.

### Inspect

```bash
pm2 list
pm2 show project-api
pm2 logs project-api --lines 100 --nostream
pm2 logs project-api
```

- `list` gives the summary table.
- `show` gives one process view.
- `logs --nostream` is safer for bounded snapshots.
- `logs` without `--nostream` is for live follow mode.

### Lifecycle ladder

```bash
pm2 restart project-api
pm2 stop project-api
pm2 delete project-api
```

- `restart` keeps the process registered and running.
- `stop` keeps it registered but inactive.
- `delete` removes it from the PM2 list.

Prefer process names over numeric ids when you control naming.

## Decision rules

### Name processes predictably

Prefer `project-role` names such as `acme-web`, `acme-api`, or `acme-worker`. Add a suffix only when it reduces ambiguity, for example `acme-web-3000`.

### Inspect before mutating state

Use this order:

1. `pm2 list`
2. `pm2 show <name>`
3. `pm2 logs <name> --lines 100 --nostream`

That sequence usually distinguishes "missing process", "stopped process", "crash loop", and "app started but unhealthy".

### Use bounded cleanup

After a local task:

1. `pm2 stop <name>`
2. `pm2 delete <name>`
3. `pm2 list`

Avoid `delete all` unless you explicitly own the full PM2 state for the current task.

## Environment notes

- Keep machine-specific paths, ports, and secrets out of reusable examples.
- PM2 documentation indicates `pm2 restart <name> --update-env` may matter after environment changes; verify that behavior on the target install when it matters.
- Confirm success with the app's own health check, CLI probe, or expected port response.

## Boundary with `ai-native-workflow`

Use this skill for PM2-specific runtime operations: naming, start/inspect/log/restart/stop/delete flows, and bounded PM2 cleanup.

Keep broader runtime setup and end-to-end verification in `ai-native-workflow`, including Docker topology plus Hurl, browser, database, and other system-level checks.

## Local evidence

This session locally verified `pm2 --version`, `pm2 start --help`, `pm2 list`, `pm2 show --help`, `pm2 logs --help`, `pm2 restart --help`, `pm2 stop --help`, and `pm2 delete --help`. Other flags or semantics should stay conservative until verified on the target install.
