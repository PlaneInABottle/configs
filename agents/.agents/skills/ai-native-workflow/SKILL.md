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

## Related Skills Reference

This workflow references these specialized skills:
- **pexels-media**: Source royalty-free images/videos from Pexels API (load with `skill` tool when needed)

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
- [ ] Verify frontend rendering with `agent-browser`:
  ```bash
  agent-browser open http://localhost:3000
  agent-browser snapshot -i          # Verify interactive elements render
  agent-browser screenshot           # Capture visual state for review
  ```

### Verification

> Can the AI agent recover from failures without human intervention?
> Can the AI agent verify the frontend loads and renders correctly?

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
  - Browser automation (`agent-browser` for frontend verification)
  - Asset sourcing via `pexels-media` skill (images, videos for UI/content)
- [ ] Test CRUD operations through each interface (Create, Read, Update, Delete)
- [ ] Verify execution capabilities (run workflows, read logs, diagnose failures, apply fixes)
- [ ] Confirm monitoring access (logs, metrics, error detection)
- [ ] Verify real-time UI sync (programmatic changes reflect immediately)
- [ ] Source assets with `pexels-media` skill when building UI features:
  ```bash
  # Load the pexels-media skill, then request images for your feature
  # The skill handles search, download, and sidecar metadata generation
  # Example: sourcing a hero image during feature implementation
  # → Search for relevant imagery → Download preferred resolution
  # → Sidecar .meta.json created automatically for attribution
  ```
- [ ] Validate frontend behavior with `agent-browser`:
  ```bash
  # Verify a programmatic change reflects in the UI
  agent-browser open http://localhost:3000/feature
  agent-browser snapshot -i
  agent-browser click @e1               # Interact with the new feature
  agent-browser wait --load networkidle
  agent-browser snapshot -i              # Confirm updated state
  ```

### Verification

> Can the AI agent build a complete feature end-to-end without human intervention?
> Can the AI agent verify that backend changes appear correctly in the frontend?

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
- Use `agent-browser` for frontend regression checks after UI changes
- Track media assets alongside code: version sidecar metadata files (`.meta.json`) with commits
- Reference `pexels-media` sidecar files for asset audit trails and attribution compliance

**Frontend Verification Loop:**
```
Make UI change → Run unit tests → Browser verify → Pass? Proceed. Fail? Fix immediately.
```
- After frontend changes, verify visually with `agent-browser`
- Check interactive elements still work (forms, buttons, navigation)
- Screenshot before/after for visual regression tracking
- Re-snapshot after every navigation or DOM mutation

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

## Frontend Development & Testing

**Goal:** Enable AI agents to develop, test, and verify frontend features using browser automation.

### When to Use agent-browser

| Scenario | Tool | Why |
|----------|------|-----|
| Unit logic (pure functions, state) | Jest/Vitest/etc. | Fast, deterministic, no browser needed |
| Component rendering | Testing library | Lightweight DOM assertions |
| User flow verification | `agent-browser` | Real browser, real interactions, real results |
| Visual regression | `agent-browser screenshot` | Capture and compare visual state |
| Form/auth flow testing | `agent-browser` | Fill, submit, verify redirect and state |
| Cross-page navigation | `agent-browser` | Follow links, verify routing works |

### Development Workflow

```
1. Implement feature (code changes)
2. Run unit tests (fast feedback)
3. Start dev server (detached shell)
4. Browser verify with agent-browser (real user simulation)
5. Fix issues found → repeat from step 2
6. Screenshot final state for records
```

### Example: Verify a New Feature End-to-End

```bash
# Start the dev server (detached so it persists)
npm run dev &

# Navigate to the feature
agent-browser open http://localhost:3000/new-feature

# Inspect what's rendered
agent-browser snapshot -i
# Output: @e1 [input type="text"] "Name", @e2 [button] "Submit", @e3 [div] "Results"

# Interact like a real user
agent-browser fill @e1 "Test Input"
agent-browser click @e2
agent-browser wait --load networkidle

# Verify the result
agent-browser snapshot -i
agent-browser get text @e3              # Check output content

# Capture visual proof
agent-browser screenshot
```

## Media & Asset Sourcing: Pexels Integration

**Goal:** Provide AI agents with standardized access to royalty-free images and videos for UI development, design assets, and content generation.

