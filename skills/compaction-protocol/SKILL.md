---
name: compaction-protocol
description: Context management protocol for rot reduction using editing, delegation, and summarization.
---
Used by `/build` to manage context rot. Read on-demand at compaction steps; do not preload.

## Tool order

1. **Context editing first.** Clear stale tool results verbatim. This is rot-immune because nothing is paraphrased.
2. **Sub-agent delegation second.** If the next bulk read can be delegated, the lead never accumulates the rot in the first place.
3. **Summarization-based `/compact` last.** Re-summarization compresses, but it also creates a new lower-fidelity anchor the model will over-attend to. Use only when conversation bulk (not tool output) is the source of pressure.

## When to trigger

Trigger on concept shifts, not percentages:

- **Next action unrelated to recent tool results.** Clear stale results before they distort the next decision.
- **Starting a new sub-issue or task-list item.** Concept boundary.
- **Just spawned a sub-agent.** Isolation already in place.
- **About to read large files or wide paths.** Delegate instead — prevent rot, don't compact.
- **Auto-compact warning appears.** Stop, run protocol, resume. Never let it run unattended.

## Context editing — the default

Use [context editing](https://platform.claude.com/docs/en/build-with-claude/context-editing) to clear superseded tool outputs (reads after edits, old test runs, stale doc lookups). Reports 84% reduction vs. summarization; no paraphrase artifacts. Default tool — reach for `/compact` only when context editing can't fix the root pressure.

## Summarization-based `/compact` — last resort

When conversation bulk (not tool output) is the pressure, write the Keep list to `.claude/NOTES.md` first:

```
/compact

Keep: <architectural decisions>; <current task and files in scope>;
<unresolved bugs or failing tests>; <open questions from the issue>.

Drop: <rejected alternatives>; <tool outputs already acted on>;
<API docs already internalized>; <exploration that led nowhere>.
```

Keep what the model can't reconstruct from the issue or `.claude/NOTES.md`. Drop anything large and replayable.

## Verification

After compaction, run: `Summarize where we are and what the next step is.`

Diff the summary against the Keep list in `.claude/NOTES.md`. If anything is missing, restate it explicitly before the next tool call. If hollow, abort and re-read the issue + `.claude/NOTES.md`.

## Rules

- **Compaction is a build-time responsibility.** Do not defer to `/wrap-up`.
- **Each step is more lossy.** Context editing → delegation → `/compact`. Never skip steps.
