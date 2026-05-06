# AUTHORING.md — Skill Authoring Standard

This document defines the authoring conventions for workflow skills in this plugin. Read it when creating or editing a skill, or when `/new-skill` asks which `_shared/` files apply.

## Skill types

Every skill fills one of five authoring roles. These extend the three-role composition model in `_shared/composition.md` (orchestrator / specialist / primitive): the orchestrator role is split into two variants, and a utility type is added for maintenance skills. Choose the correct template before authoring.

| Role                              | Definition                                                                                                                                                      | Examples                                                      | Typical model                |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | ---------------------------- |
| **Research-leading orchestrator** | Leads a phase; spawns a research team, then a main team of specialists; writes the handoff artifact. Used when deep reasoning happens at the orchestrator tier  | `/discovery`, `/define`                                       | `opus` + `effort: high` |
| **Coordinator orchestrator**      | Sequences already-designed sub-skills in a loop (e.g. build → review → verify). Deep reasoning lives in the sub-skills, not the orchestrator — no research team | `/implement`                                                  | `sonnet`                     |
| **Specialist**                    | Executes a bounded task; receives a seed brief; reports findings to the orchestrator                                                                            | `/build`, `/review`, `/architecture`, `/specify`              | `sonnet`                     |
| **Interactive primitive**         | Reusable inline behavior; invoked by specialists; no team, no handoff                                                                                           | `/grill-me`                                                   | `sonnet`                     |
| **Utility**                       | User-invocable maintenance or post-work skill. No seed-brief contract, no phase handoff artifact, no team gating                                                | `/compound`, `/prune`, `/resolve-pr-feedback`, `/find-skills`, `/wrap-up` | `sonnet` or `haiku`          |

Use the role-specific template:

- Research-leading or coordinator orchestrator → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.orchestrator.template.md` (coordinator variants omit the research-team step — see the template header note)
- Specialist or utility → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.specialist.template.md` (utility skills simply have no seed-brief input and no handoff output)
- Primitive → `${CLAUDE_PLUGIN_ROOT}/_templates/SKILL.primitive.template.md`

