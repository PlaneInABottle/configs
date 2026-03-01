# Best Practices & Anti-Patterns

Extended guidance for AI-native development workflows. Use alongside the main [SKILL.md](../SKILL.md).

---

## Core Principles

### Skill-First Approach

Before building complex automation, capture knowledge in a skill. Skills are cheaper than code — faster to write, easier to update, immediately useful.

```
Discover how something works → Write it down as a skill →
AI agents use the skill → Skill proves its value →
Automate further if needed
```

Don't skip straight to automation. A well-written skill often eliminates the need for custom tooling.

### Test Continuously (The AI Pyramid)

AI agents move fast. Tests are the guardrails, but you must use the right tools:

- **Unit logic tests after code changes.** Run the relevant language-specific suite (`pytest`, `Jest`, `cargo test`) after modifying pure functions or internal logic.
- **NEVER write, modify, or append to language-specific integration tests under ANY circumstances.** Use the Universal Toolkit (`.hurl`, `psql`, `agent-browser`) to test APIs, DBs, and UIs.
- **Fix broken tests immediately.** A failing test is a signal, not noise.
- **Reference the Playbooks:** See `../playbooks/api-contract-testing.md` and `../playbooks/universal-data-generation.md` for proper testing patterns.

### Inspect State

When something doesn't work, inspect rather than guess:

- Read the actual error output.
- **Check Detached Logs:** If a background Docker service (like a DB, `json-server`, or Prism mock) is failing, always run `docker logs --tail 50 <container_name>` to see why.
- Use Universal Tools to see real entity state (e.g., query Postgres directly instead of assuming the ORM failed).
- Enable verbose/debug logging during investigation.
- Compare expected vs. actual output at each step.

### Iterate Rapidly

AI-native development compresses the loop:

```
Traditional:  Plan → Implement → Test → Debug → Deploy  (hours/days)
AI-Native:    Intent → Implement → Assert via Boundaries → Fix  (minutes)
```

Leverage this speed:
- Small, focused changes over large batches.
- Assert immediately after each change using Universal Playbooks.
- Commit working increments frequently.

### Create Skills During Development

Don't wait until "done":
- **After debugging:** Document failure mode and resolution.
- **After integration:** Document API patterns and gotchas.
- **After onboarding a tool:** Document setup, configuration, common operations.

---

## Universal Verification Patterns

Always use language-agnostic tools to verify system state.

| Pattern | Playbook Reference | When to Use |
|---------|-------------------|-------------|
| **API Contract Testing** | `../playbooks/api-contract-testing.md` | Verifying REST/GraphQL endpoints using `.hurl`. |
| **Universal Data Generation** | `../playbooks/universal-data-generation.md` | Injecting deterministic seeds directly into DBs or Queues. |
| **Dependency Mocking** | `../playbooks/mocking-dependencies.md` | Faking 3rd party APIs with `json-server` or `Prism`. |
| **Media File Handling** | `../playbooks/media-file-handling.md` | Sourcing binary fixtures and mocking S3 via MinIO. |

---

## Headless Runtime Operations

When executing commands autonomously, agents must use robust patterns:

- **Strict Output Redirection & PID Tracking:** When running native servers detached, `&` is not enough. You must prevent stdout from corrupting the tool response, and you must track the PID to prevent port exhaustion (Zombie processes). **Always use: `npm run dev > .app.log 2>&1 & echo $! > .app.pid`**
- **Strict Bash Pipelines:** Bash pipelines like `curl | jq | cut` will silently swallow errors if a middle command fails. Always prefix multi-step bash commands with `set -euo pipefail` to ensure fail-fast behavior.
- **Headless Polling Loops:** Never assume a service starts instantly. Never use a single `curl` or a manual bash `while` loop. Always use `curl`'s built-in retry flags:
  ```bash
  curl --retry 10 --retry-connrefused --retry-delay 1 --retry-max-time 30 -sSf http://localhost:3000/health > /dev/null
  ```
- **Fail-Fast Network Calls:** Always use `curl -sSf`. The `-f` ensures HTTP 500s result in a bash error, rather than silently passing garbage data down a pipeline.

---

## Anti-Patterns — Extended

### Assuming Runtime Works
**Harm:** Silent failures, wasted debugging time.
**Fix:** Verify every service after startup with headless polling loops.

### Hanging Bash Commands
**Harm:** Agent tool calls timeout and break the session.
**Fix:** Never run `find` or `du` on directories without excluding `node_modules`, `.venv`, or `.git`. 

### Using Attached Shells for Servers
**Harm:** Services die when AI session ends, or `stdout` streams infinitely and breaks the JSON parser.
**Fix:** Always use `docker compose -d` or `> .app.log 2>&1 & echo $! > .app.pid` for native processes.

### Log Parsing for Health Checks
**Harm:** Fragile, slow, format-dependent.
**Fix:** Expose standard readiness probes. `curl -sSf` > grepping logs.

### Guessing Instead of Analyzing
**Harm:** Incorrect assumptions compound into larger failures.
**Fix:** Spawn agents to investigate and report facts before deciding.

### Monolithic Skills
**Harm:** Hard to maintain, hard to reuse.
**Fix:** One skill per concern. 

### Writing Pytest for Integration
**Harm:** Traps the AI in brittle, language-specific syntax that is hard to maintain.
**Fix:** Follow the Universal Toolkit. Use `.hurl` or `agent-browser`. 
