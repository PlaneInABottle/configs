# Analyzer Bounded Bug Sweep - Implementation Plan

## Problem Framing and Goals
Broaden analyzer template behavior so analyzer still performs a blocking review of the requested change, but also performs a bounded adjacent bug sweep limited to the affected blast radius. The change must stay inside template prompts, preserve current blocking-review semantics, and explicitly prevent analyzer from turning into a repo-wide audit agent.

## Approach
Make the smallest prompt-only change in three master templates: define the bounded sweep rule in `analyzer.md`, enforce acceptance/gating language in `coordinator.md`, and align top-level analyzer framing in `global-instructions/master.md`.

## Success Criteria
- [ ] Analyzer instructions still require blocking review of the requested change.
- [ ] Analyzer instructions add a bounded adjacent bug sweep limited to affected callers, fallback/default paths, preserved behaviors, and realistic states inside the declared blast radius.
- [ ] Future template behavior clearly distinguishes blocking findings from non-blocking adjacent observations.
- [ ] Prompt wording explicitly prevents repo-wide or unrelated audits.
- [ ] Validation uses only template reads plus dry-run generation scripts.

## Current State (evidence)
- `templates/subagents/master/analyzer.md:72-80` defines analyzer review scope and says code/commit reviews must run tests.
- `templates/subagents/master/analyzer.md:109-120` already makes plan review factual verification blocking and sets `BLOCKED` when too many HIGH/CRITICAL assumptions remain.
- `templates/subagents/master/analyzer.md:173-189` already requires blast-radius checks, invariant checks, adversarial passes, and proof-backed issues.
- `templates/subagents/master/analyzer.md:191-199` caps unproven concerns at MEDIUM and forbids approval without evidence.
- `templates/subagents/master/analyzer.md:244-277` already requires evidence, coverage verdict, scope-drift reporting, and final `APPROVED/NEEDS_CHANGES/BLOCKED` output.
- `templates/subagents/master/analyzer.md:321-365` already pushes analyzer toward fallback/default-path, legacy-state, and preservation analysis, but it does not yet name a bounded adjacent bug sweep or explicitly distinguish bounded adjacent findings from repo-wide audits.
- `templates/subagents/master/coordinator.md:223-238` enforces plan-readiness gating around facts, blast radius, invariants, preservation, and per-phase test strategy.
- `templates/subagents/master/coordinator.md:315-320` says analyzer approval is invalid without evidence, coverage, and scope-drift sections.
- `templates/global-instructions/master.md:251-259` frames analyzer as a security/performance/architecture reviewer, but does not mention bounded adjacent sweep behavior.
- `scripts/update-subagents.sh:27-41` and `scripts/update-global-instructions.sh:27-40` both support `--dry-run`, so prompt propagation can be validated without writing generated outputs.
- `templates/global-instructions/README.md:173-193` documents the master-template workflow: edit master, dry-run, then apply.

## Phase Breakdown

## Phase 1: Define bounded adjacent sweep in analyzer prompt
**Owner**: @implementer (prompt/rules)
**Dependencies**: None
**Complexity**: LOW

### Tasks
- [ ] Update `templates/subagents/master/analyzer.md` to define a named bounded adjacent bug sweep that is limited to the affected blast radius.
- [ ] Add explicit blocking vs non-blocking rules:
  - blocking = proven issues in the requested change path or proven compatibility/invariant/default-path breaks inside the affected blast radius
  - non-blocking = speculative risks, broad cleanup ideas, or issues outside the bounded sweep
- [ ] Add explicit anti-expansion wording that analyzer must not escalate the sweep into a repo-wide audit.
- [ ] Preserve existing proof requirements, severity caps for unproven concerns, and final status outputs.

### Test Strategy
- [ ] Read back `templates/subagents/master/analyzer.md` and verify the file contains all three concepts: requested-change blocking review, bounded adjacent sweep, and explicit non-repo-wide limits.
- [ ] Verify existing `APPROVED/NEEDS_CHANGES/BLOCKED` status language remains present.
- [ ] Verify unproven-risk cap language still limits unsupported adjacent concerns to MEDIUM or lower.

