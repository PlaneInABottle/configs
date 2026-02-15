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

### Test Continuously

AI agents move fast. Tests are the guardrails.

- **Unit tests after code changes.** Run the relevant suite after modifying code. Don't batch.
- **Fix broken tests immediately.** A failing test is a signal, not noise.
- **Add tests for new functionality.** Untested features are undocumented assumptions.
- **Use tests as documentation.** Well-named tests describe expected behavior better than comments.

### Inspect State

When something doesn't work, inspect rather than guess:

- Read the actual error output
- Use API inspection tools to see real entity state
- Enable verbose/debug logging during investigation
- Compare expected vs. actual output at each step

### Iterate Rapidly

AI-native development compresses the loop:

```
Traditional:  Plan → Implement → Test → Debug → Deploy  (hours/days)
AI-Native:    Intent → Implement → Test → Fix → Verify  (minutes)
```

Leverage this speed:
- Small, focused changes over large batches
- Test immediately after each change
- Fix issues while context is fresh
- Commit working increments frequently

### Build Reusable Skills

Every time an AI agent figures something out from scratch = wasted effort:

| Session | Without Skills | With Skills |
|---------|---------------|-------------|
| First | Discover process (30 min) | Discover + create skill (40 min) |
| Second | Discover again (30 min) | Load skill, execute (2 min) |
| Third | Discover again (30 min) | Load skill, execute (2 min) |
| **Total** | **90 min** | **44 min** (and accelerating) |

Investment pays for itself after a single reuse.

### Create Skills During Development

Don't wait until "done":

- **After debugging:** Document failure mode and resolution
- **After integration:** Document API patterns and gotchas
- **After optimization:** Document what was slow, what fixed it, how to measure
- **After onboarding a tool:** Document setup, configuration, common operations

Skills created in the moment capture details forgotten within days.

---

## Decision-Making Practices

- **Analyze before deciding.** Spawn agents to evaluate options in parallel. Never assume one approach fits all.
- **Document decisions.** Record what was chosen, why, and what tradeoffs were accepted.
- **Use sync agents for analysis.** Analysis tasks should block until complete — don't fire and forget.

## Runtime Operations

- **Use detached shells for long-running services.** Attached shells die with the session.
- **Health checks over log parsing.** HTTP endpoints are faster and more reliable than grepping logs.
- **Test the full lifecycle.** `Start → Verify → Use → Restart → Verify → Stop.`

## Agent Coordination

- **Parallel agents for independent analysis.** Spawn multiple explorers for different areas simultaneously.
- **Sequential agents for dependent operations.** Don't start Phase 3 until Phase 2 is verified.
- **Trust but verify.** When an agent reports success, spot-check critical changes.

---

## Common Patterns

### Infrastructure

| Pattern | When to Use |
|---------|-------------|
| Docker for stateful services | Databases, caches, message queues |
| Native execution for hot-reload | Frontend/backend apps where file-watching speed matters |
| Detached shells for persistence | Any long-running process surviving session boundaries |
| Health check endpoints | Every service should expose machine-readable health |

### AI Operations

| Pattern | When to Use |
|---------|-------------|
| Skills for operational knowledge | Startup, troubleshooting, monitoring procedures |
| Parallel agents for analysis | Evaluating options, reviewing multiple files |
| MCP/API tools for operations | CRUD operations on application entities |
| SQL tracking for complex tasks | Multi-step operations with dependencies |
| Unit tests after code changes | Every modification to application code |
| Skill creation after discovery | New pattern, debugging session, tool integrated |

---

## Anti-Patterns — Extended

### Assuming Runtime Works
**Harm:** Silent failures, wasted debugging time.
**Fix:** Verify every service after startup with health checks.

### Over-Engineering Runtime
**Harm:** Complexity slows agents, increases failure surface.
**Fix:** Choose simplest option meeting requirements. Hybrid is usually enough.

### Skipping Skill Creation
**Harm:** Knowledge lost between sessions; agents repeat same mistakes.
**Fix:** Codify operational knowledge immediately. 40 min now saves hours later.

### Using Attached Shells for Servers
**Harm:** Services die when AI session ends.
**Fix:** Always use `detach: true` for long-running processes.

### Guessing Instead of Analyzing
**Harm:** Incorrect assumptions compound into larger failures.
**Fix:** Spawn agents to investigate and report facts before deciding.

### Log Parsing for Health Checks
**Harm:** Fragile, slow, format-dependent.
**Fix:** Expose HTTP health endpoints. `curl -sf /health` > grepping logs.

### Manual Service Management
**Harm:** Not reproducible, not delegatable to AI.
**Fix:** Script everything. Put it in a skill.

### Monolithic Skills
**Harm:** Hard to maintain, hard to reuse.
**Fix:** One skill per concern: `runtime`, `testing`, `deployment`.

### Batching Changes Without Testing
**Harm:** Failures compound, root cause unclear.
**Fix:** Run tests after each meaningful change. Small loops > big batches.

### Deferring Skill Creation
**Harm:** Details forgotten, context lost.
**Fix:** Create skills during development. In the moment > after the fact.

### Fixing Symptoms Not Root Causes
**Harm:** Same issue recurs in different forms.
**Fix:** Trace errors to origin. Update skills with root cause findings.

### Testing Only Happy Paths
**Harm:** Edge cases cause production failures.
**Fix:** Include error cases, boundary conditions, invalid input in tests.
