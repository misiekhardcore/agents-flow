---
name: review
description: Review implementation against requirements or PR. Posts inline GitHub review comments.
argument-hint: "[PR# or URL]"
when_to_use: Use after /build to review implementation quality. Invoked by /implement; can run standalone against a PR.
model: sonnet
effort: high
user-invocable: true
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead review phase. Goal: Thoroughly review implementation against requirements and produce actionable findings. Produce inline GitHub review comments.

## I/O
- **Input**: Branch (standalone + issue#) or PR argument (PR# or URL).
- **Review Package**: Diff (`git diff` or `gh pr diff`), AC (issue / linked).
- **Output**: Fix brief returned to caller (for implement cycles), Findings report (user), or Posted GitHub review (PR).

Read `references/dispatch-process.md` for dispatch modes, process steps, and PR posting logic.

## Process
1. Acquire review package per dispatch mode (see `references/dispatch-process.md`).
2. Spawn `Agent("review/agents/review-runner.md")` with `diff`, `acceptance_criteria`, and `dispatch_mode`. Runner evaluates gates and spawns reviewer agents internally.
3. Collect findings from runner.
4. Emit output per dispatch mode (fix brief, findings report, or posted GitHub review).

## Rules
- **Separation**: Never fix issues during review. Report findings in the review output; fixes happen in a subsequent `/build` cycle.
- **Consensus**: All reviewers must agree before finalizing.
- **Blocking**: Critical findings block. High-severity blocks for Security/Perf are non-waivable.
- **Scope**: Flag changes outside issue scope.
