---
name: compound
description: "Capture learnings from completed work into durable wiki notes. Delegates to /save when claude-obsidian is available; otherwise emits inline."
model: sonnet
---

You are leading the knowledge compounding phase. Your job is to capture what was just learned — the fix, the insight, the pattern — into a structured, reusable artifact that future agents and developers can discover and reuse.

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Full-mode team**: 3 parallel subagents + lead synthesis. Comm-pivot ✗ (independent reads, end-synthesis), disjoint ✓, parallel ✓, payoff ≥3×. Fallback: n/a — no flag dependency (parallel subagents do not require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

This skill extracts the learning and drafts it. **Filing is delegated** to the `claude-obsidian` plugin when available: its `/save` command handles vault placement, frontmatter, cross-links, hot-cache updates, and the operation log automatically. If `claude-obsidian` is not installed, the drafted note is emitted inline for the user to copy into whatever knowledge store they prefer.

## Input

The current conversation context — a completed debugging session, feature implementation, or fix. When invoked from `/implement` end-of-flow, may also read `<worktree-root>/.claude/NOTES.md` for in-phase decisions and open questions not yet captured in the conversation context.

## Process

### Mode Selection

Assess the complexity of what was just learned:

- **Lightweight** — simple fix, single root cause, no cross-cutting concerns. Single-pass extraction, no sub-agents.
- **Full** — multi-step debugging, non-obvious root cause, or pattern that applies broadly. Parallel sub-agents for thorough extraction.

Decision tree:
1. Is this a pattern others will hit? → Full
2. Did debugging involve multiple hypotheses or files? → Full
3. Was the fix a one-liner or config change with obvious cause AND unlikely to recur? → Lightweight
4. Is the user explicitly asking for a quick capture? → Lightweight

### Lightweight

Single-pass extraction. Work through these steps yourself:

1. Identify the problem and solution from the conversation history.
2. Check for overlap with existing knowledge:
   - If the `claude-obsidian:wiki-query` command is available, ask it for notes overlapping on module, symptoms, or root cause. Use its verdict.
   - Otherwise, skip the overlap check and note in the output that it was skipped.
3. Draft the note using the appropriate Knowledge Track (see below).
4. File the note:
   - If `claude-obsidian:save` is available → invoke `/save` with the drafted content as input. Let `claude-obsidian` place it, add frontmatter, cross-link, and update its hot cache + log.
   - Otherwise → emit the drafted note inline in the response as a fenced Markdown block the user can copy, and add a one-line suggestion: `Install claude-obsidian (claude plugin marketplace add AgriciDaniel/claude-obsidian) and run /wiki to bootstrap a vault; future /compound invocations will file automatically.`
5. **Staleness check** — if the overlap check found an existing note that the new learning contradicts or supersedes, flag it to the user for consolidation. Do not auto-edit other notes. The `wiki-lint` command (from `claude-obsidian`) is the complementary audit.

### Full

1. **Dispatch 3 parallel subagents** (one Task tool call per agent in a single message):
   - **Context analyst** — reviews the full conversation history and git diff to extract: what broke, what was tried, what worked, and why.
   - **Solution extractor** — distills the fix into a reusable pattern: root cause, solution steps, prevention guidance.
   - **Overlap scanner** — if `claude-obsidian:wiki-query` is available, asks it for existing coverage of the module, symptoms, or root cause. Reports:
     - **High overlap** (same root cause or very similar symptoms) → recommend updating the existing note. Include the target note's identifier in the report.
     - **Partial overlap** (related but distinct) → recommend creating new; include the related note's identifier for cross-linking.
     - **No overlap** → recommend creating new.
     - If `wiki-query` is not available, report `"skipped: no vault query tool available"`.

2. Wait for all three subagents to return, then synthesize their findings into a single drafted note (lead synthesis).

3. File the note:
   - If `claude-obsidian:save` is available → invoke `/save` with the drafted content and, if the overlap scanner recommended an update, pass the target note identifier so `/save` updates in place rather than creating a new note.
   - Otherwise → emit the drafted note inline, plus the overlap scanner's verdict so the user knows whether to file as new or merge into an existing note.

4. **Staleness check** — if the overlap scanner flagged a contradicting or superseded note, present the conflict to the user. Do not auto-delete. Recommend running `wiki-lint` (from `claude-obsidian`) for a broader audit if conflicts are recurrent.

## Output

Choose between two knowledge tracks when filing the note. See `skills/compound/references/knowledge-tracks.md` for the full templates and the note shape for inline fallback (when `claude-obsidian` is not available).

**Bug Track** — use when the learning came from fixing a bug. Captures problem, symptoms, what didn't work, solution, root cause, and prevention guidance.

**Knowledge Track** — use when the learning is a pattern, technique, or architectural insight. Captures context, guidance, rationale, when to use, and examples.

## Rules

- Capture knowledge while it's fresh — don't defer.
- Include actual error messages and stack traces in symptoms — these are what people search for.
- Never include secrets, tokens, or credentials in notes.
- Prefer updating an existing note over creating a duplicate (the overlap scanner's job).
- Do not file directly to any filesystem path. Delegation to `/save` is the only vault-write path; the inline fallback hands responsibility to the user.
- If `claude-obsidian` is installed but `/save` invocation fails, report the error inline with the drafted note — never silently drop the capture.
