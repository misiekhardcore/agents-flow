# Issue-Autopilot: Stage 5 — Post-Merge

## Stage 5 — Post-merge

**Entry condition**: PR for `feat/issue-<N>` is merged.

1. Echo resolved repo `owner/repo`.
2. Checkpoint NOTES.md. Read `@_shared/compound-on-exit.md`. Invoke the "compound" skill exactly once on clean completion to capture final learnings.
3. Dispatch `workflow-wrap-up-runner` via the task tool from the worktree root:
   ```
   repo: <owner/repo>
   branch: feat/issue-<N>
   worktree_path: <absolute path to worktree>
   ```
4. Print:

   > Ship complete: PR merged, worktree cleaned.

**Exit.**

> **Note**: wrap-up-runner executes cleanup autonomously — no user confirmations needed. Safe to call once PR is merged.
