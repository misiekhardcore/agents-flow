---
name: build
description: Build a feature from a GitHub issue. Creates a git worktree and codes against acceptance criteria using TDD.
when_to_use: Use to implement approved architecture decisions/implementation plans.
argument-hint: "[issue#]"
effort: high
user-invocable: true
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Lead build phase. Goal: Take a fully specified GitHub issue and produce working code. Builds a feature using TDD. Produces implementation code in a worktree. Hands off via the worktree for review.

## I/O
- **Input**: A GitHub issue number (with architecture/design decisions) and any additional resources.
- **Output**: A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for review.

## Scope Assessment

Divide the issue into work units (sub-issues or file groups) which can be worked on in parallel by multiple build workers. Consider complexity, collision avoidance, dependencies, and risk when defining work units.

See `@_shared/composition.md` for spawn cost models.

## Process
Read `references/process.md` for step-by-step process, TDD, context hygiene, and commit rules.

1. Run pre-flight (repo/scope confirmation).
2. Read the issue and linked sub-issues.
3. Create worktree, init `./.claude/NOTES.md` with task list.
4. Invoke the "scope-assessment" skill with work units derived from sub-issues and file groups → receive agent plan: spawn `workflow-build-worker` via the task tool in parallel — one per work unit.
5. Consider invoking the "compaction-protocol" skill for context management during long build sessions.

<output>
<format>
```
Branch: <branch>
Worktree: <path>
Status: All AC implemented, tests passing
```
</format>
</output>

<rules>
<critical>MUST create a worktree with `wt switch --create <branch>` before writing any code. MUST NEVER code in the main repo directory.</critical>
<constraint>MUST write tests before implementation code (TDD).</constraint>
<constraint>MUST keep NOTES.md updated with progress; MUST use compaction when context limits are reached.</constraint>
</rules>
