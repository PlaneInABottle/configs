# Split Boundaries

## Purpose

Document the repository boundary between runtime-verification guidance and skill-governance guidance so future audits do not re-expand `ai-native-workflow` into a catch-all maintenance skill.

## Boundary Decision

Keep `ai-native-workflow` unified for runtime verification because its playbooks share one operating model:

- treat the app as a language-agnostic system under test
- verify behavior across stable boundaries such as HTTP, DOM, CLI, queues, and databases
- use one universal toolchain (`hurl`, `agent-browser`, native DB clients, Docker, env-native Faker, queue CLIs)

That shared systems-operator model is the reason the runtime playbooks stay together instead of splitting into separate per-protocol skills.

Move meta-skill governance out of `ai-native-workflow` because it answers different questions:

- Should a skill be split, deduplicated, or kept unified?
- Which guidance belongs in `SKILL.md` versus `references/`?
- When should a repeated explanation become a maintained skill?
- Which skill owns authoring, packaging, and validator-contract details?

Those are repository-maintenance concerns, not runtime-verification concerns.

## Ownership Map

| Concern | Owning skill | Why |
|---|---|---|
| Runtime setup, universal verification, operational playbooks | `ai-native-workflow` | One coherent systems-operator workflow across app boundaries |
| Auditing overlap, split decisions, deduplication, evidence-backed cleanup | `skill-maintainer` | Repository skill hygiene and boundary governance |
| Writing, updating, validating, and packaging skill files | `skill-creator` | Mechanical authoring workflow and validator contract |

## Relocated Guidance From `skill-creation-triggers.md`

The removed `ai-native-workflow/examples/skill-creation-triggers.md` mixed runtime examples with meta-skill guidance. Keep only the boundary-relevant heuristics here:

1. If the same repository-skill explanation has to be repeated, treat that as maintenance input for `skill-maintainer`.
2. If a session reveals non-obvious packaging, frontmatter, or validation rules, capture that under `skill-creator`, not `ai-native-workflow`.
3. If a debugging session reveals a runtime failure mode for the universal toolchain, keep it in `ai-native-workflow` or its runtime references.
4. If guidance grows beyond one concern, split at the skill boundary instead of adding another major maintenance section to `ai-native-workflow`.

## Audit Rule

When reviewing `ai-native-workflow`, allow runtime-verification breadth but reject new repository skill-audit, skill-creation, or packaging sections unless they are brief pointers to `skill-maintainer` or `skill-creator`.
