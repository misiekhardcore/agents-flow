# Interview steps for new-skill

This file details the 12-step interview sequence that new-skill conducts with the author, one question at a time.

## Step (a): Name

**Plain prompt**: "What's the skill called?"

- Must be lowercase kebab-case (e.g. `deploy-to-vercel`).
- Matches the directory name under `skills/`.

## Step (b): Description

**Plain prompt**: "In one or two sentences: what does this skill do, and when should it trigger?"

- Frame as "Does X. Use when Y."
- This is the primary trigger mechanism — specificity matters more than elegance.
- If the author's draft is vague, grill for concrete trigger phrases (what would the user type?).

## Step (c): Mis-routing

**`AskUserQuestion`** with `header: "Mis-routing"`, question: "Could another skill be invoked instead of this one?"

**Options:**
- **Yes** — mis-routing is plausible; follow up with a free-text prompt: "Describe what this skill does NOT do and which skill handles it instead (e.g. 'Does NOT audit plugin files — use /prune for that'), and any sequence precondition (e.g. 'Use after /discover'). This becomes the `when_to_use` frontmatter."
- **No / Skip** — omit `when_to_use` frontmatter.

Only generate `when_to_use` frontmatter when the author answers Yes; omit otherwise.

## Step (d): Role

**`AskUserQuestion`** with `header: "Role"`, question: "Which role does this skill fill?"

**Options** (4-option limit — if the author is unsure between the two orchestrator variants, pick **Orchestrator** here and clarify in the follow-up):
- **Orchestrator** — leads a phase; spawns sub-skills or specialists; may write a handoff artifact (e.g. `/discover`, `/define`, `/implement`)
- **Specialist** — executes a bounded task; receives a seed brief from an orchestrator (e.g. `/build`, `/review`, `/architecture`)
- **Interactive primitive** — reusable inline behavior; invoked by specialists; no team, no handoff (e.g. `/grill-me`)
- **Utility** — user-invocable maintenance/post-work skill; no seed brief, no handoff artifact (e.g. `/compound`, `/prune`, `/resolve-pr-feedback`)

**If Orchestrator:** Ask one follow-up `AskUserQuestion` with `header: "Orchestrator type"`, question: "Does this orchestrator do its own deep reasoning, or sequence already-designed sub-skills?"

**Options:**
- **Research-leading** — spawns a research team before the main team; deep reasoning at the orchestrator layer (e.g. `/discover`, `/define`). Defaults model to `opus` and `effort: high`.
- **Coordinator** — sequences sub-skills in a loop; research happens upstream or in the sub-skills (e.g. `/implement`). Defaults model to `sonnet`, no `effort`.

This answer determines which template to use in step 3 and pre-fills the model/effort defaults (which the author can still override in steps e/f).

**If Specialist or Primitive:** Ask one follow-up `AskUserQuestion` with `header: "Contract"`, question: "Does this skill require user interaction during execution (deliberation, decisions, grill-me), or is it fully autonomous (research, verification, code work)?"

**Options:**
- **Interactive (Recommended)** — user must be present; invoked via `Skill()`; set `user-invocable: true`
- **Autonomous** — no user interaction; invoked via `Agent()`; set `user-invocable: false`

> **If the skill needs BOTH research and user interaction**: it must be split into two skills — an autonomous research skill (`user-invocable: false`, `Agent()`-only) and an interactive skill (`user-invocable: true`, `Skill()`-only). Name the research skill `<name>-research`. See `_shared/composition.md` § Consumption Contracts.

Then ask one follow-up `AskUserQuestion` with `header: "Visibility"`, question: "Should this skill be hidden from the slash-command menu?"

**Options:**
- **No (Recommended)** — omit `user-invocable` (skill appears in menu; default). Not applicable if Autonomous was selected above.
- **Yes** — add `user-invocable: false` (hides from menu; required for Autonomous contract; also use for any orchestrator-internal specialist)

## Step (e): Model

