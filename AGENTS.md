# AGENTS.md — claude-workflow plugin

## Repository type

This is a **Claude Code skills plugin** installed via `claude plugin marketplace add misiekhardcore/claude-workflow`. It is not a standalone app — skills live at `skills/<name>/SKILL.md` and are loaded by Claude Code at invocation time.

## Commands

|Command|What it does|
|-|-|
|`npm run format`|Minifies all `.md` files via `bin/minify-md -i -r .`|
|`npm run prepare`|Installs husky git hooks|

Pre-commit runs `npx lint-staged` which runs `bin/minify-md -i -r` on staged `.md` files — do not fight the minifier.

No tests exist. No test framework. CI only runs `npm run format` on PRs to `main`.

## Release (manual workflow_dispatch)

Version lives in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (both `metadata.version` and `plugins[0].version`). They must stay in lockstep. The Release workflow bumps all three, commits, tags, and creates a GitHub release.

**Do not bump `package.json` (0.0.1) during release** — it is internal and independent of the plugin version (currently 1.6.2).

## Feature workflow

Pick the lightest path that fits the task:

|Size|Path|
|-|-|
|Trivial fix|`/implement` directly|
|Medium feature|`/discover` → `/implement`|
|Large feature / epic|`/discover` → `/define` → `/implement`|

Building blocks: `/describe`, `/specify`, `/architecture`, `/design`, `/build`, `/review`, `/verify`, `/grill-me`, `/wrap-up`, `/prune`, `/compound`. For the full lifecycle see `${CLAUDE_PLUGIN_ROOT}/docs/workflow.md`.

During `/define` or `/discover` exploration: time-box codebase reading to 3–5 tool calls, then ask the user a focused question.

## Architecture

- **Skills**: 26 skill dirs under `skills/`. Each has a `SKILL.md` (the actual skill body). Some also have `agents/` (worker agent files) and `references/` (per-skill static docs).
- **Shared protocols**: `_shared/*.md` — reference docs, not skills. Use `Read` not `Skill()` to access them.
- **Templates**: `_templates/` — scaffolding skeletons for new skills (`AUTHORING.md` is the canonical authoring guide).
- **Bin tools**: `bin/minify-md` (markdown minifier), `bin/list-prune-files` (used by `/prune` skill).
- **Git worktrees**: `.worktrees/` dir, managed via `wt` CLI. Always create before writing code, remove after PR is open.
- **`.claude/settings.local.json`**: Local permissions overlay (gitignored in practice, though not in .gitignore).

## Key conventions

- **Single-agent by default.** Parallel agents only for 2+ independent file groups, sub-issues, or tasks.
- **Worker SKILLs** (not agent files) get `context: fork` and explicit `agent:` type (`Explore` for read-only, `general-purpose` for writes/gh). Agent files use `background: true` and `memory: project`.
- **Preflight before gh/git push.** Invoke `Skill("preflight")` — verifies repo, branch, CWD. Spawned workers skip preflight.
- **NOTES.md** at `.claude/NOTES.md` is the in-phase progress ledger (gitignored). Create on entry, checkpoint before spawn, update on return, leave for the phase-ending skill.
- **Seed-brief** (`_shared/seed-brief.md`) packages spawn-time context as YAML in XML. Used by orchestrators when spawning agents. NOT for mid-cycle state (use NOTES.md) or phase-to-phase handoff (use issue body).
- **SKILL.md vs agent files**: SKILL.md owns process flow and spawn instructions. Agent files own the seed-brief I/O contract (input fields, output format). Never inline the contract in SKILL.md — reference the agent file. Agent file headings use `## Input (from spawn prompt)`. SKILL.md uses `## Worker Agent Inventory` with per-agent subsections.
- **Handoff artifact** (`_shared/handoff-artifact.md`): five-field issue body structure (AC, Constraints, Prior decisions, Evidence, Open questions) for cross-phase state transfer.
- **No autonomous merge.** Exit cleanly at awaiting-merge. Merging is always human.
- **No issue body updates for intra-orchestrator state.** The five-field shape is for phase boundaries only.
- **`/discovery` → `/discover` rename**. Skill lives at `skills/discover/`. The `/discover` command is now the correct entry point.

## Authoring new skills

Run `/new-skill` to scaffold a conformant `SKILL.md`. For the full authoring standard see `${CLAUDE_PLUGIN_ROOT}/_shared/AUTHORING.md`.

Token budgets per artifact/phase, CLAUDE.md placement rules, `@`-imports: `${CLAUDE_PLUGIN_ROOT}/docs/token-budgets.md`.

## Plugin path variables

- `${CLAUDE_PLUGIN_ROOT}` — plugin install dir. Skills reference `_shared/` via `${CLAUDE_PLUGIN_ROOT}/_shared/<file.md>`. Fallback: if not expanded inline, skills use `_shared/<file.md>` and Claude resolves via glob against `~/.claude/plugins/cache/<marketplace>/<version>/`.
- `${CLAUDE_PLUGIN_DATA}` — `~/.claude/plugins/data/claude-workflow/` for persistent cached state.

## Existing instruction files

- `CLAUDE.md` — symlink to this file, kept for tool compatibility.
- `AGENTS.md` (this file) — repo-specific facts an agent would guess wrong without help.

## Rules

- `.gitignore` entries: `.claude/NOTES.md`, `.worktrees/`, `node_modules/` — do not commit these.
- Skills specify their own `model:` and `effort:` in frontmatter — trust them.
- Orchestrator SKILL.md must be ≤ 150 lines. No inline domain work — delegate.
- Worker agents should include `disallowedTools: Agent` to prevent recursive spawning.
- **Persist lessons to AGENTS.md**: When you discover a project-level convention, gotcha, or architecture rule that future agents would benefit from, add it to this file under the relevant section. NOTES.md is ephemeral session scratch — durable knowledge lives here.
- **Update docs with code**: Any change to a skill, agent, or command must update all related docs (README.md, docs/*.md, AGENTS.md, other skills referencing it) in the same commit. Stale docs rot faster than dead code.
