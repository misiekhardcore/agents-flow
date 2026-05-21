---
name: wrap-up
description: Clean up local state after a PR is open — remove the worktree, delete the branch, and clear NOTES.md.
when_to_use: Run when ready to discard the feature worktree after a PR is open.
model: sonnet
allowed-tools: Bash Read
---
You safely remove the feature worktree, delete the branch, and clear any remaining NOTES.md — confirming before destructive actions and refusing when the operation would destroy protected state.

## Input

Current worktree path and branch. Optionally, an open PR number (used to verify unpushed-commit safety).

## Process

Read `references/procedure.md` for the step-by-step removal procedure (Steps 1–5).

## Output

```
Removed worktree: <path>
Deleted branch: <branch>
NOTES.md removed with worktree (was present / was already absent)
```

## Rules

- Refuse outright when branch is default branch or worktree path not in `wt list`.
- Use `wt remove --force-delete` only when dirty-worktree override was explicitly confirmed.
- Single confirmation covers all removals — do not ask separately for each artifact.
- Do not write to GitHub issue body. Use `/compound` to capture learnings into the wiki instead.
- Do not read or harvest NOTES.md — `/implement` harvests it at PR-creation time.
