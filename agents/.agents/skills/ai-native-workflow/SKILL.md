---
name: ai-native-workflow
description: Comprehensive guide for AI-managed development workflows and language-agnostic system operations. MANDATORY for any feature implementation, API creation, UI development, debugging, or testing. Defines the universal toolchain (Hurl, Faker, Docker, agent-browser) used to execute and verify code without relying on language-specific frameworks like pytest or Jest.
license: MIT
---

# AI-Native Workflow: The Systems Operator Paradigm

A true AI agent does not tie its tooling to the application's language (e.g., using `pytest` for Python or `Jest` for Node). Instead, the AI acts as a **Systems Operator**, treating the application as a language-agnostic *System Under Test (SUT)*. 

You must interact with the application across standard boundaries (HTTP, SQL, DOM, CLI) using a universal toolkit of free, isolated, scriptable CLI tools.

## The Universal Agent Toolkit

When verifying your implementations, **never** default to writing language-specific test suites. Generic requests for testing MUST use the following universal tools based on the system boundary:

| Boundary | Universal Tool | Agent Action |
|---|---|---|
| **Infrastructure** | **Docker Compose** | Standardizes "start/stop/reset". Follow YAGNI: only add auxiliary services (Redis, Mailpit) when explicitly needed. |
| **Data Generation** | **Env-Native Faker** | Use environment-native scripting (e.g., Python `faker`, Node `faker`) to generate deterministic JSON, test fixtures, or DB payloads. Data generation scripts MUST ONLY output standard formats (JSON/SQL/CSV) to stdout. They MUST NOT contain network requests, database connections, or test assertions. All outputs must be piped to the Universal Toolkit (e.g., `.hurl`, `psql`). |
| **Dependencies** | **json-server / Prism** | Spin up instant fake APIs to mock 3rd party dependencies. Use environment variables to swap real URLs for local fakes. |
| **Network / API** | **Network Boundaries** | Use `hurl` for REST/GraphQL, `grpcurl` for gRPC, and `wscat` for WebSockets. |
| **Interface (Web/CLI)** | **`agent-browser`** | Use `agent-browser` as an Interactive REPL for Web UIs. For CLI apps, use standard Unix streams (`stdout/stderr`) or `expect` scripts. |
| **Persistence / DB** | **Native Clients** | Bypass the app layer. Use native datastore clients (`psql`, `mongosh`, `sqlite3`, `redis-cli`) directly to assert state changes. If a native CLI client is unavailable, write a minimalist, single-file headless script to execute the query and print JSON to stdout. Do not write assertions inside this script; pipe the stdout to `jq` or `grep`. |
| **Async / Events** | **`redis-cli` / `rpk`** | Inject messages directly into queues and verify worker side-effects. |
| **Media / Files** | **`pexels-media` skill** | Download real, valid binary fixtures for upload testing. Never pass corrupted mock bytes. |

### The "Iterative Bash" Pattern
Because you have a persistent terminal, build complex assertions iteratively. Use bash pipes to extract state rather than writing custom parsing scripts.
*(e.g., `curl -sSf localhost:8025/api | jq | grep "token="`)*

---

## Required Binary Checks

Before following a playbook, verify the required CLI tools are installed and on `PATH`.

```bash
command -v hurl >/dev/null || echo "Install hurl before running API or GraphQL playbooks"
command -v agent-browser >/dev/null || echo "Install agent-browser before running UI playbooks"
command -v docker >/dev/null || echo "Install Docker before running infrastructure flows"
```

If a required binary is missing, stop and install it with your operating system package manager or the tool's official installation instructions before continuing.

---

## Action-Oriented Playbooks

For exact implementation details, code snippets, and CLI commands for the toolkit above, reference the following playbooks:

- [playbooks/api-contract-testing.md](playbooks/api-contract-testing.md) (REST: auth, file uploads, webhooks, negative testing)
- [playbooks/graphql-testing.md](playbooks/graphql-testing.md) (GraphQL queries, mutations, variables)
- [playbooks/websocket-testing.md](playbooks/websocket-testing.md) (WebSocket connection, messaging, auth)
- [playbooks/load-testing.md](playbooks/load-testing.md) (hey, k6, wrk for performance testing)
- [playbooks/debugging-profiling.md](playbooks/debugging-profiling.md) (Logs, remote debug, CPU/memory profiling)
- [playbooks/universal-data-generation.md](playbooks/universal-data-generation.md) (Faker.js, Python Faker for test data)
- [playbooks/mocking-dependencies.md](playbooks/mocking-dependencies.md) (JSON-Server, Prism, Wiremock)
- [playbooks/media-file-handling.md](playbooks/media-file-handling.md) (Pexels, MinIO S3 mocking)

---

## The 6 Phases of AI-Managed Development

1. **Phase 1: Runtime Setup Analysis (YAGNI Infrastructure)**
   Determine the optimal dev environment. Prefer a **Hybrid** approach: Docker for stateful services (DB), native execution for app code (fast HMR). Keep `docker-compose.yml` minimal. Only add what you need.
2. **Phase 2: Skill Creation**
   Codify operational knowledge immediately. If a setup requires non-obvious steps, undocumented workarounds, or repeated explanations, use the `skill-creator` to document it. **Skills are cheaper than code.**
