---
name: wrap-up
description: Clean up local state after a PR is open — remove the worktree, delete the branch, and clear NOTES.md.
when_to_use: Run when ready to discard the feature worktree after a PR is open.
model: sonnet
---
<!-- Stays inline: destructive sequential ops — low context cost; must confirm before each step. -->

You are cleaning up local state after a PR has been opened. Your job is to safely remove the feature worktree, delete the branch, and clear any remaining NOTES.md — confirming before destructive actions and refusing outright when the operation would destroy protected state.

## Input

The current worktree path and branch. Optionally, an open PR linked to the active issue (used to verify unpushed-commit safety).

## Process

### Step 1 — Detect state

Gather:

1. **Worktree path** — `git rev-parse --show-toplevel` from current directory, or use path user provides.
2. **Branch name** — `git rev-parse --abbrev-ref HEAD`.
3. **Default branch** — `git symbolic-ref refs/remotes/origin/HEAD --short` (strips `origin/`). Fall back to checking `['main', 'master', 'develop']` only when symbolic-ref lookup fails; log which method was used.
4. **Worktree membership** — `git worktree list --porcelain`. Confirm worktree path appears in this list.
5. **Working-tree cleanliness** — `git status --short` and `git log @{u}..HEAD --oneline` (unpushed commits not in PR).
6. **PR state** — if user provided PR number, run `gh pr view <N> --json state,headRefName` to confirm it is open and points to current branch.

### Step 2 — Apply state machine

|Condition|Outcome|
|-|-|
|Branch matches default branch|**Refuse outright.** No proceed-anyway prompt|
|Worktree path not in `git worktree list --porcelain`|**Refuse outright.** Out-of-tree paths never managed by `/wrap-up`|
|Worktree dirty (uncommitted changes or unpushed commits not in PR)|**Show state + proceed-anyway prompt** (Step 3)|
|Worktree clean, feature branch, worktree in-tree|**Single confirmation** (Step 4)|

### Step 3 — Dirty worktree: proceed-anyway prompt

Show what is dirty (uncommitted files, unpushed commit list). Then ask:

> The worktree has unsaved state (shown above). Proceed with removal anyway?
> On yes, I will use `git branch -D` (force-delete) if unpushed commits would be lost.

Wait for explicit confirmation. Do not proceed on silence.

### Step 4 — Single confirmation (clean or dirty-with-override)

Show the exact actions that will run:

> I will:
> - `git worktree remove <path>` (removes the worktree directory and its contents, including `.claude/NOTES.md` if present)
> - `git branch -d <branch>` (or `-D` if commits would be lost)
>
> Proceed?

Wait for explicit confirmation. Do not proceed on silence.

### Step 5 — Execute and report

On confirm:

1. `git worktree remove <path>` — removes worktree directory. NOTES.md, if still present inside it, is removed implicitly.
2. `git branch -d <branch>` (or `git branch -D <branch>` when dirty-worktree path was confirmed and commits would be lost).
3. Report what was removed: worktree path, branch name, whether NOTES.md was present.

## Output

A one-line summary per removed artifact:

```
Removed worktree: <path>
Deleted branch: <branch>
NOTES.md removed with worktree (was present / was already absent)
```

## Rules

- Refuse outright (no proceed-anyway) when branch is the default branch or worktree path is not in `git worktree list --porcelain`.
- Use `git branch -D` only when dirty-worktree override was explicitly confirmed by user.
- Single confirmation covers all removals — do not ask separately for each artifact.
- Do not write to GitHub issue body. This skill has no handoff artifact.
- Do not read or harvest NOTES.md — `/implement` harvests it at PR-creation time. NOTES.md removal here is incidental.
