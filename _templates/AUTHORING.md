# Skill Authoring Guide (v2)

This document defines the structural and behavioral conventions for building skills in `claude-workflow` v2.

## Three-Tier Hierarchy

Skills are organized into three tiers based on their role and visibility.

|Tier|Role|`user-invocable`|Description|
|-|-|-|-|
|**Tier 1**|Orchestrator|`true`|High-level workflows that coordinate multiple sub-skills and agents.|
|**Tier 2**|Sub-skill|`true`|Specialized, reusable functional blocks that perform a distinct part of a workflow.|
|**Tier 3**|Behavioral Convention|`false`|Internal rules, protocols, and constraints that govern how agents behave during a task.|

### Tier vs. Reference File
- **Tier 3 Skill**: Use when the behavior is a structured "protocol" that requires a formal `SKILL.md` and is invoked via `Skill()` to ensure the agent adopts the persona/constraints.
- **Reference File (`_shared/*.md`)**: Use for raw documentation, static lists, or context that is read via `Read()` without changing the agent's behavioral mode.

---

## Tier 1: Orchestrator Constraints

Orchestrators must remain "thin" to avoid context bloat and logic drift.

- **SKILL.md Limit**: Must be ≤ 150 lines.
- **No Inline Domain Work**: Orchestrators should not perform the actual task (e.g., writing code, auditing files).
- **Delegation**: All domain work must be delegated via `Skill()` (for tier-2/3 skills) or `Agent()` (for workers).

---

## Worker-Agent Dispatch Pattern

When spawning agents to perform work, follow these requirements:

### 1. Seed-Briefs
Agents start fresh. The orchestrator must construct a complete, self-contained "seed-brief" in the `prompt` argument. Do not assume the agent has context from previous turns unless explicitly passed.

### 2. Parallel Dispatch & Scope
To prevent race conditions and "last-write-wins" conflicts:
- **Disjoint Scope**: Assign agents to disjoint `files_to_touch`.
- **Isolation Escape Hatch**: If disjoint scope cannot be guaranteed, use `isolation: "worktree"` to provide each agent with its own git worktree.

### 3. Defensive Frontmatter
Worker agents should include `disallowedTools: [TeamCreate, Agent]` in their frontmatter to prevent recursive agent spawning.

---

## Custom Agent Authoring

### When to use a Custom Agent File
Prefer `Agent(general-purpose)` by default. Use a dedicated file in the `agents/` directory (at plugin root) ONLY when:
- Specific tool restrictions are required.
- A specific model override is needed.
- `disallowedTools` guardrails must be enforced.
- A `maxTurns` cap is required.

### Body Bug Workaround (GitHub #13627)
Due to a bug where agent file bodies are occasionally ignored:
- **Constraint**: All critical rules and personas must be embedded directly in the `prompt` argument of the `Agent()` call, not just in the agent file.
- `TODO: remove this workaround when GitHub #13627 is resolved`.

---

## Orchestrator Loop Pattern

For tasks requiring iterative refinement (e.g., Build → Review → Verify):
- **Cycle Counter**: Maintain an explicit counter of completed cycles.
- **Hard Stop**: Implement a hard stop at N iterations to prevent infinite loops.
- **Autonomy**: Use an `autonomous` flag in the seed-brief to signal that the agent should proceed through cycles back-to-back without user intervention.

---

## Rename Migration

The `/discovery` skill has been renamed to `/discover`.

- **Breaking Change**: Existing `CLAUDE.md` references to `/discovery` will break.
- **Action**: Users must manually update their references. No compatibility shim is provided to avoid technical debt.

---

## Skill Roles & Templates

Each skill maps to one of three templates. Use the corresponding template from `_templates/`.

|Role|Definition|Example|Model|Template|
|-|-|-|-|-|
|**Orchestrator**|Coordinates sub-skills and agents; manages loop and phase sequencing.|`/implement`, `/issue-autopilot`|`sonnet`/`opus`|`SKILL.orchestrator`|
|**Specialist**|Bounded task with seed-brief input and findings report output.|`/build`, `/review`, `/verify`|`sonnet`|`SKILL.specialist`|
|**Interactive Primitive**|Inline behavior; no delegation or handoff.|`/grill-me`|`sonnet`|`SKILL.primitive`|

---

## `_shared/` File Catalogue

Reference on-demand via `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``:

- `compaction-protocol.md` — in-phase context management
- `composition.md` — team/sub-agent cost and shape
- `handoff-artifact.md` — issue body state
- `interviewing-rules.md` — user interaction
- `notes-md-protocol.md` — `.claude/NOTES.md` state
- `orchestrator-rules.md` — pipeline orchestrator rules (CWD verification, delegation, no-merge contract)
- `repo-preflight.md` — repo/branch confirmation before `gh` or `git push`
- `scope-preflight.md` — file-list confirmation before bulk edits (≥3 files)
- `specialist-mode.md` — seed-brief logic
- `worktree-protocol.md` — worktree creation, CWD verification, and cleanup
