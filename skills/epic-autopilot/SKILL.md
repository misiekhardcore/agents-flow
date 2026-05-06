---
name: epic-autopilot
description: Autonomous epic-to-PR pipeline. Chains /discovery → /define → /implement end-to-end for each sub-issue, opening draft PRs.
when_to_use: Use when you have an epic issue number or a free-text description and want the full cycle automated.
argument-hint: "[epic# | description]"
model: opus
effort: high
---

You are orchestrating the autonomous epic-to-PR pipeline. Your goal is to take an epic GitHub issue (or a free-text description) and produce a set of draft sub-PRs plus a top-level epic PR, with no human prompts after the per-sub-issue /define gates.

## Input

A single argument — either:

- **Positive integer** → treated as an existing GitHub epic issue number. Parse: `int(arg) > 0`.
- **Any other string** → treated as a free-text description; `/discovery` will create the epic issue from it.

## Scope Assessment

Always **Deep** — this is a fanout orchestrator. No inline path exists; the skill always spawns sub-agents.

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Per-sub-issue /define gate**: sequential single-subagent per sub-issue (one at a time). Comm-pivot ✗ (no mid-task coordination), disjoint n/a, parallel ✗ (user approval required between each), payoff n/a. Model: sonnet. Fallback: n/a — no flag dependency.
- **Autonomous phase — parallel Task sub-agents per tier**: one Task sub-agent per sub-issue within a tier, dispatched in a single message. Comm-pivot ✗ (sub-issues are disjoint; lead aggregates at settle), disjoint ✓ (each sub-agent works on a separate branch and sub-issue), parallel ✓ (tier-independent sub-issues), payoff ≥3× (wall-clock on ≥3 sub-issues). Model: opus per sub-agent (inherits from `/implement`'s own model). Fallback: sequential subagents.

## Process

### Stage 0 — Resume detection

On every invocation, read the epic issue body and any sub-issue bodies first; consult the **Resume logic** table at the bottom of this skill to decide which stage to enter.

### Stage 1 — Discovery gate

If input is a positive integer and the epic issue has a well-formed `## Requirements` section (non-empty, at least 3 acceptance criteria), skip /discovery and go to Stage 2.

Otherwise:
1. Run `/discovery` on the epic (or free-text description). This is interactive — /discovery will interview the user and write the issue body.
2. **Pause for explicit user approval.** Present: "Discovery complete. Review the issue body above. Approve to continue to /define, or provide feedback."
3. Wait for explicit approval before proceeding. Silence is not approval.

### Stage 2 — Epic-level /define gate

1. Run `/define` on the epic issue. This is interactive — /define will produce architecture decisions, create sub-issues with linked-issue relationships, and update the issue body.
2. **Pause for explicit user approval.** Present: "Epic /define complete. Review the sub-issues and implementation plan above. Approve to continue to per-sub-issue /define, or provide feedback."
3. Wait for explicit approval before proceeding.

After approval, read the epic issue body and extract the list of sub-issues (GitHub issue numbers). If `/define` produced **≤1 sub-issue**:
- Print: `Decomposition produced ≤1 sub-issue — running /implement directly on #<N>`
- Invoke `/implement` on the epic in the lead session (interactive, no `autonomous: true`, no epic branch).
- Exit. Do not proceed to Stage 3.

### Stage 3 — Per-sub-issue /define gate

For each sub-issue in order (ascending issue number):

1. Check if this sub-issue already has `## Implementation plan` in its body. If yes, skip (already defined in a prior run).
2. Spawn a fresh subagent to run `/define` on this sub-issue. The subagent must finish completely before the next sub-issue's gate runs — these are sequential, not parallel.
3. After the subagent returns, **pause for explicit user approval.** Present: "Sub-issue #<M> /define complete. Review the implementation plan above. Approve to continue to the next sub-issue, or provide feedback."
4. Wait for explicit approval before moving to the next sub-issue.

Once every sub-issue has an approved `## Implementation plan`, proceed to **Stage 4 — Autonomous phase**. No further human prompts are emitted until exit.

### Stage 4 — Autonomous phase

**No human prompts from this point forward until exit.**

#### 4a. Epic branch creation

```
git checkout main && git pull
git checkout -b feat/epic-<N>
git commit --allow-empty -m "chore: open epic #<N>"
git push -u origin feat/epic-<N>
```

The epic branch must exist and be pushed before any sub-task spawns.

#### 4b. Dependency-tier computation

Read each sub-issue body's `## Implementation plan` to extract the dependency graph (which sub-issues each sub-issue depends on). Build tiers using **Kahn's topological sort**:

```
1. Build adjacency: for each sub-issue M, parse its /define output for "depends on #<X>" references.
2. Compute in-degree for each node.
3. Tier 1 = nodes with in-degree 0. Assign to tier 1.
4. Remove tier-1 nodes; recompute in-degree. Tier 2 = new zero-in-degree nodes. Repeat until empty.
5. Ties within a tier: break by ascending sub-issue number.
```

**Cycle handling**: Kahn's algorithm detects a cycle when the worklist of zero-in-degree nodes empties while one or more nodes still have non-zero in-degree (i.e., not every node has been emitted into a tier). When this happens, break a cycle deterministically:

1. Among the remaining (non-zero in-degree) nodes, pick the **highest-numbered** sub-issue `H` — this is the dependent that will be detached.
2. Among the dependencies declared by `H`, pick the **lowest-numbered** dependency `L`.
3. Drop `H`'s `depends on #L` declaration (decrement `H`'s in-degree by one).
4. Log to stdout: `Cycle broken: removed dep #<H> → #<L>` (where `→` reads as "depends on", matching how the relationship was declared in `H`'s `## Implementation plan`).
5. Resume Kahn's on the modified graph. Repeat the cycle-break step if another cycle remains, until every node is assigned a tier.

**Branch base per sub-issue**:
- Tier-1 → base is `feat/epic-<N>`.
- Single-parent sub-issue → base is that parent's branch (`feat/epic-<N>-sub-<parentM>`).
- Multi-parent sub-issue → base is the parent with the lowest tier number (most foundational); if multiple parents share the lowest tier, break the tie by choosing the **lowest-numbered** sub-issue among them (matches the ascending-issue-number tie-break used in tier computation, so base selection is deterministic across runs). Document remaining parents in the sub-PR `## Notes` as manual merge steps.

#### 4c. Parallel Task dispatch — per tier

For each tier, in ascending tier order:

1. **Before dispatching tier T**, verify every tier-T−1 sub-task has settled (PR open or FAILED). Tier 1 has no prerequisite.
2. Dispatch all sub-tasks in the current tier as parallel `Task` sub-agents **in a single message**. For each sub-issue M in the tier:
   - Emit: `[sub-issue #<M>] dispatched (tier <T>)`
   - Create the worktree and branch from the base computed in 4b, with upstream tracking set so `/implement` can resolve the PR base later: `git worktree add .worktrees/feat/epic-<N>-sub-<M> -b feat/epic-<N>-sub-<M> <base-branch>`, then in the worktree run `git branch --set-upstream-to=origin/<base-branch>` (or push and `--track`-equivalent — the upstream must reflect the base, not `main`).
   - Pass the following seed brief to the sub-agent's `/implement` invocation. Fields under `payload` follow the canonical **research brief** in `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` — only the fields epic-autopilot can populate are emitted; the others are intentionally omitted (`/implement` reads the rest from the sub-issue body it loads at startup):

```
<seed-brief>
preflight_verified: true
scope_class: Deep
repo: <owner/repo>
branch: feat/epic-<N>-sub-<M>
active_issue: <M>
autonomous: true
payload:
  type: research
  prior_art: "Sub-issue #<M>'s ## Implementation plan in its issue body (architecture and design decisions from /define)"
  open_questions: "<any unresolved constraints surfaced during /define for sub-issue #<M>, or empty>"
</seed-brief>
```

The PR base for the sub-task is **not** carried in the brief — it is communicated via the worktree's git upstream. `/implement` detects it with `git rev-parse --abbrev-ref --symbolic-full-name @{u}` and passes `--base <detected>` to `gh pr create`. This keeps the brief schema aligned with `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`'s research-brief contract.

3. Wait for all sub-agents in the tier to settle before dispatching the next tier.

#### 4d. Sub-task settlement and failure handling

Each sub-agent runs `/implement` end-to-end and attempts to open a draft PR. The `autonomous: true` flag in the seed brief suppresses `/implement`'s exhausted-exit prompt, so a draft PR (even exhausted-accepted with findings) settles successfully.

After each sub-task settles, emit one status line:
- Clean exit: `[sub-issue #<M>] PR opened: <url> (cycles:<N>)`
- Exhausted-accepted: `[sub-issue #<M>] PR opened: <url> (cycles:3 [exhausted-accepted])`
- FAILED: `[sub-issue #<M>] FAILED — second retry exhausted`

If a sub-agent **aborts** (returns an error or fails to open a PR), retry exactly once with the same seed brief (emit `[sub-issue #<M>] RETRYING (attempt 2/2)`); if the retry also aborts, mark FAILED and continue sibling sub-tasks.

#### 4e. Epic PR creation

After every sub-task across all tiers has settled (PR open or FAILED):

1. Push `feat/epic-<N>` to remote (the empty commit was pushed in 4a; push is a no-op if already up-to-date).
2. Open a draft epic PR:

```
gh pr create --draft \
  --base main \
  --head feat/epic-<N> \
  --title "feat: epic #<N> — <epic title>" \
  --body "$(cat <<'EOF'
## Summary
<1–3 sentences: what the epic delivers, which sub-issues are included>

## Sub-issues and sub-PRs

| Sub-issue | PR | Status |
|-----------|-----|--------|
| #<M> <title> | <PR url or FAILED> | <clean / exhausted-accepted / FAILED> |
...

## Merge order

Merge sub-PRs before the epic PR, in tier order: tier-1 → tier-2 → … → epic.
**GitHub does not auto-update child PR bases after a parent squash/rebase merge** — after each parent PR merges, update dependent branches manually (`git rebase` or `git merge`).

## Follow-ups
<any FAILED sub-tasks, outstanding findings, or deferred work>

Closes #<N>
EOF
)"
```

3. Print the epic PR URL and the full sub-issue/sub-PR summary table to stdout.

### Stage 5 — Exit

Print exit summary to stdout and exit. The run is complete when all sub-PRs have been opened (clean / exhausted-accepted / FAILED) and the epic PR is open. Merging is left to humans.

## Resume logic

On re-invocation with the same epic issue number, epic-autopilot detects prior state and skips completed phases:

| State detected | Action |
|----------------|--------|
| No `## Requirements` in epic body | Re-run from Stage 1 |
| `## Requirements` but no `## Implementation plan` | Re-run from Stage 2 |
| `## Implementation plan` present | Skip Stages 1–2; check sub-issues |
| Sub-issue has `## Implementation plan` | Skip per-sub-issue /define for that sub-issue |
| Sub-issue has open PR on its branch | Sub-task settled; skip |
| Sub-issue has branch but no open PR | Re-run `/implement` in the existing worktree for that sub-issue |
| Sub-issue has neither branch nor PR | Fresh sub-task spawn |

A permanently-FAILED sub-task (branch exists, no PR, two prior retries) will be re-attempted on every resume. To skip it permanently, manually delete the branch and mark the sub-issue with a `skip` label before re-invoking.

## Rules

- Require explicit user approval at each gate (Stage 1, Stage 2, and each Stage 3 sub-issue). Silence is not approval.
- The user must not modify the epic issue body or any sub-issue body during Stage 4. Sub-agents read at spawn time and do not re-fetch mid-run.
- Sub-issue branch and worktree names follow the pattern `feat/epic-<N>-sub-<M>` exactly. M is the GitHub sub-issue number (globally unique), so names are collision-safe across parallel spawns.
- `autonomous: true` in the seed brief is reserved for sub-task spawns from this skill. Do not pass it from any other orchestrator — the default `false` preserves `/implement`'s exhausted-exit rigor gate.
- `/compound` and `/wrap-up` are not run by epic-autopilot — they remain user-invoked utilities.
- See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md` for the `autonomous` seed-brief field contract.
- See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the orchestration-depth and Task sub-agent rules.