3. **Phase 3: Implementation & Verification**
   Build the feature and immediately verify it using the **Universal Toolkit Playbooks** linked above.
4. **Phase 4: Programmatic Operations**
   Ensure you can manage the application programmatically without a human (e.g., manipulating UI state using `agent-browser`).
5. **Phase 5: Continuous Iteration & Debugging**
   Run existing unit tests after every code change. Tests are your guardrails. **NEVER write, modify, or append to language-specific integration tests under ANY circumstances. Use pytest/cargo test/Jest ONLY for pure logic unit testing.** (Note: Do not use Jest/pytest to test functions that import web frameworks like Express/FastAPI, ORMs, or rely on I/O. If testing a function requires mocking external modules, database connections, or HTTP clients, it is an integration boundary. Do NOT write a unit test for it; test it end-to-end via `.hurl` or native clients). You MUST use the Universal Toolkit (`.hurl`, `agent-browser`, `psql`) for all new test assertions. During UI changes, run `agent-browser snapshot -i` and screenshot to track visual regressions. Re-snapshot after every navigation. You MUST read the output of `agent-browser snapshot -i` before interacting with ANY UI element; NEVER blindly guess element IDs. Always wait for async data fetching or specific state changes (using `agent-browser wait`) before re-snapshotting. Do not snapshot immediately after a click if a loading state or async mutation is expected.
6. **Phase 6: Teardown**
   Stop managed background processes and clean up temporary runtime state once validation is complete.

*(For detailed, step-by-step checklists for each phase, see `references/phase-checklists.md`)*

---

## PM2 Process Management

PM2 is the **recommended process manager** for running application servers. It provides log rotation, auto-restart on crash, named processes for easy targeting, and real-time log streaming.

**Prerequisite:** PM2 must be installed globally: `npm install -g pm2`

### Commands

```bash
# Start app server (Node.js)
pm2 start npm --name "project-name" -- run dev

# Start Python app
pm2 start main.py --interpreter python3 --name "python-api"

# Start with arguments
pm2 start "uvicorn main:app --host 0.0.0.0 --port 8000" --name "fastapi"

# View real-time logs
pm2 logs project-name

# View last 50 lines (no streaming)
pm2 logs project-name --lines 50 --nostream

# View all processes
pm2 list

# Stop
pm2 stop project-name

# Restart after code changes
pm2 restart project-name

# Delete completely
pm2 delete project-name

# Stop all
pm2 delete all

# Install log rotation (run once)
pm2 install pm2-logrotate

# Configure rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
```

### Multi-Language Support

PM2 auto-detects interpreter by file extension:
| Extension | Interpreter |
|-----------|-------------|
| `.py` | Python |
| `.rb` | Ruby |
| `.sh` | Bash |
| `.js` | Node |

### Hybrid Pattern with Docker

Use PM2 for app servers, Docker for databases:

```bash
# Start database (Docker)
docker compose up -d db

# Start app server (PM2)
pm2 start npm --name "myapp" -- run dev

# Verify both running
pm2 list && docker compose ps
```

---

## Interactive UI Verification (`agent-browser`)

Instead of writing rigid test scripts, act as a real user. Use `agent-browser` for fast feedback during active implementation.

For browser-specific semantics such as `--session` vs `--session-name`, saved state handling, headed/manual debugging, and advanced command patterns, load the dedicated `agent-browser` skill and follow its reference files instead of re-deriving behavior from memory.

```bash
# Start application dev server with PM2
pm2 start npm --name "myapp" -- run dev

# Wait for server to be ready (health check)
curl --retry 10 --retry-connrefused --retry-delay 1 --retry-max-time 30 -sSf http://localhost:3000/health

# Verify rendering and state
agent-browser open http://localhost:3000/login
agent-browser snapshot -i

# Interact
agent-browser fill @e1 "$TEST_USER"
agent-browser click @e2
agent-browser wait --url "**/dashboard"

# Re-snapshot because DOM changed!
agent-browser snapshot -i
agent-browser screenshot
```

---

## Best Practices & Anti-Patterns

| Practice | Why / How |
|---|---|
| **Use Environment Variables** | Swap real external services with local CLI fakes (e.g. `STRIPE_URL=http://localhost:4010`) |
| **Health Checks > Logs** | Always prefer querying an HTTP health endpoint over fragile bash `grep`s of container logs. |
| **Background Processes** | Use **PM2** for app servers (Node, Python, etc.). Use Docker for databases. |
| **Skill-First** | Check available skills *before* implementing. Load every matching skill and combine their guidance. |

| Anti-Pattern | Do Instead |
|---|---|
| Writing `pytest`/`Jest` for integration tests | Use `.hurl` for APIs, `psql` for DB, `agent-browser` for UI. Keep the SUT language-agnostic. |
| Stale browser refs | Always run `agent-browser snapshot -i` after a click/navigation. Refs invalidate on DOM mutation. |
| Over-engineering Docker | Start with just App + DB. Add Redis/Mailpit only when a specific feature requires it. |
| Creating monolithic skills | Adhere to "One skill per concern". |

---

See [references/phase-checklists.md](references/phase-checklists.md) for granular breakdowns of the 6 phases.
See [references/best-practices.md](references/best-practices.md) for extended guidance and testing pyramids.
