# AUTHORING.md — Skill Authoring Standard

Directives for creating/editing skills. Ensures consistency, token efficiency, and predictability.

## Skill Roles
All skills map to one of these five roles (extending the [Ref: composition] model). Use the corresponding template.

|Role|Definition|Example|Model|Template|
|-|-|-|-|-|
|**Research-Lead Orch**|Leads phase → research → specialists → handoff.|`/discovery`, `/define`|`opus`|`SKILL.orchestrator`|
|**Coordinator Orch**|Sequences sub-skills in loop (Build → Review → Verify).|`/implement`|`sonnet`|`SKILL.orchestrator`|
|**Specialist**|Bounded task → seed-brief → report findings.|`/build`, `/review`|`sonnet`|`SKILL.specialist`|
|**Interactive Primitive**|Inline behavior; no team or handoff.|`/grill-me`|`sonnet`|`SKILL.primitive`|
|**Utility**|Maintenance/post-work. No seed-brief or handoff.|`/compound`, `/prune`|`sonnet`/`haiku`|`SKILL.specialist`|

## Structure & Density
**Goal**: Maximize info-density. Replace narrative with constraints.

### Frontmatter
Order: `name` → `description` → `when_to_use` → `argument-hint` → `model` → `effort` → `allowed-tools` → `user-invocable` → `disable-model-invocation`.
- `description`: <= 150 chars. Trigger-focused.
- `model`: `haiku` (fast/retrieval), `sonnet` (standard/impl), `opus` (deep research/arch).

### Body Layout
1. **Role & Constraints**: Imperative directives. No "You are a...".
2. **Specialist Mode**: [Ref: specialist-mode] seed-brief skip-list.
3. **I/O**: Input → Output. No paragraphs.
4. **Scope Assessment**: Table based on complexity → Action.
5. **Spawn Justification**: [Ref: composition] rubric (Pivot, Disjoint, Parallel, Payoff).
6. **Process**: Step-by-step imperative flow.
7. **Rules**: Hard constraints + [Ref: interviewing-rules].

## `_shared/` Integration
Do not preload. Reference on-demand via `${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md`.
- `handoff-artifact.md`: Issue body state.
- `interviewing-rules.md`: User interaction.
- `notes-md-protocol.md`: `.claude/NOTES.md` state.
- `specialist-mode.md`: Seed-brief logic.
- `compaction-protocol.md`: In-phase context management.
- `composition.md`: Team/sub-agent cost and shape.

`[Ref: name]` is shorthand for `${CLAUDE_PLUGIN_ROOT}/_shared/name.md`. Skills use it for compact inline references in space-constrained skill bodies.

## Compaction Checklist
Before declaring any compaction (density pass, context-hygiene trim) complete:
- All gates and numeric thresholds preserved verbatim (no approximation).
- All spawn rubrics, dispatch contracts, and payload specs intact.
- All `[Ref:]` cross-references present — none silently removed.
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
- **Imperative**: "Read issue", not "You should read".
- **Surgical**: One short comment line max.
- **Dense**: No filler, no preamble, no "The skill does X".
- **Rational**: Pair every "Don't" with a "Do" (Augment Code study).