**`AskUserQuestion`** with `header: "Model"`, question: "Which model fits?"

**Options:**
- **sonnet** — standard multi-step workflows, implementation, review
- **haiku** — fast lookup, formatting, retrieval, light verification
- **opus** — deep research, architecture, high-stakes decisions

## Step (f): Effort

**`AskUserQuestion`** with `header: "Effort"`, question: "Does this skill run long-form multi-turn research or decision-making?"

**Options:**
- **Standard** — omit `effort` (default)
- **High** — add `effort: high` to frontmatter

## Step (g): Argument hint

**Plain prompt**: "Does this skill accept a positional argument from the user? If yes, enter the hint text (e.g. `[issue#]`, `[PR# or URL]`). Type 'no' to skip."

- Store as `argument-hint` when provided.
- Omit when skipped.

## Step (h): Allowed tools

**`AskUserQuestion`** with `header: "Tools"`, question: "Should the skill have access to all tools, or a restricted subset?".

**Options:**
- **All tools** — omit the field (default; what most skills want)
- **Restricted subset** — set `allowed-tools:` explicitly

If the author picks **Restricted subset**, ask one free-text follow-up: "Which tools should it be allowed to use? (space-separated — e.g. `Read Grep Glob Bash`)".

- Validate that each entry is a real Claude Code tool name (reject unknown names and re-ask).
- Use the answer verbatim as the value of `allowed-tools:`.

## Step (i): Parallelism

**`AskUserQuestion`** with `header: "Parallelism"`, question: "Does this skill spawn sub-agents or teams? If yes, which primitive?".

**Options:**
- **No parallelism** — skill runs inline; no sub-agents
- **Parallel subagents** — skill spawns independent subagents; lead merges results (applies to all roles)

If the author picks **Parallel subagents**, ask a follow-up free-text: "Which conditions gate the spawn decision? (reference the rubric in `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` — e.g., scope class, file count, main-thread overrun)".

- Store the answer as a "Spawn justification" block in the skill body.

## Step (j): Shared protocols

**`AskUserQuestion`** with `header: "Protocols"`, `multiSelect: true`, question: "Which shared protocols does this skill need?"

- Walk through the AUTHORING.md decision table.

**Options** (4-option limit):
- **Handoff artifact** — writes or reads a GitHub issue handoff block → include `handoff-artifact.md`
- **Interviewing rules** — interviews the user, asks questions, seeks approval → include `interviewing-rules.md`
- **NOTES.md protocol** — creates or reads `.claude/NOTES.md` → include `notes-md-protocol.md`
- **Compaction protocol** — manages in-phase context (clearing stale results, delegating, `/compact`) → include `compaction-protocol.md`

Then a second `AskUserQuestion` call: `header: "Composition"`, question: "Does this skill author an orchestrator or design a multi-skill workflow?"

**Options:**
- **No** — skip `composition.md`
- **Yes** — include `composition.md`

## Step (k): Target location

**`AskUserQuestion`** with `header: "Target"`, question: "Where should the skill be written?"

**Options:**
- **Personal (Recommended)** — `~/.claude/skills/<name>/SKILL.md` (individual use)
- **Project** — `<cwd>/.claude/skills/<name>/SKILL.md` (committed to the current repo)
- **Plugin** — `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md` (contributing to this plugin; dogfooding)

## Step (l): Reference file loading phases

**Plain prompt**: "Does this skill load reference files at different execution points? If yes, describe the natural phases (e.g. 'pre-flight assesses scope, then execution begins'). Type 'no' or 'single phase' to skip."

- If the author describes **2+ distinct phases**: scaffold one reference file stub per phase under `skills/<name>/references/`. Name each stub after the phase or topic (e.g. `scope.md`, `process.md`).
- If the author describes **1 phase** (or says "no"): scaffold a single reference file stub if the entry-point would exceed 150 lines; otherwise skip reference scaffolding entirely.
- Do **not** force per-phase stubs on simple skills — if the skill body fits ≤150 lines without references, skip entirely.
