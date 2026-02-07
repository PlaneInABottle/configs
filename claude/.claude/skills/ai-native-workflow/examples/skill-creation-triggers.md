# Skill Creation Triggers — Examples

Real-world examples of when and how to create skills during AI-native development. Use alongside the main [SKILL.md](../SKILL.md).

---

## Phase-Based Skill Checkpoints

Each phase has a natural skill creation checkpoint. These are moments where operational knowledge has been discovered and should be captured.

### After Phase 1: Runtime Setup

**Trigger:** You discovered non-obvious runtime characteristics.

**Examples:**
- "Docker volumes cause 3–5× slower HMR due to 4000+ source files"
- "Native binaries (better-sqlite3, sharp) require Linux rebuild in containers"
- "Turbopack file watching doesn't work with Docker volume mounts"
- "PostgreSQL has no performance issues in Docker; app code does"

**Skill to create:** `project-runtime` — captures the runtime decision, rationale, and setup instructions.

### After Phase 2: Skill Creation

**Trigger:** The initial skill is written but untested against real failures.

**Examples:**
- Runtime skill covers startup but not port conflict resolution
- Health checks documented but failure modes missing
- Shutdown sequence exists but order matters and isn't captured

**Action:** Mark the skill as "v1 — needs validation in Phase 3."

### After Phase 3: Implementation & Verification

**Trigger:** Testing revealed gaps in the skill.

**Examples:**
- "Database needs 5 seconds before accepting connections after Docker start"
- "Detached shells (`detach: true`) are required — attached shells kill services on session end"
- "Port 3000 conflict: `lsof -i :3000 | grep LISTEN` then `kill <PID>`"
- "Stale Docker containers from previous session cause port conflicts — run `docker compose down` first"

**Action:** Update the runtime skill with every failure mode encountered. Add timing, error messages, and resolutions.

### After Phase 4: Programmatic Operations

**Trigger:** You've mapped out available APIs/tools and discovered patterns.

**Examples:**
- "MCP server provides 20+ workflow operations — document the full inventory"
- "Workflow creation requires specific block positioning (200–300px horizontal spacing)"
- "Real-time UI sync: programmatic changes reflect immediately without refresh"
- "Custom tool creation requires specific schema format with function definition"

**Skill to create:** `project-operations` — documents tool inventory, common patterns, and API quirks.

### During Phase 5: Continuous Iteration

**Trigger:** Any of the following signals during ongoing development.

---

## Signal-Based Triggers

### "I've Explained This Twice"

**Signal:** You've told an AI agent how to do something more than once.

**Example:**
> "To run tests for a specific module, use `bun test apps/sim/lib/feature` not `bun test feature`."

After the second time, create a `testing-conventions` skill covering test commands, file patterns, and common gotchas.

### "This Requires a Non-Obvious Workaround"

**Signal:** An operation has a step that isn't self-evident.

**Example:**
> "The API returns paginated results but the `next` cursor is in a header, not the body. You must read `X-Next-Cursor` from response headers."

Document in an integration-specific skill immediately.

### "That Debugging Session Taught Me Something"

**Signal:** A debugging session revealed knowledge not documented anywhere.

**Example:**
> "Error `ECONNREFUSED on :5432` doesn't always mean Postgres is down — sometimes it means the Docker network hasn't initialized. Wait 3 seconds and retry."

Update the runtime skill's troubleshooting section.

### "We Just Integrated a New Tool"

**Signal:** A new tool, API, or service has been integrated.

**Example:**
> "Integrated Slack webhooks. The API requires `Content-Type: application/json`, the token goes in `Authorization: Bearer`, and rate limits are 1 req/sec per channel."

Create a `slack-integration` skill covering setup, auth, rate limits, and common operations.

### "I Optimized Something and It Matters"

**Signal:** A performance optimization yielded measurable results.

**Example:**
> "Switched from `JSON.parse(JSON.stringify(obj))` to `structuredClone(obj)` — 3× faster for large workflow states. Test: `bun test apps/sim/stores/`."

Document in a `performance-patterns` skill.

---

## Skill Creation Process

When a trigger fires:

```
1. Identify the pattern or knowledge gap
   → What would a fresh agent need to know?

2. Document core operations
   → Commands, expected outputs, failure modes

3. Include real examples from your project
   → Concrete, not abstract

4. Test by having a fresh AI agent follow it
   → If the agent gets stuck, the skill is incomplete

5. Iterate where the agent struggled
   → Add missing context, clarify ambiguous steps

6. Commit to version control
   → Skills are project artifacts
```

## Skill Scope Rules

**One skill per concern.** A skill covering "everything about deployment" is too broad.

**Good:**
- `deployment-staging` — staging deploy process
- `deployment-production` — production deploy (different approvals)
- `deployment-rollback` — rollback procedures

**Bad:**
- `deployment` — covers staging, production, rollback, monitoring, and incident response

**Rule of thumb:** If the skill has more than 3 major sections, it should be split.

## Skill Maintenance

Skills are living documents. Update when:

| Trigger | Action |
|---------|--------|
| Process changes | Update commands, steps, expected outputs |
| Failure reveals gap | Add failure mode + resolution |
| Better approach found | Replace old approach, note why it changed |
| Tool version update | Verify commands still work, update if needed |

**Never delete old skills without replacement.** If a skill is obsolete, archive it with a note pointing to the replacement.
