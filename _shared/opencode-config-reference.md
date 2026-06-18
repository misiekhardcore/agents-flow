# Opencode Config & Permission Reference

## Permission Levels

Every `permission` key in opencode agent frontmatter accepts one of three values:

|Value|Meaning|
|-|-|
|`"allow"`|Allow without asking|
|`"ask"`|Ask user for approval|
|`"deny"`|Deny outright|

Permission keys and their gated tools are documented in `_shared/frontmatter-reference.md` (§ Permission Keys).

## Agent Frontmatter Fields

|Field|Required|Values|Description|
|-|-|-|-|
|`mode`|no|`primary`, `subagent`, `all`|`primary` = Tab-switchable; `subagent` = Task/@-invoke only; `all` = both. Default `all`.|
|`model`|no|`provider/model-id`|Model override (cross-reference `_shared/frontmatter-reference.md` for Claude Code model syntax).|
|`permission`|no|object|Tool permission overrides per the Permission Keys table in `frontmatter-reference.md`.|
|`tools`|no|list of tool names|Tool allowlist (opencode equivalent of Claude Code's `allowed-tools`).|
|`template`|no|file path|Prompt template file path.|
|`prompt`|no|string|Inline system prompt override.|
|`temperature`|no|0.0–1.0|Response randomness. Omit for model default.|
|`maxSteps`|no|number|Max agentic iterations before forced text response.|
|`hidden`|no|`true`, `false`|Hide from `@` autocomplete. Only for `mode: subagent`.|
|`disable`|no|`true`, `false`|Disable the agent entirely.|
|`color`|no|hex or theme color|UI appearance.|
|`top_p`|no|0.0–1.0|Response diversity (alternative to temperature).|

## Command Frontmatter Fields

|Field|Required|Values|Description|
|-|-|-|-|
|`name`|yes|lowercase kebab-case|Command name (slug used in `/` invocation).|
|`description`|yes|string|Short description shown in command palette.|
|`model`|no|`provider/model-id`|Model override for the command.|
|`prompt`|no|string|Inline system prompt.|
|`template`|no|file path|Prompt template file.|
|`permission`|no|object|Tool permission overrides for command execution.|
|`temperature`|no|0.0–1.0|Response randomness.|
|`maxSteps`|no|number|Max iterations.|
|`hidden`|no|`true`, `false`|Hide from command palette.|
|`disable`|no|`true`, `false`|Disable command.|

## Naming Reconciliation

The IgorWarzocha/Opencode-Workflows repo uses different names for some fields. Cross-reference when working with both sources:

|Our field|Their field|Notes|
|-|-|-|
|`maxSteps`|`steps`|Same semantics — max iterations before forced response|
|`edit` (permission key)|`write`/`patch`|Their permission system splits write and patch; ours uses `edit` for both (`write`, `edit`, `apply_patch` tools)|

## Cross-Reference

See `_shared/frontmatter-reference.md` for:
- The full permission key table with tool mappings
- Claude Code ↔ OpenCode field mapping table
- Per-role default values by field
