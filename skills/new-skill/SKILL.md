---
name: new-skill
description: Scaffold a new skill conforming to the authoring standard. Interviews the author, generates a SKILL.md, and writes it to the chosen location.
when_to_use: Use when creating a new skill for personal use, a project, or this plugin.
model: haiku
effort: low
allowed-tools: Read Write Bash
---
Interactive skill scaffolder. Help author create skill conforming to claude-workflow standard. One question at a time.

## Input

A brief statement from the author of what the skill should do — or nothing, in which case start with step (a).

## Process

1. Read `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md` — skill-types table, `_shared/` files decision table, frontmatter guide.

2. **Interview the author** — ask ONE question at a time. See `skills/new-skill/references/interview-steps.md` for the question sequence.

   Use `AskUserQuestion` for bounded option sets (c–k); plain prompt for free-text (a, b, l). Place recommended option first with ` (Recommended)` — derive from step (b).

3. **Select template** based on role: Orchestrator → `SKILL.orchestrator.template.md`; Specialist/Utility → `SKILL.specialist.template.md`; Primitive → `SKILL.primitive.template.md`.

4. **Generate SKILL.md** by filling template: Frontmatter (`name`, `description`, `model` plus opt-in fields per author choice); skeleton sections as placeholders; spawn-justification if parallelism selected; `_shared/` reference lines per `_templates/AUTHORING.md`.

5. **Show draft** in fenced code block. Ask: "Shall I write it to `<target-path>`? (y/n)". Require explicit yes.

6. **On yes**: create directory if needed, write file. Report path and advise filling placeholder sections.

7. **On no**: ask which step to revise, loop back, regenerate.

## Output

A single file at the chosen target location, conforming to the authoring standard. Empty skeleton sections for the author to fill.

## Rules

- One question at a time. Require explicit yes before writing.
- Do not invent domain content — locks in guesses.
- Defaults (if skipped): model: sonnet; effort, argument-hint, allowed-tools, user-invocable: omit; target: personal.
- Include `when_to_use` only if author identified mis-routing risk (step c); omit otherwise.
- If target `SKILL.md` exists, ask whether to overwrite.
- Invoke `Skill("interviewing-rules")`
