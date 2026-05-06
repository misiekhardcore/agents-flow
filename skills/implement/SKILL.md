---
name: implement
description: Full implementation cycle — build, review, and verify a feature from a GitHub issue, then open a PR.
argument-hint: "[issue#]"
model: sonnet
---

You are orchestrating the full implementation cycle. Your goal is to take a fully defined GitHub issue and produce a ready-to-merge PR.

## Input

A GitHub issue number (with architecture/design decisions from /define) and any additional resources (docs, API specs, etc.).

## Scope Assessment

Classify the work before dispatching. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the right-sizing rationale.

1. **Lightweight** — single-file fix, typo, docstring, rename, config tweak; AC list has 1–2 items; no logic changes.
   - Run `/build` inline (no implementation team); skip `/review` as a separate team; run a single inline AC check in place of `/verify`.
2. **Standard** — typical multi-file feature with acceptance criteria spanning one module.
   - Full build → review → verify cycle with the default team widths each sub-skill picks.
3. **Deep** — cross-module, security-sensitive, migration, or breaking change; AC list spans multiple areas.
   - Full cycle with `/review` at Deep scope and extra critique iterations allowed before escalation.

Decision tree:

1. Diff will be under ~50 lines with no logic changes? → Lightweight
2. Touches auth/security, migrations, public APIs, or performance-critical paths? → Deep
3. Otherwise → Standard

**Design gate** (Standard / Deep only):

Once you've assessed the scope as **Standard** or **Deep**, inspect the GitHub issue body for a `## Implementation plan` section containing architecture and design decisions from `/define`. If absent:
- **Pause** and prompt: _"No architecture/design decisions recorded on this issue. Run `/define` first, or confirm this is a trivial enough change to skip the gate."_
- If the user confirms this is trivial enough (typo, single-line fix, etc.), downgrade to **Lightweight** scope and proceed.
- Otherwise, wait for the user to run `/define`.

Skip this gate for **Lightweight** scope.

## Pre-flight

Run `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md` once at entry.
Suppress branch line: true

Run `${CLAUDE_PLUGIN_ROOT}/_shared/scope-preflight.md` if the file list is 3 or more files. Pass `preflight_verified: true` in every seed brief issued to specialists — they skip their own preflight when this flag is set.

## Process

**Autonomy contract**: inside a single `/implement` invocation, run build → review → verify → fix cycles back-to-back without asking the user between sub-skills. The only user-interrupt point is after the PR is opened and the cycle has either (a) passed clean, (b) exhausted 3 cycles with findings remaining, or (c) hit a blocker the sub-skill cannot resolve. Status updates during the loop are informational only — do **not** end them with a question.

**Seed-brief handling**: when invoked by an orchestrator (e.g. `/epic-autopilot`) with a `<seed-brief>` block, read the `autonomous` field at startup — default `false` when absent or when no seed brief is present. This flag affects only the Finalize block; all build→review→verify cycles run identically regardless. See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

### Lightweight

1. Auto-run `/build` — lead codes inline in the worktree, no team spawn, TDD only for logic-heavy snippets.
2. Auto-run an inline AC self-check — walk every acceptance criterion against the diff and the running code; skip the `/review` and `/verify` team spawns.
3. Fall through to the **PR creation** block, then the **Finalize** block. No prompts in between.

### Standard / Deep — autonomous cycle: build → review → verify

Construct a seed brief for each specialist at spawn time:

```
<seed-brief>
preflight_verified: true
scope_class: <Lightweight|Standard|Deep>
repo: <owner/repo>
branch: <feat/slug>
active_issue: <N>
payload:
  type: <fix|research>
  # type-specific fields per _shared/composition.md
</seed-brief>
```