### Acceptance Criteria
- [ ] Analyzer prompt names the bounded sweep and defines its bounds using blast-radius language.
- [ ] Analyzer prompt preserves blocking review of the requested change.
- [ ] Analyzer prompt states what adjacent findings can block and what must remain advisory.
- [ ] Analyzer prompt explicitly forbids repo-wide/unrelated audits.

---

## Phase 2: Align coordinator gating with bounded sweep behavior
**Owner**: @implementer (workflow/rules)
**Dependencies**: Phase 1
**Complexity**: LOW

### Tasks
- [ ] Update `templates/subagents/master/coordinator.md` so coordinator expects analyzer reviews to cover both the exact requested path and the bounded adjacent sweep inside the declared blast radius.
- [ ] Make coordinator reject analyzer reviews that omit the bounded-sweep coverage verdict or that drift into unrelated repo-wide review.
- [ ] Keep coordinator acceptance focused on proof, coverage, and scope control rather than adding new broad review obligations.

### Test Strategy
- [ ] Read back `templates/subagents/master/coordinator.md` and verify acceptance/gating language references both exact-change review and bounded adjacent coverage.
- [ ] Verify coordinator wording still requires evidence and scope-drift reporting.
- [ ] Verify coordinator wording does not require unrelated repository scanning.

### Acceptance Criteria
- [ ] Coordinator expects bounded-sweep coverage but only within affected blast radius.
- [ ] Coordinator treats missing exact-path proof or missing bounded-sweep coverage as blocking/needs-changes.
- [ ] Coordinator rejects scope drift into unrelated audit behavior.

---

## Phase 3: Update top-level analyzer framing
**Owner**: @implementer (global prompt/rules)
**Dependencies**: Phase 2
**Complexity**: LOW

### Tasks
- [ ] Update `templates/global-instructions/master.md` so the analyzer description/use guidance mentions blocking review of the requested change plus a bounded adjacent bug sweep within blast radius.
- [ ] Keep the description concise and aligned with the narrower analyzer scope defined in Phases 1-2.
- [ ] Avoid metadata or unrelated template changes unless implementation evidence proves they are necessary.

### Test Strategy
- [ ] Read back `templates/global-instructions/master.md` and verify analyzer framing matches the bounded-sweep rule.
- [ ] Run dry-run generation commands and inspect output summaries to confirm no extra template files are required for prompt propagation validation.

### Acceptance Criteria
- [ ] Global instructions describe analyzer behavior consistently with Phases 1-2.
- [ ] No additional template file is required to express the bounded sweep rule.
- [ ] The analyzer remains described as a focused reviewer, not a repo-wide auditor.

---

## Deliverables
| Phase | Files Created/Modified |
|-------|------------------------|
| Phase 1 | `templates/subagents/master/analyzer.md` |
| Phase 2 | `templates/subagents/master/coordinator.md` |
| Phase 3 | `templates/global-instructions/master.md` |

## Verified Facts vs Assumptions
| Item | Status | Severity if wrong | Evidence |
|------|--------|-------------------|----------|
| Analyzer already performs blocking review with proof requirements and explicit final statuses. | VERIFIED | HIGH | `templates/subagents/master/analyzer.md:109-120,191-199,244-277` |
| Analyzer already checks blast radius, preserved behavior, fallback/default paths, and legacy state. | VERIFIED | MEDIUM | `templates/subagents/master/analyzer.md:173-189,321-365` |
| Coordinator already enforces evidence, blast radius, invariants, and scope-drift sections. | VERIFIED | HIGH | `templates/subagents/master/coordinator.md:223-238,315-320` |
| Global analyzer framing currently lacks bounded adjacent sweep wording. | VERIFIED | LOW | `templates/global-instructions/master.md:251-259` |
| Dry-run validation is available for subagent and global-instructions generation scripts. | VERIFIED | LOW | `scripts/update-subagents.sh:27-41`; `scripts/update-global-instructions.sh:27-40` |
| The requested behavior can be implemented using only the three scoped template files. | VERIFIED | HIGH | Existing behavior rules live in those files; metadata only affects descriptions/examples, not rule execution: `templates/subagents/master/METADATA.json:88-101` |

**Readiness note:** Zero CRITICAL/HIGH unverified assumptions remain.

