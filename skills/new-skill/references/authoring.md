# Skill Authoring Guide

This document defines the structural and behavioral conventions for building skills in `agents-flow`.

## Role Taxonomy

Skills are classified by execution context and responsibility. See `docs/dispatch-primitives.md` for the canonical taxonomy and `references/dispatch-decision.md` for the condensed runtime reference.

### Skill vs. Reference File

Skills and reference files serve different purposes and require different access patterns. Use this table to choose the right artifact and syntax.

|What you're accessing|When to use|How to access|
|-|-|-|
|Protocol or Worker skill|Runtime behavior agents must adopt or execute|Invoke the `<name>` skill|
|Per-skill reference doc|Static tables, checklists, or context scoped to one skill|`Read \`references/<file>.md\``|
|Shared reference doc|Static tables, checklists, or context shared across skills|`Read \`_shared/<file>.md\``|

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

### Protocol Skills in `agents-flow`

The current Protocol skill catalog lives in `skills/`. Consult `ls skills/` for a list of available protocols. Each skill directory contains a `SKILL.md` with the authoritative protocol definition.

## Orchestrator Constraints

Orchestrators must remain "thin" to avoid context bloat and logic drift.

- **SKILL.md Limit**: Must be ≤ 150 lines.
- **No Inline Domain Work**: Orchestrators should not perform the actual task (e.g., writing code, auditing files).
- **Delegation**: All domain work must be delegated via the skill tool (for Worker or Protocol skills) or the task tool (for Worker Agents).

## Worker-Agent Dispatch Pattern

When spawning agents to perform work, follow these requirements:

### 1. Seed-Briefs
The caller must pass all needed context in the `prompt` argument. For single inputs, use one-line inline. For multiple inputs, use a structured YAML block. See AGENTS.md § Key Conventions — Seed-brief for the packaging convention.

### 2. Parallel Dispatch & Scope
To prevent race conditions and "last-write-wins" conflicts:
- **Disjoint Scope**: Assign agents to disjoint `files_to_touch`.
- **Isolation Escape Hatch**: If disjoint scope cannot be guaranteed, use `isolation: "worktree"` to provide each agent with its own git worktree.

### 3. Defensive Frontmatter
Worker agents should include opencode guardrails:

- **Permission**: `permission: { task: {"*": "deny"}, question: "deny" }` — prevents recursive agent spawning and user interaction.
- **Read-only workers** (reviewers, scanners): Add `edit: "deny"` to `permission`.

## Custom Agent Authoring

### When to use a Custom Agent File
Use a dedicated file in the `agents/` directory when:
- Specific tool restrictions are required (`permission` for opencode).
- A specific model override is needed.
- `mode` classification must be set (`primary` for orchestrators, `all` for sub-orchestrators, `subagent` for workers).
- A `maxTurns` (`steps` in opencode) cap is required.

### Body Bug Workaround (GitHub #13627)
Due to a bug where agent file bodies are occasionally ignored:
- **Constraint**: All critical rules and personas must be embedded directly in the spawn prompt when dispatching via the task tool, not just in the agent file.
- `TODO: remove this workaround when GitHub #13627 is resolved`.

## Orchestrator Loop Pattern

For tasks requiring iterative refinement (e.g., Build → Review → Verify):
- **Cycle Counter**: Maintain an explicit counter of completed cycles.
- **Hard Stop**: Implement a hard stop at N iterations to prevent infinite loops.
- **Autonomy**: Use an `autonomous` flag in the seed-brief to signal that the agent should proceed through cycles back-to-back without user intervention.

## NOTES.md Progress Ledger

Orchestrators (and standalone L2 skills) use `.claude/NOTES.md` as their in-phase progress tracker:

- **Create on entry**: Write `## Current task` and initial state when the phase starts.
- **Checkpoint before spawn**: Before every skill invocation or agent spawn, write the current task, next action, and any open questions. This provides crash recovery if the session dies mid-spawn.
- **Update on return**: After sub-agent completes, append findings, decisions, and updated task state.
- **Slice in seed-brief**: Include a `progress` field in the seed-brief payload carrying the relevant NOTES.md slice (task list subset + decisions).

**Ownership model**: Ownership transfers with the running agent. The orchestrator owns NOTES.md before spawn and after return. The spawned sub-skill owns it during execution. Since execution is sequential (spawn → wait → return), there are no concurrent writers.

Standalone L2 skills (called directly by the user, not by an orchestrator) follow the same pattern: create on entry, update during work, leave in place for resume.

See `_shared/notes-md-protocol.md` for the full protocol.

## Rename Migration

The `/discovery` skill has been renamed to `/discover`.

- **Breaking Change**: Existing `AGENTS.md` references to `/discovery` will break.
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
Adopt the "<protocol-name>" skill.
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

Per-role frontmatter defaults are documented in `references/frontmatter.md` (§ Default Values by Role). That file also serves as the canonical field registry for both tools and both file types (SKILL.md + agent `.md`).

## Orchestrator Decomposition

When an orchestrator must decide how to fan out work across agents, use `/scope-assessment` as the canonical decomposition step:

1. Build a `work_units` list — one entry per issue, file group, or bounded task, each with an `id` and `resources` list.
2. Invoke `/scope-assessment`; receive back an agent plan where each entry covers a set of work units that share no resources with any other entry.
3. Dispatch one agent per entry in the plan.

Document the orchestrator's specific definition of "work unit" (what counts as an input, what its `resources` list must contain) in a dedicated `references/` doc. That doc must also cite `/scope-assessment` as the canonical decomposition algorithm. The protocol skill encodes the algorithm only; per-caller variation lives at the call site.

## External Style & Config References

See `references/rfc-xml-style.md` for RFC 2119 + XML tag conventions and `references/opencode-config.md` for opencode config/permission fields. These are the adopted external best-practice patterns for artifact authoring.

## `_shared/` File Catalogue

- `notes-md-protocol.md` — `.claude/NOTES.md` lifecycle, shape, and update cadence (S6 territory; access via `Read \`_shared/notes-md-protocol.md\``)

All other shared docs have moved to skill-local `references/` directories or become skills. Access patterns:
- Authoring refs: `skills/new-skill/references/<file>` (authoring.md, frontmatter.md, dispatch-decision.md, rfc-xml-style.md, opencode-config.md, agent-presets.md)
- Spawn cost models: `skills/compound/references/composition.md`
- Seed-brief format: AGENTS.md § Key Conventions
- Worktree CLI: `skills/worktree/references/protocol.md`

## Agent File Template

Agent files live in `agents/<agent-name>.md`:

```yaml
---
name: <agent-name>
description: <one sentence — what it does and when it's spawned>
mode: subagent  # primary | all | subagent
# model: sonnet  # optional override
# hidden: true  # hide from @ menu (subagent only)
# permission:
#   task:
#     "*": "deny"
#   question: "deny"
#   edit: "deny"  # for read-only agents
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

All agent files live under `agents/`. See each skill's `## Worker Agent Inventory` section for spawned agents. Dispatch is a single tier — the primary orchestrator (or a lifecycle skill) dispatches leaf workers directly; no intermediate runner agents. Common patterns:
- `agents/<role>-agent.md` / `agents/workflow-<role>.md` — parallel leaf worker (spawned directly by the orchestrator)
- `agents/workflow-reviewer.md` — parameterized reviewer, one dispatch per `focus:` (replaces the old per-domain reviewer agents)
