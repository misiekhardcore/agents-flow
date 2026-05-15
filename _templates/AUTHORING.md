# AUTHORING.md — Skill Authoring Standard

Directives for creating/editing skills. Ensures consistency, token efficiency, and predictability.

## Skill Roles
All skills map to one of these five roles (extending the team-composition model; read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`). Use the corresponding template.

|Role|Definition|Example|Model|Template|
|-|-|-|-|-|
|**Research-Lead Orch**|Leads phase → research → specialists → handoff.|`/discovery`, `/define`|`opus`|`SKILL.orchestrator`|
|**Coordinator Orch**|Sequences sub-skills in loop (Build → Review → Verify).|`/implement`|`sonnet`|`SKILL.orchestrator`|
|**Specialist**|Bounded task → seed-brief → report findings.|`/build`, `/review`|`sonnet`|`SKILL.specialist`|
|**Interactive Primitive**|Inline behavior; no team or handoff.|`/grill-me`|`sonnet`|`SKILL.primitive`|
|**Utility**|Maintenance/post-work. No seed-brief or handoff.|`/compound`, `/prune`|`sonnet`/`haiku`|`SKILL.specialist`|

## File architecture

### File type hierarchy

| File type | Location | Line cap | Notes |
|-|-|-|-|
| Entry-point | `skills/<name>/SKILL.md` | ≤150 lines | Cap applies here only |
| Reference | `skills/<name>/references/<concern>.md` | No limit | Single concern; named after phase or topic |
| Shared protocol | `_shared/<concern>.md` | No limit | Promote when ≥3 skills reference it |

### Design principles

1. **Single responsibility**: One concern per reference file. Name reflects the phase or topic (e.g. `scope.md`, `process.md`, `gates.md`).
2. **Lazy loading**: Each `Read` instruction appears at the point of need in `SKILL.md` — not unconditionally at the top. A skill with two phases loads each reference file when entering that phase.
3. **DRY**: Promote a protocol to `_shared/` when ≥3 skills reference it. Keep under `skills/<name>/references/` below that threshold.
4. **Composition**: Reference `_shared/` files on-demand via `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\`` within skill bodies — never preload.

### Split heuristics

Split a reference file when two sections are loaded at different execution points (e.g. pre-flight vs. execution start) or one section runs on every invocation while another runs only in specific stages.

Do **not** split when all steps always run in linear order (one concern, no branching) or the file is already under ~50 lines.

### Example — two-phase skill

```
## Scope Assessment
Read `references/scope.md` for scope classification criteria.
...

## Process Overview
...
Step 4: Read `references/process.md` for step-by-step TDD flow and commit rules.
```

`scope.md` loads only during scope assessment. `process.md` loads only when execution begins.

### `_shared/` file catalogue

Reference on-demand via `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``:
- `compaction-protocol.md`: In-phase context management.
- `composition.md`: Team/sub-agent cost and shape.
- `handoff-artifact.md`: Issue body state.
- `interviewing-rules.md`: User interaction.
- `notes-md-protocol.md`: `.claude/NOTES.md` state.
- `specialist-mode.md`: Seed-brief logic.

Use explicit read instructions inline: `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/composition.md\`` instead of shorthand `[Ref: composition]`.

## Structure & Density
**Goal**: Maximize info-density. Replace narrative with constraints.

### Frontmatter
Order: `name` → `description` → `when_to_use` → `argument-hint` → `model` → `effort` → `allowed-tools` → `user-invocable` → `disable-model-invocation`.
- `description`: <= 150 chars. Trigger-focused.
- `when_to_use`: <= 1,536 chars combined with `description`. Include only when mis-routing is plausible: add explicit exclusions ("Does NOT X — use /Y"), sequence preconditions, or disambiguation from similar skills. Omit when `description` alone is unambiguous.
- `model`: `haiku` (fast/retrieval), `sonnet` (standard/impl), `opus` (deep research/arch).

#### Optional frontmatter fields

| Field | Values | When to use |
|-|-|-|
| `argument-hint` | `"[arg]"` string | Skills that accept a positional argument from the user. |
| `effort` | `low` / `high` | `high` for deep research/decision-making; `low` for maintenance/utility. Omit for standard. |
| `allowed-tools` | space-separated tool names | Pre-approves a narrow tool surface (skips permission prompts). Does **not** restrict access — the agent can still call other tools if unlocked at runtime. `Agent` is a valid tool name and must be listed for all orchestrating skills. |
| `user-invocable` | `false` | Hides the skill from the slash-command menu. Use for orchestrator-internal specialists. |
| `disable-model-invocation` | `true` | Skips the model call entirely — the skill is treated as a pure pipeline step that only sequences sub-skills. Only use for skills with no model-driven logic (no reasoning, no user interaction, no branching decisions). |

#### tools vs allowed-tools (agent frontmatter)

`allowed-tools` (skill frontmatter) and `tools` / `disallowedTools` (agent frontmatter) are distinct:

- **`allowed-tools`** — skill-level hint, pre-approves tools to skip permission prompts. Does not block access.
- **`tools`** — agent-level allowlist; only listed tools may be called (hard restriction).
- **`disallowedTools`** — agent-level blocklist; listed tools are always blocked, regardless of `tools`.

Agents (in `agents/`) use `tools` + `disallowedTools` for security isolation. Skills use `allowed-tools` for UX (fewer prompts).

#### Plugin security restrictions

Agents dispatched inside a plugin context run with constrained tool access by default. Declaring `tools:` in the agent frontmatter is the authoritative way to enforce least-privilege. `Skill` is a valid tool name for agents that need to invoke sub-skills (e.g. `prune-lane` invoking `claude-obsidian:wiki-lint`).

#### context and agent frontmatter

`context: fork` isolates an agent's context from the parent session. It is intentionally **not** used on claude-workflow orchestrating skills (`/define`, `/implement`, `/epic-autopilot`) because they need to sequence sub-skills with shared in-session state. Use `context: fork` only when the sub-task is fully self-contained and should not see parent context.

### Body Layout
1. **Role & Constraints**: Imperative directives. No "You are a...".
2. **Specialist Mode**: Read `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md` for seed-brief skip-list.
3. **I/O**: Input → Output. No paragraphs.
4. **Scope Assessment**: Table based on complexity → Action.
5. **Spawn Justification**: Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for team-composition rubric (Pivot, Disjoint, Parallel, Payoff).
6. **Process**: Step-by-step imperative flow.
7. **Rules**: Hard constraints plus interaction rules (read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`).

## Compaction Checklist
Before declaring any compaction (density pass, context-hygiene trim) complete:
- All gates and numeric thresholds preserved verbatim (no approximation).
- All spawn rubrics, dispatch contracts, and payload specs intact.
- All cross-references to `_shared/` files present with explicit `Read` instructions — none silently removed.
- All verdict/mutation/resolution steps accounted for.
- Output format spec and section headings unchanged.

## Implementation Rigor
- **Parallelism**: Default: inline → subagent → `TeamCreate`. Justify >= 3× payoff.
- **Overrun Prevention**: Delegate to sub-agent if:
  - >= 5 files read in loop (File-sweep).
  - N × item_size > budget (Fan-out).
  - Retrieval-only/Formatting (Thin-synthesis).
  - Verbose tool output → small field set (Verbose-I/O).
- **Naming**: `skills/<name>/SKILL.md` (lowercase kebab-case for dir, uppercase for file).

## Writing Style
- **External audience**: Write for external users — no personal paths, internal vault refs, or assumed local plugins. Link official Anthropic docs; one sentence plus a link is enough context.
- **Imperative**: "Read issue", not "You should read".
- **Surgical**: One short comment line max.
- **Dense**: No filler, no preamble, no "The skill does X".
- **Rational**: Pair every "Don't" with a "Do" (Augment Code study).
- **Numbered workflows**: Step-by-step processes outperform prose (+25% correctness per Augment study).
- **Decision tables**: Resolve routing ambiguity before coding (+25% best-practices adherence).
- **Code snippets**: 3–10 lines from real production use (+20% pattern reuse).