1. Auto-run `/build` — spawns implementation team (or runs inline per `/build`'s own Scope Assessment), codes against the issue. Pass a seed brief with `type: research` and the issue's architectural context.
2. Auto-run `/review` — spawns review team; Deep scope triggers `/review`'s Deep mode (all specialists, `opus`). Pass a seed brief with `type: research` (diff + AC).
3. Auto-run `/verify` — spawns QA team, verifies every acceptance criterion. Pass a seed brief with `type: research` (diff + AC + test commands).
4. **Evaluate findings** (no user prompt):
   - **Clean pass** (`/review` and `/verify` both return no issues) → exit loop, fall through to **PR creation**.
   - **Findings present** and cycle count < 3 → package a **fix brief** (failing criteria + reviewer findings as `file:line` + prior architectural decisions; no review/verify session history). Before re-entering `/build`, write the fix brief to `./.claude/NOTES.md` and follow `${CLAUDE_PLUGIN_ROOT}/_shared/compaction-protocol.md` — context editing first (clear cycle N tool outputs already acted on), sub-agent delegation second, `/compact` last resort. After compaction, resume from the fix brief in NOTES.md. Then auto-feed to `/build`, auto-re-run `/review` and `/verify`. Do not ask the user to confirm the next iteration.
   - **Findings present** and cycle count = 3 → exit loop with findings attached; fall through to **PR creation** and surface the remaining findings in the finalize step.

Progress reporting during the loop: emit one status line per cycle (`Cycle N/3 — /build <state>, /review <n findings>, /verify <n failures>`) so the user can follow along, but never pause for input.

### PR creation (after the loop exits — clean or exhausted)

Run these steps automatically, without asking:

**All git and `gh` commands in this block must run from within the worktree root** (`cd <worktree-root>` before the first command if the shell's CWD is not already there). Running from the main repo directory fails because `gh pr create` uses the current directory's branch, which would be `main`.

1. Read `<worktree-root>/.claude/NOTES.md` if it exists. Harvest `## Decisions made this session` and `## Open questions` — these flow into the PR body's `## Notes` section.
2. Push the branch to remote.
3. Resolve the PR base. Run `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null` — if it returns an upstream like `origin/<base>`, strip the `origin/` prefix and use `<base>` as the PR base. If no upstream is configured (standalone invocation in a fresh feature branch), default to the repo's default branch (typically `main`). Stacked-branch orchestrators (e.g. `/epic-autopilot`) pre-set the upstream so the sub-PR targets the correct parent branch.
4. Open a draft PR (`gh pr create --draft --base <resolved-base>`) with the body shape below. Link to the issue:
   - `Closes #<issue>` — if this is the only/final PR for the issue.
   - `Related to #<issue>` — if this is a partial implementation.

**PR body shape:**

```markdown
## Summary
<1-2 sentences: what was implemented, why, ACs satisfied>

## Testing notes
<repro steps, env setup, expected behavior — concrete enough that a reviewer can verify locally>

## Notes
<free-form prose, with bullet lists where natural; absorbs assumptions, uncertainties, follow-ups, outstanding findings from NOTES.md harvest and any exhausted-exit findings>
```

`## Notes` is omitted entirely when there is nothing to note (no NOTES.md content, no outstanding findings).

5. Run `/compound` — autonomous, reads the cycle context and any remaining NOTES.md content, files durable learnings to the wiki via `claude-obsidian:save` when the plugin is installed (otherwise returns the note inline).
6. Delete `<worktree-root>/.claude/NOTES.md`.
7. Exit with PR URL and any outstanding findings.

### Finalize

One deterministic finalize block follows PR creation. Branch on the loop's exit state:

- **Clean exit** (no remaining findings) → present the PR URL to the user. `/compound` has already run autonomously.
- **Exhausted exit** (3 cycles consumed, findings remain):
  - If `autonomous: true` (from seed brief) → skip the prompt; execute the Accept / close branch unconditionally; emit one status line: `autonomous accept: 3 cycles, <N> findings flowed into PR body ## Notes`. `/compound` has already run autonomously. Done.
  - If `autonomous: false` (default) → present the PR URL plus the outstanding findings to the user and ask a single binary question: **"Continue the implementation loop, or accept this PR and close out?"**
    - **Accept / close** → `/compound` has already run autonomously. Done.
    - **Continue** → run one more build → review → verify cycle, then return to this finalize block. Each continuation is a new escalation — log it explicitly in the PR description under `## Notes` before re-entering the loop.

## Output

A draft PR linking the issue (`Closes #N` or `Related to #N`) with acceptance criteria met (or with an explicit outstanding findings block in `## Notes` if the user accepted an exhausted exit), a Testing notes section with concrete repro steps, and `/compound` run (filed or inline). No handoff artifact beyond the PR — this is the terminal phase.

## Rules

- **Never prompt between sub-skills.** Build → review → verify → fix cycles and the PR / `/compound` finalize chain all run without asking. The only permitted user-interrupt is the single binary question after an **exhausted exit** (3 cycles with findings remaining) — suppressed when `autonomous: true` is set in the seed brief.
- Run repo-preflight once at entry; pass `preflight_verified: true` to every specialist via seed brief.
- Do not open a PR until both /review and /verify pass clean (Standard/Deep) **or** the cycle has exhausted 3 iterations with findings attached. Lightweight scope opens the PR after the inline AC self-check.
- Maximum 3 build→review→verify cycles before escalating; escalation is the one-question finalize prompt, not per-cycle approval. Lightweight never cycles — if it fails the inline check, upgrade to Standard and restart.
- Each cycle must address **all** findings from the previous cycle; partial fixes do not count as a cycle.
- Emit one status line per cycle for user visibility (`Cycle N/3 — …`). Status lines are informational and must never end with a question.
- `/compound` runs automatically after PR creation. It owns its own prompts; `/implement` does not wrap it in additional confirmations.
- Do not call `/wrap-up`. It is a user-invoked utility — the user invokes it when ready to clean up the worktree and branch.
- In-phase state lives in `./.claude/NOTES.md` (read by `/build` on resume) and in the issue body (cross-phase). See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md`.
- The issue body after `/implement` contains only `## Requirements` (from `/discovery`) and `## Implementation plan` (from `/define`). Do not write a `## Session handoff` block.
