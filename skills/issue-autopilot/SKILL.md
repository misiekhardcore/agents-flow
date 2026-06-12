---
name: issue-autopilot
description: Single-issue equivalent of /epic-autopilot. Chains /define → /implement → /resolve-pr-feedback → /compound → /wrap-up for one issue.
when_to_use: Use when you have a single GitHub issue and want the full lifecycle automated end-to-end with natural pause points for human review and merge.
argument-hint: <issue#>
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

### 0 — Detection

Invoke `Skill("preflight")`. Echo resolved `owner/repo`. Read `references/detection.md` at point of need to determine entry stage from issue/PR/branch state.

### 1 — Define

If issue lacks `## Implementation plan`: read `references/stage-1.md` at point of need. Invoke `Skill("define")` with seed-brief handoff (`issue: <N>`). Print pause message. **Exit.** User re-invokes after reviewing the plan.

### 2 — Implement

If plan present, branch absent, no open PR: read `references/stage-2.md` at point of need. Invoke `Skill("implement")` with seed-brief handoff (`repo`, `branch`, `issue`, `max_cycles: 3`). Print pause message. **Exit.** User re-invokes after review.

### 3 — Resolve PR feedback

If open PR with unresolved threads: read `references/stage-3.md` at point of need. Invoke `Skill("resolve-pr-feedback")` with seed-brief handoff. Apply loop-break heuristic per stage-3.md. On zero unresolved → proceed to Stage 4 in same invocation.

### 4 — Awaiting merge

If clean PR awaiting merge: read `references/stage-4.md` at point of need. Print PR status and prompt user to merge. **Exit.** Merging is human-only.

### 5 — Post-merge (compound-on-exit)

If PR merged: read `references/stage-5.md` at point of need. Invoke `Skill("compound")` (compound-on-exit pattern). Invoke `Skill("wrap-up")` with seed-brief handoff (`repo`, `branch`, `worktree_path`). Print ship-complete summary. **Exit.**

## Worker Agent Inventory

### implement
- **Invocation**: `Skill("implement")`
- **Seed-brief handoff**: `repo`, `branch`, `issue`, `max_cycles`
- **Output**: PR URL, findings

### wrap-up
- **Invocation**: `Skill("wrap-up")`
- **Seed-brief handoff**: `repo`, `branch`, `worktree_path`
- **Output**: Removal summary

## Rules
- Invoke `Skill("orchestrator-rules")` for CWD, delegation, no-autonomous-merge, seed-brief, and NOTES.md tracking.
- All `Agent()` spawns include a comprehensive `<seed-brief>` block with `repo`, `branch`, `issue`, and `payload`.
- `Skill()` calls to phase orchestrators include seed-brief handoff in spawn context.
- Reference reads are point-of-need — per-stage, not preloaded.
- Compound-on-exit: `Skill("compound")` on clean completion only. No invocation on abort or early exit.
- **Loop-break**: In Stage 3, break if unresolved thread count non-zero and unchanged after one pass.
- **Compound**: `/implement` invokes `/compound` at PR creation (implementation-time pass). Stage 3 re-invokes when all threads resolve for review-time learnings — two passes, no dedup needed.
- No autonomous merge. Merging is always human.
