# Epic-Autopilot: Stage Gates and Resume Logic

## Stage 0 — Resume detection

On every invocation, read the epic issue body and any sub-issue bodies first; consult the **Resume logic** table at the bottom to decide which stage to enter.

## Stage 1 — Discovery gate

If input is a positive integer and the epic issue has a well-formed `## Requirements` section (≥3 acceptance criteria), skip /discovery and go to Stage 2.

Otherwise:
1. Run `/discovery` on the epic (or free-text description). This is interactive.
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

## Stage 5 — Exit

Print exit summary to stdout and exit. The run is complete when all sub-PRs have been opened and the epic PR is open. Merging is left to humans.

## Resume logic

On re-invocation with the same epic issue number, epic-autopilot detects prior state and skips completed phases:

|State detected|Action|
|-|-|
|No `## Requirements` in epic body|Re-run from Stage 1|
|`## Requirements` but no `## Implementation plan`|Re-run from Stage 2|
|`## Implementation plan` present|Skip Stages 1–2; check sub-issues|
|Sub-issue has `## Implementation plan`|Skip per-sub-issue /define for that sub-issue|
|Sub-issue has open PR on its branch|Sub-task settled; skip|
|Sub-issue has branch but no PR|Re-run `/implement` in existing worktree|
|Sub-issue has neither branch nor PR|Fresh sub-task spawn|

A permanently-FAILED sub-task (branch exists, no PR, two prior retries) will be re-attempted on every resume. To skip it permanently, delete the branch and mark the sub-issue with a `skip` label before re-invoking.
