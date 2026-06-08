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

Each stage delegates to the designated sub-skill. Do not reimplement logic owned by phase-ending or sub-skills — each has a defined scope; respect it.

## No autonomous merge

Merging is always a human action. Exit cleanly at the awaiting-merge stage; never trigger a merge.

## Seed-brief contract

See `Skill("specialist-mode")` for Seed-brief shape and field requirements. Each sub-skill documents its expected seed-brief fields in its own file.

## Progress tracking via NOTES.md

Orchestrators use NOTES.md as the progress ledger for multi-step pipelines that delegate to sub-agents. The pattern:

1. **Create** — On entry (after preflight), create NOTES.md with the full task list derived from work units.
2. **Checkpoint before sub-agent spawn** — Write `## Current task` (what the sub-agent will do) and `## Next action on resume` (how to reconstruct if session dies) before every `Skill()` or `Agent()` call. This ensures crash-safe resume.
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
3. Include a NOTES.md slice in the seed-brief payload (`progress:` field) so the agent arrives with progress context:

```
<seed-brief>
...
payload:
  type: research
  progress: |
    ## Task list (relevant)
    - [x] Scope assessment → 3 work units
    - [ ] Build specialist (current)
    - [ ] Review specialist

    ## Decisions made this session
    - Split auth into own work unit (why: security isolation)
  open_questions: ""
</seed-brief>
```

Slice rules:
- Include only the subset of `## Task list` relevant to the spawned agent's scope.
- Include `## Decisions made this session` in full (decisions are global to the phase).
- Omit `## Current task` (the agent will set its own).
- Cap at 15 lines — the brief is not a state dump.

### After sub-agent returns

1. Flip checkbox(es) for completed work.
2. Log key results and decisions from the findings report.
3. Set `## Next action on resume` to the next step.

### On exit

- **Clean exit**: Leave NOTES.md in place for the phase-ending skill to harvest.
- **Abnormal exit**: NOTES.md preserves resume state — do not delete.

### Rules

- **Checkpoint before every `Skill()` or `Agent()` call.** If the session dies mid-spawn, NOTES.md is the sole resume source.
- **No issue body updates for intra-orchestrator state.** Phase boundaries use the handoff-artifact; everything else stays in NOTES.md.
- **Keep under 1k tokens.** If the decision log grows, promote stable decisions to the issue body and trim NOTES.md.
