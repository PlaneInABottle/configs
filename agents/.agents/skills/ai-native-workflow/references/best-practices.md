# Best Practices & Anti-Patterns

Extended guidance for AI-native development workflows. Use alongside the main [SKILL.md](../SKILL.md).

---

## Core Principles

### Test Continuously (The AI Pyramid)

AI agents move fast. Tests are the guardrails, but you must use the right tools:

- **Unit logic tests after code changes.** Run the relevant language-specific suite (`pytest`, `Jest`, `cargo test`) after modifying pure functions or internal logic.
- **NEVER write, modify, or append to language-specific integration tests under ANY circumstances.** Use the Universal Toolkit (`.hurl`, `psql`, `agent-browser`) to test APIs, DBs, and UIs.
- **Fix broken tests immediately.** A failing test is a signal, not noise.
- **Reference the Playbooks:** See `../playbooks/api-contract-testing.md` and `../playbooks/universal-data-generation.md` for proper testing patterns.

### Inspect State

When something doesn't work, inspect rather than guess:

- Read the actual error output.
- **Check Background Logs:** If a background Docker service (like a DB, `json-server`, or Prism mock) is failing, always run `docker logs --tail 50 <container_name>` to see why.
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

### Capture Runtime Findings During Development

Don't wait until "done":
- **After debugging:** Document the failure mode and resolution in runtime notes.
- **After integration:** Document API patterns and gotchas in the relevant playbook or reference.
- **After onboarding a tool:** Document setup, configuration, and common operations needed to run or verify the system.
- **If those findings become repository-level skill guidance:** Hand the authoring and governance work to `skill-maintainer` / `skill-creator` instead of expanding this runtime reference into a skill-management workflow.

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

### Process Management (PM2)

**PM2 is the recommended process manager** for application servers. It handles PID tracking, log rotation, and crash recovery automatically.

```bash
# Start app server
pm2 start npm --name "project" -- run dev

# View logs
pm2 logs project

# Stop
pm2 stop project

# Restart after code changes
pm2 restart project

# Install log rotation
pm2 install pm2-logrotate
```

### Fallback: Bash Patterns

Only use bash for quick experiments. For reliable process management, use PM2.

- **Strict Output Redirection & PID Tracking:** When running application servers in the background using standard bash (fallback only), `&` is not enough. You must prevent stdout from corrupting the tool response, and you must track the PID to prevent port exhaustion (Zombie processes). **Use PM2 instead of: `npm run dev > .app.log 2>&1 & echo $! > .app.pid`**
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
**Fix:** Use **PM2** for app servers (`pm2 start npm -- run dev`) or Docker's `-d` for databases.

### Log Parsing for Health Checks
**Harm:** Fragile, slow, format-dependent.
**Fix:** Expose standard readiness probes. `curl -sSf` > grepping logs.

### Guessing Instead of Analyzing
**Harm:** Incorrect assumptions compound into larger failures.
**Fix:** Spawn agents to investigate and report facts before deciding.

### Writing Pytest for Integration
**Harm:** Traps the AI in brittle, language-specific syntax that is hard to maintain.
**Fix:** Follow the Universal Toolkit. Use `.hurl` or `agent-browser`. 
