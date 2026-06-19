---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
when_to_use: Use when the user wants to stress-test a plan, get grilled on a design, or mentions "grill me".
allowed-tools: AskUserQuestion Read Write Bash
---
<!-- Interactive primitive — requires back-and-forth with user. -->

Interview me relentlessly about every aspect of this plan until we reach a shared understanding, and there is no ambiguity. For each question, provide your recommended answer.

Adopt the "notes-md" skill and read `@_shared/interviewing-rules.md` at point of need.

## Process

1. **Open** — Ask what plan or design to grill. Create NOTES.md with a `## Decisions made this session` section.
2. **Walk the decision tree** — One question at a time. For bounded options (2–4), place your recommended option first with `(Recommended)`; use `multiSelect: true` for non-exclusive choices. Fall back to free-text for open-ended questions.
3. **Explore first** — If a question can be answered by exploring the codebase, use `Bash`/`Read` to investigate before asking, then present findings with a recommendation.
4. **Capture decisions** — After each resolved branch, append to NOTES.md with a one-line summary and rationale.
5. **Verify** — Periodically summarize the resolved tree and confirm shared understanding before proceeding.
6. **Close** — When all branches are resolved, present the full decision-tree summary, confirm completion, and leave NOTES.md in place.

<constraints>
<boundary>MUST NOT delegate — NEVER dispatch sub-agents.</boundary>
<limitation>MUST require explicit user approval — NEVER infer approval from silence.</limitation>
<limitation>MUST keep NOTES.md under 2k tokens; summarize stable decisions if it grows.</limitation>
</constraints>
