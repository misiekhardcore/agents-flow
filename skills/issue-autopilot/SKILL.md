---
name: issue-autopilot
description: Single-issue equivalent of /epic-autopilot. Chains /define → /implement → /resolve-pr-feedback → /compound → /wrap-up for one issue.
when_to_use: Use when you have a single GitHub issue and want the full lifecycle automated end-to-end with natural pause points for human review and merge.
argument-hint: "<issue#>"
model: opus
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---

You are orchestrating the single-issue ship pipeline. Your goal: take a GitHub issue number and drive it to a merged PR with clean local state — pausing only where human action is required (review, merge).

## Input

A single positive integer — the GitHub issue number to ship.

## Process

### Stage 0 — Resume detection

On every invocation:

1. Run [Ref: repo-preflight]. Echo resolved `owner/repo` back to the user. Pause for confirmation.
2. Detect current state using the commands in **State detection** below.
3. Consult the **Resume state machine** to determine which stage to enter.

### Stage 1 — Define gate

**Entry condition**: Issue lacks `## Implementation plan` in its body.

1. Run `/define <N>` (interactive). `/define` produces architecture and design decisions and writes `## Implementation plan` into the issue body.
2. `/define` pauses for its own user-approval gate — do not add a second gate.
3. After `/define` exits, print:

   > Definition complete. Re-invoke `/issue-autopilot <N>` to continue to implementation.

4. **Exit.** User re-invokes after reviewing the plan.

### Stage 2 — Implement

**Entry condition**: Issue has `## Implementation plan`, branch `feat/issue-<N>` does not exist, no open PR.

1. Pull latest `main` and create worktree for branch `feat/issue-<N>` on base `main`. See [Ref: worktree-protocol].

2. Determine `scope_class` from the plan body (look for size/scope hints; default to `Standard`).

3. Run `/implement <N>` from within the worktree. See [Ref: specialist-mode — Autonomous Implement Invocation] with overrides:
   - `scope_class`: determined above
   - `branch`: `feat/issue-<N>`
   - `active_issue`: `<N>`
   - `payload.prior_art`: `"Issue #<N> ## Implementation plan (architecture and design decisions from /define)"`
   - `payload.open_questions`: open questions from the plan, or empty

4. `/implement` runs the full build → review → verify cycle and opens a draft PR (`autonomous: true` suppresses its exit prompt).

5. After `/implement` exits, print:

   > Draft PR opened. Invite human review, then re-invoke `/issue-autopilot <N>`.

6. **Exit.**

### Stage 3 — Resolve PR feedback loop

**Entry condition**: Branch `feat/issue-<N>` exists, open PR on that branch, PR not merged, unresolved review threads > 0.

1. Record initial unresolved thread count:

   ```bash
   gh pr view <PR#> --json reviewThreads --jq '[.reviewThreads[] | select(.isResolved == false)] | length'
   ```

2. Echo resolved repo `owner/repo` before the cross-repo mutation.

3. Run `/resolve-pr-feedback` (no thread URL — processes all unresolved threads on this PR).

4. After `/resolve-pr-feedback` exits, record final unresolved count via the same command.

5. Apply **loop-break heuristic**:

   | Result | Action |
   |-|-|
   | Final count == 0 | Proceed immediately to Stage 4 in this invocation |
   | Final count > 0 and decreased | Print "Partial progress: `<before>` → `<after>` unresolved threads. Re-invoke `/issue-autopilot <N>` after the next review pass." Exit. |
   | Final count > 0 and unchanged (or `/resolve-pr-feedback` returned `needs-human` verdicts) | Print needs-human summary listing remaining threads. Exit with: "Needs human review — see threads above. Re-invoke `/issue-autopilot <N>` after addressing them." |

### Stage 4 — Zero unresolved, awaiting merge

**Entry condition** (reached from Stage 3 or on re-invocation): Branch exists, open PR, PR not merged, zero unresolved review threads.

Print:

> PR #`<PR#>` is clean — zero unresolved review threads.
> Merge the PR on GitHub, then re-invoke `/issue-autopilot <N>` to capture learnings and clean up.

**Exit.** Merging is a human action; the skill never triggers a merge.

### Stage 5 — Post-merge

**Entry condition**: PR for `feat/issue-<N>` is merged.

1. Echo resolved repo `owner/repo`.
2. Run `/compound` — review-time learnings pass (autonomous; pass NOTES.md context if present).
3. Run `/wrap-up` from the worktree root — preserves its interactive confirms (worktree removal is destructive).
4. Print:

   > Ship complete: PR merged, learnings filed, worktree cleaned.

**Exit.**

## Resume state machine

| State on entry | Stage |
|-|-|
| Issue closed, no open PR | Refuse: print state, exit |
| Issue lacks `## Implementation plan` | Stage 1 — Define gate |
| Plan present, branch `feat/issue-<N>` absent, no open PR | Stage 2 — Implement |
| Branch and open PR exist, PR not merged, unresolved threads > 0 | Stage 3 — Resolve PR feedback loop |
| Branch and open PR exist, PR not merged, unresolved threads == 0 | Stage 4 — Zero unresolved, awaiting merge |
| PR merged | Stage 5 — Post-merge |

## State detection

```bash
# Issue state and body
gh issue view <N> --json state,body

# Open PR on branch
gh pr list --head feat/issue-<N> --json number,url,state,reviewThreads

# Unresolved thread count (once PR# is known)
gh pr view <PR#> --json reviewThreads \
  --jq '[.reviewThreads[] | select(.isResolved == false)] | length'
```

## Rules

See [Ref: orchestrator-rules] for CWD verification, delegation, no-autonomous-merge, and seed-brief contract.

- **Loop-break**: In Stage 3, if the unresolved thread count is non-zero and unchanged after one pass, break immediately with a needs-human summary.
- **Compound placement**: `/implement` already invokes `/compound` at PR creation (implementation-time pass). `/issue-autopilot` re-invokes `/compound` in Stage 5 after merge to capture review-time learnings — two passes, no deduplication needed.
