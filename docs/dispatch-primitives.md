# Dispatch Primitives — Decision Framework

This document establishes when to use each dispatch mechanism in `agents-flow` (`Skill`, `Agent`, `isolation: worktree`) and defines the canonical role taxonomy (Orchestrator, Interaction, Worker, Protocol).

## Core Principle

Main context is the conductor. Background agents are the orchestra.

The main conversation handles human interaction (approvals, grill-me, confirmations), dispatch (spawning Workers, calling sub-Orchestrators), response analysis (merging findings from Workers), and summary. All actual work — research, file scanning, code analysis, verification, knowledge extraction — runs in background Workers. Nothing that can be delegated should run inline in the main context.

## Role Taxonomy

Four roles define the dispatch contract and execution context:

|Role|Runs in|User interaction|Dispatches|
|-|-|-|-|
|**Orchestrator**|Main context|Yes|Optionally: other Orchestrators and/or Workers|
|**Interaction**|Main context|Yes — only|Never|
|**Worker**|Background/isolated|Task confirmations only|Optionally: other Workers|
|**Protocol**|Caller's context|N/A|Never|

Worker sub-types — same role, different packaging:

|Sub-type|Format|Invocation|User-invocable|
|-|-|-|-|
|Worker Skill|SKILL.md|`Skill("name")`|Can be|
|Worker Agent|`agents/*.md` file|`Agent("path.md")`|Never|

Key distinctions:

- **Orchestrators CAN have sub-Orchestrators**: Architecture calls grill-me; define calls architecture.
- **Interaction skills are simple Orchestrators**: They interact with user but never dispatch. `grill-me` and `specify` are the examples.
- **Workers run isolated from conversation history**: They may still exchange messages with the user for task-level confirmations (NOT for deliberation requiring conversation context).
- **Protocols are adopted, not spawned**: They modify the calling agent's behavior.

## Dispatch Primitives

### `Skill("name")` — in-context invocation

Runs in caller's session. Use for Orchestrators and Interactions. The skill shares conversation history with the caller.

### `Agent("path.md")` — Worker Agent dispatch

Use for parallel fan-out and bulk I/O workers. Worker Agents live in `agents/*.md` at the repo root, one per role. They always run isolated (autonomous, no user interaction). Standard frontmatter: `permission: { task: {"*": "deny"}, question: "deny" }` (prevents recursive spawning and interactive prompts).

When to use Worker Agent vs Worker Skill:

- Worker Skill: task is user-invocable OR meaningful enough to stand as its own skill directory. Worker Skills are autonomous and run in isolation — the SKILL.md body becomes the task prompt.
- Worker Agent: internal implementation detail of a parent skill, never invoked directly by users.

### `isolation: worktree`

Parameter on `Agent()` calls. Gives the spawned agent its own git worktree to prevent filesystem race conditions. Use when spawning 2+ parallel agents and disjoint file scope cannot be guaranteed after `/scope-assessment`. Skip when scope is cleanly disjoint.
