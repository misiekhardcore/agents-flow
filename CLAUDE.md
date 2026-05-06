# CLAUDE.md — claude-workflow plugin

Guidance for Claude Code when the claude-workflow plugin is active.

## Feature Workflow

Pick the lightest path that fits the task:

| Size                 | Path                                    |
| -------------------- | --------------------------------------- |
| Trivial fix          | `/implement` directly                   |
| Medium feature       | `/discovery` → `/implement`             |
| Large feature / epic | `/discovery` → `/define` → `/implement` |

For the full lifecycle walkthrough — prerequisites, outcomes, and handoffs for each step — see `${CLAUDE_PLUGIN_ROOT}/docs/workflow.md`.

### Canonical example — medium feature

> User: "Add a CSV export button to the reports page."
>
> 1. `/discovery` — interview the user, write the issue with acceptance criteria, get explicit approval.
> 2. `/implement` — `/build` codes against the issue with TDD, `/review` runs specialist reviewers, `/verify` checks each criterion, then PR.

The building blocks: `/describe`, `/specify`, `/architecture`, `/design`, `/build`, `/review`, `/verify`, `/grill-me`, `/wrap-up`, `/prune`, `/compound`.

## Implementation Rules

- **Default to single-agent.** Use `TeamCreate` only for parallelizable work across 3+ independent files or sub-issues.
- **Use the cheapest viable model.** Skills set their own `model:` and `effort:` — trust them.
- **Respond concisely.** No filler, no preamble.

## Token budgets

Per-artifact and per-phase budgets, CLAUDE.md placement, and `@`-imports: `${CLAUDE_PLUGIN_ROOT}/docs/token-budgets.md`.

## Authoring New Skills

To scaffold a new skill conforming to this standard, run `/new-skill`. It will interview you, generate a conformant `SKILL.md`, and write it to your chosen location.

For the full authoring standard — template shape, `_shared/` file conventions, naming rules — see `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md`.

## Plugin path variables

**`${CLAUDE_PLUGIN_ROOT}`** — the plugin's installation directory. Skills reference shared protocols via `${CLAUDE_PLUGIN_ROOT}/_shared/<file>.md`. If your Claude Code version does not expand this variable inline in skill body text, the fallback convention is: skills reference `_shared/<file>.md` and Claude resolves the path by globbing against the plugin cache at `~/.claude/plugins/cache/<marketplace>/claude-workflow/<version>/`.

**`${CLAUDE_PLUGIN_DATA}`** — a persistent directory (`~/.claude/plugins/data/claude-workflow/`) for cached state that survives plugin updates. Use it for installed dependencies, compiled indexes, or cached fetched data. See `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md` for the diff-then-install pattern when detecting dependency updates.
