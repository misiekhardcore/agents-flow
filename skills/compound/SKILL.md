---
name: compound
description: Capture learnings from completed work into durable wiki notes. Delegates to /save when claude-obsidian is available.
when_to_use: Use after a feature is merged to capture learnings into durable wiki notes.
model: sonnet
effort: low
allowed-tools: Agent Bash Read
user-invocable: true
---
## Role & Constraints
Lead knowledge compounding. Goal: Extract fixes, insights, or patterns into reusable artifacts. Captures learnings from the completed phase into durable wiki notes. Delegates to `/save` when claude-obsidian is available. Degrades gracefully when `/save` is unavailable — outputs wiki content to terminal instead.

## Assessment
Before selecting a mode, evaluate the session against these value buckets:
- **Novel decisions** — design, architecture, or tradeoff choices made during this session.
- **Non-obvious fixes** — subtle bugs or root causes others will hit again.
- **Reusable patterns** — generalizable techniques or preventive measures.

Skip if the work was routine edits, mechanical refactors, or changes already captured in existing notes.
If none of the buckets yield content → print `Nothing to compound.` and exit.
Otherwise → proceed to Mode Selection.

## Mode Selection
|Mode|Criteria|Action|
|-|-|-|
|**Lightweight**|Simple fix, single root cause, obvious recurrence|Single-pass extraction. No sub-agents.|
|**Full**|Complex debug, non-obvious root cause, broad pattern|Parallel sub-agents for thorough extraction.|

**Decision**: Pattern others will hit? → Full; Multi-hypothesis/file debug? → Full; else → Lightweight.

## Process

Invoke `Skill("notes-md")` — adopt NOTES.md lifecycle protocol.

### Lightweight
1. **Extraction**: Identify problem/solution from history.
2. **Overlap Check**: If `claude-obsidian:wiki-query` available → search for overlapping notes on module/symptoms/root cause.
3. **Draft**: Use appropriate Knowledge Track.
4. **Filing**:
   - `claude-obsidian:save` available → invoke `/save` with drafted content.
   - Otherwise → emit inline fenced Markdown + install prompt.
5. **Staleness**: Flag contradictions with existing notes for user consolidation.

### Full
1. **Parallel Extraction** (3 sub-agents):
   - `Agent("compound/agents/context-analyst.md")` — what broke, tried, worked, and why.
   - `Agent("compound/agents/solution-extractor.md")` — reusable pattern (root cause, solution, prevention).
   - `Agent("compound/agents/overlap-scanner.md")` — overlap check; recommend Update or New.
2. **Synthesis**: Synthesize findings into a single drafted note.
3. **Filing**: Same as Lightweight. If overlap scanner recommended Update → pass target identifier to `/save`.
4. **Staleness**: Present contradicting/superseded notes to user → recommend `wiki-lint`.

## I/O
- **Input**: Completed session context; optionally `<worktree-root>/.claude/NOTES.md`.
- **Output**: Bug Track or Knowledge Track note (see `skills/compound/references/knowledge-tracks.md`).
- **Constraint**: Never include secrets/tokens. No direct filesystem writes → delegate to `/save`.

## Rules
- Capture while fresh.
- Include verbatim error messages/stack traces in symptoms.
- Prioritize updating existing notes over duplicates.
- Report `/save` failures inline with the drafted note.
