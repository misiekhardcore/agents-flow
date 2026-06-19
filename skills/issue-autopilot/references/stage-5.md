# Issue-Autopilot: Stage 5 — Post-Merge

## Stage 5 — Post-merge

**Entry condition**: PR for `feat/issue-<N>` is merged.

1. Echo resolved repo `owner/repo`.
2. Checkpoint NOTES.md. Invoke the "compound" skill exactly once on clean completion (per the "orchestrator-rules" skill § Compound on exit) to capture final learnings.
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
