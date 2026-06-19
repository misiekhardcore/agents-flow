# Frontmatter Field Reference

Canonical field registry for `agents-flow` — covers opencode frontmatter for SKILL.md and agent `.md` files.

## SKILL.md Fields

|Field|Required|Description|
|-|-|-|
|`name`|yes|Lowercase kebab-case, 1–64 chars. Must match directory name.|
|`description`|yes|1–1024 chars. "Does X. Use when Y." — specificity matters.|
|`metadata`|no|String-to-string map for arbitrary extra data. Eg `audience: maintainers`.|
|`license`|no|SPDX license identifier, e.g. `MIT`.|

## Agent `.md` Fields

|Field|Required|Values|Description|
|-|-|-|-|
|`name`|derived from filename|—|Agent identifier.|
|`description`|yes|—|One sentence — what it does and when it's spawned.|
|`model`|no|`provider/model-id` format|Model override for the agent.|
|`mode`|no|`primary`, `subagent`, `all`|Defaults `all`. `primary` = Tab-switchable; `subagent` = Task/@-invoke only; `all` = both.|
|`hidden`|no|`true`, `false`|Hide from `@` autocomplete. Only applies to `mode: subagent`.|
|`permission`|no|object|Tool permission overrides. Keys from permission table below.|
|`temperature`|no|0.0–1.0|Response randomness. Omit for model default.|
|`steps`|no|number|Max agentic iterations before forced text response.|
|`disable`|no|`true`, `false`|Disable the agent entirely.|
|`color`|no|hex or theme color|UI appearance.|
|`top_p`|no|0.0–1.0|Response diversity (alternative to temperature).|

## Permission Keys (OpenCode agents)

Valid keys for the `permission` field. Set each to `"allow"`, `"ask"`, or `"deny"`.

|Key|Tools it gates|
|-|-|
|`read`|`read`|
|`edit`|`write`, `edit`, `apply_patch`|
|`glob`|`glob`|
|`grep`|`grep`|
|`list`|`list`|
|`bash`|`bash`|
|`task`|`task` (subagent spawning)|
|`external_directory`|Any tool reading/writing outside project worktree|
|`todowrite`|`todowrite`, `todoread`|
|`webfetch`|`webfetch`|
|`websearch`|`websearch`|
|`lsp`|`lsp`|
|`skill`|`skill`|
|`question`|`question`|
|`doom_loop`|Recovery prompts when agent appears stuck|

`read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `lsp`, `skill` accept a shorthand action (`"allow"|"ask"|"deny"`) or an object of glob/pattern → action for fine-grained control. The remaining keys accept shorthand only.

## Default Values by Role (SKILL.md)

opencode skill frontmatter = `name` + `description` only (+ optional `license`, `compatibility`, `metadata`). No model, effort, allowed-tools, or user-invocable. See `references/authoring.md` for body patterns by role.

See `references/authoring.md` § Body Assembly by Role/Tier for the full role-to-template mapping. See `references/opencode-config.md` for how these opencode frontmatter fields map to workflow conventions.
