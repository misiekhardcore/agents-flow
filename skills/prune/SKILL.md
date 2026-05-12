---
name: prune
description: Audit CLAUDE.md rule hygiene, skill authoring quality, and optionally the Obsidian vault for stale content.
model: haiku
effort: low
allowed-tools: Agent Bash Read
---
## Role & Constraints
Audit project rules and docs for staleness and authoring quality.

## Lanes
1. **Rules**: Audits `CLAUDE.md` (global/project), imports, and auto-memory.
2. **Authoring**: Checks `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality based on Augment Code study.
3. **Vault**: (Optional) Delegates to `claude-obsidian:wiki-lint`.

## Process

**Lane selection**: Ask the user which lanes to run before doing any work:

`AskUserQuestion` with `header: "Lanes"`, `multiSelect: true`, question: "Which audit lanes should I run?". Pre-select all three. Options:
- **Rules** — audit `CLAUDE.md` files, imports, and auto-memory for staleness
- **Authoring** — check `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality
- **Vault** — lint the Obsidian wiki for stale/orphaned content (requires claude-obsidian)

**Vault dependency check**: If Vault is selected, check whether the `claude-obsidian` plugin is installed (look for `claude-obsidian:wiki-lint` skill availability). If not installed, note "claude-obsidian not installed, skipping vault lane" and proceed with the remaining selected lanes only.

**Dispatch**: Run `bin/list-prune-files --<lane>` from the project root for each selected lane to get a concrete file list, then spawn one Task sub-agent per selected lane in parallel.

Each spawn prompt must include: `lane` (rules|authoring|vault), `cwd` (absolute project root path), `files` (pre-enumerated list above), `claude_obsidian_installed` (true/false; vault lane only). Each must start with `cd <cwd> && pwd`.

### Rules Lane
1. **Gather**: Global `CLAUDE.md` → `@imports` → Project `CLAUDE.md` → `MEMORY.md` + topic files.
2. **Assess**: Does tool/command exist? Does pattern apply? Superseded? Redundant with built-in behavior?
3. **Auto-Memory**: Is info accurate? Redundant with `CLAUDE.md`?

### Authoring Lane
Read each file in `files`. Run 5 checks (Cite Augment Code study):
1. **Length Triage**: Flag if exceeds cap (Global: 50, Project: 200, Subdir: 50, Shared: 100, `.claude/` files use Subdir: 50).
2. **Unpaired "Don't"**: Scan for `Don't`/`Avoid`/`Never` without a paired `Do`/`Always`/`Prefer` within 3 lines.
3. **Warning-Stack**: Flag if `Don't` lines > 10 (warning) or > 30 (error).
4. **Architecture Smell**: Headings like `Architecture`/`Overview` exceeding 30 lines → recommend relocation to reference file.
5. **Decision-Table**: Prose matching "Use X for A, use Y for B" (>= 3 branches) → recommend table conversion.

### Vault Lane
Invoke `claude-obsidian:wiki-lint` and flag obsolete/orphaned concept and entity notes.

## Classification & Output
**Classify Rule items**: `Current` | `Stale` | `Superseded` | `Unclear`.

**Final Report**:
- Total audited items.
- Items by classification.
- Authoring findings (grouped by file, cite source, specific issue).
- Vault results.
- Specific recommendations + suggested edits.

## Rules
- **No Auto-Delete**: Present recommendations → wait for approval.
- **Conservative**: "Unclear" >= "Stale".
- **Aggregate Only**: Main thread synthesizes sub-agent output; no re-reading files.
- **Surgical**: Only list authoring findings; do not rewrite files.
