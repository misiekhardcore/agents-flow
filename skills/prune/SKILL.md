---
name: prune
description: Audit skill authoring quality and prune dead state from ~/.claude/. Vault health is delegated to /lint.
model: haiku
effort: low
allowed-tools: Agent AskUserQuestion Bash Read
---
## Role & Constraints
Audit skill authoring quality and dead state in `~/.claude/`. Archive approved candidates — never delete.

## Lanes
1. **Authoring**: Checks `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality.
2. **Dead-state**: Audits global `~/.claude/` for dead project dirs, orphan agents, stale plugin caches, stale scheduled tasks, and sub-agent plan artifacts.

## Process

**Lane selection**: Ask the user which lanes to run before doing any work:

`AskUserQuestion` with `header: "Lanes"`, `multiSelect: true`, question: "Which audit lanes should I run?". Pre-select both. Options:
- **Authoring** — check `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality
- **Dead-state** — flag dead project dirs, orphan agents, stale plugin caches, stale schedules, and sub-agent artifacts in `~/.claude/`

**Dispatch**: Run `${PLUGIN_ROOT}/bin/list-prune-files --<lane>` from the project root for each selected lane to get a concrete file list, then spawn one Task sub-agent per selected lane in parallel.

Each spawn prompt must include: `lane` (authoring|dead-state), `cwd` (absolute project root path), `files` (pre-enumerated list above). Each must start with `cd <cwd> && pwd`.

Read `references/audit-checks.md` for Authoring Lane checks and Dead-state Lane classes.

## Aggregation & Archive

After sub-agents return:

**Authoring**: Report findings grouped by file (path, line, issue, recommendation).

**Dead-state**: Print candidates table (path | size | mtime | reason | suggested-action), grouped by scope. Regular plans: `suggested-action: keep`.

**Approval**: `AskUserQuestion` over candidates. Pre-select all `suggested-action: archive`.

**Archive** (approved items only):
- **Filesystem paths**: Ensure parent directory exists via `mkdir -p "$(dirname "$dst")"`, then `mv` to `${HOME}/.claude/archive/$(date -I)/${rel}`.
- **`scheduled_task:<cwd>` entries**: First copy `scheduled_tasks.json` to archive, then edit the original in place to remove entries. Print manifest: `removed entries: <cwd1>, <cwd2>, …`.

Never use `rm`. Print manifest per item.

## Rules
- **No Delete**: Archive only — never `rm` any file.
- **Aggregate Only**: Main thread synthesizes sub-agent output; no re-reading files.
- **Surgical**: Only list findings; do not rewrite files.
- **Vault**: Out of scope. Direct users to run `/lint` separately.
