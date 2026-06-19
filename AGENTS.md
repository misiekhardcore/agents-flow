# AGENTS.md — agents-flow

## Repository type

This is a skill/agent collection for AI coding agents. Skills live at `skills/<name>/SKILL.md`, agents at `agents/*.md`.

## Install

```bash
bin/install
```

Symlinks `commands/`, `agents/`, `skills/` into `~/.config/opencode/` (or `$XDG_CONFIG_HOME/opencode`). Idempotent — re-run safely. Use `bin/install --uninstall` to remove only symlinks pointing back into this repo.

## Commands

|Command|What it does|
|-|-|
|`/discover`|Full discovery phase — explore a problem and produce a GitHub issue with AC.|
|`/define`|Lead definition phase — resolve architecture and design technical decisions.|
|`/implement`|Full implementation cycle — build, review, and verify, then open a PR.|
|`npm run format`|Minifies all `.md` files via `bin/minify-md -i -r .`|
|`npm run prepare`|Installs husky git hooks|
|`./bin/install`|Symlinks `commands/`, `agents/`, `skills/` into opencode config dir|
|`make test-install-smoke`|Runs install smoke test against throwaway XDG_CONFIG_HOME|
|`make test-install-docker`|Runs install smoke test in a fresh Ubuntu container|

Pre-commit runs `npx lint-staged` which runs `bin/minify-md -i -r` on staged `.md` files — do not fight the minifier.

Smoke tests at `tests/install-smoke.sh`. CI runs format check + install smoke on PRs to `main`. The lifecycle commands (`/discover`, `/define`, `/implement`) are auto-discovered by opencode from `commands/` — no config registration needed.

## Feature workflow

Pick the lightest path that fits the task:

|Size|Path|
|-|-|
|Trivial fix|`/implement` directly|
|Medium feature|`/discover` → `/implement`|
|Large feature / epic|`/discover` → `/define` → `/implement`|

Building blocks: `/describe`, `/specify`, `/architecture`, `/design`, `/grill-me`, `/wrap-up`, `/prune`, `/compound`. For the full lifecycle see `docs/workflow.md`.

During `/define` or `/discover` exploration: time-box codebase reading to 3–5 tool calls, then ask the user a focused question.

## Architecture

- **Skills**: 22 skill dirs under `skills/`. Each has a `SKILL.md` (the actual skill body). Some also have `references/` (per-skill static docs).
- **Commands**: `commands/` at repo root — opencode command files.
- **Agent files**: `agents/` at repo root — 16 agent files: the discover/define/implement orchestrators (`mode: primary`) plus 15 leaf worker agents, one per single-responsibility role. Dispatch is a single tier — orchestrators spawn leaf workers directly; no intermediate runner agents.
- **Shared protocols**: Protocol behaviors are skills (allowlisted per-agent). Reference docs live in skill-local `references/` dirs. `_shared/notes-md-protocol.md` is the sole remaining shared doc (S6 territory).
- **Templates**: `_templates/` — scaffolding skeletons for new skills (`AUTHORING.md` is the canonical authoring guide).
- **Bin tools**: `bin/minify-md` (markdown minifier), `bin/list-prune-files` (used by `/prune` skill), `bin/install` (opencode symlink installer).
- **Git worktrees**: `.worktrees/` dir, managed via `wt` CLI. Implementation MUST run in a worktree created before any code write. A draft PR MUST be open before any terminal/yield. Remove worktree after PR is open.

### Skill-name registry

Canonical surviving skills post-S5. Orchestrator/agent `permission.skill` allowlists reference exactly these names.

| Skill name | Description (lazy-advertised ~100 tok) | Primary consumer(s) |
|---|---|---|
| `orchestrator-rules` | Standard directives for pipeline orchestrators coordinating specialist sub-skills. | all orchestrators |
| `notes-md` | In-phase NOTES.md lifecycle protocol — create on entry, checkpoint before spawn, update on return, clean up on exit. | all orchestrators |
| `preflight` | Repository and scope verification protocol before mutations or bulk file edits. | all orchestrators |
| `compound` | Capture learnings from completed work into durable wiki notes. Delegates to /save when agents-memo is available. | all orchestrators |
| `worktree` | Worktree lifecycle protocol — always create a worktree before writing code, remove after PR is open. | implement-orchestrator |
| `scope-assessment` | Given a list of work units (each with an id and resource list), group them by shared resources and output one agent entry per conflict-free group. | implement-orchestrator, define-orchestrator |
| `describe` | Explore and understand a problem space interactively. Uses visualizations and user stories to build shared understanding. | discover-orchestrator |
| `specify` | Turn a problem statement into precise, testable acceptance criteria. | discover-orchestrator |
| `architecture` | Decide on technical architecture for a feature (components, data flow, APIs, dependencies). | define-orchestrator |
| `design` | Explore visual and UX design (UI layouts, interaction flows, component structure). | define-orchestrator |
| `grill-me` | Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. | define-orchestrator, standalone |
| `interviewing-rules` | Atomic-question interview protocol for user-interactive discovery. One question at a time, explicit approval only, evidence-first. | discover-orchestrator, new-skill |
| `handoff-artifact` | Phase-boundary handoff protocol — five-field issue body structure (AC, Constraints, Prior decisions, Evidence, Open questions) for cross-phase state transfer. | all orchestrators |
| `compaction-protocol` | Context management protocol for rot reduction using editing, delegation, and summarization. | utility |
| `new-skill` | Scaffold a conformant SKILL.md. Interviews the author, generates the file, writes it. | standalone |
| `find-skills` | Discover and install agent skills when the user asks if Claude can do something or wants to extend capabilities. | standalone |
| `prune` | Audit skill authoring quality and prune dead state from ~/.claude/. | standalone |
| `audit-issues` | Audit open GitHub issues for drift against repo state. Flags broken refs, stale claims, and contradictions. | standalone (S9 will convert) |
| `resolve-pr-feedback` | Process PR review feedback in bulk — triage, fix in parallel, and reply with verdicts. | standalone (S9 will convert) |
| `issue-autopilot` | Single-issue equivalent of /epic-autopilot. Chains /define → /implement → /resolve-pr-feedback → /compound → /wrap-up for one issue. | standalone (S7 will consolidate) |
| `epic-autopilot` | Autonomous epic-to-PR pipeline. Chains /discover → /define → /implement end-to-end for each sub-issue, opening draft PRs. | standalone (S7 will consolidate) |
| `wrap-up` | Clean up local state after a PR is open — remove the worktree, delete the branch, and clear NOTES.md. | standalone |

