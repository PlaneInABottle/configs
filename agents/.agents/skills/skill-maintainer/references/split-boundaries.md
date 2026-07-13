# Split Boundaries

## Purpose

Keep runtime orchestration, protocol operators, domain adapters, and skill governance distinct so an agent loads the minimum context for the active task.

## Boundary Decision

Keep `ai-native-workflow` unified as the runtime and evidence orchestrator. It owns Phase 0 discovery, capability routing, the acceptance-evidence matrix, bounded recovery, review, and cleanup.

Do not make the umbrella repeat dedicated operator procedures. API contracts, WebSockets, load testing, runtime observability, migrations, visual regression, dependency upgrades, releases, and security baselines have separate trigger surfaces, tools, risks, and evidence formats. The umbrella selects and composes those skills.

Keep small supporting playbooks inside the umbrella when they do not justify an independent trigger surface, such as fixture generation, dependency fakes, media fixtures, and GraphQL checks until usage evidence supports a split.

Move meta-skill governance out of `ai-native-workflow`. Auditing overlap, deciding splits, changing frontmatter contracts, authoring, validation, and packaging belong to `skill-maintainer` and `skill-creator`.

## Ownership Map

| Concern | Owner |
|---|---|
| Project discovery, runtime phases, skill routing, evidence completion | `ai-native-workflow` |
| Protocol/tool execution, recovery, cleanup, stop conditions | Matching operator skill |
| Framework-specific implementation | Matching domain skill |
| Durable project runtime contract creation | `project-onboarding` |
| Skill overlap, split, deduplication, and quality audit | `skill-maintainer` |
| Skill authoring, validation, and packaging mechanics | `skill-creator` |

## Audit Rule

Allow orchestration breadth in `ai-native-workflow`, but reject duplicated operator procedures and repository skill-governance sections. Split only when a concern has an independent trigger surface and materially different tools, risks, or evidence; do not split supporting detail merely because a file is long.
