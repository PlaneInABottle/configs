---
name: ai-native-workflow
description: Comprehensive guide for establishing AI-managed development workflows. Use when starting a new project, transitioning between phases, or optimizing AI-human collaboration. Covers runtime setup, skill creation, implementation, programmatic operations, and continuous iteration.
license: MIT
---

# AI-Native Workflow

Guide for establishing and maintaining AI-managed development workflows across any project.

## When to Use This Skill

- **Starting a new project:** Set up AI-native workflow from scratch
- **Phase transitions:** Moving from one phase to the next
- **Stuck or unclear:** Need direction on next steps
- **Optimizing workflow:** Want to improve AI collaboration
- **Creating skills:** Discovered a pattern worth codifying

## The 5 Phases

| # | Phase | Goal | Key Deliverable |
|---|-------|------|-----------------|
| 1 | Runtime Setup Analysis | Determine optimal dev environment | Architecture decision document |
| 2 | Skill Creation | Codify operational knowledge | Reusable skill package |
| 3 | Implementation & Verification | Validate end-to-end under AI management | Working AI-managed environment |
| 4 | Programmatic Operations | Enable AI to create/modify/execute features | Autonomous feature building |
| 5 | Continuous Iteration | Sustainable dev cycles with growing skills | Self-improving workflow |

## Quick Decision Framework

```
Starting fresh?
  → Phase 1: Analyze runtime options

Have a runtime decision?
  → Phase 2: Create skills to capture operational knowledge

Have skills but untested?
  → Phase 3: Verify end-to-end with AI agents

Environment works but can't build features?
  → Phase 4: Inventory and test programmatic interfaces

Everything works?
  → Phase 5: Iterate, test, create skills, optimize
```

**When stuck at any phase:**
1. Check the phase checklist below
2. Identify which step is incomplete
3. Complete that step before moving forward
4. Update skills with what you learned

## Phase 1: Runtime Setup Analysis

**Goal:** Determine optimal dev environment for AI automation.

### Checklist

- [ ] Profile the project (file count, dependency size, native binaries, HMR mechanism, stateful services, build time)
- [ ] Evaluate three options:
  - **Full Docker:** Reproducible but slow HMR on macOS
  - **Fully Native:** Fast HMR but inconsistent service setup
  - **Hybrid:** Docker for stateful services, native for app code (usually best)
- [ ] Assess AI-specific requirements:
  - Log access (shell or API)
  - Health check endpoints (HTTP > log parsing)
  - Process management (detached shells)
  - Deterministic startup (scriptable with clear signals)
- [ ] Document decision with rationale and tradeoffs

### Verification

> Can an AI agent understand WHY this runtime was chosen and reproduce the setup?

🎯 **Skill Checkpoint:** Create a `project-runtime` skill if you discovered non-obvious runtime characteristics (e.g., polling-based file watching needed, native binaries require Linux rebuild).

## Phase 2: Skill Creation

**Goal:** Codify operational knowledge so any AI agent can manage the project.

### Checklist

- [ ] Initialize skill structure:
  ```
  skill-name/
  ├── skill.md          # Primary knowledge document
  ├── scripts/          # Automation scripts (optional)
  └── README.md         # Human-readable overview
  ```
- [ ] Document core operations:

  | Section | Contents |
  |---------|----------|
  | Prerequisites | Tools, versions, env vars |
  | Startup Sequence | Ordered steps with commands + expected output |
  | Health Checks | Endpoints/commands per service |
  | Monitoring | Log locations, error patterns |
  | Troubleshooting | Common failures → resolutions |
  | Shutdown | Graceful stop sequence |

- [ ] Write for machines: `command → expected output → failure mode → resolution`
- [ ] Include automation scripts for complex operations
- [ ] Commit skill to version control

### Verification

> Can a fresh AI agent follow this skill to start and manage the environment without human help?

🎯 **Skill Checkpoint:** Your runtime skill is the foundation. Update it with every failure mode encountered during Phase 3.

## Phase 3: Implementation & Verification

**Goal:** Validate the runtime setup works end-to-end under AI management.

### Checklist

- [ ] Spawn an agent to start the environment using the skill (no manual steps)
- [ ] Verify all services:

  | Check | Method | Expected |
  |-------|--------|----------|
  | Database | Container status or connection test | Running, accepting connections |
  | Application | HTTP health endpoint | 200 OK |
  | Auxiliary services | Protocol-specific check | Healthy response |

- [ ] Test detached mode: services survive session boundaries
- [ ] Test full lifecycle: `Start → Verify → Use → Restart → Verify → Stop → Verify stopped`
- [ ] Test edge cases: port conflicts, migration needed, stale containers, missing env vars

