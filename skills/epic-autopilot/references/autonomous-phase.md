# Epic-Autopilot: Stage 4 — Autonomous Phase

## Stage 4 — Autonomous phase

**No human prompts from this point forward until exit.**

### 4a. Epic branch creation

```
git checkout main && git pull
wt switch --create feat/epic-<N>
git commit --allow-empty -m "chore: open epic #<N>"
git push -u origin feat/epic-<N>
```

The epic branch must exist and be pushed before any sub-task spawns.

### 4b. Dependency-tier computation

Read each sub-issue body's `## Implementation plan` to extract the dependency graph. Build tiers using **Kahn's topological sort**:

1. Build adjacency: for each sub-issue M, parse its /define output for "depends on #<X>" references.
2. Compute in-degree for each node.
3. Tier 1 = nodes with in-degree 0. Assign to tier 1.
4. Remove tier-1 nodes; recompute in-degree. Tier 2 = new zero-in-degree nodes. Repeat until empty.
5. Ties within a tier: break by ascending sub-issue number.

**Cycle handling**: When Kahn's algorithm detects a cycle (zero-in-degree nodes exhaust while nodes remain with non-zero in-degree):

1. Among remaining nodes, pick the **highest-numbered** sub-issue `H`.
2. Among `H`'s declared dependencies, pick the **lowest-numbered** dependency `L`.
3. Drop `H`'s `depends on #L` declaration (decrement `H`'s in-degree).
4. Log to stdout: `Cycle broken: removed dep #<H> → #<L>`.
5. Resume Kahn's on modified graph.

**Branch base per sub-issue**:
- Tier-1 → base is `feat/epic-<N>`.
- Single-parent → base is that parent's branch.
- Multi-parent → base is the parent with lowest tier number; if multiple parents share lowest tier, choose **lowest-numbered** sub-issue among them. Document remaining parents in the sub-PR `## Notes` as manual merge steps.

### 4c. Parallel Task dispatch — per tier

For each tier in ascending order:

1. **Before dispatching tier T**, verify every tier-T−1 sub-task has settled (PR open or FAILED). Tier 1 has no prerequisite.
2. Dispatch all sub-tasks in current tier as parallel `Task` sub-agents **in a single message**. For each sub-issue M:
   - Emit: `[sub-issue #<M>] dispatched (tier <T>)`
   - Create worktree for branch `feat/epic-<N>-sub-<M>` on base `<base-branch>`. Invoke the worktree protocol (`Read @_shared/worktree-protocol.md`).
   - Dispatch `workflow-implement-runner` via the task tool with seed brief:
     - `repo`: owner/repo
     - `branch`: `feat/epic-<N>-sub-<M>`
     - `active_issue`: `<M>`
     - `max_cycles`: 3
     - `scope`: `"Sub-issue #<M> of epic #<N> — <title>"`
     - `payload.resources`: `[]`
     - `payload.progress`: NOTES.md slice with task list subset and decisions
     - `payload.prior_art`: `"Sub-issue #<M>'s ## Implementation plan (architecture and design decisions from /define)"`
     - `payload.open_questions`: unresolved constraints from /define for sub-issue #M, or empty

PR base is communicated via git upstream, not the brief. `/implement` detects it with `git rev-parse --abbrev-ref --symbolic-full-name @{u}` and passes `--base <detected>` to `gh pr create`.

3. Wait for all sub-agents in tier to settle before dispatching next tier.

### 4d. Sub-task settlement and failure handling

Each sub-agent runs `/implement` end-to-end and attempts to open a draft PR. The `autonomous: true` flag suppresses `/implement`'s exhausted-exit prompt, so a draft PR (even exhausted-accepted) settles successfully.

After each sub-task settles, emit one status line:
- Clean exit: `[sub-issue #<M>] PR opened: <url> (cycles:<N>)`
- Exhausted-accepted: `[sub-issue #<M>] PR opened: <url> (cycles:3 [exhausted-accepted])`
- FAILED: `[sub-issue #<M>] FAILED — second retry exhausted`

If a sub-agent **aborts**, retry exactly once with same seed brief (emit `[sub-issue #<M>] RETRYING (attempt 2/2)`); if retry also aborts, mark FAILED and continue siblings.

### 4e. Epic PR creation

After every sub-task across all tiers has settled (PR open or FAILED):

1. Push `feat/epic-<N>` to remote (empty commit pushed in 4a; push is no-op if already up-to-date).
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

Merge sub-PRs before the epic PR, in tier order. **GitHub does not auto-update child PR bases after a parent squash/rebase merge** — after each parent PR merges, update dependent branches manually.

## Follow-ups
<any FAILED sub-tasks, outstanding findings, or deferred work>

Closes #<N>
EOF
)"
```

3. Print epic PR URL and full sub-issue/sub-PR summary table to stdout.
4. Run `/compound` — epic-level learnings pass (autonomous). Epic-scoped context (architecture decisions, decomposition trade-offs, cross-sub-issue insights from Stages 1–4) is warm at this point.
