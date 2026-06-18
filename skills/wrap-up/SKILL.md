---
name: wrap-up
description: Clean up local state after a PR is open — remove the worktree, delete the branch, and clear NOTES.md.
when_to_use: Run when ready to discard the feature worktree after a PR is open.
model: sonnet
user-invocable: true
allowed-tools: Bash Read
---
Safely remove the feature worktree, delete the branch, and clear any remaining NOTES.md. In standalone mode, confirms before destructive actions and refuses when the operation would destroy protected state. When invoked with `confirmed` as skill arg (e.g., `/wrap-up confirmed`), executes directly without user prompts. Orchestrators spawn `Agent('agents/workflow-wrap-up-runner.md')` for fully autonomous cleanup. Cleans up local state: removes worktree, deletes branch, clears NOTES.md. Expects PR to be in a terminal state. Refuses destructive actions on dirty state in standalone mode.

## Input

- Current worktree path and branch.
- Optional: `confirmed` skill arg — when present, skips user confirmations.
- Optional: PR number (used to verify unpushed-commit safety in standalone mode).

## Process

1. Check for `confirmed` in skill args.
2. Invoke `Skill("worktree")` — adopt worktree lifecycle protocol.
3. Invoke `Skill("notes-md")` — adopt NOTES.md lifecycle protocol.
4. Read `references/procedure.md` for the step-by-step removal procedure.
5. Run step 1 (detect state) in all cases.
6. If `confirmed` arg present: skip to step 5 (execute removal). If worktree is dirty in this mode, **refuse**.
7. Otherwise (standalone mode): run steps 2–4 (state machine + user confirmations), then step 5.
8. Report what was removed.

**Orchestrator mode**: orchestrators should spawn `Agent('agents/workflow-wrap-up-runner.md')` directly instead of calling this skill — the runner is fully autonomous.

## Output

```
Removed worktree: <path>
Deleted branch: <branch>
NOTES.md removed with worktree (was present / was already absent)
```

## Rules

- Refuse outright when branch is default branch or worktree path not in `wt list`.
- Single confirmation covers all removals in standalone mode — do not ask separately for each artifact.
- Do not write to GitHub issue body. Use `/compound` to capture learnings into the wiki instead.
- Do not read or harvest NOTES.md — `/implement` harvests it at PR-creation time.
