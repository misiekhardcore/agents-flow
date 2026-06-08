# NOTES.md — In-Phase Memory Layer

`.claude/NOTES.md` is rot-immune external memory for in-phase state. Read on-demand when creating, updating, or harvesting; do not preload.

## Where it sits in the memory hierarchy

Four layers:

|Layer|Where|Lifetime|Authoritative for|
|-|-|-|-|
|`TodoWrite`|In-context|This session|Throwaway scratchpad|
|`.claude/NOTES.md`|Worktree-local, gitignored|This phase, across sessions|In-flight decisions, task progress, current task, open questions|
|GitHub issue|Remote|Cross-phase|Acceptance criteria, prior-phase decisions, handoff state|
|Durable vault|claude-obsidian vault (git-tracked)|Durable, cross-feature|Patterns, bug-fix history, architectural insights|

Do not mirror `TodoWrite` and `.claude/NOTES.md` — they serve different roles. The vault layer materializes when `claude-obsidian` is installed; without it, skills that would write degrade gracefully.

## NOTES.md vs the vault's recency channels

|Artifact|Scope|Lifetime|Committed?|
|-|-|-|-|
|`.claude/NOTES.md`|One worktree, one feature|Ends when worktree removed|No (gitignored)|
|Vault hot cache|Whole repo, all work|Cross-session, curated|Yes|
|Session archive|One session|Permanent|Yes|
|Vault log|Whole repo|Permanent, append-only|Yes|

- **While working** — log to `.claude/NOTES.md` (phase-local scratch).
- **Between sessions on same feature** — resume from `.claude/NOTES.md` (authoritative in-flight state).
- **Between features** — promote durable learnings to vault. That crosses the worktree boundary.
- **For recent context across repo** — use vault's hot cache (curated, committed), not NOTES.md (raw, ephemeral).

The phase-ending skill is the harvest point: at PR creation it reads NOTES.md, flows the decisions and open questions into the PR body, then deletes NOTES.md after promoting durable learnings to vault. See that skill's own file for details.

## Location and lifecycle

- **Path:** `<worktree-root>/.claude/NOTES.md`.
- **Created by the agent that starts the phase** — either an orchestrator (L1) or a standalone skill (L2).
- **Ownership transfers with execution.** The running agent always owns NOTES.md. An orchestrator owns it before spawn and after return; the spawned sub-skill owns it during execution. Since execution is sequential (spawn → wait → return), there is no concurrent write conflict.
- **Updated by the currently running agent** after each completed task, significant decision, or before spawning a further sub-agent (checkpoint). This applies equally to orchestrators and spawned sub-skills.
- **Read on resume** — before re-reading the issue, reconstruct state from NOTES.md.
- **Harvested at phase end** — `## Decisions made this session` and `## Open questions` flow into PR body's `## Notes` section.
- **Deleted after harvest** by the phase-ending skill. If that skill exits abnormally, NOTES.md persists; cleanup happens with worktree removal.
- **Left in place** by standalone skills — cleanup happens when worktree is removed.
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
- **Before any compaction** — write Keep list first, so post-compaction summary can be diffed against external record.
- **Before ending session normally** — the phase-ending skill harvests at PR-creation time.

Don't update for trivial moves (opening file, running test). Checkpoint log, not transcript.

## Resume protocol

When `.claude/NOTES.md` exists in worktree, it's a resume:

1. Read `./.claude/NOTES.md` first.
2. Read the GitHub issue second (cross-phase decisions and acceptance criteria).
3. Resume from **Next action on resume**, or from first unchecked item in Task list if stale.
4. Update **Current task** and **Next action on resume** before first real action.

## Standalone skill pattern

A standalone L2 skill (invoked directly by the user, not by an orchestrator) uses NOTES.md as a lightweight progress tracker:

1. **Create** — On entry, create NOTES.md with `## Task list`, `## Decisions made this session`, and `## Next action on resume`.
2. **Update** — Flip checkboxes as tasks complete, log decisions, update `## Current task` and `## Next action on resume` at each natural breakpoint.
3. **Leave** — On exit, leave NOTES.md in place. Do not delete.

No checkpoint-before-spawn is needed — standalone skills do not spawn sub-agents. The pattern is create → update → leave.

## Rules

- **NOTES.md is authoritative for in-flight state.** Trust the file; in-context recall is rot-degraded.
- **Issue is authoritative for cross-phase state.** Acceptance criteria, locked decisions, prior-phase handoff live in issue, not file.
- **Ownership transfers with the running agent.** The agent currently executing owns NOTES.md — whether that's the orchestrator or a spawned sub-skill. On return, ownership passes back to the caller.
- **Orchestrator checkpoints before every spawn** so NOTES.md contains enough state to reconstruct if the session dies mid-spawn (sub-skill never started or partially executed).
- **Sub-skills use NOTES.md for their own multi-step tracking** while they run (same sections, same conventions). This is safe because execution is sequential — no concurrent writers.
- **Deletion is the phase-ending skill's responsibility.** Standalone skills leave NOTES.md in place.
