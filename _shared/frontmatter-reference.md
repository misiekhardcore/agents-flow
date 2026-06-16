# Frontmatter Field Reference

Canonical field registry for `agents-flow` — covers both Claude Code and opencode frontmatter for SKILL.md and agent `.md` files. Unknown fields are silently ignored by both tools.

## SKILL.md Fields

### Shared (both tools)

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Lowercase kebab-case, 1–64 chars. Must match directory name. |
| `description` | yes | 1–1024 chars. "Does X. Use when Y." — specificity matters. |

### Claude Code only

| Field | Required | Description |
|-------|----------|-------------|
| `when_to_use` | no | Routing hint: what this skill does NOT do and which skill handles it instead. Prevents mis-routing. |
| `argument-hint` | no | Positional argument hint e.g. `[issue#]`, `[PR# or URL]`. |
| `model` | no | `haiku` / `sonnet` / `opus`. Sets model per skill invocation. |
| `effort` | no | `low` / `high`. High for research-leading or multi-turn skills. |
| `allowed-tools` | no | Space-separated tool names to restrict tool surface. Omit for all tools. Eg `Agent Bash Read`. |
| `user-invocable` | no | `false` to hide from `/` slash-command menu. Defaults `true`. |
| `context` | no | `fork` — causes skill to run in separate context, preserving parent state. |
| `agent:` | no | `general-purpose` (writes) / `Explore` (read-only). Used with `context: fork`. |

### OpenCode only

| Field | Required | Description |
|-------|----------|-------------|
| `compatibility` | no | Space-separated tool IDs, e.g., `claude-code opencode`. Both tools ignore unknown fields, so listing compatibility is a human signal. |
| `metadata` | no | String-to-string map for arbitrary extra data. Eg `audience: maintainers`. |
| `license` | no | SPDX license identifier, e.g. `MIT`. |

## Agent `.md` Fields

### Shared (both tools)

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Claude Code: required. OpenCode: derived from filename. | Agent identifier. |
| `description` | yes | One sentence — what it does and when it's spawned. |
| `model` | no | Claude Code: `haiku`/`sonnet`/`opus`. OpenCode: `provider/model-id` format. |

### Claude Code only

| Field | Required | Description |
|-------|----------|-------------|
| `user-invocable` | no | `false` to hide from the user. |
| `disallowedTools` | no | Space-separated tool names the agent must not use. Eg `Agent AskUserQuestion Write Edit`. |
| `maxTurns` | no | Maximum conversation turns before forced response. |
| `background` | no | `true` for parallel execution workers. |
| `memory` | no | `project` — gives agent repo-level context. |

### OpenCode only

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `mode` | no | `primary`, `subagent`, `all` | Defaults `all`. `primary` = Tab-switchable; `subagent` = Task/@-invoke only; `all` = both. |
| `hidden` | no | `true`, `false` | Hide from `@` autocomplete. Only applies to `mode: subagent`. |
| `permission` | no | object | Tool permission overrides. Keys from permission table below. |
| `temperature` | no | 0.0–1.0 | Response randomness. Omit for model default. |
| `steps` | no | number | Max agentic iterations before forced text response. |
| `disable` | no | `true`, `false` | Disable the agent entirely. |
| `color` | no | hex or theme color | UI appearance. |
| `top_p` | no | 0.0–1.0 | Response diversity (alternative to temperature). |

## Permission Keys (OpenCode agents)

Valid keys for the `permission` field. Set each to `"allow"`, `"ask"`, or `"deny"`.

| Key | Tools it gates |
|-----|----------------|
| `read` | `read` |
| `edit` | `write`, `edit`, `apply_patch` |
| `glob` | `glob` |
| `grep` | `grep` |
| `list` | `list` |
| `bash` | `bash` |
| `task` | `task` (subagent spawning) |
| `external_directory` | Any tool reading/writing outside project worktree |
| `todowrite` | `todowrite`, `todoread` |
| `webfetch` | `webfetch` |
| `websearch` | `websearch` |
| `lsp` | `lsp` |
| `skill` | `skill` |
| `question` | `question` |
| `doom_loop` | Recovery prompts when agent appears stuck |

`read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `lsp`, `skill` accept a shorthand action (`"allow"|"ask"|"deny"`) or an object of glob/pattern → action for fine-grained control. The remaining keys accept shorthand only.

## Default Values by Role (Claude Code SKILL.md)

Default frontmatter values for each skill role. `/new-skill` uses these when generating a new SKILL.md.

| Field | Orchestrator | Specialist | Utility | Primitive | Protocol |
|-------|-------------|------------|---------|-----------|----------|
| `model` | `sonnet` | `sonnet` | `sonnet` | `sonnet` | `sonnet` |
| `effort` | omit | omit | omit | omit | omit |
| `allowed-tools` | omit | omit | omit | omit | omit |
| `user-invocable` | omit (defaults true) | omit | omit | omit | `false` |

See `_shared/AUTHORING.md` § Body Assembly by Role/Tier for the full role-to-template mapping.

## Field Mapping: Claude Code → OpenCode

| Concept | Claude Code field | OpenCode field |
|---------|------------------|----------------|
| Restrict tool surface | `allowed-tools: Bash Read` | `permission: { bash: "allow", read: "allow" }` — but prefer global permission config for this |
| Prevent subagent spawning | `disallowedTools: Agent` | `permission: { task: {"*": "deny"} }` |
| Prevent user questions | `disallowedTools: AskUserQuestion` | `permission: { question: "deny" }` |
| Prevent file writes | `disallowedTools: Write Edit` | `permission: { edit: "deny" }` |
| Hide from user | `user-invocable: false` | `mode: subagent` + `hidden: true` |
| Make user-facing | `user-invocable: true` (omit) | `mode: primary` |
| Max iterations | `maxTurns` | `steps` |
| Works in both | `mode: all` | (no Claude Code equivalent) |