## Key conventions

- **Single-agent by default.** Parallel agents only for 2+ independent file groups, sub-issues, or tasks.
- **Worker SKILLs** run autonomously in isolation — the SKILL.md body becomes the task prompt.
- **Preflight before gh/git push.** Invoke the "preflight" skill — verifies repo, branch, CWD. Spawned workers skip preflight.
- **NOTES.md** at `.claude/NOTES.md` is the in-phase progress ledger (gitignored). Create on entry, checkpoint before spawn, update on return, leave for the phase-ending skill.
- **Seed-brief** — spawn-time context packaged as raw YAML inside a `<seed-brief>` XML block in the agent's prompt. Fields: `repo` (owner/repo), `branch` (feat/slug), `payload` (research, prior art, findings). Single input → one-line inline; multiple inputs → structured YAML block. NOT for mid-cycle state (use NOTES.md) or phase-to-phase handoff (use issue body). Verify `repo` and `branch` against `git` before constructing.
- **SKILL.md vs agent files**: SKILL.md owns process flow and spawn instructions. Agent files own the seed-brief I/O contract (input fields, output format). Never inline the contract in SKILL.md — reference the agent file. Agent file headings use `## Input (from spawn prompt)`. SKILL.md uses `## Worker Agent Inventory` with per-agent subsections.
- **Handoff artifact** (`_shared/handoff-artifact.md`): five-field issue body structure (AC, Constraints, Prior decisions, Evidence, Open questions) for cross-phase state transfer.
- **No autonomous merge.** Exit cleanly at awaiting-merge. Merging is always human.
- **No issue body updates for intra-orchestrator state.** The five-field shape is for phase boundaries only.
- **`/discovery` → `/discover` rename**. Skill lives at `skills/discover/`. The `/discover` command is now the correct entry point.

## Authoring new skills

Run `/new-skill` to scaffold a conformant `SKILL.md`. For the full authoring standard see `skills/new-skill/references/authoring.md`.

Token budgets per artifact/phase, instruction file placement rules, `@`-imports: `docs/token-budgets.md`.

## Shared protocol access

Protocol behaviors are opencode skills — load via the skill tool, allowlisted in agent frontmatter. Reference docs live in skill-local `references/` dirs.

| Protocol / reference | Access |
|---|---|
| Interviewing rules | `skill("interviewing-rules")` |
| Handoff artifact | `skill("handoff-artifact")` |
| Orchestrator rules | `skill("orchestrator-rules")` |
| Seed-brief format | AGENTS.md § Key Conventions — Seed-brief |
| Worktree CLI | `skills/worktree/references/protocol.md` |
| Spawn cost models | `skills/compound/references/composition.md` |
| NOTES.md protocol | `_shared/notes-md-protocol.md` |
| Authoring guide | `skills/new-skill/references/authoring.md` |

## Existing instruction files

- `AGENTS.md` (this file) — repo-specific facts an agent would guess wrong without help. Loaded by opencode; referenced by other AI coding agents.

## Rules

- `.gitignore` entries: `.claude/NOTES.md`, `.worktrees/`, `node_modules/` — do not commit these.
- Orchestrator agents (`mode: primary`) drive the process and own the loop. They delegate domain work to sub-skills and subagents. Orchestrator SKILL.md files must be ≤ 150 lines.
- Worker agents should include `permission: { task: {"*": "deny"}, question: "deny" }` to prevent recursive spawning and user interaction.
- **Persist lessons to AGENTS.md**: When you discover a project-level convention, gotcha, or architecture rule that future agents would benefit from, add it to this file under the relevant section. NOTES.md is ephemeral session scratch — durable knowledge lives here.
- **Update docs with code**: Any change to a skill, agent, or command must update all related docs (README.md, docs/*.md, AGENTS.md, other skills referencing it) in the same commit. Stale docs rot faster than dead code.
- **XML-tag names in issue/PR bodies → HTML entities in prose**: raw `<tag>` is stripped by both GitHub rendering and the MCP read-back (so read-modify-write loses it). Write `&lt;tag&gt;` in prose — not in backticks (entities stay literal inside code spans). N/A to artifact bodies (commands/agents/skills): they keep raw angle brackets for opencode.
