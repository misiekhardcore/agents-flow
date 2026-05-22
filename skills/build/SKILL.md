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

## Specialist Assessment

Invoke `Skill("build-specialist-assessment")` at entry (before spawning workers). It reads plan/AC from context and emits a `specialists:` list.

## Process Overview

Read `references/process.md` for step-by-step process, TDD, context hygiene, and commit rules.

1. Run pre-flight (repo/scope confirmation).
2. Read the issue and linked sub-issues.
3. Create worktree, init `./.claude/NOTES.md` with task list.
4. Invoke `Skill("scope-assessment")` with work units derived from sub-issues and file groups → receive agent plan → spawn one agent per entry.

## Output

A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for /review.

## Rules

- **Always create a worktree** with `wt switch --create <branch>` before writing any code. Never code in the main repo directory.
