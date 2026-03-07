# CLI Patterns

## Local Verification Notes

- In one local environment, `sqlite3 --help` showed `-batch`, `-json`, `-tabs`, `-noheader`, `-readonly`, and `-cmd`.
- In one local environment, `psql --help` showed `-c`, `-X`, `-v ON_ERROR_STOP=1`, `-A`, `-t`, `-F`, and `--csv`.
- In one local environment, `redis-cli --help` showed `-x`, `--raw`, `--csv`, `--json`, `-n`, `-u`, and `-e` on `redis-cli 8.4.0`.
- In one local environment, `docker exec --help` showed `-i` keeps stdin open, and `docker compose exec --help` showed `-T` disables TTY allocation.
- `mongosh` was not installed in that environment, so its non-interactive examples below remain conservative, pattern-based suggestions rather than locally executed commands.

## Tool-Specific Patterns

### sqlite3

Prefer direct non-interactive queries against a file path:

```bash
sqlite3 -batch -readonly -json app.db "select id, status from jobs order by id;"
sqlite3 -tabs -noheader app.db "select id, status from jobs order by id;"
sqlite3 -cmd '.headers off' -cmd '.mode json' app.db "select count(*) as total from jobs;"
```

Use `-json` when downstream tooling expects JSON. Use `-tabs -noheader` when you want stable plain-text diffs or `cut`/`awk` pipelines.

### psql

Prefer explicit non-interactive flags and stable output:

```bash
psql -X -v ON_ERROR_STOP=1 --csv -c "select id,status from jobs order by id" "$DATABASE_URL"
psql -X -v ON_ERROR_STOP=1 -A -t -F $'\t' -c "select id,status from jobs order by id" "$DATABASE_URL"
docker compose exec -T db psql -X -v ON_ERROR_STOP=1 --csv -U app -d appdb -c "select id,status from jobs order by id"
```

Use `-X` to avoid local `~/.psqlrc` surprises. Use `--csv` or `-A -t` to avoid pretty table output.

### mongosh

Verify exact option support with `mongosh --help` in the target environment before relying on it.

If the target environment supports `--quiet`, `--eval`, and `--json[=canonical|relaxed]`, conservative scripted patterns may look like:

```bash
mongosh --quiet --json=canonical "$MONGODB_URI/app" --eval 'db.jobs.find({}, { _id: 1, status: 1 }).sort({ _id: 1 }).toArray()'
mongosh --quiet --json=canonical --eval 'db.jobs.countDocuments({ status: "done" })' "$MONGODB_URI/app"
```

Keep the wording around `mongosh` conservative unless you can verify it locally in the target environment.

### redis-cli

Prefer raw or JSON-shaped output and stdin piping for payloads:

```bash
redis-cli --raw GET job:123:status
redis-cli --json HGETALL job:123
printf '%s' '{"job":123,"status":"queued"}' | redis-cli -x SET last-job-payload
docker compose exec -T redis redis-cli --raw LRANGE worker:events 0 -1
```

`--json` is version-sensitive. Confirm it with `redis-cli --help` on the target machine before depending on it.

## Snapshot and Diff Patterns

Take a snapshot before the app action, then compare it after:

```bash
before="$(sqlite3 -json app.db 'select id,status from jobs order by id;')"
# run API/UI/worker action here
after="$(sqlite3 -json app.db 'select id,status from jobs order by id;')"
python3 - <<'PY' "$before" "$after"
import json, sys
print({"before": json.loads(sys.argv[1]), "after": json.loads(sys.argv[2])})
PY
```

The same pattern works with `psql`, `mongosh`, or `redis-cli` if you first normalize output to deterministic JSON or delimiter-based text.

## Verification Boundaries

- Verify local tool availability before promising a command.
- Prefer local help output over memory for flag support.
- If the native client is unavailable, say so and either install it or use a minimal one-shot script that only prints data.
- Do not overstate cross-version behavior; call out version-sensitive flags such as `redis-cli --json`.
- Keep examples path-agnostic. Use environment variables, connection strings, or container/service names instead of machine-specific paths.