### Verification

> Can the AI agent recover from failures without human intervention?

🎯 **Skill Checkpoint:** Update your runtime skill with failure modes hit during verification. A skill that only covers the happy path is incomplete.

## Phase 4: Programmatic Operations

**Goal:** Enable AI agents to create, modify, execute, and test features programmatically.

### Checklist

- [ ] Inventory all programmatic interfaces:
  - MCP tools
  - REST/GraphQL APIs
  - CLI commands
  - Database access
  - File system operations
- [ ] Test CRUD operations through each interface (Create, Read, Update, Delete)
- [ ] Verify execution capabilities (run workflows, read logs, diagnose failures, apply fixes)
- [ ] Confirm monitoring access (logs, metrics, error detection)
- [ ] Verify real-time UI sync (programmatic changes reflect immediately)

### Verification

> Can the AI agent build a complete feature end-to-end without human intervention?

🎯 **Skill Checkpoint:** Create a skill for programmatic operations — document tool inventory, common patterns, error handling, and workarounds.

## Phase 5: Continuous Iteration

**Goal:** Sustainable development with growing skill coverage and test validation.

### Ongoing Practices

**Test-Driven Development:**
```
Make change → Run tests → Pass? Proceed. Fail? Fix immediately.
```
- Run unit tests after every code change
- Fix broken tests immediately (don't batch)
- Add tests for new functionality (including edge cases)
- Tests are the primary safety net for AI-driven changes

**Structured Debugging:**
1. Read error message + stack trace
2. Identify failing component
3. Inspect relevant code/config
4. Form hypothesis → test with targeted fix
5. Verify fix doesn't introduce new failures
6. Trace root cause, not symptoms

**Skill Creation Triggers:**
- Explained the same process to an AI agent more than once
- Operation requires non-obvious steps or workarounds
- Debugging session revealed undocumented knowledge
- New tool/API integrated with usage patterns worth capturing

**Performance Optimization:**
- Establish baselines before optimizing
- Profile, don't guess at bottlenecks
- One change at a time, measure impact
- Run tests after each optimization

### Verification

> Are skills growing? Are tests running? Is debugging structured?

🎯 **Skill Checkpoint:** Create skills during development, not after. Details are forgotten within days.

## Skill Creation Guide

### When to Create

| Signal | Example |
|--------|---------|
| Repeated explanation | "Start services with X, then Y, then Z" — third time? Skill it. |
| Non-obvious workaround | "Use polling in Docker because fswatch breaks" |
| Debugging discovery | "Error X actually means Y, fix with Z" |
| New integration | "API requires header A, pagination via B" |

### How to Create

1. Identify the pattern or knowledge gap
2. Document core operations (commands, expected outputs, failure modes)
3. Include real examples from your project
4. Test by having a fresh AI agent follow it
5. Iterate where the agent gets stuck
6. Commit to version control

### Rules

- **One skill per concern** — not "everything about deployment"
- **Keep skills focused** — `deployment-staging`, `deployment-production`, `deployment-rollback`
- **Update continuously** — when process changes, failure reveals gap, or better approach found

## Best Practices Summary

| Practice | Why |
|----------|-----|
| Skill-first approach | Document before automating; skills are cheaper than code |
| Test continuously | Unit tests after every code change; tests are guardrails |
| Inspect state | Read errors, don't guess; use verbose logging |
| Iterate rapidly | Small focused changes, test immediately, commit often |
| Build reusable skills | Every discovery codified saves 30+ min on reuse |
| Detached shells for servers | Attached shells die with session |
| Health checks over log parsing | HTTP endpoints are faster and more reliable |
| Parallel agents for analysis | Spawn multiple explorers for independent areas |

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Assume runtime works | Verify every service after startup |
| Over-engineer runtime | Simplest option that meets requirements |
| Skip skill creation | Codify knowledge immediately |
| Use attached shells for servers | `detach: true` for persistence |
| Guess instead of analyzing | Spawn agents to investigate facts |
| Parse logs for health | Expose HTTP health endpoints |
| Create monolithic skills | One skill per concern |
| Batch changes without testing | Test after each change |
| Defer skill creation | Create during development |
| Fix symptoms | Trace to root cause |

---

See [references/phase-checklists.md](references/phase-checklists.md) for detailed phase breakdowns.
See [references/best-practices.md](references/best-practices.md) for extended guidance and patterns.
See [examples/skill-creation-triggers.md](examples/skill-creation-triggers.md) for real-world skill creation examples.