For generic composition theory (patterns, briefs, decomposition rules), see `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

## Composition patterns

Multi-skill workflows follow four patterns: linear, branch, loop, and parallel. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for definitions, when to use each, and the seed-brief contract that governs how orchestrators seed specialists with context. The three standard brief types (research, prior-art, fix) are defined there.

## Skill structure

Use the role-specific templates for new skills: orchestrator, specialist, or primitive. Each template is a loose skeleton — not every section is required. Use what fits.

### Frontmatter fields

| Field           | Required | Values                        | Notes                                                                                                                                                                                                                                                                |
| --------------- | -------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`          | yes      | lowercase kebab-case          | Matches the directory name under `skills/`                                                                                                                                                                                                                           |
| `description`   | yes      | 1–2 sentences, ≤150 chars     | Primary trigger mechanism — include both what it does and when to use it. Hard cap: 150 chars; move examples and use-cases into the skill body where they load on invocation only |
| `model`         | yes      | `haiku` \| `sonnet` \| `opus` | See model guide below                                                                                                                                                                                                                                                |
| `effort`        | no       | `low|medium|high|xhigh|max` | Elevates model effort for long-form research/decision-making. Use `high` for opus-tier research skills (discovery, define, architecture, describe).                                                                                                                  |
| `when_to_use`   | no       | free text                     | Trigger phrases and "use before/after X" guidance. Rendered in the slash-command picker alongside `description`. Combined cap with `description`: 1,536 chars; keep `description` itself ≤150 chars per plugin convention.                                           |
| `argument-hint` | no       | `[hint text]`                 | Hint shown after the slash command in the picker (e.g. `[issue#]`, `[PR# or URL]`). Forward-compatible; not yet rendered in plugin autocomplete (upstream bug [anthropics/claude-code#46626](https://github.com/anthropics/claude-code/issues/46626)).               |
| `user-invocable`| no       | `false`                       | Set to `false` to hide the skill from the slash-command menu. Omit to keep visible (default). Use for orchestrator-internal specialists not meant for direct user invocation.                                                                                         |
| `disable-model-invocation` | no | `true`                   | Prevents Claude from auto-invoking the skill without explicit user action.                                                                                                                                                                                            |
| `allowed-tools` | no       | space-separated tool names    | Pre-approves listed tools so they run without per-use permission prompts. Does **not** restrict access — every tool remains callable. Omit by default; to actually block tools, use deny rules in `.claude/settings.json` or a subagent with its own `tools:` field. |

### Canonical field order

When multiple fields are present, use this order so diffs are predictable:

```
name → description → when_to_use → argument-hint → model → effort → allowed-tools → user-invocable → disable-model-invocation
```

Omit optional fields when not set — never write empty strings or `null` as values.

### Model guide

| Model    | Use for                                                               |
| -------- | --------------------------------------------------------------------- |
| `haiku`  | Fast lookup, formatting, retrieval, light verification                |
| `sonnet` | Standard multi-step workflows, implementation, review                 |
| `opus`   | Deep research, architecture, high-stakes decisions with many branches |

## `_shared/` files — when and how

Shared protocols live at `${CLAUDE_PLUGIN_ROOT}/_shared/`. Reference them on-demand from the skill body; do not preload.

### Decision table

| `_shared/` file          | Reference when the skill...                                                                                                                                                             |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `handoff-artifact.md`    | Writes or reads a GitHub issue handoff block (phase-boundary skills: `/discovery`, `/define`). Note: `/implement` is the terminal phase — its output is the PR, not an issue body update. `/wrap-up` is a utility, not a phase-boundary skill. |
| `interviewing-rules.md`  | Interviews the user — asks questions, seeks approval, uses multi-choice forms (`/discovery`, `/define`, `/describe`, `/specify`, `/architecture`, `/design`, `/grill-me`, `/new-skill`) |
| `notes-md-protocol.md`   | Creates, updates, or resumes from `.claude/NOTES.md` (`/build`); harvests and deletes it (`/implement` at PR-creation time)                                                             |
| `specialist-mode.md`     | Documents or implements specialist-mode detection (seed-brief check, skip-list, standalone fallback) for any skill that can be seeded by an orchestrator                                |
| `compaction-protocol.md` | Manages in-phase context — clearing stale tool results, delegating bulk reads, using `/compact` (`/build`)                                                                              |
| `composition.md`         | Authors an orchestrator skill or designs a multi-skill workflow — patterns, briefs, decomposition rules                                                                                 |

### Reference pattern

Add a reference line at the end of the relevant section in the skill body. Use the full `${CLAUDE_PLUGIN_ROOT}` path:

```markdown
See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol — apply it throughout all user interactions.
```

```markdown
See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for the five-field handoff shape.
```

```markdown
See `${CLAUDE_PLUGIN_ROOT}/_shared/notes-md-protocol.md`.
```

```markdown
See `${CLAUDE_PLUGIN_ROOT}/_shared/compaction-protocol.md`. Context editing first, sub-agents second, `/compact` last.
```

## Persistent plugin data

Use `${CLAUDE_PLUGIN_DATA}` to store cached state that survives across plugin updates and sessions. This resolves to `~/.claude/plugins/data/claude-workflow/` — a directory created automatically on first use. Common uses include caching fetched data, compiled indexes, or installed dependencies.

When your hook or MCP server needs to detect updates and reinstall dependencies, use the diff-then-install pattern. This example checks if either the bundled manifest or its lockfile has changed and reinstalls `node_modules` only when needed:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "(diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 && diff -q \"${CLAUDE_PLUGIN_ROOT}/package-lock.json\" \"${CLAUDE_PLUGIN_DATA}/package-lock.json\" >/dev/null 2>&1) || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_ROOT}/package-lock.json\" . && npm ci) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package-lock.json\""
          }
        ]
      }
    ]
  }
}
```

Track the lockfile alongside `package.json`: a transitive-dependency bump may change `package-lock.json` while `package.json` stays the same, and skipping reinstall in that case leaves `${CLAUDE_PLUGIN_DATA}/node_modules` stale. Use `npm ci` (not `npm install`) so the install is deterministic against the lockfile. For other ecosystems, swap in the appropriate manifest/lockfile pair (`pnpm-lock.yaml` + `pnpm install --frozen-lockfile`, `yarn.lock` + `yarn install --immutable`, `requirements.txt`/`uv.lock`, etc.).

The `diff` chain exits nonzero when either stored copy is missing (first run) or differs from the bundled version (after an update), triggering reinstall. If installation fails, the trailing `rm` removes the stale manifests so the next session retries. Scripts can then reference the persisted `node_modules`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/server.js"],
      "env": {
        "NODE_PATH": "${CLAUDE_PLUGIN_DATA}/node_modules"
      }
    }
  }
}
```

