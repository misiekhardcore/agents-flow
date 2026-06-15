# Skill Authoring Guide (v2)

This document defines the structural and behavioral conventions for building skills in `claude-workflow` v2.

## Role Taxonomy

Skills are classified by execution context and responsibility. See `${CLAUDE_PLUGIN_ROOT}/docs/dispatch-primitives.md` for the canonical taxonomy and `${CLAUDE_PLUGIN_ROOT}/_shared/dispatch-decision.md` for the condensed runtime reference.

### Skill vs. Reference File

Skills and reference files serve different purposes and require different access patterns. Use this table to choose the right artifact and syntax.

|What you're accessing|When to use|How to access|
|-|-|-|
|Protocol or Worker skill|Runtime behavior agents must adopt or execute|`Invoke \`Skill("<name>")\``|
|Per-skill reference doc|Static tables, checklists, or context scoped to one skill|`Read \`references/<file>.md\``|
|Shared reference doc|Static tables, checklists, or context shared across skills|`Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``|

**Decision rule**: If the file encodes a behavioral constraint agents must actively operate under → Protocol skill. If the file contains format tables, field lists, CLI command references, or read-only lookup context → `_shared/` doc. The instruction "agents must do X" is a Protocol skill; "here is the YAML format for field Z" is a shared reference doc.

## Protocol Skills

Protocol skills encode internal rules and behavioral constraints. They do not perform domain work themselves; instead, they communicate behavioral expectations to the calling agent.

### When to Create a Protocol Skill

Create a Protocol skill when you have:
1. **Structured behavioral protocol** — A protocol or set of rules that must be adopted by agents during their task (e.g., how to handle seed-briefs, CWD verification, orchestration rules).
2. **Cross-skill reuse** — The protocol is referenced by 3+ other skills or sub-agents.
3. **Conditional invocation** — The protocol is invoked based on conditions detected at runtime (e.g., checking for a seed-brief in the input).

Use `_shared/<file>.md` instead when the content is a format template, field list, or lookup table that callers simply read — not a behavioral constraint they must actively operate under.

### Protocol Skill Design

**Frontmatter:**
```yaml
user-invocable: false
```

**Content Structure:**
- Open with a 1-2 sentence summary of the protocol.
- Divide into sections: **Contract**, **Behavior**, **Verification** (as appropriate).
- Document entry conditions, exit behaviors, and any state mutations.

### Protocol Skills in `claude-workflow`

The current Protocol skill catalog lives in `skills/`. Consult `ls skills/` for a list of available protocols. Each skill directory contains a `SKILL.md` with the authoritative protocol definition.

## Orchestrator Constraints

Orchestrators must remain "thin" to avoid context bloat and logic drift.

- **SKILL.md Limit**: Must be ≤ 150 lines.
- **No Inline Domain Work**: Orchestrators should not perform the actual task (e.g., writing code, auditing files).
- **Delegation**: All domain work must be delegated via `Skill()` (for Worker or Protocol skills) or `Agent()` (for Worker Agents).

## Worker-Agent Dispatch Pattern

When spawning agents to perform work, follow these requirements:

### 1. Seed-Briefs
The caller must pass all needed context in the `prompt` argument. For single inputs, use one-line inline. For multiple inputs, use a structured YAML block. See `_shared/seed-brief.md` for the packaging convention.

### 2. Parallel Dispatch & Scope
To prevent race conditions and "last-write-wins" conflicts:
- **Disjoint Scope**: Assign agents to disjoint `files_to_touch`.
- **Isolation Escape Hatch**: If disjoint scope cannot be guaranteed, use `isolation: "worktree"` to provide each agent with its own git worktree.

### 3. Defensive Frontmatter
Worker agents should include `disallowedTools: Agent` in their frontmatter to prevent recursive agent spawning.

## Custom Agent Authoring

### When to use a Custom Agent File
Use a dedicated file in the skill's `agents/` directory when:
- Specific tool restrictions are required.
- A specific model override is needed.
- `disallowedTools` guardrails must be enforced.
- A `maxTurns` cap is required.

### Body Bug Workaround (GitHub #13627)
Due to a bug where agent file bodies are occasionally ignored:
- **Constraint**: All critical rules and personas must be embedded directly in the `prompt` argument of the `Agent()` call, not just in the agent file.
- `TODO: remove this workaround when GitHub #13627 is resolved`.

## Orchestrator Loop Pattern

For tasks requiring iterative refinement (e.g., Build → Review → Verify):
- **Cycle Counter**: Maintain an explicit counter of completed cycles.
- **Hard Stop**: Implement a hard stop at N iterations to prevent infinite loops.
- **Autonomy**: Use an `autonomous` flag in the seed-brief to signal that the agent should proceed through cycles back-to-back without user intervention.

## NOTES.md Progress Ledger

Orchestrators (and standalone L2 skills) use `.claude/NOTES.md` as their in-phase progress tracker:

- **Create on entry**: Write `## Current task` and initial state when the phase starts.
- **Checkpoint before spawn**: Before every `Skill()` or `Agent()` call, write the current task, next action, and any open questions. This provides crash recovery if the session dies mid-spawn.
- **Update on return**: After sub-agent completes, append findings, decisions, and updated task state.
- **Slice in seed-brief**: Include a `progress` field in the seed-brief payload carrying the relevant NOTES.md slice (task list subset + decisions).

**Ownership model**: Ownership transfers with the running agent. The orchestrator owns NOTES.md before spawn and after return. The spawned sub-skill owns it during execution. Since execution is sequential (spawn → wait → return), there are no concurrent writers.