## Blast Radius / Affected Prompts and Entry Points
- `templates/subagents/master/analyzer.md` - primary analyzer prompt behavior for exact-path review, severity, proof, coverage, and bounded adjacent sweep rules.
- `templates/subagents/master/coordinator.md` - orchestration/acceptance gate that decides whether analyzer output is sufficient.
- `templates/global-instructions/master.md` - top-level analyzer purpose/use guidance that shapes when analyzer is invoked and how its role is understood.
- `scripts/update-subagents.sh` dry-run path - validation entry point for generated analyzer/coordinator prompt propagation without modifying generated files.
- `scripts/update-global-instructions.sh` dry-run path - validation entry point for top-level instruction propagation without modifying generated files.

## Exact Files Expected to Change
- `/Users/Y_ALTAY1/Documents/configs/templates/subagents/master/analyzer.md`
- `/Users/Y_ALTAY1/Documents/configs/templates/subagents/master/coordinator.md`
- `/Users/Y_ALTAY1/Documents/configs/templates/global-instructions/master.md`

## Allowed Scope / Forbidden Scope
- Allowed: wording/rules in the three template files above; dry-run validation commands; read-only inspection of generated behavior.
- Forbidden: `planner.md`, `METADATA.json`, scripts, generated instruction files, runtime code outside templates, unrelated prompt cleanups, repo-wide analyzer policy changes.

## Invariants
| Invariant | Why it matters | How to verify |
|-----------|----------------|---------------|
| Analyzer must still do a blocking review of the requested change. | Core requested behavior must not regress. | Confirm explicit blocking language remains in `analyzer.md` and coordinator still rejects insufficient review in `coordinator.md`. |
| Adjacent sweep must stay bounded to the affected blast radius. | Prevents scope creep into repo-wide audit behavior. | Confirm prompt text limits sweep to affected callers, fallback/default branches, preserved behaviors, and realistic states tied to the changed path. |
| Unproven adjacent concerns must not escalate above MEDIUM. | Preserves evidence-based review and prevents speculative blockers. | Confirm proof-standard language remains intact in `analyzer.md`. |
| Final review outputs must still use `APPROVED/NEEDS_CHANGES/BLOCKED`. | Existing coordinator workflow depends on this contract. | Confirm output-format section remains unchanged for final statuses. |
| Coordinator must accept only evidence-backed, bounded reviews. | Keeps review enforceable and prevents scope drift. | Confirm `coordinator.md` acceptance gate references evidence, bounded coverage, and scope control. |

## Behavior That Must Not Change
- Analyzer must continue to treat the requested change review as the primary blocking path.
- Analyzer must continue to require evidence/proof for HIGH/CRITICAL issues and cap unproven risks at MEDIUM or lower.
- Analyzer must continue to report evidence reviewed, coverage verdict, and plan adherence/scope drift.
- Coordinator must continue to reject analyzer approvals that omit required evidence sections.
- The templates must not instruct analyzer to perform unrelated repository sweeps, code cleanup hunts, or general audits outside the affected blast radius.

## Blocking vs Non-Blocking Future Template Behavior
| Finding type | Expected severity behavior | Blocking? |
|--------------|----------------------------|-----------|
| Proven defect in the requested changed path | Existing severity model applies | Yes |
| Proven invariant/preservation/default-path break within affected blast radius | Existing severity model applies | Yes |
| Missing proof that exact regression path was checked | NEEDS_CHANGES/BLOCKED via evidence rules | Yes |
| Missing bounded-sweep coverage for declared blast radius | NEEDS_CHANGES/BLOCKED via coordinator acceptance gate | Yes |
| Speculative adjacent concern without proof | Cap at MEDIUM or LOW | No |
| Issue outside declared blast radius or unrelated repo area | Advisory only or explicitly out of scope | No |
| Cleanup/style suggestion unrelated to requested change | LOW | No |

