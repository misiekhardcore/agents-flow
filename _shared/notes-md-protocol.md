`.claude/NOTES.md` is rot-immune external memory for in-phase state. Read on-demand when creating, updating, or harvesting; do not preload.

## Where it sits in the memory hierarchy

Four tiers:

|Tier|Where|Lifetime|Authoritative for|
|-|-|-|-|
|`TodoWrite`|In-context|This session|Throwaway scratchpad|
|`.claude/NOTES.md`|Worktree-local, gitignored|This phase, across sessions|In-flight decisions, current task, open questions|
|GitHub issue|Remote|Cross-phase|Acceptance criteria, prior-phase decisions, handoff state|
|Durable vault|claude-obsidian vault (git-tracked)|Durable, cross-feature|Patterns, bug-fix history, architectural insights|

Do not mirror `TodoWrite` and `.claude/NOTES.md` — they serve different roles. The vault tier materializes when `claude-obsidian` is installed; without it, skills that would write degrade gracefully.

## NOTES.md vs the vault's recency channels

|Artifact|Scope|Lifetime|Committed?|
|-|-|-|-|
|`.claude/NOTES.md`|One worktree, one feature|Ends when worktree removed|No (gitignored)|
|Vault hot cache|Whole repo, all work|Cross-session, curated|Yes|
|Session archive|One session|Permanent|Yes|
|Vault log|Whole repo|Permanent, append-only|Yes|

- **While working** — log to `.claude/NOTES.md` (phase-local scratch).
- **Between sessions on same feature** — resume from `.claude/NOTES.md` (authoritative in-flight state).
- **Between features** — promote durable learnings to vault via `/compound`. That crosses the worktree boundary.
- **For recent context across repo** — use vault's hot cache (curated, committed), not NOTES.md (raw, ephemeral).

`/implement` is the harvest point: at PR creation it reads NOTES.md, flows the decisions and open questions into the PR body, then deletes NOTES.md after `/compound` has run.

## Location and lifecycle

- **Path:** `<worktree-root>/.claude/NOTES.md`.
- **Created by `/build`** at phase start, immediately after `wt switch --create`, with initial task list from issue.
- **Updated by `/build`** after each completed task, significant decision, and before `/compact`.
- **Read on resume by `/build`** — before re-reading the issue.
- **Harvested by `/implement`** at PR-creation time. `## Decisions made this session` and `## Open questions` flow into PR body's `## Notes` section.
- **Deleted by `/implement`** after `/compound` runs. If `/implement` exits abnormally, NOTES.md persists; `/wrap-up` cleans it up with worktree removal.
- **Left in place** by standalone `/build`, `/review`, `/verify` — cleanup happens when worktree is removed.
- **Not committed to git.** Ensure `/.claude/NOTES.md` is gitignored; add entry if missing.

## Required sections

`.claude/NOTES.md` is a bullet list, not prose. Keep the whole file readable in one screen — it should cost <1k tokens to re-read.

```markdown
# NOTES — feat/<feature-slug>

## Current task
- <the one thing you are working on right now>

## Task list
- [x] <done task>
- [ ] <pending or in-progress task — first unchecked item is the current one>
- [!] <blocked task — with reason>

## Decisions made this session
- <one-line decision> (why: <rationale>)
- ...

## Open questions
- <question that needs the user or next phase to resolve>

## Next action on resume
- <exact command or file to open if the session dies>
```

## Update cadence

Update at these points (bullet-level only):

- **After each completed task** — flip checkbox, log any decision.
- **After each significant decision** — one line with rationale.
- **Before any `/compact`** — write Keep list first, so post-compaction summary can be diffed against external record.
- **Before ending session normally** — `/implement` harvests at PR-creation time.

Don't update for trivial moves (opening file, running test). Checkpoint log, not transcript.

## Resume protocol

When `.claude/NOTES.md` exists in worktree, it's a resume:

1. Read `./.claude/NOTES.md` first.
2. Read the GitHub issue second (cross-phase decisions and acceptance criteria).
3. Resume from **Next action on resume**, or from first unchecked item in Task list if stale.
4. Update **Current task** and **Next action on resume** before first real action.

## Rules

- **NOTES.md is authoritative for in-flight state.** Trust the file; in-context recall is rot-degraded.
- **Issue is authoritative for cross-phase state.** Acceptance criteria, locked decisions, prior-phase handoff live in issue, not file.
- **Deletion is `/implement`'s responsibility.** It deletes after `/compound` runs. Standalone `/build` leaves in place.
