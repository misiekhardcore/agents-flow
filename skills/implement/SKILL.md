---
name: implement
description: Full implementation cycle — build, review, and verify, then open a PR.
when_to_use: Use to run the full implementation cycle (build → review → verify → PR) from an approved issue.
argument-hint: "[issue#]"
model: sonnet
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
## Role & Constraints
Goal: Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR. Delegates all phase work to sub-skills and worker agents — never codes, reviews, or runs tests inline.

## Behavioral Conventions
Adopt conventions via `Skill("orchestrator-rules")` (Protocol skill):
- **Seed-brief contract**: Every `Agent()` spawn includes a `<seed-brief>` block with `repo`, `branch`, `active_issue`, and `payload`. See `_shared/seed-brief.md`.
- **Progress tracking**: NOTES.md checkpointing before every `Skill()` or `Agent()` call. See `skills/notes-md/SKILL.md`.
- **No autonomous merge**: Exit at awaiting-merge stage; never trigger a merge.

## Sub-skills Owned by /implement

| Artifact | Type | Purpose |
|----------|------|---------|
| `agents/implement-runner.md` | Runner (autonomous) | Drive build → review → verify cycles per work unit |
| `references/scope-cycles.md` | Reference | Cycle detail and PR creation reference |
| `Skill("scope-assessment")` | Worker Skill | Decompose work into disjoint file groups (no preset count) |

Referenced (external):

| Skill | Phase | Invocation |
|-------|-------|------------|
| `Skill("preflight")` | Entry | Repo/scope verification |
| `Skill("orchestrator-rules")` | Entry | Protocol conventions |
| `build` | Build | Via implement-runner |
| `review` | Review | Via implement-runner |
| `verify` | Verify | Via implement-runner |
| `Skill("compound")` | Exit | Capture learnings |

## Work-unit Types
- **Single-unit**: One implementation plan, no sub-issues → one runner directly.
- **Multi-unit**: Sub-issues or distinct file groups → invoke `Skill("scope-assessment")` with work units (each with `id` and `resources`) → one runner per disjoint group returned.

## Process

1. **Entry**: Invoke `Skill("orchestrator-rules")` to adopt conventions. Invoke `Skill("preflight")` with `suppress branch line: true`.
2. **Ingestion**: Read issue body (`## Requirements`, `## Implementation plan`). If plan absent and non-trivial → prompt: "Run `/define` first, or confirm this is trivial." If trivial → proceed as single-unit.
3. **Scoping**: Build work units from sub-issues and file groups. Invoke `Skill("scope-assessment")` with work units → receive agent plan of disjoint groups.
4. **Delegation**: Per disjoint group, spawn `Agent("implement/agents/implement-runner.md")` with seed-brief containing `repo`, `branch`, `active_issue`, `max_cycles: 3`, `scope`, and `payload` (resources + NOTES.md progress slice). See `_shared/seed-brief.md`.
5. **Collection**: Wait for runner return. Collect PR URL and findings.
6. **Compound**: Read `_shared/compound-on-exit.md`. On clean completion, invoke `Skill("compound")` exactly once. No invocation on abort or early exit.
7. **Finalize**: Present PR URL. If findings remain after 3 cycles → binary: "Continue loop, or accept and close?" On continue → one more cycle → log escalation in PR body.

## Point-of-Need References
Read these only when the relevant step is reached:
- `_shared/seed-brief.md` — before spawning workers
- `_shared/composition.md` — when sizing team shape
- `_shared/compound-on-exit.md` — before compound step
- `references/scope-cycles.md` — cycle detail reference

## Loop Structure

3-cycle hard stop per wiki (`references/scope-cycles.md`):
1. **Cycle 1-3**: Build → review → verify per runner. Each cycle addresses ALL previous findings.
2. **Evaluation**: Clean pass → PR. Findings + cycles < 3 → fix brief → next cycle. Cycles = 3 → PR with remaining findings surfaced.
3. **Exhausted-exit**: After runner returns, present PR URL + findings → binary continue/accept.

## Rules
- **Zero prompts**: No user prompting between sub-skills.
- **Rigor**: No PR before clean pass OR 3 cycles exhausted.
- **Completeness**: Each cycle must address ALL previous findings.
- **State**: In-phase state in `.claude/NOTES.md`. Issue body stores `## Requirements` and `## Implementation plan`.

