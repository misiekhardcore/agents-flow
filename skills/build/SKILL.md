---
name: build
description: Build a feature from a GitHub issue. Creates a git worktree and codes against acceptance criteria using TDD.
when_to_use: Use after /define has produced approved architecture decisions. Invoked automatically by /implement.
argument-hint: "[issue#]"
model: sonnet
---

You are leading the build phase. Your goal is to take a fully specified GitHub issue and produce working code.

## Input

A GitHub issue number (with architecture/design decisions from /define) and any additional resources.

## Scope Assessment

Classify the build before dispatching. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the right-sizing rationale.

1. **Lightweight** — single-file or tightly scoped change; AC fits in one module; no sub-issues.
   - Lead codes inline in the worktree. No team. TDD still applies to logic-heavy snippets.
2. **Standard** — typical feature with 2–3 natural work splits (sub-issues or distinct file groups).
   - Implementation team with one teammate per split.
3. **Deep** — epic with many sub-issues, cross-module work, or architecture-changing scope.
   - Larger implementation team; peer coordination via messages; lead merges results.

Decision tree:

1. Issue has zero sub-issues and the diff will live in one module? → Lightweight
2. Issue has 4+ sub-issues, or touches 3+ independent modules? → Deep
3. Otherwise → Standard

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Standard**: TeamCreate at ≥3 splits, else parallel subagents. Comm-pivot ✓ at scale, disjoint ✓, parallel ✓, payoff ≥3× only at ≥3 splits. Gate: ≥3 sub-issues OR ≥3 disjoint file groups. Fallback: parallel subagents or sequential.
- **Deep**: TeamCreate. All four ✓ for epics. Fallback: sequential subagents.

## Specialist mode

When invoked by `/implement` with a `<seed-brief>` block, skip:
- repo-preflight (already run by the orchestrator; `preflight_verified: true` is in the brief)
- scope-preflight (scope class is in the brief as `scope_class`)
- scope-class confirmation (the orchestrator has already classified)

Always keep: the design gate — architecture decisions must be cross-phase verified even when seeded.

Without a seed brief, run all prompts as described below. See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

## Process

### Step 0 — Pre-flight

See `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md`.
Confirmation prompt: "Does this match the repo and branch you intend to work on?"

See `${CLAUDE_PLUGIN_ROOT}/_shared/scope-preflight.md` and run it when its Trigger conditions apply.

### Steps 1+

1. Read the issue, all comments, and linked sub-issues to understand the full scope.

2. **Create a git worktree** for the feature (`git worktree add`). Worktrees keep the main workspace clean and let teammates operate in isolation. Lightweight still uses a worktree — the isolation is independent of team width.

   Before creating `./.claude/NOTES.md`, verify `/.claude/NOTES.md` is listed in the repo root `.gitignore`; add it there if missing. Then create `./.claude/NOTES.md` with the initial task list harvested from the issue. This is the living worklog for the phase — it survives unexpected session close and is the resume point if this session dies before `/wrap-up`. See `${CLAUDE_PLUGIN_ROOT}/_shared/notes-md-protocol.md`.

   **On resume in an existing worktree**, read `./.claude/NOTES.md` _before_ re-reading the issue — it has the latest in-flight state. Resume from its **Next action on resume** field.

3. **Implementation** — spawn workers per the Spawn justification block (Lightweight: inline; Standard/Deep: subagents or TeamCreate per gate).
   - Assign each worker a separate sub-issue or file group to avoid conflicts
   - With TeamCreate, teammates communicate peer-to-peer; with subagents, the lead merges results
   - The lead coordinates via the shared task list

4. Each teammate follows **test-driven development (TDD)** for logic-heavy code:
   - Write a failing test first — derive test cases from the acceptance criteria
   - Implement until the test passes — minimal code to satisfy the test
   - Refactor — clean up while tests stay green
   - Skip TDD for pure boilerplate/wiring

5. **Verify before marking done** — run `superpowers:verification-before-completion` after each task. Mandatory, no user approval needed; fix any gaps before committing.

6. **Simplify as you go** — after every 2-3 task completions from the task list, do a quick consolidation scan:
   - Review files you just touched for obvious duplication, dead code, or consolidation opportunities
   - This is NOT a full refactor — just a fast scan for low-hanging improvements
   - If found, create a micro-task to consolidate before proceeding to the next implementation task
   - Keep it lightweight: "scan for obvious duplication in files you just touched"

7. **Keep context focused.** Trigger on **concept shifts**, not on a percentage:
   - Stale tool results in context after the work has moved on → clear them with **context editing** (verbatim — the default tool).
   - About to read a large file or grep wide paths → delegate to a sub-agent that returns a focused report (the lead never accumulates the bulk).
   - About to start a new sub-issue, or just spawned a sub-agent → natural reset point.
   - If summarization-based `/compact` is unavoidable: flush the working set into `./.claude/NOTES.md` first, emit a `Keep: / Drop:` note, run `/compact`, then diff the post-compaction summary against the Keep list **in `.claude/NOTES.md`** before the next tool call.

   See `${CLAUDE_PLUGIN_ROOT}/_shared/compaction-protocol.md`. Context editing first, sub-agents second, `/compact` last.

8. Commit changes incrementally using semantic commit messages (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`). Update `./.claude/NOTES.md` after each completed task — it is the resume point if the session dies unexpectedly.

## Output

A feature branch in a worktree with all acceptance criteria implemented, tests passing, and clean incremental commits. Ready for /review.

## Rules

- Use superpowers:test-driven-development for the TDD workflow
- Use `git worktree add` / `git worktree remove` for worktree management. [worktrunk](https://github.com/max-sixty/worktrunk)'s `wt` wrapper is an optional convenience when installed; the skill assumes only the stock `git worktree` commands.
- Pick the spawn primitive per the Spawn justification block above. Lightweight codes inline.
- Do not ask the user whether to use teams — pick the scope and go
- Do not open a PR — that happens after /implement completes the full cycle
- Always run the 5-question verification check before marking a task done
- Consolidation scans are lightweight — spend seconds, not minutes
- Context hygiene is a build-time responsibility, not a wrap-up afterthought — trigger on concept shifts, not percentages, and never let auto-compact run unattended
- `./.claude/NOTES.md` is authoritative for in-flight state; if your recall disagrees with the file, trust the file
