---
name: new-skill
description: Scaffold a conformant SKILL.md. Interviews the author, generates the file, writes it.
when_to_use: Creating or extending a skill in any context — plugin, project, or personal config.
model: sonnet
effort: low
allowed-tools: Read Write Bash
---
Maintenance skill that interviews the author to produce a conformant SKILL.md. Runs entirely in main context; never uses `context: fork`. One question at a time.

## Protocol skills

Adopt `Skill("interviewing-rules")`.

## Process

1. **Read authoring guide** — Read `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md` for skill-types table, `_shared/` files decision table, and frontmatter guide.

2. **Interview the author** — Follow the sequence in `references/interview-steps.md`. Ask one question at a time per `Skill("interviewing-rules")`. Use `AskUserQuestion` for bounded option sets; plain prompt for free-text.

3. **Select template** — Read `${CLAUDE_PLUGIN_ROOT}/docs/dispatch-primitives.md` for the role taxonomy and dispatch rules.

   From the description, assess which role fits. Present the likely role with rationale. `AskUserQuestion` `header: "Role"`: "Does `<role>` match your intent?"

   Options: **Yes (Recommended)**, **No, let me choose**. If No, show the role table from dispatch-primitives and let them pick.

   **Role follow-ups:**
   - **Orchestrator** — `AskUserQuestion` `header: "Orchestrator type"`: "Research-leading (deep reasoning, `opus`, `effort: high`) or Coordinator (sequences sub-skills, `sonnet`)?"
   - **Worker** — Plain prompt: "What input does it expect and what does it produce?"
   - **Interaction** — "Does it need a research sub-agent?" If yes, split: autonomous research agent + interactive skill.
   - **Protocol** — Plain prompt: "Which behavioral convention does it encode?"

   Based on the determined role: Orchestrator → `SKILL.orchestrator.template.md`; Specialist/Utility → `SKILL.specialist.template.md`; Primitive → `SKILL.primitive.template.md`.

4. **Generate SKILL.md** — Fill template with interview answers: frontmatter, skeleton sections, spawn-justification if parallelism selected, `_shared/` reference lines per AUTHORING.md.

5. **Show draft** — Fenced code block. Ask: "Shall I write it to `<target-path>`? (y/n)". Require explicit yes.

6. **On yes** — Create directory if needed, write file. Report path and advise filling placeholder sections.

7. **On no** — Ask which step to revise, loop back, regenerate.

## Output

Single SKILL.md at target path, shown for approval before writing.

## Rules

- Require explicit yes before writing.
- Do not invent domain content — locks in guesses.
- All reference-file reads are point-of-need, not unconditional at top.
- Defaults (if skipped): `model: sonnet`; `effort`, `argument-hint`, `allowed-tools`, `user-invocable`: omit; target: personal.
- Generated frontmatter: no `layer:`, no `context: fork`, no `agent:`.
- Generated `Agent()` calls must include a seed-brief per `${CLAUDE_PLUGIN_ROOT}/_shared/seed-brief.md`.
- If target `SKILL.md` exists, ask before overwriting.
