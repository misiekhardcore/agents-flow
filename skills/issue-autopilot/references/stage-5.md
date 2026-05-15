# Issue-Autopilot: Stage 5 — Post-Merge

## Stage 5 — Post-merge

**Entry condition**: PR for `feat/issue-<N>` is merged.

1. Echo resolved repo `owner/repo`.
2. Run `/wrap-up` from the worktree root — preserves its interactive confirms (worktree removal is destructive).
3. Print:

   > Ship complete: PR merged, worktree cleaned.

**Exit.**
