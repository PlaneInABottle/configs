# Phase Checklists — Detailed Breakdowns

Detailed guidance for each phase of the AI-native workflow. Use alongside the main [SKILL.md](../SKILL.md).

---

## Phase 1: Runtime Setup Analysis

### Step 1.1 — Analyze Project Characteristics

Profile the project before choosing a runtime:

| Dimension | How to Measure | Why It Matters |
|-----------|---------------|----------------|
| File count | `find . -type f \| wc -l` | Affects Docker volume performance |
| Dependency size | `du -sh node_modules/` | Large deps slow container builds |
| Native binaries | Check for `.node`, `.so`, compiled deps | May not work across architectures |
| Hot-reload mechanism | Webpack, Vite, Turbopack, etc. | File watching differs in containers |
| Stateful services | Databases, caches, queues | Containers excel here |
| Build time | Time a full build | Baseline for optimization |

### Step 1.2 — Compare Runtime Options

**Option A: Full Docker**
- ✅ Reproducible, isolated, matches production
- ❌ File watching unreliable on macOS (polling fallback)
- ❌ Native binaries may need rebuilding
- ❌ HMR latency from volume I/O

**Option B: Fully Native**
- ✅ Fastest HMR, native file watching
- ❌ Database/service setup varies per machine
- ❌ Version conflicts with system packages

**Option C: Hybrid (Usually Best)**
- ✅ Fast HMR + reliable stateful services
- ✅ File watching works natively
- ✅ Database isolation without app performance cost
- ❌ Slightly more complex setup

### Step 1.3 — AI-Specific Requirements

AI agents need:
- **Log access:** Agents parse logs to detect errors. Ensure logs accessible via shell or API.
- **Health check endpoints:** HTTP health checks beat log parsing — faster and more reliable.
- **Process management:** Agents must start, stop, restart services. Detached shells essential.
- **Deterministic startup:** Scriptable with clear success/failure signals.

### Step 1.4 — Document the Decision

Record:
- Which option was chosen and why
- What tradeoffs were accepted
- What project characteristics drove the decision

**Analysis method:** Spawn parallel agents to evaluate each option against project characteristics. Agents return structured comparisons; coordinator makes the final call.

---

## Phase 2: Skill Creation

### Step 2.1 — Initialize Skill Structure

```
skill-name/
├── skill.md          # Primary knowledge document
├── scripts/          # Automation scripts (optional)
└── README.md         # Human-readable overview
```

### Step 2.2 — Document Core Operations

Every runtime skill must cover:

| Section | Format |
|---------|--------|
| Prerequisites | List: tool, version, env var |
| Startup Sequence | `Command → Expected output → Failure → Resolution` |
| Health Checks | `Endpoint/command → Expected response` |
| Monitoring | Log locations, common error patterns |
| Troubleshooting | `Symptom → Cause → Fix` |
| Shutdown | Ordered stop sequence |

### Step 2.3 — Write for Machines

Optimize for AI parseability. Use structured formats:

```markdown
## Start PostgreSQL
Command: `docker compose -f docker-compose.local.yml up -d`
Verify: `docker compose -f docker-compose.local.yml ps` → status "Up"
Health: `curl -s http://localhost:5432` or check container logs
Failure: If port 5432 occupied, run `lsof -i :5432` and kill the process
```

Avoid narrative explanations. Command → expected → failure → resolution.

### Step 2.4 — Include Automation Scripts

For complex operations, include executable scripts:

```bash
#!/bin/bash
# health-check.sh - Verify all services are operational
check_service() {
  local name="$1" url="$2"
  if curl -sf "$url" > /dev/null 2>&1; then
    echo "✓ $name"; return 0
  else
    echo "✗ $name"; return 1
  fi
}

