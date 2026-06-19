---
name: new-skill
description: Scaffold a conformant SKILL.md. Interviews the author, generates the file, writes it.
---
Maintenance orchestrator that interviews the author to produce a conformant SKILL.md. Runs entirely in main context; no agents. One question at a time.

## Protocol skills

Adopt the "orchestrator-rules" skill.
Adopt the "interviewing-rules" skill.

## Process

1. **Init NOTES.md** — Create `.claude/NOTES.md` with initial state: skill name, role, tier.

2. **Read AUTHORING.md** — Read `references/authoring.md` for body-pattern composition, tier mapping, frontmatter defaults, and protocol-skill catalog. Skip the "interviewing-rules" skill at this point (point-of-need — invoked implicitly by the "interviewing-rules" skill).

3. **Interview author** — Follow `references/interview-steps.md` sequence. Ask one question at a time per the "interviewing-rules" skill. Use `AskUserQuestion` for bounded option sets; plain prompt for free-text. Checkpoint NOTES.md before each question with current state and next step.

   Derive tier from role after step (d). Present derived tier with criteria. Ask author to confirm or override.

4. **Assemble SKILL.md** — Read `_templates/SKILL.template.md`. Fill frontmatter with interview answers (name, description only — opencode skills have no model/effort/tool fields). Compose body sections from AUTHORING.md § Body Assembly by Role/Tier per derived role. Include only sections the role needs.

5. **Show draft** — Fenced code block. Ask: "Shall I write it to `<target-path>`? (y/n)". Require explicit yes.

6. **On yes** — Create directory if needed, write file. Report path.

7. **On no** — Ask which step to revise. Loop back from that step. Regenerate.

8. **Compound** — Invoke the "compound" skill to capture learnings.

## Rules

- Require explicit yes before writing. Silence is NOT approval.
- Do not invent domain content — locks in guesses.
- Point-of-need reads only; nothing loaded at skill entry except protocol skills.
- Defaults (if skipped): target: personal.
- Generated agent spawns (via the task tool) must include a seed-brief per AGENTS.md § Key Conventions — Seed-brief.
- If target `SKILL.md` exists, ask before overwriting.
