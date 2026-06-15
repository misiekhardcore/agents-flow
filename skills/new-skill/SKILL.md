---
name: new-skill
description: Scaffold a conformant SKILL.md. Interviews the author, generates the file, writes it.
when_to_use: Creating or extending a skill in any context — plugin, project, or personal config.
model: sonnet
effort: low
allowed-tools: Read Write Bash
---
Maintenance orchestrator that interviews the author to produce a conformant SKILL.md. Runs entirely in main context; no agents. One question at a time.

## Protocol skills

Adopt `Skill("orchestrator-rules")`.
Adopt `Skill("interviewing-rules")`.

## Process

1. **Init NOTES.md** — Create `.claude/NOTES.md` with initial state: skill name, role, tier.

2. **Read AUTHORING.md** — Read `${CLAUDE_PLUGIN_ROOT}/_shared/AUTHORING.md` for body-pattern composition, tier mapping, frontmatter defaults, and protocol-skill catalog. Skip `_shared/interviewing-rules.md` at this point (point-of-need — invoked implicitly by `Skill("interviewing-rules")`).

3. **Interview author** — Follow `references/interview-steps.md` sequence. Ask one question at a time per `Skill("interviewing-rules")`. Use `AskUserQuestion` for bounded option sets; plain prompt for free-text. Checkpoint NOTES.md before each question with current state and next step.

   Derive tier from role after step (d). Present derived tier with criteria. Ask author to confirm or override.

4. **Assemble SKILL.md** — Read `_templates/SKILL.template.md`. Fill frontmatter with interview answers (name, description, model, effort, allowed-tools, user-invocable per tier). Compose body sections from AUTHORING.md § Body Assembly by Role/Tier per derived role. Include only sections the role needs.

5. **Show draft** — Fenced code block. Ask: "Shall I write it to `<target-path>`? (y/n)". Require explicit yes.

6. **On yes** — Create directory if needed, write file. Report path.

7. **On no** — Ask which step to revise. Loop back from that step. Regenerate.

8. **Compound** — Invoke `Skill("compound")` to capture learnings.

## Rules

- Require explicit yes before writing. Silence is NOT approval.
- Do not invent domain content — locks in guesses.
- Point-of-need reads only; nothing loaded at skill entry except protocol skills.
- Defaults (if skipped): `model: sonnet`; `effort`, `argument-hint`, `allowed-tools`, `user-invocable`: omit; target: personal.
- Generated `Agent()` calls must include a seed-brief per `${CLAUDE_PLUGIN_ROOT}/_shared/seed-brief.md`.
- If target `SKILL.md` exists, ask before overwriting.
