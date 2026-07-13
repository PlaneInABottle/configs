---
name: ai-native-workflow
description: Coordinate runtime setup and boundary-level verification for feature implementation, debugging, and testing. Use when work spans application processes, HTTP APIs, databases, browser or mobile UI, queues, containers, or multiple verification layers. Complement rather than replace the repository's existing test framework.
license: MIT
---

# AI-Native Workflow: The Systems Operator Paradigm

Treat the application as a system with several observable boundaries. Use repository-native tests for logic and established integration coverage, then add boundary-level checks when they provide evidence the existing suite cannot.

## The Universal Agent Toolkit

Choose tools from local project conventions first. Add the following tools when their boundary matches the behavior under test:

| Boundary | Universal Tool | Agent Action |
|---|---|---|
| **Infrastructure** | **Docker Compose** | Standardizes "start/stop/reset". Follow YAGNI: only add auxiliary services (Redis, Mailpit) when explicitly needed. |
| **Data Generation** | **Env-Native Faker** | Generate deterministic fixtures in the project's normal language or fixture system. Keep standalone generators focused on data generation. |
| **Dependencies** | **json-server / Prism** | Spin up instant fake APIs to mock 3rd party dependencies. Use environment variables to swap real URLs for local fakes. |
| **Network / API** | **Network Boundaries** | Use `hurl` for REST/GraphQL, `grpcurl` for gRPC, and `wscat` for WebSockets. |
| **External APIs** | **`api-discovery` skill** | Find and select reliable public APIs for your needs. Maps dev tasks to APIs (weather, geocoding, email validation, etc.). |
| **Interface (Web/CLI)** | **`agent-browser`** | Use `agent-browser` as an Interactive REPL for Web UIs. For CLI apps, use standard Unix streams (`stdout/stderr`) or `expect` scripts. |
| **Interface (Mobile)** | **`maestro mcp`** | Use `maestro mcp` to directly control iOS/Android simulators — tap, input text, inspect hierarchy, screenshot. For the full skill, load `maestro-testing`. |
| **Persistence / DB** | **Native Clients** | Inspect state with `psql`, `mongosh`, `sqlite3`, or `redis-cli` when direct state evidence matters. Do not expose secret values in output. |
| **Async / Events** | **`redis-cli` / `rpk`** | Inject messages directly into queues and verify worker side-effects. |
| **Media / Files** | **`pexels-media` skill** | Download real, valid binary fixtures for upload testing. Never pass corrupted mock bytes. |

### Iterative verification

Start with the smallest observable check. Add another boundary only when it resolves a real uncertainty. Avoid printing credentials, tokens, decrypted secrets, or full environment values while debugging.

---

## Required Binary Checks

Before following a playbook, verify the required CLI tools are installed and on `PATH`.

```bash
command -v hurl >/dev/null || echo "Install hurl before running API or GraphQL playbooks"
command -v agent-browser >/dev/null || echo "Install agent-browser before running UI playbooks"
command -v maestro >/dev/null || echo "Install maestro before running mobile playbooks"
command -v docker >/dev/null || echo "Install Docker before running infrastructure flows"
```

If a required binary is missing, use an existing project tool when possible. Install new global software only when the task requires it and the installation source has been verified.

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
- **`api-discovery` skill** - Find and select reliable public APIs for weather, geocoding, email validation, etc.

---

## The 6 Phases of AI-Managed Development

1. **Phase 1: Runtime Setup Analysis (YAGNI Infrastructure)**
   Determine the optimal dev environment. Prefer a **Hybrid** approach: Docker for stateful services (DB), native execution for app code (fast HMR). Keep `docker-compose.yml` minimal. Only add what you need.
2. **Phase 2: Runtime Knowledge Handoff**
   Keep this skill focused on runtime setup and verification. If session findings turn into repository skill-governance work (for example: auditing overlap, deciding split boundaries, or updating shared skill guidance), hand that work to [`skill-maintainer`](../skill-maintainer/SKILL.md) for boundary decisions and [`skill-creator`](../skill-creator/SKILL.md) for authoring/package mechanics instead of expanding this skill into a governance playbook.
3. **Phase 3: Implementation & Verification**
   Build the feature, run affected repository-native tests, and add focused boundary checks where useful.
4. **Phase 4: Programmatic Operations**
   Ensure you can manage the application programmatically without a human (e.g., manipulating UI state using `agent-browser` for web, `maestro mcp` for mobile).
5. **Phase 5: Continuous Iteration & Debugging**
   Run the smallest affected test set while iterating, then the broader repository checks required by the change. Add tests in the project's established framework when behavior is testable there. Use Hurl, native clients, `agent-browser`, or Maestro for boundaries that are better verified externally. Inspect the current UI hierarchy before interacting and wait for asynchronous state changes before re-inspecting.
6. **Phase 6: Teardown**
   Stop managed background processes and clean up temporary runtime state once validation is complete.

*(For detailed, step-by-step checklists for each phase, see `references/phase-checklists.md`)*

---

## PM2 Process Management

PM2 is the **recommended process manager** for running application servers. 

**Prerequisite:** `npm install -g pm2`

**Essential commands:**
```bash
pm2 start npm --name "project" -- run dev    # Start
pm2 logs project-name                          # View logs
pm2 restart project-name                       # Restart after changes
pm2 delete project-name                        # Targeted cleanup
pm2 install pm2-logrotate                      # Log rotation (one-time)
```

For detailed PM2 operations, load the `pm2-runtime-operator` skill.

---

## Interactive UI Verification

### Web (`agent-browser`)

Use `agent-browser` for fast UI feedback during implementation.

```bash
pm2 start npm --name "myapp" -- run dev
agent-browser open http://localhost:3000/login
agent-browser snapshot -i
agent-browser fill @e1 "$TEST_USER"
agent-browser click @e2
```

For browser-specific semantics, load the `agent-browser` skill.

### Mobile (`maestro mcp`)

Use Maestro MCP for direct device control during mobile feature implementation and debugging.

```bash
# Use the connected MCP interface rather than assuming tool names.
# Typical sequence: list devices, inspect the screen, run an inline flow,
# then inspect or capture a screenshot again.
```

**During implementation/debugging, use MCP tools interactively on a live device.** Write YAML flows only after the feature is validated, for CI and repeatable regression runs. Load `maestro-testing` skill for full YAML syntax and flow authoring.

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
| Replacing an established test suite with a parallel one | Extend existing tests first; add boundary tools only where they provide distinct evidence. |
| Writing Maestro YAML flows before validating a feature | Use `maestro mcp` tools interactively during implementation. Write YAML flows only after the feature works on a live device. |
| Stale browser refs | Always run `agent-browser snapshot -i` after a click/navigation. Refs invalidate on DOM mutation. |
| Over-engineering Docker | Start with just App + DB. Add Redis/Mailpit only when a specific feature requires it. |
| Creating monolithic skills | Adhere to "One skill per concern". |

---

See [references/phase-checklists.md](references/phase-checklists.md) for granular breakdowns of the 6 phases.
See [references/best-practices.md](references/best-practices.md) for extended guidance and testing pyramids.