## Parallelism decision

When authoring an orchestrator or designing a multi-skill workflow, you must make an explicit parallelism choice. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the full rubric — it defines Scope Assessment (Lightweight / Standard / Deep), TeamCreate decision criteria, and cost models for different primitives.

**Key decision points:**

- **Scope Assessment**: Classify before spawning. Lightweight runs inline; Standard/Deep trigger dispatch. See composition.md for heuristics and cost gradients.
- **Primitive choice**: Default to inline → subagent → TeamCreate. Parallel adds coordination overhead — confirm genuine communication pivot, file disjointness, classifiable parallelism, and ≥3× wall-clock payoff before paying the ~7× token premium.
- **Spawn justification**: Document your choice in the skill body. State which rubric factors apply and which don't. See the template below for the canonical shape.

New skills created via `/new-skill` will be guided through this decision during scaffolding.

### Spawn justification template

Every orchestrator or specialist that dispatches a team or subagents includes a `### Spawn justification` block. Copy this structure — apply each rubric criterion explicitly. Vague references make the gate opaque to future authors.

```markdown
### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **<team or session name>**: <shape — e.g. "2 parallel subagents", "TeamCreate at ≥3 splits", "researcher subagent → architect lead-inline → critic subagent">. Comm-pivot <✓|✗> (<one-clause why>), disjoint <✓|✗|n/a> (<why>), parallel <✓|✗> (<why>), payoff <≥3×|<3×> (<why>). Model: <model choice + one-clause rationale>. Fallback: <see options below>.
```

**`Fallback:` options** — each entry describes what runs when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is unset (the env-var prerequisite is documented once in composition.md, not per skill):

- `Fallback: sequential subagents` — degrade `TeamCreate` to one-at-a-time subagent dispatch.
- `Fallback: parallel subagents or sequential` — when the gate already chooses subagents at low scale, this just clarifies the further degradation path.
- `Fallback: n/a — no flag dependency` — for inline / interactive / single-subagent shapes that don't use `TeamCreate`. Use this exact wording so readers can grep for env-var-dependent skills.

**What stays per-skill**: the rubric application — comm-pivot, disjoint, parallel, payoff judgments are role-specific and load-bearing. Don't compress them. The boilerplate "fallback applies when env var unset" sentence is redundant with composition.md's prerequisite line and should be omitted.

See `skills/architecture/SKILL.md` and `skills/build/SKILL.md` for canonical examples.

## Naming conventions

- **Skill directory**: `skills/<name>/` — lowercase kebab-case, matches the `name` frontmatter field.
- **Entry point**: `skills/<name>/SKILL.md` — always `SKILL.md`, uppercase.
- **Bundled resources** (optional): `skills/<name>/references/`, `skills/<name>/scripts/`, `skills/<name>/assets/` — same sub-structure as the skill-creator standard.

## Length guidance

- Keep `SKILL.md` under 500 lines. If you're approaching this limit, split domain content into `references/` sub-files and link to them with clear "read when X" guidance.
- The body is loaded into context on every invocation — keep it focused on instructions, not background narrative.

### Progressive disclosure via `references/`

Use `references/` when a section is **>~40 lines**, runs only in a specific execution branch, and removing it doesn't break the default path. The trade-off: the main skill loads faster, but the reference loads only when that branch executes. See `skills/find-skills/references/`, `skills/compound/references/` for examples.

## Writing style

- Use imperative form: "Read the issue", "Spawn a team", not "You should read" or "The skill reads".
- Explain the _why_ behind non-obvious constraints. A rule without rationale becomes cargo cult.
- Avoid `ALWAYS` / `NEVER` in all-caps when a reasoned explanation works better — prefer "do X because Y" over "ALWAYS do X".
- No multi-paragraph docstrings or comment blocks. One short comment line max.

## Dogfooding this standard

The `/new-skill` scaffolder is itself written to conform to this standard. When extending this plugin, run `/new-skill` rather than copying an existing skill by hand.