check_service "Application" "http://localhost:3000/api/health"
check_service "WebSocket"   "http://localhost:3001/health"
```

### Step 2.5 — Commit to Version Control

Skills are project artifacts:
```bash
git add .skills/project-runtime/
git commit -m "feat: add project-runtime skill for AI-managed development"
```

---

## Phase 3: Implementation & Verification

### Step 3.1 — Agent-Driven Startup

Don't start services manually. Have an AI agent follow the skill:

```
Agent prompt: "Use the project-runtime skill to start the full development
environment. Verify all services are healthy before reporting success."
```

This tests both the skill's accuracy and the agent's ability to execute it.

### Step 3.2 — Service Verification

After startup, confirm every service:

| Check | Method | Expected |
|-------|--------|----------|
| Database | Container status or connection test | Running, accepting connections |
| Application | HTTP health endpoint | 200 OK |
| Auxiliary services | Protocol-specific check | Healthy response |

Automated health checks are non-negotiable.

### Step 3.3 — Detached Mode Testing

Services must survive session boundaries:
1. Start services in detached mode
2. Confirm running
3. Simulate session end (start new agent)
4. Verify services still running

If services die when the session ends, the setup is not production-ready for AI.

### Step 3.4 — Full Lifecycle Test

```
Start → Verify → Use → Restart → Verify → Stop → Verify stopped
```

Test edge cases:
- Port already in use
- Database migration needed
- Stale containers from previous session
- Missing environment variables

---

## Phase 4: Programmatic Operations

### Step 4.1 — Inventory APIs and Tools

Catalog every programmatic interface:
- MCP tools (Model Context Protocol servers)
- REST/GraphQL APIs
- CLI commands
- Database access
- File system operations

### Step 4.2 — Test CRUD Operations

| Operation | Test |
|-----------|------|
| Create | Build a new entity from scratch |
| Read | Retrieve and inspect existing entities |
| Update | Modify an entity and verify changes |
| Delete | Remove an entity and confirm removal |

### Step 4.3 — Execution Capabilities

Beyond CRUD:
- Run workflows/pipelines/tests
- Read execution logs and results
- Detect and diagnose failures
- Apply fixes and re-run

### Step 4.4 — Monitoring and Logging

Confirm AI can observe system behavior:
- Access application logs
- Query metrics endpoints
- Detect anomalies or errors
- Correlate events across services

---

## Phase 5: Continuous Iteration

### Test-Driven Development Cycle

```
1. Make a change to a module
2. Run unit tests immediately
3. Tests fail → fix code or update tests
4. Tests pass → proceed to next change
```

| Scenario | Action |
|----------|--------|
| Test fails, behavior changed intentionally | Update the test |
| Test fails due to bug in change | Fix the code |
| Test is flaky or unrelated | Note it, investigate separately |

### Debugging Workflow

1. Read error message + stack trace
2. Identify failing component
3. Inspect relevant code/config
4. Form hypothesis
5. Test with targeted fix
6. Verify no new failures introduced

Principles:
- Enable debug logging during investigation
- Compare expected vs. actual at each step
- Check all relevant service logs
- Trace to root cause, not symptom

### Performance Optimization

1. Establish baselines (execution time, resource usage, response times)
2. Profile before optimizing — don't guess
3. One change at a time, measure impact
4. Run tests after each optimization
5. Document: what changed, improvement, tradeoffs

### Expanding Capabilities

| Priority | Criteria |
|----------|----------|
| High | Done daily, takes >5 min, error-prone |
| Medium | Done weekly, moderate complexity |
| Low | Rare, simple, or already fast enough |

### Monitoring and Observability

- Define key health indicators
- Set up automated health checks on schedule
- Alert on degradation, not just failure
- Review execution logs for error patterns
- Track operation success rates over time
- Feed monitoring findings back into skills

---

## Startup Sequence Template

```
1. Start stateful services (Docker)     → Verify via container status
2. Wait for services to accept traffic  → Verify via health endpoint
3. Run migrations if needed             → Verify via exit code
4. Start application (detached)         → Verify via health endpoint
5. Start auxiliary services (detached)  → Verify via health endpoint
6. Final integration check              → All endpoints healthy
```

## Project-Specific Considerations

When adapting to a new project, evaluate:

| Concern | Questions |
|---------|-----------|
| Package manager | Workspaces? Lock file format? |
| Build system | Incremental? Watch mode? |
| Hot reload | Native file watching or polling? |
| Test runner | Parallel execution? Watch mode? |
| Type checking | Separate step or integrated? |
| Native deps | Compile native code? Work in Docker? |
| File watching | `fs.watch`, `chokidar`, `inotify`? Polling in Docker? |
| Ports | List all ports, conflict resolution |
| Env vars | Required vars, secrets vs config, `.env.example` |
| Database | Migration strategy, seed data, reset procedure |
