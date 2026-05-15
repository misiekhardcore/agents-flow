---
name: issue-autopilot
description: Single-issue equivalent of /epic-autopilot. Chains /define → /implement → /resolve-pr-feedback → /compound → /wrap-up for one issue.
when_to_use: Use when you have a single GitHub issue and want the full lifecycle automated end-to-end with natural pause points for human review and merge.
argument-hint: "<issue#>"
model: opus
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---

Orchestrate the single-issue ship pipeline. Take a GitHub issue number and drive it to a merged PR with clean local state — pausing only where human action is required (review, merge).

## Overview

**Input**: A single positive integer — the GitHub issue number to ship.

**Output**: 
- Stage 0: Confirm repo and detect current state.
- Stages 1–5: Read `references/stage-<stage>.md` for the active stage logic, pausing at human decision points (after define, after impl, after review, before merge, complete).

**State machine**: Resume state machine in `references/detection.md` determines which stage to enter on each invocation based on issue/PR/branch state.

## Process Flow

1. Read `references/detection.md` (Stage 0) to run preflight, confirm repo, detect current state, and determine which stage to enter.
2. Read `references/stage-<stage>.md` for the active stage's logic, where `<stage>` is the determined stage number.
3. Execute stage logic; print stage-exit message and exit (or proceed to next stage if heuristic allows).

## Rules

See `${CLAUDE_PLUGIN_ROOT}/_shared/orchestrator-rules.md` for CWD verification, delegation, no-autonomous-merge, and seed-brief contract.

- **Loop-break**: In Stage 3, break if unresolved thread count non-zero and unchanged after one pass.
- **Compound**: `/implement` invokes `/compound` at PR creation (implementation-time pass). Stage 3 re-invokes when all threads resolve for review-time learnings — two passes, no dedup needed.
