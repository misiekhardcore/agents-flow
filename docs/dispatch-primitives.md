# Dispatch Primitives — Decision Framework

This document establishes when to use each dispatch mechanism in `claude-workflow` (`Skill`, `Agent`, `context: fork`, `agent:`, `isolation: worktree`), defines the canonical role taxonomy (Orchestrator, Interaction, Worker, Protocol), and audits all 26 skills against those rules. It replaces the layer-number terminology in `AUTHORING.md` as the human-facing classification system. The `layer:` frontmatter field remains until tooling is updated — see Tooling Note.

## Deliverables

This spec drives the following changes:

| File | Action |
|---|---|
| `docs/dispatch-primitives.md` | This document |
| `_shared/dispatch-decision.md` | New — condensed runtime-readable table for agents to consult when making dispatch decisions |
| `_templates/AUTHORING.md` | Update — replace layer-number role descriptions with new taxonomy; add pointer to this doc |
| `_shared/composition.md` | Update — fix "None" user interaction claim in consumption contracts table |
| `skills/audit-issues/SKILL.md` | Edit — remove `context: fork` |
| `skills/find-skills/SKILL.md` | Edit — remove `context: fork` |
| `skills/compound/SKILL.md` | Edit — add `context: fork` + `agent: general-purpose` |
| `skills/scope-assessment/SKILL.md` | Edit — add `context: fork` + `agent: Explore` |
| `skills/verify/SKILL.md` | Edit — add `context: fork` + `agent: general-purpose` |
| GitHub v2 issues | Audit — update open v2 issues to reflect new taxonomy and architecture; create issues for gaps; close issues made irrelevant by this design |

## Core Principle

Main context is the conductor. Background agents are the orchestra.

The main conversation handles human interaction (approvals, grill-me, confirmations), dispatch (spawning Workers, calling sub-Orchestrators), response analysis (merging findings from Workers), and summary. All actual work — research, file scanning, code analysis, verification, knowledge extraction — runs in background Workers. Nothing that can be delegated should run inline in the main context.

## Role Taxonomy

Four roles define the dispatch contract and execution context:

| Role | Runs in | User interaction | Dispatches | `context: fork` |
|---|---|---|---|---|
| **Orchestrator** | Main context | Yes | Optionally: other Orchestrators and/or Workers | Never |
| **Interaction** | Main context | Yes — only | Never | Never |
| **Worker** | Background/isolated | Task confirmations only | Optionally: other Workers | Always (Skill); implied (Agent file) |
| **Protocol** | Caller's context | N/A | Never | Never |

Worker sub-types — same role, different packaging:

| Sub-type | Format | Invocation | User-invocable |
|---|---|---|---|
| Worker Skill | SKILL.md + `context: fork` | `Skill("name")` | Can be |
| Worker Agent | `agents/*.md` file | `Agent("path.md")` | Never |

Key distinctions:

- **Orchestrators CAN have sub-Orchestrators**: Architecture calls grill-me; define calls architecture. Each is an Orchestrator with no `context: fork` required.
- **Interaction skills are simple Orchestrators**: They interact with user but never dispatch. `grill-me` and `specify` are the examples.
- **Workers run isolated from conversation history**: They may still exchange messages with the user for task-level confirmations (NOT for deliberation requiring conversation context).
- **Protocols are adopted, not spawned**: They modify the calling agent's behavior.

## Dispatch Primitives

### `Skill("name")` — in-context invocation

Runs in caller's session. Use for Orchestrators and Interactions. The skill shares conversation history with the caller.

### `context: fork` — isolated Worker Skill

Add to SKILL.md frontmatter when the skill is a Worker. The skill's markdown becomes the task prompt for a subagent. No conversation history. Always pair with `agent:`.

Criterion — use when ALL hold:

1. Explicit, argument-driven task (not behavioral guidelines).
2. No user deliberation during execution (task-level confirmations are fine).
3. Does not own orchestration state or user decision loops.

Never use on Orchestrators, Interactions, or Protocols.

### `agent:` — subagent type selector (only with `context: fork`)

Always specify explicitly — never rely on the silent `general-purpose` default.

| Task type | `agent:` |
|---|---|
| Read-only or pure computation: file scan, codebase research, lookups, structured reasoning over prompt input | `Explore` — Haiku model, no CLAUDE.md loaded |
| Read-only: planning-phase analysis | `Plan` — no CLAUDE.md |
| Agent dispatch required, writes required, or gh mutations | `general-purpose` |

### `Agent("path.md")` — Worker Agent dispatch

Use for parallel fan-out and bulk I/O workers. Worker Agents are defined as `agents/*.md` files within a skill directory. They always run isolated (autonomous, no user interaction). Standard frontmatter: `disallowedTools: [Agent, AskUserQuestion]` (prevents recursive spawning and interactive prompts).

When to use Worker Agent vs Worker Skill:

