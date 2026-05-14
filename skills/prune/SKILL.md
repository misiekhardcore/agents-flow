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

**Dispatch**: Run `bin/list-prune-files --<lane>` from the project root for each selected lane to get a concrete file list, then spawn one Task sub-agent per selected lane in parallel.

Each spawn prompt must include: `lane` (authoring|dead-state), `cwd` (absolute project root path), `files` (pre-enumerated list above). Each must start with `cd <cwd> && pwd`.

### Authoring Lane
Read each file in `files`. Run 5 checks (Cite Augment Code study):
1. **Length Triage**: Flag if exceeds cap (Global: 50, Project: 200, Subdir: 50, Shared: 100, `.claude/` files use Subdir: 50).
2. **Unpaired "Don't"**: Scan for `Don't`/`Avoid`/`Never` without a paired `Do`/`Always`/`Prefer` within 3 lines.
3. **Warning-Stack**: Flag if `Don't` lines > 10 (warning) or > 30 (error).
4. **Architecture Smell**: Headings like `Architecture`/`Overview` exceeding 30 lines → recommend relocation to reference file.
5. **Decision-Table**: Prose matching "Use X for A, use Y for B" (>= 3 branches) → recommend table conversion.

### Dead-state Lane
Always audits global `~/.claude/` regardless of CWD. Flags the following classes:
- `~/.claude/projects/<encoded>/` dirs whose encoded CWD does not resolve to any directory on disk.
- `.jsonl` transcripts inside those flagged directories.
- `~/.claude/agents/*.md` files not referenced by any installed skill, `settings*.json`, or recent transcript.
- `~/.claude/plugins/cache/<plugin>/<version>/` dirs whose version is not the currently installed one.
- `~/.claude/scheduled_tasks.json` entries pointing at a CWD that no longer exists.
- `~/.claude/plans/*-agent-<hex>.md` files (sub-agent spawn artifacts). Always candidates.

Regular plans (`~/.claude/plans/*.md` without `-agent-` suffix) are listed informational-only with `mtime`, size, and first H1/first-line snippet. `suggested-action: keep`.

## Aggregation & Archive

After both sub-agents return:

**Authoring output**: Report findings grouped by file (path, line, issue, recommendation).

**Dead-state output**: Print full candidate table grouped by scope (`current project` / `other projects`):

```
path | size | mtime | reason | suggested-action
```

Regular plans appear in the table with `suggested-action: keep` and a snippet.

**Approval gate**: Single `AskUserQuestion` over the full dead-state candidate table. Question: "Which items should be archived?". `multiSelect: true`. Pre-select all `suggested-action: archive` items. If the user excludes any, drop those paths before proceeding.

**Archive step** (for approved items only):
```bash
archive_root="${HOME}/.claude/archive/$(date -I)"
# for each approved path <src>:
rel="${src#${HOME}/.claude/}"
dst="${archive_root}/${rel}"
mkdir -p "$(dirname "$dst")"
mv "$src" "$dst"
echo "${src} → ${dst}"
```

Never use `rm`. Print a manifest of moved paths (`src → dst` per line).

## Classification & Output
**Classify Authoring items**: `Current` | `Stale` | `Superseded` | `Unclear`.

**Final Report**:
- Authoring findings (grouped by file, cite source, specific issue).
- Dead-state archive manifest (or "No items archived.").
- Specific recommendations + suggested edits.

## Rules
- **No Delete**: Archive only — never `rm` any file.
- **Conservative**: "Unclear" >= "Stale".
- **Aggregate Only**: Main thread synthesizes sub-agent output; no re-reading files.
- **Surgical**: Only list authoring findings; do not rewrite files.
- **Vault**: Vault health is out of scope. Direct users to run `/lint` separately.
