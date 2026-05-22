# Scope Assessment and Cycle Details for implement

## Team Shape

Invoke `Skill("scope-assessment")` with work units (one per sub-issue or distinct file group from `## Implementation plan`). Receive agent plan; spawn one `/build` invocation per disjoint group.

For trivial changes (≤ 50 lines, no logic change): pass a single work unit → 1 `/build` agent → inline AC check → PR (no `/review`/`/verify` teams needed).

### Design Gate (Multi-unit only)

Verify `## Implementation plan` in issue body. If absent:
- **Pause** → Prompt: "Run `/define` first, or confirm this is trivial."
- If trivial → proceed as single-unit.
- Otherwise → Wait for `/define`.

## Autonomous Cycle (Multi-unit)

**Seed Brief**: Raw YAML in `<seed-brief>` tag per specialist-mode. `payload: { type: research, ... }`.

1. **`/build`**: Implementation team → codes against issue.
2. **`/review`**: Review team → multi-unit scope triggers detailed review.
3. **`/verify`**: QA team → verifies every AC.
4. **Evaluation**:
   - **Clean pass** → PR creation.
   - **Findings present & cycles < 3** → Package **fix brief** (failing AC + `file:line` findings) in `./.claude/NOTES.md`. Invoke `Skill("compaction-protocol")` to format concisely. Resume `/build` → `/review` → `/verify`.
   - **Cycles = 3** → PR creation → surface remaining findings in Finalize.

**Reporting**: Emit one status line per cycle: `Cycle N/3 — /build <state>, /review <n findings>, /verify <n failures>`.

## PR Creation & Finalize

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
