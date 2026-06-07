---
name: orchestrator-rules
description: Standard directives for pipeline orchestrators coordinating specialist sub-skills.
user-invocable: false
layer: 3
---
Rules that apply to all pipeline orchestrators.

## CWD verification

Invoke `Skill("preflight")` at entry. Echo resolved `owner/repo` before every downstream cross-repo `gh` mutation. Pass `preflight_verified: true` in seed briefs so sub-skills skip redundant preflights.

## Delegation

Each stage delegates to the designated sub-skill. Do not reimplement logic owned by `/implement`, `/resolve-pr-feedback`, `/compound`, `/wrap-up`, or any other sub-skill.

## No autonomous merge

Merging is always a human action. Exit cleanly at the awaiting-merge stage; never trigger a merge.

## Seed-brief contract

See `Skill("specialist-mode")` § Autonomous Implement Invocation for seed-brief shape and field requirements.

## Progress tracking via NOTES.md

Orchestrators use `.claude/NOTES.md` as the in-phase progress ledger. Read `${CLAUDE_PLUGIN_ROOT}/_shared/notes-md-protocol.md` § Orchestrator checkpoint pattern for the full protocol.

### On entry

After preflight, create NOTES.md with:
- `## Task list` — one checkbox per work unit or pipeline step, in order.
- `## Decisions made this session` — empty initially.
- `## Next action on resume` — the first step to take if session dies.

### Before spawning a sub-agent

1. Write `## Current task` with what the sub-agent will do.
2. Write `## Next action on resume` with the exact command that would reconstruct state.
3. Include a NOTES.md slice in the seed-brief payload (`progress:` field) — see notes-md-protocol.md § Seed-brief slice for format and cap.

### After sub-agent returns

1. Flip checkbox(es) for completed work.
2. Log key results and decisions from the findings report.
3. Set `## Next action on resume` to the next step.

### On exit

- **Clean exit**: Leave NOTES.md in place for `/implement` to harvest.
- **Abnormal exit**: NOTES.md preserves resume state — do not delete.

### Rules

- **Checkpoint before every `Skill()` or `Agent()` call.** If the session dies mid-spawn, NOTES.md is the sole resume source.
- **No issue body updates for intra-orchestrator state.** Phase boundaries use the handoff-artifact; everything else stays in NOTES.md.
- **Keep under 1k tokens.** If the decision log grows, promote stable decisions to the issue body and trim NOTES.md.
