# Dispatch Primitives — Decision Framework

This document establishes when to use each dispatch mechanism in `agents-flow` (`Skill`, `Agent`, `context: fork`, `agent:`, `isolation: worktree`) and defines the canonical role taxonomy (Orchestrator, Interaction, Worker, Protocol). It replaces the layer-number terminology in `_shared/AUTHORING.md` as the human-facing classification system.

## Core Principle

Main context is the conductor. Background agents are the orchestra.

The main conversation handles human interaction (approvals, grill-me, confirmations), dispatch (spawning Workers, calling sub-Orchestrators), response analysis (merging findings from Workers), and summary. All actual work — research, file scanning, code analysis, verification, knowledge extraction — runs in background Workers. Nothing that can be delegated should run inline in the main context.

## Role Taxonomy

Four roles define the dispatch contract and execution context:

|Role|Runs in|User interaction|Dispatches|`context: fork`|
|-|-|-|-|-|
|**Orchestrator**|Main context|Yes|Optionally: other Orchestrators and/or Workers|Never|
|**Interaction**|Main context|Yes — only|Never|Never|
|**Worker**|Background/isolated|Task confirmations only|Optionally: other Workers|Always (Skill); implied (Agent file)|
|**Protocol**|Caller's context|N/A|Never|Never|

Worker sub-types — same role, different packaging:

|Sub-type|Format|Invocation|User-invocable|
|-|-|-|-|
|Worker Skill|SKILL.md + `context: fork`|`Skill("name")`|Can be|
|Worker Agent|`agents/*.md` file|`Agent("path.md")`|Never|

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

|Task type|`agent:`|
|-|-|
|Read-only or pure computation: file scan, codebase research, lookups, structured reasoning over prompt input|`Explore` — Haiku model, no CLAUDE.md loaded|
|Read-only: planning-phase analysis|`Plan` — no CLAUDE.md|
|Agent dispatch required, writes required, or gh mutations|`general-purpose`|

### `Agent("path.md")` — Worker Agent dispatch

Use for parallel fan-out and bulk I/O workers. Worker Agents live in `agents/*.md` at the repo root, one per role. They always run isolated (autonomous, no user interaction). Standard frontmatter: `disallowedTools: Agent AskUserQuestion` (prevents recursive spawning and interactive prompts).

When to use Worker Agent vs Worker Skill:

- Worker Skill: task is user-invocable OR meaningful enough to stand as its own skill directory.
- Worker Agent: internal implementation detail of a parent skill, never invoked directly by users.

### `isolation: worktree`

Parameter on `Agent()` calls. Gives the spawned agent its own git worktree to prevent filesystem race conditions. Use when spawning 2+ parallel agents and disjoint file scope cannot be guaranteed after `/scope-assessment`. Skip when scope is cleanly disjoint.
