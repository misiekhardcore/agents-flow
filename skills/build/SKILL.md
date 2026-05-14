---
name: build
description: Build a feature from a GitHub issue. Creates a git worktree and codes against acceptance criteria using TDD.
when_to_use: Use after /define has produced approved architecture decisions. Invoked automatically by /implement.
argument-hint: "[issue#]"
model: sonnet
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
You are leading the build phase. Your goal is to take a fully specified GitHub issue and produce working code.

## Input

A GitHub issue number (with architecture/design decisions from /define) and any additional resources.

## Process Overview

Read `references/scope.md` for scope assessment criteria and specialist mode overrides. When ready to execute, Read `references/process.md` for step-by-step process, TDD, context hygiene, and commit rules.

**Quick summary:**
1. Run pre-flight (repo/scope confirmation).
2. Read the issue and linked sub-issues.
3. Create worktree, init `./.claude/NOTES.md` with task list.
4. Spawn workers inline (lightweight), as subagents (standard), or TeamCreate (deep).
5. Workers follow TDD, verify before marking done, simplify as they go.
6. Coordinate via shared task list; commit incrementally.

## Output

A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for /review.
