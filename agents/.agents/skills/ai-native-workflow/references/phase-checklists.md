# Phase Checklists — Detailed Breakdowns

## Contents

- [Phase 1: Runtime Setup Analysis](#phase-1-runtime-setup-analysis)
- [Phase 2: Environment Bootstrapping](#phase-2-environment-bootstrapping)
- [Phase 3: Implementation & Verification (The Universal Toolkit)](#phase-3-implementation-verification-the-universal-toolkit)
- [Phase 4: Programmatic Operations](#phase-4-programmatic-operations)
- [Phase 5: Continuous Iteration](#phase-5-continuous-iteration)
- [Phase 6: Teardown](#phase-6-teardown)

Detailed guidance for each phase of the AI-native workflow. Use alongside the main [SKILL.md](../SKILL.md).

---

## Phase 1: Runtime Setup Analysis

### Step 1.1 — Analyze Project Characteristics

Profile the project before choosing a runtime using robust, non-hanging bash commands:

| Dimension | AI-Safe Command | Why It Matters |
|-----------|---------------|----------------|
| File count | `find . -type f -not -path "*/node_modules/*" -not -path "*/\.git/*" -not -path "*/\.venv/*" -not -path "*/target/*" \| wc -l` | Affects Docker volume performance |
| Dependency size | `[ -d node_modules ] && du -sh node_modules/ \|\| echo "0"` | Large deps slow container builds |
| Native binaries | Check for `.node`, `.so`, compiled deps | May not work across architectures |
| Hot-reload | JS/TS (Vite), Rust (cargo watch), Go (Air) | File watching differs in containers |
| Stateful services | Databases, caches, queues | Containers excel here |

### Step 1.2 — Compare Runtime Options

**Option A: Full Docker** (Reproducible but slow HMR on macOS)
**Option B: Fully Native** (Fast HMR but inconsistent database setup)
**Option C: Hybrid (Usually Best)** (Fast native HMR + reliable stateful Docker services)

### Step 1.3 — AI-Specific Requirements

AI agents need:
- **Process Management:** Use PM2 for app servers (auto-restart, log rotation, named processes)
- **Headless Management:** Agents must start/stop processes in the background with proper tracking.
- **Machine-Readable Readiness Probes:** Instead of parsing logs, use `curl -sSf` for HTTP, `pg_isready` for Postgres, etc.

### Step 1.4 — Inventory Boundaries
- [ ] Network / HTTP (`hurl`, `curl`)
- [ ] gRPC / WebSockets (`grpcurl`, `wscat`)
- [ ] Persistence Layers (`psql`, `mongosh`, `sqlite3`, `redis-cli`)
- [ ] File/Media Systems (MinIO S3 mock, `../playbooks/media-file-handling.md`)

---

## Phase 2: Environment Bootstrapping

### Step 2.1 — Bootstrapping & Dependencies
Before starting services, explicitly install the project's dependencies with its native package manager, verify mandatory binaries are available, and bootstrap `.env` only if it does not already exist:
```bash
command -v hurl >/dev/null || echo "Install hurl before running API playbooks"
command -v agent-browser >/dev/null || echo "Install agent-browser before running UI playbooks"
command -v docker >/dev/null || echo "Install Docker before running docker compose services"
[ -f .env ] || cp .env.example .env
```

Dependency installation examples:

```bash
# JavaScript / TypeScript
npm install
pnpm install
yarn install

# Python
pip install -r requirements.txt
uv sync

# Rust / Go
cargo build
go mod download
```

### Step 2.2 — Write the Startup Sequence

Document the startup sequence using structured, AI-parseable runtime notes.
**CRITICAL: Use PM2 for app servers. Use Docker for databases.**

````markdown
## Start Database (Example: Postgres)
Command: `docker compose up -d db`
Verify (bounded readiness): 
```bash
for attempt in {1..30}; do
  docker compose exec -T db pg_isready && break
  sleep 1
  if [ "$attempt" -eq 30 ]; then
    echo "Postgres did not become ready in time" >&2
    exit 1
  fi
done
```
Failure: `docker compose logs db` to inspect crashes

## Start Application Server (Example: Node.js)
Command: `pm2 start npm --name "myapp" -- run dev`
Verify (Polling loop):
```bash
curl --retry 10 --retry-connrefused --retry-delay 1 --retry-max-time 30 -sSf http://localhost:3000/health
```
Failure: `pm2 logs myapp` to inspect errors
````

### Step 2.3 — Test Background Mode
Services must survive session boundaries.

1. Start services using PM2 (app servers) or Docker.
   - App: `pm2 start npm --name "myapp" -- run dev`
   - Database: `docker compose up -d db`
2. Simulate session end (kill the current bash session).
3. Start a new session and verify the services are still running:
   - PM2: `pm2 list` to check status
   - Docker: `docker compose ps`

---

## Phase 3: Implementation & Verification (The Universal Toolkit)

Once the environment is running, extend the repository's established test suite and add boundary checks where they provide distinct evidence. Do not create a parallel testing stack without a concrete need.

### Step 3.1 — Verify via Universal Boundaries
1. **Mock Dependencies:** Reuse the project's existing fake or mock boundary. Add WireMock or Prism only when the feature requires an external API fake (see `../playbooks/mocking-dependencies.md`).
2. **Inject State:** Use existing fixtures or generate deterministic payloads when needed (see `../playbooks/universal-data-generation.md`).
3. **Execute & Assert:** Run affected project tests, then use Hurl or native datastore clients for external boundary evidence where useful.

### Step 3.2 — Interactive Interface Verification
If the application has a UI, verify it headlessly:
- **Web UI:** Use `agent-browser open` and `agent-browser snapshot -i` to verify DOM state.
- **Web UI browser semantics:** Follow the dedicated `agent-browser` skill references for session persistence, headed/manual debugging, and ref handling instead of relying on memory.
- **CLI App:** Run standard Unix streams (`mycli --dry-run > out.txt`) and assert the exit code `echo $?`.

---

## Phase 4: Programmatic Operations

### Step 4.1 — Enumerate Machine-Controllable Flows

List the flows that must work without human intervention:
- [ ] HTTP / GraphQL endpoints (See `../playbooks/api-contract-testing.md` or `../playbooks/graphql-testing.md`)
- [ ] CLI entry points and flags
- [ ] Web UI actions reachable through DOM events (`agent-browser`)
- [ ] Async entry points such as queues, cron-style jobs, or WebSockets when applicable (See `../playbooks/websocket-testing.md`)

### Step 4.2 — Verify Non-Interactive Control

For each flow, confirm an agent can execute it end-to-end without manual clicks, prompts, or hidden setup:
- [ ] Inputs can be injected by command, file, HTTP request, or browser action
- [ ] The command is bounded and does not hang indefinitely
- [ ] Success can be verified via exit code, HTTP status, DOM snapshot, or datastore query
- [ ] Failure output is inspectable via logs, stderr, or response body

### Step 4.3 — Confirm Automation Readiness

Run at least one concrete verification per surface:
- [ ] API flows can be triggered from `.hurl`, `curl`, or another scriptable client
- [ ] CLI flows support flags, stdin, or environment variables instead of interactive-only prompts
- [ ] UI flows can be driven through `agent-browser open`, `snapshot -i`, `click`, `fill`, and `wait`
- [ ] Resulting state can be asserted through the appropriate playbook boundary rather than manual observation

If a flow needs deeper protocol-specific coverage, use the relevant playbook instead of duplicating procedures here.

---

## Phase 5: Continuous Iteration

### Test-Driven Development Cycle (Revised for AI)

1. **Implement Core Logic:** Keep the change focused and consistent with the repository architecture.
2. **Run Native Tests:** Use the project's established unit, component, and integration suites for behavior they already own.
3. **Implement Boundaries:** Expose or update HTTP, gRPC, CLI, worker, or UI boundaries as required.
4. **Add Boundary Evidence:** Use Hurl, native datastore inspection, `agent-browser`, or Maestro when an external check adds coverage that the project suite does not provide.

### Robust Debugging Workflow

1. Read error message + stack trace.
2. Form hypothesis.
3. Apply targeted fix.
4. **Verify safely:** Do not write infinite `while` loops to check logs. Use curl's built-in retry flags to assert the fix worked.
```bash
# Example AI-safe verification loop
curl --retry 10 --retry-connrefused --retry-delay 1 --retry-max-time 30 -sSf http://localhost:3000/health > /dev/null
```

---

## Phase 6: Teardown
Never leave background processes or unmanaged state running indefinitely.

- PM2 app servers: `pm2 delete <app-name>`
- Docker services: `docker compose down`
- Both combined: delete the named PM2 process, then run `docker compose down` for the current project
