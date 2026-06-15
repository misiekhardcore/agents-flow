# Epic-Autopilot: Stage Gates (Stages 1–3)

## Stage 1 — Discovery gate

If input is a positive integer and the epic issue has a well-formed `## Requirements` section (≥3 acceptance criteria), skip /discover and go to Stage 2.

Otherwise:
1. Run `/discover` on the epic (or free-text description). This is interactive.
2. **Pause for explicit user approval.** Present: "Discovery complete. Review the issue body above. Approve to continue to /define, or provide feedback."
3. Wait for explicit approval before proceeding.

## Stage 2 — Epic-level /define gate

1. Run `/define` on the epic issue. This is interactive — /define will produce architecture decisions, create sub-issues with linked-issue relationships, and update the issue body.
2. **Pause for explicit user approval.** Present: "Epic /define complete. Review the sub-issues and implementation plan above. Approve to continue to per-sub-issue /define, or provide feedback."
3. Wait for explicit approval.

After approval, read the epic issue body and extract the list of sub-issues. If `/define` produced **≤1 sub-issue**:
- Print: `Decomposition produced ≤1 sub-issue — running /implement directly on #<N>`
- Invoke `/implement` on the epic in the lead session (interactive, no `autonomous: true`).
- Exit.

## Stage 3 — Per-sub-issue /define gate

For each sub-issue in order (ascending issue number):

1. Check if this sub-issue already has `## Implementation plan` in its body. If yes, skip (already defined in prior run).
2. Spawn a fresh subagent to run `/define` on this sub-issue. Must finish before the next sub-issue's gate — these are sequential.
3. After the subagent returns, **pause for explicit user approval.** Present: "Sub-issue #<M> /define complete. Review the implementation plan above. Approve to continue to the next sub-issue, or provide feedback."
4. Wait for explicit approval before moving to next sub-issue.

Once every sub-issue has an approved `## Implementation plan`, proceed to **Stage 4 — Autonomous phase**. No further human prompts until exit.
