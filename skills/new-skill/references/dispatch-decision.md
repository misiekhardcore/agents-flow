# Dispatch Decision Reference

Condensed tables for dispatch decisions at authoring time and runtime. Full framework: `docs/dispatch-primitives.md`.

## Role taxonomy

|Role|Runs in|User interaction|Dispatches|
|-|-|-|-|
|**Orchestrator**|Main context|Yes|In-context skills + leaf Workers — single background tier, no background sub-orchestrators|
|**Interaction**|Main context|Yes — only|Never|
|**Worker**|Background/isolated|Task confirmations only|Never — leaf; carries `permission.task: {"*":"deny"}`|
|**Protocol**|Caller's context|N/A|Never|

## Worker Agent vs Worker Skill

|Use|When|
|-|-|
|Worker Skill|Task is user-invocable OR meaningful as its own skill directory. Runs autonomously — the SKILL.md body becomes the task prompt.|
|Worker Agent (`agents/*.md`)|Internal implementation detail, never user-invocable|

## `isolation: worktree`

Add to task-tool dispatches when spawning 2+ parallel agents with overlapping file scope. Skip when `/scope-assessment` guarantees disjoint scope.
