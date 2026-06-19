---
name: orchestrator-rules
description: Standard directives for pipeline orchestrators coordinating specialist sub-skills.
user-invocable: false
---
Rules that apply to all pipeline orchestrators.

## CWD verification

Invoke the "preflight" skill at entry. Echo resolved `owner/repo` before every downstream cross-repo `gh` mutation.

## Delegation

Each stage delegates to the designated sub-skill. Do not reimplement logic owned by phase-ending or sub-skills — each has a defined scope; respect it.

## No autonomous merge

Merging is always a human action. Exit cleanly at the awaiting-merge stage; never trigger a merge.

## Seed-brief contract

See `_shared/seed-brief.md` for the YAML packaging convention. Each agent spawn includes all needed context in the prompt — callers define the input contract; receivers do not detect or switch modes.

## Progress tracking via NOTES.md

Orchestrators use NOTES.md as the progress ledger for multi-step pipelines that delegate to sub-agents. The pattern:

1. **Create** — On entry (after preflight), create NOTES.md with the full task list derived from work units.
2. **Checkpoint before sub-agent spawn** — Write `## Current task` (what the sub-agent will do) and `## Next action on resume` (how to reconstruct if session dies) before every skill invocation or agent spawn. This ensures crash-safe resume.
3. **Update after sub-agent returns** — The sub-skill may have written its own progress, decisions, and task updates to NOTES.md while it ran. Read the file, integrate its results, flip checkboxes, and log any new decisions. The orchestrator's view is authoritative for the overall pipeline; the sub-skill's entries are intermediate working state.
4. **Wrap-up** — On clean exit, leave NOTES.md in place for the phase-ending skill to harvest. On abnormal exit, NOTES.md serves as the resume point.

### On entry

After preflight, create NOTES.md with:
- `## Task list` — one checkbox per work unit or pipeline step, in order.
- `## Decisions made this session` — empty initially.
- `## Next action on resume` — the first step to take if session dies.

### Before spawning a sub-agent

1. Write `## Current task` with what the sub-agent will do.
2. Write `## Next action on resume` with the exact command that would reconstruct state.
3. Include a NOTES.md slice in the agent's spawn prompt so it arrives with progress context:

```
repo: owner/repo
branch: feat/my-feature
issue: 123
progress: |
  ## Task list (relevant)
  - [x] Scope assessment → 3 work units
  - [ ] Build work unit 1 (current)
  - [ ] Review

  ## Decisions made this session
  - Split auth into own work unit (why: security isolation)
```

Slice rules:
- Include only the subset of `## Task list` relevant to the spawned agent's scope.
- Include `## Decisions made this session` in full (decisions are global to the phase).
- Omit `## Current task` (the agent will set its own).
- Cap at 15 lines — the spawn prompt is not a state dump.

### After sub-agent returns

1. Flip checkbox(es) for completed work.
2. Log key results and decisions from the findings report.
3. Set `## Next action on resume` to the next step.

### On exit

- **Clean exit**: Leave NOTES.md in place for the phase-ending skill to harvest.
- **Abnormal exit**: NOTES.md preserves resume state — do not delete.

### Rules

- **Checkpoint before every skill invocation or agent spawn.** If the session dies mid-spawn, NOTES.md is the sole resume source.
- **No issue body updates for intra-orchestrator state.** Phase boundaries use the handoff-artifact; everything else stays in NOTES.md.
- **Keep under 2k tokens.** - ummarize stable decisions if it grows.
