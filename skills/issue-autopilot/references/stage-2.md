# Issue-Autopilot: Stage 2 — Implement

## Stage 2 — Implement

**Entry condition**: Issue has `## Implementation plan`, branch `feat/issue-<N>` does not exist, no open PR.

1. Checkpoint NOTES.md. Dispatch `workflow-implement-runner` via the task tool from current directory:
   ```
   repo: <owner/repo>
   branch: feat/issue-<N>
   issue: <N>
   max_cycles: 3
   ```
   Runner creates the worktree, runs the full build → review → verify cycle, and opens a draft PR autonomously.

2. Runner opens a draft PR and returns the PR URL.

3. After implement-runner exits, print:

   > Draft PR opened. Invite human review, then re-invoke `/issue-autopilot <N>`.

4. **Exit.**
