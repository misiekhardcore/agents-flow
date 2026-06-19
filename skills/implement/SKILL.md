---
name: implement
description: Full implementation cycle — build, review, and verify, then open a PR.
when_to_use: Use to run the full implementation cycle (build → review → verify → PR) from an approved issue.
argument-hint: "[issue#]"
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR. Delegates all phase work to sub-skills and worker agents — never codes, reviews, or runs tests inline.

Adopt the "orchestrator-rules" skill for checkpoint, NOTES.md, and seed-brief conventions.

Read `references/scope.md` for work-unit types.

## Process

### 1. Entry
Load the "orchestrator-rules", "notes-md", and "preflight" skills (the last with `suppress branch line: true`). Create `.claude/NOTES.md`.

### 2. Ingestion
Read issue body (`## Requirements`, `## Implementation plan`). If plan absent and non-trivial → prompt: "Run `/define` first, or confirm this is trivial." If trivial → proceed as single-unit.

### 3. Scope
Build work units from sub-issues and file groups. Invoke the "scope-assessment" skill with work units (each with `id` and `resources`) → receive agent plan of disjoint groups. Single-unit (no sub-issues, no disjoint file groups) → one group, run the loop directly. Multi-unit → one loop per disjoint group.

### 4. Worktree
Invoke the "worktree" skill to create or verify the implementation worktree.

### 5. Handoff
Read `_shared/handoff-artifact.md` at this point. Ensure issue body has the five-field structure (AC, Constraints, Prior decisions, Evidence, Open questions).

### 6. Build → review → verify loop
Per disjoint group, run a bounded loop (3-cycle hard stop per `references/scope-cycles.md`), dispatching leaf workers directly — no intermediate runner:
1. **Build**: spawn `workflow-build-worker` via the task tool with a `<seed-brief>` (`repo`, `branch`, `active_issue`, `scope`, `payload` = resources + NOTES.md progress slice).
2. **Review**: invoke the "review" skill (dispatch_mode: fix-brief) — it dispatches `workflow-reviewer` per activated focus and returns merged findings.
3. **Verify**: invoke the "verify" skill — it dispatches `workflow-reviewer focus: correctness` per AC group and returns the pass/fail report.
4. **Evaluate**: clean pass → step 7; findings present & cycle < 3 → write fix brief to NOTES.md, resume; cycle = 3 → step 7 with remaining findings surfaced.

Checkpoint NOTES.md before each spawn. See `_shared/seed-brief.md` for seed-brief format and `@_shared/composition.md` for spawn cost models.

### 7. PR creation
From the worktree root: harvest `## Decisions made this session` + `## Open questions` from `.claude/NOTES.md`; push the branch; resolve base (`git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`); `gh pr create --draft --base <base>` with `## Summary`, `## Testing notes`, `## Notes`; then delete `.claude/NOTES*.md`.

### 8. Compound
Read `_shared/compound-on-exit.md`. On clean completion, invoke the "compound" skill exactly once. No invocation on abort or early exit.

### 9. Finalize
Present PR URL. If findings remain after 3 cycles → binary: "Continue loop, or accept and close?" On continue → one more cycle → log escalation in PR body.

<rules>
<constraint>MUST NOT prompt the user between sub-skills.</constraint>
<constraint>MUST NOT open a PR before a clean pass OR 3 cycles are exhausted.</constraint>
<constraint>Each cycle MUST address ALL previous findings.</constraint>
<critical>MUST NOT trigger an autonomous merge — exit at the awaiting-merge stage; NEVER trigger a merge.</critical>
<constraint>MUST checkpoint NOTES.md before every spawn. See the "orchestrator-rules" skill § Progress tracking.</constraint>
</rules>

<guidelines>
<recommendation>Read at point of need, do not preload: `_shared/seed-brief.md` before spawning workers, `_shared/composition.md` when sizing team shape, `_shared/compound-on-exit.md` before the compound step, `references/scope-cycles.md` when evaluating cycles.</recommendation>
</guidelines>
