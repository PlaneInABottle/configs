# Phase Checklists — Detailed Breakdowns

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
- **Headless Management:** Agents must start/stop processes in the background with output redirection.
- **Machine-Readable Readiness Probes:** Instead of parsing logs, use `curl -sSf` for HTTP, `pg_isready` for Postgres, etc.

### Step 1.4 — Inventory Boundaries
- [ ] Network / HTTP (`hurl`, `curl`)
- [ ] gRPC / WebSockets (`grpcurl`, `wscat`)
- [ ] Persistence Layers (`psql`, `mongosh`, `sqlite3`, `redis-cli`)
- [ ] File/Media Systems (MinIO S3 mock, `../playbooks/media-file-handling.md`)

---

## Phase 2: Skill Creation & Environment Bootstrapping

### Step 2.1 — Bootstrapping & Dependencies
Before starting services, explicitly install dependencies and prepare the environment:
```bash
npm install
cp .env.example .env
```

### Step 2.2 — Write the Startup Sequence

Create the runtime skill document using structured, AI-parseable formats.
**CRITICAL: Never assume a human is watching the terminal. Use headless tools.**

```markdown
## Start Database (Example: Postgres)
Command: `docker compose up -d db`
Verify (Polling loop): 
```bash
until docker exec db pg_isready; do sleep 1; done
```
Failure: `docker compose logs db` to inspect crashes
```

### Step 2.3 — Test Background Mode
Services must survive session boundaries.
1. Start services in the background (e.g. `docker compose -d` or `npm run dev > .app.log 2>&1 & echo $! > .app.pid`).
2. Simulate session end (kill the current bash session).
3. Start a new session and verify the services are still running via readiness probes.

---

## Phase 3: Implementation & Verification (The Universal Toolkit)

Once the environment is running, NEVER write language-specific integration tests under ANY circumstances. Use the Universal Playbooks.

### Step 3.1 — Verify via Universal Boundaries
1. **Mock Dependencies:** Spin up WireMock or Prism if the feature requires external APIs (See `../playbooks/mocking-dependencies.md`).
2. **Inject State:** Generate specific deterministic payloads using environment-native Faker scripts, and pipe them directly into the API or DB (See `../playbooks/universal-data-generation.md`).
3. **Execute & Assert:** Use `.hurl` to trigger the network boundary (See `../playbooks/api-contract-testing.md`), or use native datastore clients to assert persistence changes directly. 

### Step 3.2 — Interactive Interface Verification
If the application has a UI, verify it headlessly:
- **Web UI:** Use `agent-browser open` and `agent-browser snapshot -i` to verify DOM state.
- **CLI App:** Run standard Unix streams (`mycli --dry-run > out.txt`) and assert the exit code `echo $?`.

---

## Phase 4: Programmatic Operations

Ensure you can manage the application programmatically without a human. Confirm you can trigger all flows via APIs, CLI, or DOM events.

---

## Phase 5: Continuous Iteration

### Test-Driven Development Cycle (Revised for AI)

1. **Implement Core Logic:** Write pure functions/methods.
2. **Unit Test Pure Logic:** Use the language's native runner (`pytest`, `Jest`, `cargo test`) **ONLY** for pure, isolated unit logic. 
3. **Implement Boundaries:** Expose the logic via HTTP/gRPC/CLI.
4. **Integration Verification:** NEVER write, modify, or append to `pytest` or `Jest` files for API/Database testing. NEVER use, write, or modify Cypress, Playwright, or React Testing Library (RTL) test scripts. All UI testing MUST be done interactively via `agent-browser` against the running dev server. You MUST use `.hurl`, `agent-browser`, or database injection to verify the integration.

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
- If using Docker: `docker compose down`
- If using native background processes: `kill $(cat .app.pid) && rm .app.pid`
