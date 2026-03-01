---
name: ai-native-workflow
description: Comprehensive guide for AI-managed development workflows and language-agnostic system operations. MANDATORY for any feature implementation, API creation, UI development, debugging, or testing. Defines the universal toolchain (Hurl, Faker, Docker, agent-browser) used to execute and verify code without relying on language-specific frameworks like pytest or Jest.
license: MIT
---

# AI-Native Workflow: The Systems Operator Paradigm

A true AI agent does not tie its tooling to the application's language (e.g., using `pytest` for Python or `Jest` for Node). Instead, the AI acts as a **Systems Operator**, treating the application as a language-agnostic *System Under Test (SUT)*. 

You must interact with the application across standard boundaries (HTTP, SQL, DOM, CLI) using a universal toolkit of free, isolated, scriptable CLI tools.

## The Universal Agent Toolkit

When verifying your implementations, **never** default to writing brittle, language-specific test suites unless the user explicitly names a test framework (e.g., "write a pytest suite"). Generic requests for testing MUST use the following universal tools based on the system boundary:

| Boundary | Universal Tool | Agent Action |
|---|---|---|
| **Infrastructure** | **Docker Compose** | Standardizes "start/stop/reset". Follow YAGNI: only add auxiliary services (Redis, Mailpit) when explicitly needed. |
| **Data Generation** | **Env-Native Faker** | Use environment-native scripting (e.g., Python `faker`, Node `faker`) to generate deterministic JSON, test fixtures, or DB payloads. The principle is isolated scripts, not the specific language. |
| **Dependencies** | **json-server / Prism** | Spin up instant fake APIs to mock 3rd party dependencies. Use environment variables to swap real URLs for local fakes. |
| **Network / API** | **Network Boundaries** | Use `hurl` for REST/GraphQL, `grpcurl` for gRPC, and `wscat` for WebSockets. |
| **Interface (Web/CLI)** | **`agent-browser`** | Use `agent-browser` as an Interactive REPL for Web UIs. For CLI apps, use standard Unix streams (`stdout/stderr`) or `expect` scripts. |
| **Persistence / DB** | **Native Clients** | Bypass the app layer. Use native datastore clients (`psql`, `mongosh`, `sqlite3`, `redis-cli`) directly to assert state changes. |
| **Async / Events** | **`redis-cli` / `rpk`** | Inject messages directly into queues and verify worker side-effects. |
| **Media / Files** | **`pexels-media` skill** | Download real, valid binary fixtures for upload testing. Never pass corrupted mock bytes. |

### The "Iterative Bash" Pattern
Because you have a persistent terminal, build complex assertions iteratively. Use bash pipes to extract state rather than writing custom parsing scripts.
*(e.g., `curl -sSf localhost:8025/api | jq | grep "token="`)*

---

## Action-Oriented Playbooks

For exact implementation details, code snippets, and CLI commands for the toolkit above, reference the following playbooks:

- [playbooks/api-contract-testing.md](playbooks/api-contract-testing.md) (Hurl syntax, iterative bash assertions, handling async state)
- [playbooks/universal-data-generation.md](playbooks/universal-data-generation.md) (Universal Node/Faker.js for DB seeds, API mock payloads, and test fixtures)
- [playbooks/mocking-dependencies.md](playbooks/mocking-dependencies.md) (JSON-Server, Prism, Wiremock - payloads generated via Faker.js)
- [playbooks/media-file-handling.md](playbooks/media-file-handling.md) (Pexels, MinIO S3 mocking)

---

## The 5 Phases of AI-Managed Development

1. **Phase 1: Runtime Setup Analysis (YAGNI Infrastructure)**
   Determine the optimal dev environment. Prefer a **Hybrid** approach: Docker for stateful services (DB), native execution for app code (fast HMR). Keep `docker-compose.yml` minimal. Only add what you need.
2. **Phase 2: Skill Creation**
   Codify operational knowledge immediately. If a setup requires non-obvious steps, undocumented workarounds, or repeated explanations, use the `skill-creator` to document it. **Skills are cheaper than code.**
3. **Phase 3: Implementation & Verification**
   Build the feature and immediately verify it using the **Universal Toolkit Playbooks** linked above.
4. **Phase 4: Programmatic Operations**
   Ensure you can manage the application programmatically without a human (e.g., manipulating UI state using `agent-browser`).
5. **Phase 5: Continuous Iteration & Debugging**
   Run existing unit tests after every code change. Tests are your guardrails. **NEVER write language-specific integration tests under ANY circumstances. Use pytest/cargo test/Jest ONLY for pure logic unit testing.** (Note: Do not use Jest/pytest to test functions that import web frameworks like Express/FastAPI, ORMs, or rely on I/O. If you must mock HTTP or DB calls to test a function, it is an integration test. Use `.hurl` instead). You MUST use the Universal Toolkit (`.hurl`, `agent-browser`, `psql`) for all new test assertions. During UI changes, run `agent-browser snapshot -i` and screenshot to track visual regressions. Re-snapshot after every navigation. You MUST read the output of `agent-browser snapshot -i` before interacting with ANY UI element; NEVER blindly guess element IDs. Always wait for async data fetching or specific state changes (using `agent-browser wait`) before re-snapshotting. Do not snapshot immediately after a click if a loading state or async mutation is expected.

*(For detailed, step-by-step checklists for each phase, see `references/phase-checklists.md`)*

---

## Interactive UI Verification (`agent-browser`)

Instead of writing rigid test scripts, act as a real user. Use `agent-browser` for fast feedback during active implementation.

```bash
# Start dev server detached
npm run dev &

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
| **Detached Shells** | Start persistent services with `&` or Docker's `-d`. Attached shells die with your session. |
| **Skill-First** | Check available skills *before* implementing. Load every matching skill and combine their guidance. |

| Anti-Pattern | Do Instead |
|---|---|
| Writing `pytest`/`Jest` for integration tests | Use `.hurl` for APIs, `psql` for DB, `agent-browser` for UI. Keep the SUT language-agnostic. |
| Stale browser refs | Always run `agent-browser snapshot -i` after a click/navigation. Refs invalidate on DOM mutation. |
| Over-engineering Docker | Start with just App + DB. Add Redis/Mailpit only when a specific feature requires it. |
| Creating monolithic skills | Adhere to "One skill per concern". |

---

See [references/phase-checklists.md](references/phase-checklists.md) for granular breakdowns of the 5 phases.
See [references/best-practices.md](references/best-practices.md) for extended guidance and testing pyramids.
