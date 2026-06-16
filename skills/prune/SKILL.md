---
name: prune
description: Audit skill authoring quality and prune dead state from ~/.claude/. Vault health is delegated to /lint.
model: haiku
effort: low
allowed-tools: Agent AskUserQuestion Bash Read
compatibility: claude-code opencode
---
Audit skill authoring quality and prune dead state from `~/.claude/`. Archive approved candidates — never delete.

## Pre-flight

Invoke `Skill("preflight")` at entry for repo verification.

## Lanes

1. **Authoring** — Checks `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality.
2. **Dead-state** — Audits global `~/.claude/` for dead project dirs, orphan agents, stale plugin caches, stale scheduled tasks, and sub-agent plan artifacts.

## Process

### 1. Lane selection

`AskUserQuestion` with `header: "Lanes"`, `multiSelect: true`, question: "Which audit lanes should I run?". Pre-select both. Options:
- **Authoring** — check `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality
- **Dead-state** — flag dead project dirs, orphan agents, stale plugin caches, stale schedules, and sub-agent artifacts in `~/.claude/`

### 2. Enumerate

Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` § Main-Thread Overrun to confirm delegation threshold.

Run `${PLUGIN_ROOT}/bin/list-prune-files --<lane>` from the project root for each selected lane to get a concrete file list.

### 3. Dispatch

Read `${CLAUDE_PLUGIN_ROOT}/_shared/dispatch-decision.md` § Role taxonomy and `isolation: worktree`.

Spawn one `Agent("agents/workflow-prune-auditor.md")` per selected lane in parallel. Each spawn must include a seed-brief:

```
<seed-brief>
repo: <owner/repo via git remote -v>
branch: <branch via git rev-parse --abbrev-ref HEAD>
payload:
  lane: <authoring|dead-state>
  cwd: <absolute project root>
  files:
    <path1>
    <path2>
</seed-brief>
```

See `${CLAUDE_PLUGIN_ROOT}/_shared/seed-brief.md` for the YAML packaging convention.

Files per lane are disjoint, so parallel dispatch is safe. Each must start with `cd <cwd> && pwd`. Checkpoint NOTES.md before each spawn per `Skill("orchestrator-rules")` § Progress tracking.

### 4. Aggregate

After sub-agents return:

**Authoring**: Report findings grouped by file (path, line, issue, recommendation).

**Dead-state**: Print candidates table (path | size | mtime | reason | suggested-action), grouped by scope. Regular plans: `suggested-action: keep`.

**Approval**: `AskUserQuestion` over candidates. Pre-select all `suggested-action: archive`.

### 5. Archive (approved items only)

- **Filesystem paths**: `mkdir -p "$(dirname "$dst")"`, then `mv` to `${HOME}/.claude/archive/$(date -I)/${rel}`.
- **`scheduled_task:<cwd>` entries**: Copy `scheduled_tasks.json` to archive first, then edit the original in place to remove entries. Print manifest: `removed entries: <cwd1>, <cwd2>, …`.

Print manifest per item.

## Rules
- **No Delete**: Archive only — never `rm` any file.
- **Aggregate Only**: Main thread synthesizes sub-agent output; no re-reading files.
- **Surgical**: Only list findings; do not rewrite files.
- **Vault**: Out of scope. Direct users to run `/lint` separately.
- **Seed-brief required**: Every `Agent()` spawn must include a seed-brief with repo, branch, and payload (see § Dispatch).
- **NOTES.md**: Follow `Skill("orchestrator-rules")` § Progress tracking via NOTES.md — checkpoint before every spawn, update on return.
