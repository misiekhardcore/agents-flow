# CLAUDE.md — claude-workflow plugin

## Feature Workflow

Pick the lightest path that fits the task:

|Size|Path|
|-|-|
|Trivial fix|`/implement` directly|
|Medium feature|`/discovery` → `/implement`|
|Large feature / epic|`/discovery` → `/define` → `/implement`|

**Canonical example**: "Add a CSV export button to the reports page."
1. `/discovery` — interview the user, write the issue with acceptance criteria, get explicit approval.
2. `/implement` — `/build` codes against the issue with TDD, `/review` runs specialist reviewers, `/verify` checks each criterion, then PR.

Building blocks: `/describe`, `/specify`, `/architecture`, `/design`, `/build`, `/review`, `/verify`, `/grill-me`, `/wrap-up`, `/prune`, `/compound`.

For the full lifecycle — prerequisites, outcomes, handoffs — see `${CLAUDE_PLUGIN_ROOT}/docs/workflow.md`.

## Implementation Rules

- **Default to single-agent.** Use `TeamCreate` only for parallelizable work across 3+ independent files or sub-issues. Below that threshold, delegate bulk I/O work to Task sub-agents to prevent main-thread context overrun (see `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` § "Main-thread overrun").
- **Use the cheapest viable model.** Skills set their own `model:` and `effort:` — trust them.
- **Respond concisely.** No filler, no preamble.

## Token budgets

Per-artifact and per-phase budgets, CLAUDE.md placement, `@`-imports: `${CLAUDE_PLUGIN_ROOT}/docs/token-budgets.md`.

## Authoring New Skills

Run `/new-skill` to scaffold a conformant `SKILL.md`. For the full authoring standard — template shape, `_shared/` conventions, naming rules — see `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md`.

## Plugin path variables

**`${CLAUDE_PLUGIN_ROOT}`** — the plugin installation directory. Skills reference shared protocols via `${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md`. Fallback: if not expanded inline, skills reference `_shared/<file>.md` and Claude resolves via glob against `~/.claude/plugins/cache/<marketplace>/claude-workflow/<version>/`.

**`${CLAUDE_PLUGIN_DATA}`** — persistent directory (`~/.claude/plugins/data/claude-workflow/`) for cached state surviving plugin updates. See `_templates/AUTHORING.md` for the diff-then-install pattern when detecting dependency updates.