## Validation Matrix
| Check | Command / Method | Proves |
|------|-------------------|--------|
| Exact regression path | Read updated `templates/subagents/master/analyzer.md`; run `./scripts/update-subagents.sh --agent=analyzer --dry-run` | Analyzer still performs blocking review of the requested change after the prompt update. |
| Edge case / boundedness | Read updated `templates/subagents/master/analyzer.md` and `templates/subagents/master/coordinator.md`; verify wording limits sweep to affected blast radius and rejects repo-wide audit drift | Adjacent sweep is bounded and enforced by coordinator rather than expanding globally. |
| Preservation check | Read updated `templates/subagents/master/analyzer.md` and `templates/subagents/master/coordinator.md`; verify `APPROVED/NEEDS_CHANGES/BLOCKED`, proof-standard, evidence-reviewed, and scope-drift sections remain intact | Existing review contract and blocking/evidence behavior are preserved. |
| Global framing consistency | Run `./scripts/update-global-instructions.sh --system=all --dry-run`; inspect analyzer guidance in `templates/global-instructions/master.md` | Top-level instructions match the bounded-sweep rule without requiring extra template files. |

## Evidence Owners
| Item | Owner | Proof Required |
|------|-------|----------------|
| Bounded-sweep wording in analyzer template | @implementer | File diff/readback showing exact bounded-sweep rule |
| Coordinator acceptance rule for bounded coverage | @implementer | File diff/readback showing exact acceptance-gate language |
| Preservation of blocking review + proof standard | @analyzer | Readback against `analyzer.md` output-format/proof-standard sections |
| No extra template file required | @analyzer | Readback of scoped templates plus `METADATA.json:88-101` evidence |
| Dry-run propagation evidence | @implementer | Successful `--dry-run` command output summaries |

## Failure Signals
- Analyzer wording allows adjacent sweep without a bound such as declared blast radius, affected callers, fallback/default paths, or preserved behavior.
- Coordinator accepts reviews that mention adjacent issues but do not prove exact-path coverage.
- Global wording broadens analyzer into a general repo audit or cleanup agent.
- Implementation requires changes to `METADATA.json`, scripts, or generated files to make the bounded rule work.
- The updated analyzer text weakens proof requirements or removes existing final status contracts.

## Review Gates
| Gate | After Phase | Focus Area |
|------|-------------|------------|
| Gate 1 | Phase 1 | Exact blocking-path preservation and bounded-sweep definition |
| Gate 2 | Phase 2 | Coordinator enforcement of bounded coverage and anti-scope-drift rules |
| Gate 3 | Phase 3 | Global framing consistency without extra template expansion |

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Analyzer wording becomes too broad and triggers repo-wide review behavior | MEDIUM | HIGH | Add explicit non-goal language and coordinator rejection of unrelated sweep scope |
| Analyzer wording becomes too weak and adjacent sweep becomes optional/non-enforced | MEDIUM | MEDIUM | Add explicit coordinator acceptance criteria tied to bounded coverage |
| Future implementer changes extra template files unnecessarily | LOW | MEDIUM | Keep exact-files section strict and require evidence before expanding scope |

## Rollback Notes
- Roll back by reverting only the modified wording in the three scoped template files.
- If Phase 1 introduces ambiguity, revert `templates/subagents/master/analyzer.md` first and restore exact blocking-review wording before attempting a narrower rewrite.
- If Phase 2 over-constrains coordinator flow, revert only the new bounded-coverage acceptance wording in `templates/subagents/master/coordinator.md`.
- If Phase 3 creates inconsistency or scope creep, revert the analyzer description/use edits in `templates/global-instructions/master.md` without touching subagent rules.
- Do not roll back by editing generated outputs directly; master-template rollback plus regeneration is the only valid path.

## Decision Log
| Decision | Chosen | Rejected | Rationale | Evidence |
|----------|--------|----------|-----------|----------|
| Files to modify | Only the 3 scoped master templates | Expanding to `planner.md` or `METADATA.json` | The behavior request is about analyzer review semantics and enforcement, which already live in analyzer/coordinator/global templates | `analyzer.md:72-80,173-199`; `coordinator.md:223-238,315-320`; `global-instructions/master.md:251-259`; `METADATA.json:88-101` |
| How to enforce boundedness | Prompt rule + coordinator acceptance gate | Repo-wide audit language or metadata-only wording | Smallest change that preserves existing contracts and adds enforceable bounds | Same evidence as above |
| Validation method | Readback + `--dry-run` scripts | Runtime code/tests outside templates | Scope is prompt-template only; dry-run generation is sufficient and already supported | `scripts/update-subagents.sh:27-41`; `scripts/update-global-instructions.sh:27-40`; `templates/global-instructions/README.md:173-193` |
