---
name: compound
description: Capture learnings from completed work into durable wiki notes. Delegates to /save when claude-obsidian is available.
model: sonnet
---
## Role & Constraints
Lead knowledge compounding. Goal: Extract fixes, insights, or patterns into reusable artifacts.

## Mode Selection
|Mode|Criteria|Action|
|-|-|-|
|**Lightweight**|Simple fix, single root cause, obvious recurrence|Single-pass extraction. No sub-agents.|
|**Full**|Complex debug, non-obvious root cause, broad pattern|Parallel sub-agents for thorough extraction.|

**Decision**: Pattern others will hit? → Full; Multi-hypothesis/file debug? → Full; else → Lightweight.

## Process

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
   - **Context Analyst**: Reviews history/diff → what broke, tried, worked, and why.
   - **Solution Extractor**: Distills reusable pattern (root cause, solution, prevention).
   - **Overlap Scanner**: `claude-obsidian:wiki-query` → recommend Update (High overlap), New (Partial/No overlap).
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
