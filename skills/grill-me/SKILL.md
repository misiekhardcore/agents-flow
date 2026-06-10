---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
when_to_use: Use when the user wants to stress-test a plan, get grilled on a design, or mentions "grill me".
allowed-tools: AskUserQuestion Read Write Bash
---

Adopt behavioral conventions from supporting skills and shared references at point of need:

- `Skill("notes-md")`
- `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md\``

## Process

1. **Open** — Ask the user what plan or design they want to grill. Create NOTES.md via `Skill("notes-md")` with `## Decisions made this session` section.
2. **Walk the decision tree** — One question at a time per interviewing-rules. For bounded options (2–4), use `AskUserQuestion` with `(Recommended)` on the first option; use `multiSelect: true` for non-exclusive choices. For open-ended exploration, fall back to free-text prompts.
3. **Explore first** — If a question can be answered by exploring the codebase, use `Bash`/`Read` to investigate before asking, then present findings with a recommendation.
4. **Capture decisions** — After each resolved branch, append to NOTES.md under `## Decisions made this session` with a one-line summary and rationale.
5. **Verify** — Periodically summarize the resolved tree back to the user and confirm shared understanding before proceeding.
6. **Close** — When all branches are resolved, present the full decision-tree summary, confirm completion with the user, and leave NOTES.md in place.

## Constraints

- One question at a time.
- No delegation — grill-me never dispatches sub-agents.
- Require explicit user approval — never infer from silence or non-objection.
- Keep NOTES.md under 1k tokens. If the decision log grows, summarize stable decisions into the session summary and trim.
