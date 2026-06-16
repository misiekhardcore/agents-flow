---
name: verify
description: QA verification of implementation against AC. Reports pass/fail per criterion.
argument-hint: "[issue#]"
when_to_use: Use after /build to verify all acceptance criteria are met. Invoked by /implement; can run standalone.
model: haiku
effort: low
user-invocable: true
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
context: fork
agent: general-purpose
compatibility: claude-code opencode
---
Lead verification phase. Goal: Verify every AC from the issue is met with evidence. Report pass/fail per criterion.

## I/O
- **Input**: Branch + GitHub issue number.
- **Verification Package**: Diff, AC, test commands (type-check, lint, unit, build, e2e).
- **Output**: QA report (pass/fail per AC with evidence) returned to caller.

## Process
1. Acquire verification package: `git diff` for diff, `gh issue view` for AC.
2. Spawn `Agent("agents/workflow-verify-runner.md")` with `acceptance_criteria` and `diff`. Runner groups AC, spawns qa-agents in parallel, and returns the unified report.

## Rules
- **Separation**: Never fix issues during verification. Report failures in the verify output; fixes are a `/build` responsibility.
- **Evidence-Based**: No "it works" — every criterion needs evidence.
- **Feedback Loop**: Any failure → report goes back to `/build` for fixes.
- **Isolation**: Pass only acceptance_criteria and diff to the runner — not the full build session history.
