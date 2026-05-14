# Build Skill — Scope Assessment & Process Details

## Scope Assessment

Classify the build per criteria below:

|Scope|Criteria|Team|
|-|-|-|
|Lightweight|Single-file or tightly scoped; AC fits one module; no sub-issues|Code inline, no team|
|Standard|2–3 natural work splits (sub-issues or distinct file groups)|Implementation team, one teammate per split|
|Deep|Many sub-issues, cross-module work, or architecture-changing scope|Larger implementation team; peer coordination|

### Decision Tree

1. Zero sub-issues and diff in one module? → Lightweight
2. 4+ sub-issues or touches 3+ independent modules? → Deep
3. Otherwise → Standard

### Spawn Justification

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Standard**: TeamCreate at ≥3 splits, else parallel subagents.
- **Deep**: TeamCreate.

## Specialist Mode

When invoked by `/implement` with a `<seed-brief>` block, skip:
- repo-preflight (already run; `preflight_verified: true` in brief)
- scope-preflight (scope class in brief as `scope_class`)
- scope-class confirmation

Always keep: the design gate — architecture decisions must be verified cross-phase even when seeded.

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

## Process Steps

### Step 0 — Pre-flight

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md`.
Confirmation prompt: "Does this match the repo and branch you intend to work on?"

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/scope-preflight.md` — run when Trigger conditions apply.

### Step 1 — Issue Review

Read the issue, all comments, and linked sub-issues to understand the full scope.

### Step 2 — Git Worktree & Task List

Create a git worktree (`wt switch --create`). Worktrees keep the main workspace clean and let teammates operate in isolation. Lightweight still uses a worktree.

Before creating `./.claude/NOTES.md`, verify `/.claude/NOTES.md` is listed in `.gitignore` at repo root; add if missing. Create `./.claude/NOTES.md` with the initial task list harvested from the issue. This is the living worklog — it survives unexpected session close.

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/notes-md-protocol.md`.

**On resume in an existing worktree**, read `./.claude/NOTES.md` _before_ re-reading the issue. Resume from its **Next action on resume** field.

### Step 3 — Spawn Workers

Spawn workers per the Scope Assessment:
- **Lightweight**: Code inline, no team.
- **Standard**: Implementation team or parallel subagents (one per sub-issue or file group).
- **Deep**: TeamCreate for larger teams.

With TeamCreate, teammates communicate peer-to-peer; with subagents, the lead merges results. Coordinate via the shared task list.

### Step 4 — Test-Driven Development

Each teammate follows **test-driven development (TDD)** for logic-heavy code:
- Write failing test first — derive from acceptance criteria.
- Implement until test passes — minimal code.
- Refactor — clean up while tests stay green.
- Skip TDD for pure boilerplate/wiring.

### Step 5 — Verify Before Marking Done

Run `superpowers:verification-before-completion` after each task. Mandatory; fix any gaps before committing.

### Step 6 — Simplify as You Go

After every 2-3 task completions, scan for obvious duplication, dead code, or consolidation opportunities in touched files. Not a full refactor — just fast low-hanging fruit. If found, create a micro-task to consolidate before proceeding.

### Step 7 — Context Hygiene

Keep context focused. Trigger on **concept shifts**, not percentages:
- Stale tool results after work has moved on → clear with context editing.
- About to read a large file or grep wide → delegate to sub-agent that returns focused report.
- About to start a new sub-issue or just spawned a sub-agent → natural reset.
- If `/compact` is unavoidable: flush working set into `./.claude/NOTES.md`, emit `Keep: / Drop:` note, run `/compact`, diff post-compaction summary against Keep list in `./.claude/NOTES.md` before next tool call.

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/compaction-protocol.md`. Context editing first, sub-agents second, `/compact` last.

### Step 8 — Incremental Commits & Notes

Commit changes incrementally using semantic messages (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`). Update `./.claude/NOTES.md` after each completed task — resume point if session dies.

## Output

A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for /review.

## Rules

- Use `superpowers:test-driven-development` for the TDD workflow.
- Use `wt switch --create` / `wt remove` for worktree management.
- Pick the spawn primitive per the Scope Assessment. Lightweight codes inline.
- Do not ask the user whether to use teams — pick the scope and go. Pick inline / subagent / team based on the Scope Assessment table above.
- Do not open a PR — that happens after /implement completes the full cycle.
- Always run the 5-question verification check before marking a task done.
- Consolidation scans are lightweight — spend seconds, not minutes.
- Context hygiene is a build-time responsibility — trigger on concept shifts, not percentages. Trigger `/compact` automatically at concept shifts; delegate bulk I/O to sub-agents before context overruns.
- `./.claude/NOTES.md` is authoritative for in-flight state; if your recall disagrees, trust the file.