Standalone L2 skills (called directly by the user, not by an orchestrator) follow the same pattern: create on entry, update during work, leave in place for resume.

See `_shared/notes-md-protocol.md` for the full protocol.

## Rename Migration

The `/discovery` skill has been renamed to `/discover`.

- **Breaking Change**: Existing `CLAUDE.md` references to `/discovery` will break.
- **Action**: Users must manually update their references. No compatibility shim is provided to avoid technical debt.

## Body Assembly by Role/Tier

Each skill maps to a role and tier. `/new-skill` derives the tier from the role, then assembles the SKILL.md body from these patterns.

### Tier Mapping

|Role|Tier|`user-invocable`|Template|
|-|-|-|-|
|**Orchestrator**|1 (Orchestrator)|`true`|Single minimal template|
|**Specialist**|2 (Sub-skill)|`true`|Single minimal template|
|**Utility**|2 (Sub-skill)|`true`|Single minimal template|
|**Primitive**|2 (Sub-skill)|`true`|Single minimal template|
|**Protocol**|3 (Behavioral)|`false`|Single minimal template|

### Body Sections by Role

`/new-skill` composes the SKILL.md body from these sections per derived role. Each section is documented inline; the skill generates only what the role needs.

|Role|Sections to include|`## Protocol skills`|`## Process` format|
|-|-|-|-|
|**Orchestrator**|`## Process`, `## Rules`|Required|`### N. Title` per step|
|**Specialist**|`## Input`, `## Process`, `## Output`, `## Rules`|If needed (Protocol skills)|`### N. Title` per step|
|**Utility**|`## Process`, `## Rules`|If needed|Plain numbered list|
|**Primitive**|`## Input`, `## Process` (2-4 steps), `## Output`, `## Rules`|Never|Plain numbered list|
|**Protocol**|Summary sentence, `## Contract`, `## Behavior`, `## Verification`|Never|Titled sections (no Process heading)|

### Section Templates

**`## Protocol skills`** (Orchestrator, Specialist, Utility):
```
Adopt `Skill("<protocol-name>")`.
```
One line per protocol. Usually `orchestrator-rules` for orchestrators, `interviewing-rules` for interactive skills.

**`## Process`** (Orchestrator):
```
### 1. <Title>
<Step description.>
```
Sequential step numbering. Orchestrators always include Init NOTES.md, Sign-off, and Compound.

**`## Input`** (Specialist, Primitive):
```
<!-- What the skill receives — issue, seed-brief fields, or problem statement. -->
```

**`## Output`** (Specialist, Primitive):
```
<!-- What the skill produces — report, file, findings. -->
```

**`## Rules`** (Orchestrator, Specialist, Utility, Primitive):
```
- <Rule 1>
- <Rule 2>
```

### Default Frontmatter by Role

|Field|Orchestrator|Specialist|Utility|Primitive|Protocol|
|-|-|-|-|-|-|
|`model`|`sonnet`|`sonnet`|`sonnet`|`sonnet`|`sonnet`|
|`effort`|omit|omit|omit|omit|omit|
|`allowed-tools`|omit|omit|omit|omit|omit|
|`user-invocable`|omit (defaults true)|omit|omit|omit|`false`|

## Orchestrator Decomposition

When an orchestrator must decide how to fan out work across agents, use `/scope-assessment` as the canonical decomposition step:

1. Build a `work_units` list — one entry per issue, file group, or bounded task, each with an `id` and `resources` list.
2. Invoke `/scope-assessment`; receive back an agent plan where each entry covers a set of work units that share no resources with any other entry.
3. Dispatch one agent per entry in the plan.

Document the orchestrator's specific definition of "work unit" (what counts as an input, what its `resources` list must contain) in a dedicated `references/` doc. That doc must also cite `/scope-assessment` as the canonical decomposition algorithm. The protocol skill encodes the algorithm only; per-caller variation lives at the call site.

## `_shared/` File Catalogue

Reference on-demand via `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md\``:

- `composition.md` — team/sub-agent cost and shape
- `dispatch-decision.md` — condensed role taxonomy and `context: fork` decision table
- `handoff-artifact.md` — five-field issue-body structure for phase handoffs
- `interviewing-rules.md` — one-question-at-a-time interviewing protocol for user-interactive discovery
- `notes-md-protocol.md` — `.claude/NOTES.md` lifecycle, shape, and update cadence
- `seed-brief.md` — spawn-time context packaging (caller-side YAML convention)
- `worktree-protocol.md` — `wt` CLI command protocol for creating and managing feature worktrees

## Agent File Template

Agent files live in `skills/<skill-name>/agents/<agent-name>.md`. Use this template:

```yaml
---
name: <agent-name>
description: <one sentence — what it does and when it's spawned>
model: <sonnet|haiku|opus>
user-invocable: false
disallowedTools: Agent AskUserQuestion
---
<Role sentence. Input source. No user interaction.>

## Input (from spawn prompt)

- `field`: description

## Process

1. `cd <cwd> && pwd` — always verify CWD first.
2. ...

## Output

```
structured output block
```

## Rules

- No user interaction.
- Read only unless explicitly writing code/files.
```

## Agent Catalogue

Agent files live under `skills/<name>/agents/`. See each skill's `agents/` directory for its agent files. Common patterns:
- `<skill>/agents/<skill>-runner.md` — autonomous core (Tier 2 shell + runner split)
- `<skill>/agents/<role>-agent.md` — parallel worker (spawned by runner)
- `<skill>/agents/reviewer-<domain>.md` — domain reviewer (spawned by review-runner)