> **This integration is optional but recommended for any project involving UI or design work.**

### When to Use pexels-media

| Scenario | Use pexels-media? | Why |
|----------|-------------------|-----|
| UI placeholder images during development | ✅ Yes | Realistic placeholders improve design feedback |
| Hero images for landing pages | ✅ Yes | High-quality, royalty-free, attribution-tracked |
| Design assets for mockups/prototypes | ✅ Yes | Fast sourcing with consistent metadata |
| Content generation (blog posts, docs) | ✅ Yes | Relevant imagery with sidecar metadata |
| Proprietary brand imagery | ❌ No | Use brand asset library instead |
| Licensed/copyrighted content | ❌ No | Pexels is royalty-free only |
| Icons or vector graphics | ❌ No | Use icon libraries (e.g., Lucide, Heroicons) |
| AI-generated imagery | ❌ No | Use image generation tools instead |

### Integration Pattern

Load the `pexels-media` skill when you need image/video assets:

1. **Load the skill:** Use the `skill` tool to load `pexels-media`
2. **Configure credentials:** Ensure `PEXELS_API_KEY` is set in `.env.pexels`
3. **Search and download:** The skill handles search, resolution selection, and download
4. **Sidecar metadata:** Every asset gets a `.meta.json` file automatically with attribution, source URL, and license info

### Example Workflow (Phase 4–5)

```
Building a feature with UI components:
  1. Implement feature code (Phase 4)
  2. Identify image needs (hero banner, thumbnails, backgrounds)
  3. Load pexels-media skill
  4. Search for relevant imagery → Download preferred resolution
  5. Sidecar .meta.json created automatically
  6. Reference images in code → Run tests → Browser verify
  7. Commit code + assets + sidecar metadata together
```

### Asset Management Best Practices

- [ ] Store downloaded assets in a consistent directory (e.g., `public/assets/`, `static/images/`)
- [ ] Always commit sidecar `.meta.json` files alongside assets for attribution tracking
- [ ] Use descriptive filenames from the skill output (not generic `image1.jpg`)
- [ ] Review sidecar metadata for license compliance before production deployment
- [ ] Version assets with code: asset changes should be part of feature commits
- [ ] Use `pexels-media` curated/popular endpoints for high-quality defaults

### Checklist

- [ ] `PEXELS_API_KEY` configured in `.env.pexels`
- [ ] Asset output directory established and documented
- [ ] Sidecar metadata files committed to version control
- [ ] Attribution requirements reviewed for production use
- [ ] Assets referenced in code with correct paths

## Verification Workflows

**Goal:** Use `agent-browser` to confirm features work from the user's perspective, not just pass tests.

### Pattern: Post-Deploy Verification

```bash
# After deploying a change, verify it works in the running app
agent-browser open http://localhost:3000
agent-browser snapshot -i

# Check critical elements exist
agent-browser get text @e1              # Verify heading text
agent-browser click @e2                 # Navigate to key page
agent-browser wait --load networkidle
agent-browser snapshot -i               # Re-snapshot after navigation

# Screenshot for audit trail
agent-browser screenshot --full
```

### Pattern: Form Submission Verification

```bash
# Verify a form works end-to-end
agent-browser open http://localhost:3000/contact
agent-browser snapshot -i

# Fill and submit
agent-browser fill @e1 "Test User"
agent-browser fill @e2 "test@example.com"
agent-browser fill @e3 "This is a test message"
agent-browser click @e4                 # Submit button
agent-browser wait --load networkidle

# Verify success state
agent-browser snapshot -i
agent-browser get text body             # Check for success message
```

### Pattern: Auth Flow Verification

```bash
# Verify login → protected page → logout cycle
agent-browser open http://localhost:3000/login
agent-browser snapshot -i
agent-browser fill @e1 "$TEST_USER"
agent-browser fill @e2 "$TEST_PASS"
agent-browser click @e3
agent-browser wait --url "**/dashboard"

# Verify protected content loads
agent-browser snapshot -i
agent-browser get title                 # Should be "Dashboard"

# Save auth state for reuse in other tests
agent-browser state save test-auth.json
```

### Pattern: Error State Verification