- Worker Skill: task is user-invocable OR meaningful enough to stand as its own skill directory.
- Worker Agent: internal implementation detail of a parent skill, never invoked directly by users.

### `isolation: worktree`

Parameter on `Agent()` calls. Gives the spawned agent its own git worktree to prevent filesystem race conditions. Use when spawning 2+ parallel agents and disjoint file scope cannot be guaranteed after `/scope-assessment`. Skip when scope is cleanly disjoint.

## Correction to `composition.md`

The "User Interaction" column in `composition.md`'s consumption contracts table is incorrect. Specifically, the row for "Forked (autonomous)" claims `None` — the correct characterization is "No conversation history". Task-level user confirmations (within an autonomous task, not requiring conversation history) are allowed. The distinction is subtle but load-bearing: Orchestrators deliberate with users interactively; Workers may confirm with users procedurally.

Update required: fix the consumption contracts table in `_shared/composition.md` to clarify that `context: fork` skills have "Task confirmations only, no conversation history" rather than "None".

## Skills Audit

Complete table of all 26 skills with assigned role and required changes:

| Skill | Role | `context: fork` | `agent:` | Required change |
|---|---|---|---|---|
| `architecture` | Orchestrator | — | — | Verify all research phases use background `Agent()` calls |
| `audit-issues` | Orchestrator | ❌ remove | ❌ remove | Remove `context: fork` — has interactive Phase 4; this is an Orchestrator |
| `build` | Orchestrator | — | — | None |
| `compaction-protocol` | Protocol | — | — | None |
| `compound` | Worker Skill | ✅ add | `general-purpose` | Add `context: fork` + `agent: general-purpose` |
| `define` | Orchestrator | — | — | None |
| `describe` | Orchestrator | — | — | Verify domain-researcher uses background `Agent()` |
| `design` | Orchestrator | — | — | Verify ux-researcher and reviewer use background `Agent()` |
| `discovery` | Orchestrator | — | — | Verify prior-art scouts use background `Agent()` |
| `epic-autopilot` | Orchestrator | — | — | None |
| `find-skills` | Orchestrator | ❌ remove | ❌ remove | Remove `context: fork` — has user confirmation step; this is an Orchestrator |
| `grill-me` | Interaction | — | — | None |
| `implement` | Orchestrator | — | — | None |
| `issue-autopilot` | Orchestrator | — | — | None |
| `new-skill` | Orchestrator | — | — | None |
| `notes-md` | Protocol | — | — | None |
| `orchestrator-rules` | Protocol | — | — | None |
| `preflight` | Protocol | — | — | None |
| `prune` | Orchestrator | — | — | None |
| `resolve-pr-feedback` | Orchestrator | — | — | None |
| `review` | Orchestrator | — | — | Calls `preflight` (user interaction) — stays in main context |
| `scope-assessment` | Worker Skill | ✅ add | `Explore` | Reclassify from Protocol; add `context: fork` + `agent: Explore` — pure computation, no tools needed |
| `specify` | Interaction | — | — | None |
| `verify` | Worker Skill | ✅ add | `general-purpose` | Add `context: fork` + `agent: general-purpose` |
| `worktree` | Protocol | — | — | None |
| `wrap-up` | Orchestrator | — | — | None |

No new agent files are required for these changes. The "Verify" items are audit checkpoints; any gaps found feed the restructuring epic.

## GitHub Issue Audit

All open v2 issues must be reconciled against this design before implementation begins.

Actions:
- **Update**: Issues referencing layer numbers, "Specialist", "Behavioral Convention", or the old context:fork semantics must be reworded to use the new taxonomy.
- **Create**: New issues for each skill change in the audit table (one issue per skill that requires a frontmatter edit or reclassification); one issue for the `_shared/dispatch-decision.md` new file; one issue for the AUTHORING.md and composition.md updates; one issue for the `layer:` tooling dependency cleanup.
- **Close**: Issues that described work now superseded by this design (e.g., any prior plan to add `context: fork` based on different criteria, or issues proposing a different taxonomy).

The restructuring epic (deferred below) should be tracked as a milestone containing both the issue audit sub-issues and the follow-up skill restructuring sub-issues.

## Deferred: Restructuring Epic

Skills like `architecture` currently mix research dispatch with interactive grill-me. The new taxonomy does not require those to be broken apart now — `architecture` is an Orchestrator and can own both. A follow-up restructuring epic will:

- Identify skills where the interactive component could be lifted to the calling Orchestrator to enable deeper background execution.
- Create GitHub sub-issues per skill.
- Update the v2 milestone to reflect the new architecture.

This document is the spec that drives that epic. No agent files are created or modified in the current deliverable.

## Tooling Note

The `layer:` frontmatter field (values 1/2/3) is used by `bin/list-prune-files` for the `prune` skill. Before removing it from skill frontmatter, that tooling dependency must be resolved. The field is deprecated as human-facing taxonomy (replaced by the role names in this doc) but should remain in frontmatter until the tooling is updated. File a sub-issue in the restructuring epic.
