---
name: prune
description: Audit CLAUDE.md rules, authoring quality, and optionally the obsidian vault for staleness.
model: haiku
---
## Role & Constraints
Audit project rules and docs for staleness and authoring quality.

## Lanes
1. **Rules**: Audits `CLAUDE.md` (global/project), imports, and auto-memory.
2. **Authoring**: Checks `CLAUDE.md` / `AGENTS.md` / `SKILL.md` for structural quality based on Augment Code study.
3. **Vault**: (Optional) Delegates to `claude-obsidian:wiki-lint`.

## Process
**Dispatch**: Spawn 3 parallel Task sub-agents (one per lane). Each must start with `cd <abs-path> && pwd`.

### Rules Lane
1. **Gather**: Global `CLAUDE.md` → `@imports` → Project `CLAUDE.md` → `MEMORY.md` + topic files.
2. **Assess**: Does tool/command exist? Does pattern apply? Superseded? Redundant with built-in behavior?
3. **Auto-Memory**: Is info accurate? Redundant with `CLAUDE.md`?

### Authoring Lane
Enumerate all `CLAUDE.md`, `AGENTS.md`, `SKILL.md` files. Run 5 checks (Cite Augment Code study):
1. **Length Triage**: Flag if exceeds cap (Global: 50, Project: 200, Subdir: 50).
2. **Unpaired "Don't"**: Scan for `Don't`/`Avoid`/`Never` without a paired `Do`/`Always`/`Prefer` within 3 lines.
3. **Warning-Stack**: Flag if `Don't` lines $> 10$ (warning) or $> 30$ (error).
4. **Architecture Smell**: Headings like `Architecture`/`Overview` exceeding 30 lines → recommend relocation to reference file.
5. **Decision-Table**: Prose matching "Use X for A, use Y for B" (>= 3$ branches) → recommend table conversion.

### Vault Lane
- `claude-obsidian:wiki-lint` available → invoke it → flag obsolete concept/entity notes.
- Otherwise → skip and note installation prompt.

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
- **Conservative**: "Unclear" >=$ "Stale".
- **Aggregate Only**: Main thread synthesizes sub-agent output; no re-reading files.
- **Surgical**: Only list authoring findings; do not rewrite files.
