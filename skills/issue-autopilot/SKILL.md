---
name: issue-autopilot
description: Single-issue equivalent of /epic-autopilot. Chains /define → /implement → /resolve-pr-feedback → /compound → /wrap-up for one issue.
---
Orchestrate the single-issue ship pipeline. Take a GitHub issue number and drive it to a merged PR with clean local state — pausing only where human action is required (review, merge).

Invoke the "orchestrator-rules" skill for CWD verification, delegation, NOTES.md lifecycle, no-autonomous-merge, and seed-brief contract.

## Process

### 1. Detection

Invoke the "preflight" skill. Echo resolved `owner/repo`. Read `references/detection.md` at point of need to determine entry stage from issue/PR/branch state. Create `.claude/NOTES.md` with task list and next-action per the "orchestrator-rules" skill.

### 2. Define (Stage 1)

If issue lacks `## Implementation plan`: read `references/stage-1.md` at point of need. Invoke the "define" skill with seed-brief handoff (`issue: <N>`). Print pause message. **Exit.** User re-invokes after reviewing the plan.

### 3. Implement (Stage 2)

If plan present, branch absent, no open PR: read `references/stage-2.md` at point of need. Checkpoint NOTES.md. Dispatch `workflow-implement-runner` via the task tool with `<seed-brief>` YAML block per AGENTS.md § Key Conventions — Seed-brief:
```
repo: <owner/repo>
branch: feat/issue-<N>
issue: <N>
max_cycles: 3
```
Print pause message. **Exit.** User re-invokes after review.

### 4. Resolve PR feedback (Stage 3)

If open PR with unresolved threads: read `references/stage-3.md` at point of need. Invoke the "resolve-pr-feedback" skill with seed-brief handoff. Apply loop-break heuristic per stage-3.md. On zero unresolved → invoke the "compound" skill (review-time pass) and proceed to Stage 4 in same invocation.

### 5. Awaiting merge (Stage 4)

If clean PR awaiting merge: read `references/stage-4.md` at point of need. Print PR status and prompt user to merge. **Exit.** Merging is human-only.

### 6. Post-merge cleanup (Stage 5)

If PR merged: read `references/stage-5.md` at point of need. Checkpoint NOTES.md. Invoke the "compound" skill exactly once on clean completion (per the "orchestrator-rules" skill § Compound on exit). Dispatch `workflow-wrap-up-runner` via the task tool with `<seed-brief>` YAML block per AGENTS.md § Key Conventions — Seed-brief:
```
repo: <owner/repo>
branch: feat/issue-<N>
worktree_path: <absolute path to worktree>
```
Print ship-complete summary. **Exit.**

## Rules

- **Loop-break**: Stage 3 — break if unresolved thread count non-zero and unchanged after one pass.
- **Compound-on-exit**: Invoke the "compound" skill on clean completion only (Stage 3, Stage 5). No invocation on abort or early exit.
- **No autonomous merge**: Merging is always human.
- **Point-of-need reads**: Read `references/stage-<N>.md` before step N only. See AGENTS.md § Key Conventions — Seed-brief before first spawn.
- **NOTES.md**: Checkpoint before every spawn per the "orchestrator-rules" skill § Progress tracking.
