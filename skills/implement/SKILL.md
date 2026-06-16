---
name: implement
description: Full implementation cycle — build, review, and verify, then open a PR.
when_to_use: Use to run the full implementation cycle (build → review → verify → PR) from an approved issue.
argument-hint: "[issue#]"
model: sonnet
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
compatibility: claude-code opencode
---
Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR. Delegates all phase work to sub-skills and worker agents — never codes, reviews, or runs tests inline.

Adopt `Skill("orchestrator-rules")` for checkpoint, NOTES.md, and seed-brief conventions.

Read `references/scope.md` for work-unit types.

## Process

### 1. Entry
Invoke `Skill("orchestrator-rules")`, `Skill("notes-md")`, `Skill("preflight")` (with `suppress branch line: true`). Create `.claude/NOTES.md`.

### 2. Ingestion
Read issue body (`## Requirements`, `## Implementation plan`). If plan absent and non-trivial → prompt: "Run `/define` first, or confirm this is trivial." If trivial → proceed as single-unit.

### 3. Scope
Build work units from sub-issues and file groups. Invoke `Skill("scope-assessment")` with work units (each with `id` and `resources`) → receive agent plan of disjoint groups. Single-unit (no sub-issues, no disjoint file groups) → one runner directly. Multi-unit → one runner per disjoint group.

### 4. Worktree
Invoke `Skill("worktree")` to create or verify the implementation worktree.

### 5. Handoff
Read `_shared/handoff-artifact.md` at this point. Ensure issue body has the five-field structure (AC, Constraints, Prior decisions, Evidence, Open questions).

### 6. Delegate
Per disjoint group, spawn `Agent("agents/workflow-implement-runner.md")` with seed-brief containing `repo`, `branch`, `active_issue`, `max_cycles: 3`, `scope`, and `payload` (resources + NOTES.md progress slice). See `_shared/seed-brief.md` for seed-brief format and `agents/workflow-implement-runner.md` for the runner I/O contract. Runner handles build → review → verify cycles internally (3-cycle hard stop per `references/scope-cycles.md`).

Each `Agent()` spawn includes a `<seed-brief>` YAML block per `_shared/seed-brief.md`.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

### 7. Collect
Wait for runner return. Collect PR URL and findings.

### 8. Compound
Read `_shared/compound-on-exit.md`. On clean completion, invoke `Skill("compound")` exactly once. No invocation on abort or early exit.

### 9. Finalize
Present PR URL. If findings remain after 3 cycles → binary: "Continue loop, or accept and close?" On continue → one more cycle → log escalation in PR body.

## Rules
- **Zero prompts**: No user prompting between sub-skills.
- **Rigor**: No PR before clean pass OR 3 cycles exhausted.
- **Completeness**: Each cycle must address ALL previous findings.
- **No autonomous merge**: Exit at awaiting-merge stage; never trigger a merge.
- **Point-of-need reads**: Read `_shared/seed-brief.md` before spawning workers, `_shared/composition.md` when sizing team shape, `_shared/compound-on-exit.md` before compound step, `references/scope-cycles.md` when evaluating cycles. Do not preload.
- **NOTES.md**: Checkpoint before every spawn. See `Skill("orchestrator-rules")` § Progress tracking.