```bash
# Verify error handling works correctly
agent-browser open http://localhost:3000/form
agent-browser snapshot -i
agent-browser click @e5                 # Submit empty form
agent-browser wait 1000

# Check validation errors appear
agent-browser snapshot -i               # Should show error messages
agent-browser get text @e6              # Read error text
```

## Browser Automation Integration by Phase

How `agent-browser` fits into each phase of the workflow:

| Phase | agent-browser Usage | Example |
|-------|-------------------|---------|
| 1 — Runtime Setup | Not typically needed | — |
| 2 — Skill Creation | Document browser test patterns | Add verification commands to skill |
| 3 — Implementation & Verification | Verify frontend renders after setup | `open` → `snapshot` → `screenshot` |
| 4 — Programmatic Operations | Validate UI reflects API/data changes | Change data → browser verify → confirm |
| 5 — Continuous Iteration | Frontend regression checks after changes | Test flows after every UI change |

### Integration Checklist

- [ ] Dev server starts in detached mode before browser tests
- [ ] `agent-browser` is available in the environment
- [ ] Test URLs are known and documented in skills
- [ ] Auth credentials for test accounts are available (env vars, not hardcoded)
- [ ] Screenshots are saved to a consistent location for review
- [ ] Refs are re-snapshotted after every navigation or DOM change

## Testing Best Practices with AI Agents

### Test Pyramid for AI-Managed Development

```
         ╱  Browser Tests  ╲        ← agent-browser (few, critical paths)
        ╱  Integration Tests ╲       ← API + DB tests (moderate count)
       ╱    Unit Tests        ╲      ← Fast, many, run after every change
```

- **Unit tests** run after every code change (fast, deterministic)
- **Integration tests** run after feature completion (API, DB, services)
- **Browser tests** run for user-facing flows (forms, auth, navigation)

### Patterns That Work

| Pattern | Description |
|---------|-------------|
| Smoke test after startup | `agent-browser open` + `snapshot` to confirm app loads |
| Screenshot before/after | Capture visual state before and after changes |
| Re-snapshot after interaction | Always `snapshot -i` after clicks, fills, or navigation |
| State persistence for auth | `state save` / `state load` to avoid repeated logins |
| Scoped snapshots | `snapshot -s "#component"` to focus on specific areas |
| Wait for network | `wait --load networkidle` before asserting state |

### Patterns to Avoid

| Anti-Pattern | Why | Do Instead |
|-------------|-----|------------|
| Browser test for logic | Slow, flaky | Unit test pure logic |
| Stale refs after navigation | Refs invalidate on DOM change | Re-snapshot after every interaction |
| Hardcoded credentials | Security risk | Use env vars: `$TEST_USER` |
| No waits between actions | Race conditions | `wait --load networkidle` or `wait @element` |
| Testing everything in browser | Slow test suite | Reserve for critical user flows |
| Skipping screenshots | Lose visual context | Screenshot at verification points |

## Best Practices Summary

| Practice | Why |
|----------|-----|
| Skill-first approach | Document before automating; skills are cheaper than code |
| Test continuously | Unit tests after every code change; tests are guardrails |
| Browser verify critical flows | `agent-browser` catches what unit tests miss |
| Inspect state | Read errors, don't guess; use verbose logging |
| Iterate rapidly | Small focused changes, test immediately, commit often |
| Build reusable skills | Every discovery codified saves 30+ min on reuse |
| Detached shells for servers | Attached shells die with session |
| Health checks over log parsing | HTTP endpoints are faster and more reliable |
| Parallel agents for analysis | Spawn multiple explorers for independent areas |
| Re-snapshot after navigation | Refs invalidate on page change; always get fresh refs |
| Screenshot at checkpoints | Visual proof of state for debugging and audit |
| Use pexels-media for image assets | Standardized sourcing, sidecar metadata, attribution compliance |

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
| Use stale refs after navigation | Re-snapshot to get fresh `@e` refs |
| Browser test pure logic | Use unit tests for non-UI logic |
| Hardcode test credentials | Use environment variables |
| Skip browser verification for UI | `agent-browser` catches rendering issues |

---

See [references/phase-checklists.md](references/phase-checklists.md) for detailed phase breakdowns.
See [references/best-practices.md](references/best-practices.md) for extended guidance and patterns.
See [examples/skill-creation-triggers.md](examples/skill-creation-triggers.md) for real-world skill creation examples.
