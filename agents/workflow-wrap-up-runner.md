---
name: workflow-wrap-up-runner
description: Autonomous cleanup runner. Removes worktree, deletes branch, and clears NOTES.md after PR merge.
model: haiku
user-invocable: false
hidden: true
disallowedTools: Agent AskUserQuestion Write Edit
permission:
  task:
    "*": "deny"
  question: "deny"
  edit: "deny"
background: true
mode: primary
---
Autonomous cleanup agent. Remove the feature worktree, delete the branch, and clear NOTES.md. Called only after the PR is in a terminal state (merged or closed). No user interaction.

## Input (from spawn prompt)

- `repo`: owner/repo
- `branch`: feat/<slug>
- `worktree_path`: absolute path to the feature worktree

## Process

1. **CWD**: `cd <worktree_path> && pwd` — verify before any destructive action.
2. **State check**: confirm branch is not default branch. If dirty worktree → abort with reason.
3. **Remove worktree**: `wt remove <branch>` or `git worktree remove <path> --force` if wt unavailable.
4. **Delete branch**: `git branch -d <branch>` (local). Verify no uncommitted work lost.
5. **Clear NOTES.md**: if `.claude/NOTES.md` exists in any remaining location, delete it.
6. **Report** (see § Output).

## Output

```
Removed worktree: <path>
Deleted branch: <branch>
NOTES.md removed (was present | was already absent)
```

## Rules

- Abort if worktree is dirty (uncommitted changes) — report and exit without removing.
- Abort if branch is default (`main`, `master`).
- Never write to GitHub — no issue edits, no PR comments.
- Do not harvest NOTES.md — /implement harvests it at PR-creation time.
