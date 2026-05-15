# Epic-Autopilot: Stage 0 — Resume Detection

## Stage 0 — Resume detection

On every invocation, read the epic issue body and any sub-issue bodies first; consult the **Resume logic** table below to decide which stage to enter.

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
