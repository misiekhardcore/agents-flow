---
name: build
description: Build a feature from a GitHub issue. Creates a git worktree and codes against acceptance criteria using TDD.
when_to_use: Use to implement approved architecture decisions.
argument-hint: "[issue#]"
model: sonnet
effort: high
layer: 2
user-invocable: true
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
## Role & Constraints
Lead build phase. Goal: Take a fully specified GitHub issue and produce working code. Builds a feature using TDD. Produces implementation code in a worktree. Hands off via the worktree for review.

## I/O
- **Input**: A GitHub issue number (with architecture/design decisions) and any additional resources.
- **Output**: A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for review.

## Specialist Assessment
Invoke `Skill("build-specialist-assessment")` at entry (before spawning workers). It reads plan/AC from context and emits a `specialists:` list.

## Process
Read `references/process.md` for step-by-step process, TDD, context hygiene, and commit rules.

1. Run pre-flight (repo/scope confirmation).
2. Read the issue and linked sub-issues.
3. Create worktree, init `./.claude/NOTES.md` with task list.
4. Invoke `Skill("scope-assessment")` with work units derived from sub-issues and file groups → receive agent plan → spawn one agent per entry.
5. Consider invoking `Skill("compaction-protocol")` for context management during long build sessions.

## Output
```
Branch: <branch>
Worktree: <path>
Status: All AC implemented, tests passing
```

## Rules
- **Always create a worktree** with `wt switch --create <branch>` before writing any code. Never code in the main repo directory.
- **TDD**: Write tests before implementation code.
- **Context Hygiene**: Keep NOTES.md updated with progress; use compaction when context limits are reached.
