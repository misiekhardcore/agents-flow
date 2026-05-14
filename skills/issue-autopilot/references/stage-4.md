# Issue-Autopilot: Stage 4 — Awaiting Merge

## Stage 4 — Zero unresolved, awaiting merge

**Entry condition** (reached from Stage 3 or on re-invocation): Branch exists, open PR, PR not merged, zero unresolved review threads.

Print:

> PR #`<PR#>` is clean — zero unresolved review threads.
> Merge the PR on GitHub, then re-invoke `/issue-autopilot <N>` to capture learnings and clean up.

**Exit.** Merging is a human action; the skill never triggers a merge.
