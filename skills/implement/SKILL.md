---
name: implement
description: Full implementation cycle — build, review, and verify, then open a PR.
argument-hint: "[issue#]"
model: sonnet
---
## Role & Constraints
Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR.

## Scope Assessment
|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|<= 50 lines, no logic change, 1-2 AC|`/build` (inline) → inline AC check → PR. Skip `/review` and `/verify` teams.|
|**Standard**|Typical multi-file, AC in one module|Full Build → Review → Verify cycle.|
|**Deep**|Cross-module, security, migration, breaking|Full cycle + Deep review + extra critique iterations.|

**Decision**: <= 50 lines + no logic change → Lightweight; Auth/Security/Migrations/Perf → Deep; else → Standard.

### Design Gate (Standard/Deep only)
Verify `## Implementation plan` in issue body. If absent:
- **Pause** → Prompt: "Run `/define` first, or confirm this is trivial."
- If trivial → Downgrade to Lightweight.
- Otherwise → Wait for `/define`.

## Pre-flight
1. [Ref: repo-preflight] at entry (suppress branch line).
2. [Ref: scope-preflight] if >= 3 files. Pass `preflight_verified: true` in seed-briefs.

## Process
**Autonomy Contract**: Run cycles back-to-back without prompting. Only interrupt after PR is open if (a) clean, (b) 3 cycles exhausted, or (c) blocker hit.

### Lightweight
1. `/build` (inline) → TDD for logic-heavy snippets.
2. Inline AC self-check.
3. PR creation → Finalize.

### Standard / Deep (Autonomous Cycle)
**Seed Brief**: Raw YAML in `<seed-brief>` tag per [Ref: specialist-mode]. `payload: { type: research, ... }`.

1. **`/build`**: Implementation team → codes against issue.
2. **`/review`**: Review team → Deep scope triggers Deep mode.
3. **`/verify`**: QA team → verifies every AC.
4. **Evaluation**:
   - **Clean pass** → PR creation.
   - **Findings present & cycles < 3** → Package **fix brief** (failing AC + `file:line` findings) in `./.claude/NOTES.md`. Follow [Ref: compaction-protocol]. Resume `/build` → `/review` → `/verify`.
   - **Cycles = 3** → PR creation → surface remaining findings in Finalize.

**Reporting**: Emit one status line per cycle: `Cycle N/3 — /build <state>, /review <n findings>, /verify <n failures>`.

### PR Creation
Run from worktree root.
1. Harvest `## Decisions made this session` and `## Open questions` from `.claude/NOTES.md` → PR `## Notes`.
2. Push branch → Resolve base (default to `main` if no upstream).
3. Create draft PR (`gh pr create --draft --base <base>`).
   - `Closes #<issue>` (final) or `Related to #<issue>` (partial).
   - **Body**: `## Summary` (1-2 sentences), `## Testing notes` (concrete repro), `## Notes` (from NOTES.md / exhausted findings).
4. `/compound` (autonomous) → file durable learnings to wiki.
5. Delete `.claude/NOTES.md`.

### Finalize
- **Clean exit** → present PR URL.
- **Exhausted exit** (3 cycles, findings remain):
  - `autonomous: true` → Accept/close unconditionally → status line.
  - `autonomous: false` → PR URL + findings → binary question: "Continue loop, or accept and close?"
    - **Continue** → One more cycle → log escalation in PR `## Notes` → return to Finalize.

## Rules
- **Zero Prompts**: No prompting between sub-skills.
- **Rigor**: Do not open PR until clean pass OR 3 cycles exhausted.
- **Completeness**: Each cycle must address ALL previous findings.
- **State**: In-phase state in `.claude/NOTES.md`. Issue body stores `## Requirements` and `## Implementation plan`.
- [Ref: handoff-artifact]
