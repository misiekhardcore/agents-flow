# Issue-Autopilot: Stage 2 — Implement

## Stage 2 — Implement

**Entry condition**: Issue has `## Implementation plan`, branch `feat/issue-<N>` does not exist, no open PR.

1. Pull latest `main` and create worktree for branch `feat/issue-<N>` on base `main`. See `${CLAUDE_PLUGIN_ROOT}/_shared/worktree-protocol.md`.

2. Determine `scope_class` from the plan body (look for size/scope hints; default to `Standard`).

3. Run `/implement <N>` from within the worktree. See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md` § Autonomous Implement Invocation with overrides:
   - `scope_class`: determined above
   - `branch`: `feat/issue-<N>`
   - `active_issue`: `<N>`
   - `payload.prior_art`: `"Issue #<N> ## Implementation plan (architecture and design decisions from /define)"`
   - `payload.open_questions`: open questions from the plan, or empty

4. `/implement` runs the full build → review → verify cycle and opens a draft PR (`autonomous: true` suppresses its exit prompt).

5. After `/implement` exits, print:

   > Draft PR opened. Invite human review, then re-invoke `/issue-autopilot <N>`.

6. **Exit.**
