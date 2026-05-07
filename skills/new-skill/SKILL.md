---
name: new-skill
description: Scaffold a new skill conforming to the authoring standard. Interviews the author, generates a SKILL.md, and writes it to the chosen location.
when_to_use: Use when creating a new skill for personal use, a project, or this plugin.
model: haiku
---
Interactive skill scaffolder. Help author create skill conforming to claude-workflow standard. One question at a time.

## Input

A brief statement from the author of what the skill should do — or nothing, in which case start with question (a) below.

## Process

1. Read `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md` — the skill-types table, decision table for `_shared/` files, and frontmatter guide. You will quote its guidance back to the author when they are unsure.

2. **Interview the author** — ask ONE question at a time. Do not bundle. See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`.

   Use `AskUserQuestion` for every question with a bounded option set (steps c, d, e, f, g, h). For free-text questions (a, b), use a plain prompt. In each `AskUserQuestion` call, place the recommended option first and append ` (Recommended)` to its label — derive the recommendation from the description collected in step (b).

   a. **Name** — plain prompt: "What's the skill called?" Must be lowercase kebab-case (e.g. `deploy-to-vercel`). Matches the directory name under `skills/`.

   b. **Description** — plain prompt: "In one or two sentences: what does this skill do, and when should it trigger?" Frame as "Does X. Use when Y." This is the primary trigger mechanism — specificity matters more than elegance. If the author's draft is vague, grill for concrete trigger phrases (what would the user type?).

   c. **Role** — `AskUserQuestion` with `header: "Role"`, question: "Which role does this skill fill?". Options (4-option limit — if the author is unsure between the two orchestrator variants, pick **Orchestrator** here and clarify in the follow-up):
   - **Orchestrator** — leads a phase; spawns sub-skills or specialists; may write a handoff artifact (e.g. `/discovery`, `/define`, `/implement`)
   - **Specialist** — executes a bounded task; receives a seed brief from an orchestrator (e.g. `/build`, `/review`, `/architecture`)
   - **Interactive primitive** — reusable inline behavior; invoked by specialists; no team, no handoff (e.g. `/grill-me`)
   - **Utility** — user-invocable maintenance/post-work skill; no seed brief, no handoff artifact (e.g. `/compound`, `/prune`, `/resolve-pr-feedback`)

     If the author picks **Orchestrator**, ask one follow-up `AskUserQuestion` with `header: "Orchestrator type"`, question: "Does this orchestrator do its own deep reasoning, or sequence already-designed sub-skills?". Options:

   - **Research-leading** — spawns a research team before the main team; deep reasoning at the orchestrator tier (e.g. `/discovery`, `/define`). Defaults model to `opus` and `effort: high`.
   - **Coordinator** — sequences sub-skills in a loop; research happens upstream or in the sub-skills (e.g. `/implement`). Defaults model to `sonnet`, no `effort`.

     This answer determines which template to use in step 3 and pre-fills the model/effort defaults (which the author can still override in steps d/e).

     If the author picks **Specialist** or **Primitive**, ask one follow-up `AskUserQuestion` with `header: "Visibility"`, question: "Should this skill be hidden from the slash-command menu?". Options:
   - **No (Recommended)** — omit `user-invocable` (skill appears in menu; default)
   - **Yes** — add `user-invocable: false` (hides from menu; use for orchestrator-internal specialists not meant for direct user invocation)

   d. **Model** — `AskUserQuestion` with `header: "Model"`, question: "Which model fits?". Options:
   - **sonnet** — standard multi-step workflows, implementation, review
   - **haiku** — fast lookup, formatting, retrieval, light verification
   - **opus** — deep research, architecture, high-stakes decisions

   e. **effort** — `AskUserQuestion` with `header: "Effort"`, question: "Does this skill run long-form multi-turn research or decision-making?". Options:
   - **Standard** — omit `effort` (default)
   - **High** — add `effort: high` to frontmatter

   f. **argument-hint** — ask: "Does this skill accept a positional argument from the user? If yes, enter the hint text (e.g. `[issue#]`, `[PR# or URL]`). Type 'no' to skip." Store as `argument-hint` when provided; omit when skipped.

   g. **allowed-tools** — `AskUserQuestion` with `header: "Tools"`, question: "Should the skill have access to all tools, or a restricted subset?". Options:
   - **All tools** — omit the field (default; what most skills want)
   - **Restricted subset** — set `allowed-tools:` explicitly

     If the author picks **Restricted subset**, ask one free-text follow-up: "Which tools should it be allowed to use? (space-separated — e.g. `Read Grep Glob Bash`)". Validate that each entry is a real Claude Code tool name (reject unknown names and re-ask). Use the answer verbatim as the value of `allowed-tools:`.

   h. **Parallelism** — `AskUserQuestion` with `header: "Parallelism"`, question: "Does this skill spawn sub-agents or teams? If yes, which primitive?". Options:
   - **No parallelism** — skill runs inline; no sub-agents or teams
   - **Parallel subagents** — skill spawns 2–3 independent subagents (applies to all roles)
   - **TeamCreate** — skill spawns a team (orchestrators / specialists only)

     If the author picks **Parallel subagents** or **TeamCreate**, ask a follow-up free-text: "Which conditions gate the spawn decision? (reference the rubric in `_shared/composition.md` — e.g., scope class, file count, communication pivot)". Store the answer as a "Spawn justification" block in the skill body.

   i. **Shared protocols** — `AskUserQuestion` with `header: "Protocols"`, `multiSelect: true`, question: "Which shared protocols does this skill need?". Walk through the AUTHORING.md decision table. Options (4-option limit):
   - **Handoff artifact** — writes or reads a GitHub issue handoff block → include `handoff-artifact.md`
   - **Interviewing rules** — interviews the user, asks questions, seeks approval → include `interviewing-rules.md`
   - **NOTES.md protocol** — creates or reads `.claude/NOTES.md` → include `notes-md-protocol.md`
   - **Compaction protocol** — manages in-phase context (clearing stale results, delegating, `/compact`) → include `compaction-protocol.md`

     Then a second `AskUserQuestion` call: `header: "Composition"`, question: "Does this skill author an orchestrator or design a multi-skill workflow?". Options:

   - **No** — skip `composition.md`
   - **Yes** — include `composition.md`

   j. **Target location** — `AskUserQuestion` with `header: "Target"`, question: "Where should the skill be written?". Options:
   - **Personal (Recommended)** — `~/.claude/skills/<name>/SKILL.md` (individual use)
   - **Project** — `<cwd>/.claude/skills/<name>/SKILL.md` (committed to the current repo)
   - **Plugin** — `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md` (contributing to this plugin; dogfooding)

3. **Select the template** based on the author's role answer (step 2c):
   - Orchestrator (either variant) → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.orchestrator.template.md`. For Coordinator, drop the "Dispatch a research team" step from the template body per its header note.
   - Specialist or Utility → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.specialist.template.md`. For Utility, remove the "Optionally: a seed brief" paragraph from Input — utility skills are user-invocable and don't receive briefs.
   - Primitive → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.primitive.template.md`

   Both orchestrator and specialist templates now include placeholders for parallelism justification (step 2h). Fill these in based on the author's answer.

   Read the selected template — that is the skeleton you will fill in.

4. **Generate the SKILL.md** by filling in the selected template:
   - Frontmatter: `name`, `description`, `model`; include `effort: high` / `argument-hint: ...` / `allowed-tools: ...` / `user-invocable: false` only when the author opted in; apply the canonical field order from `_templates/AUTHORING.md`
   - Body: keep the skeleton sections (Input / Process / Output / Rules) as placeholders for the author to fill — don't invent domain content
   - If the author selected parallelism in step 2h, include the spawn-justification text from their answer in the "Spawn justification" block in the skill body (orchestrator or specialist templates both have this now)
   - Append a reference line at the end of the relevant section for each selected `_shared/` file. Use the full `${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md` path, matching the pattern in `_templates/AUTHORING.md` (§ "Reference pattern")
   - Include `composition.md` reference if the author selected it in step 2i

5. **Show the draft** to the author in a fenced code block. Ask: "Does this look right? Shall I write it to `<target-path>`? (y/n)". Do not write on silence or "looks good" — require an explicit yes.

6. **On yes**: create the directory if needed, write the file. Report the absolute path and tell the author:
   - "Fill in the Input / Process / Output / Rules sections. The skeleton has placeholders."
   - "Test by invoking `/<name>` in a new session. Claude loads skills at session start."

7. **On no**: ask which question they want to revise, loop back to that step, regenerate.

## Output

A single file written to the chosen target location, conforming to the authoring standard. Empty skeleton sections that the author fills in afterwards — this skill scaffolds the frame, not the domain content.

## Rules

- One question at a time. No bundling.
- Never write the file without explicit confirmation. "Sounds good" / silence / non-objection is NOT confirmation.
- The skeleton is intentionally sparse. Do not invent domain content for sections you were not told about — that locks in guesses.
- If the author skips a question with "skip" or "default", use the documented default (model: sonnet, effort: omit, argument-hint: omit, allowed-tools: omit, user-invocable: omit, target: personal).
- If the target directory already contains a `SKILL.md`, stop and ask whether to overwrite or pick a new name.
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol.
