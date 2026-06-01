# Skill Authoring Guide (v2)

This document defines the structural and behavioral conventions for building skills in `claude-workflow` v2.

## Three-Layer Hierarchy

Skills are organized into three layers based on their role and visibility.

|Layer|Role|`user-invocable`|Description|
|-|-|-|-|
|**Layer 1**|Orchestrator|`true`|High-level workflows that coordinate multiple sub-skills and agents.|
|**Layer 2**|Sub-skill|`true`|Specialized, reusable functional blocks that perform a distinct part of a workflow.|
|**Layer 3**|Behavioral Convention|`false`|Internal rules, protocols, and constraints that govern how agents behave during a task.|

### Layer vs. Reference File

Skills and reference files serve different purposes and require different access patterns. Use this table to choose the right artifact and syntax.

|What you're accessing|When to use|How to access|
|-|-|-|
|Layer-3 behavioral skill|Runtime protocol agents must actively adopt|`Invoke \`Skill("<name>")\``|
|Per-skill reference doc|Static tables, checklists, or context scoped to one skill|`Read \`references/<file>.md\``|
|Shared reference doc|Static tables, checklists, or context shared across skills|`Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``|

**Decision rule**: If the file encodes a behavioral constraint agents must actively operate under → layer-3 skill. If the file contains format tables, field lists, or read-only lookup context → `_shared/` doc.

---

## Layer 3: Behavioral Convention Skills

Layer-3 skills encode internal protocols, rules, and behavioral constraints. They do not perform domain work themselves; instead, they communicate behavioral expectations to the calling agent.

### When to Create a Layer-3 Skill

Create a layer-3 skill when you have:
1. **Structured behavioral protocol** — A protocol or set of rules that must be adopted by agents during their task (e.g., how to handle seed-briefs, CWD verification, orchestration rules).
2. **Cross-skill reuse** — The protocol is referenced by 3+ other skills or sub-agents.
3. **Conditional invocation** — The protocol is invoked based on conditions detected at runtime (e.g., checking for a seed-brief in the input).

Use `_shared/<file>.md` instead when the content is a format template, field list, or lookup table that callers simply read — not a behavioral constraint they must actively operate under.

### Layer-3 Skill Design

**Frontmatter:**
```yaml
user-invocable: false
layer: 3
```

**Content Structure:**
- Open with a 1-2 sentence summary of the protocol.
- Divide into sections: **Contract**, **Behavior**, **Verification** (as appropriate).
- Document entry conditions, exit behaviors, and any state mutations.

### Layer-3 Skills in `claude-workflow`

The current layer-3 skill catalog lives in `skills/`. Consult `ls skills/` for a list of available protocols. Each skill directory contains a `SKILL.md` with the authoritative protocol definition.

---

## Layer 1: Orchestrator Constraints

Orchestrators must remain "thin" to avoid context bloat and logic drift.

- **SKILL.md Limit**: Must be ≤ 150 lines.
- **No Inline Domain Work**: Orchestrators should not perform the actual task (e.g., writing code, auditing files).
- **Delegation**: All domain work must be delegated via `Skill()` (for layer-2/3 skills) or `Agent()` (for workers).

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
|**Orchestrator** (Layer 1)|Coordinates sub-skills and agents; manages loop and phase sequencing.|`/implement`, `/issue-autopilot`|`sonnet`/`opus`|`SKILL.orchestrator`|
|**Specialist** (Layer 2)|Bounded task with seed-brief input and findings report output.|`/build`, `/review`, `/verify`|`sonnet`|`SKILL.specialist`|
|**Interactive Primitive** (Layer 2)|Inline behavior; no delegation or handoff.|`/grill-me`|`sonnet`|`SKILL.primitive`|

---

## Orchestrator Decomposition

When an orchestrator must decide how to fan out work across agents, use `/scope-assessment` as the canonical decomposition step:

1. Build a `work_units` list — one entry per issue, file group, or bounded task, each with an `id` and `resources` list.
2. Invoke `/scope-assessment`; receive back an agent plan where each entry covers a set of work units that share no resources with any other entry.
3. Dispatch one agent per entry in the plan.

Document the orchestrator's specific definition of "work unit" (what counts as an input, what its `resources` list must contain) in the orchestrator's own `references/scope.md`. That file must also cite `/scope-assessment` as the canonical decomposition algorithm. The layer-3 skill encodes the algorithm only; per-caller variation lives at the call site.

---

## `_shared/` File Catalogue

Reference on-demand via `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``:

- `composition.md` — team/sub-agent cost and shape
- `handoff-artifact.md` — five-field issue-body structure for phase handoffs
- `notes-md-protocol.md` — `.claude/NOTES.md` lifecycle, shape, and update cadence

## Agent Catalogue

- `agents/prune-lane.md` — pruning logic (dispatched by `/prune`)
