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
Phase lead. Goal: Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR.

## Pre-flight
1. Invoke `Skill("preflight")` at entry (pass `suppress branch line: true`).
2. If >= 3 files changed, run the scope checks within `preflight` again.

## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per sub-issue or distinct file group from `## Implementation plan`. Receive agent plan; spawn one `/build` invocation per disjoint group.

**Design Gate** (multi-unit only): Verify `## Implementation plan` in issue body. If absent:
- **Pause** → Prompt: "Run `/define` first, or confirm this is trivial."
- If trivial → proceed as single-unit.
- Otherwise → Wait for `/define`.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process

**Autonomy Contract**: Run cycles back-to-back without prompting. Only interrupt after PR is open if (a) clean, (b) 3 cycles exhausted, or (c) blocker hit.

1. **Ingestion**: Read issue (problem statement, AC, and `## Implementation plan`).
2. **Scoping**: Invoke `Skill("scope-assessment")` → determine trivial vs. multi-unit.
3. **Delegation** (per scope/work unit):
   - Spawn `Agent("implement/agents/implement-runner.md")` with `repo`, `branch`, `issue`, `max_cycles: 3` one per work unit. Runner handles build → review → verify cycles and PR creation.

## Rules
- **Zero Prompts**: No prompting between sub-skills.
- **Rigor**: Do not open PR until clean pass OR 3 cycles exhausted.
- **Completeness**: Each cycle must address ALL previous findings.
- **State**: In-phase state in `.claude/NOTES.md`. Issue body stores `## Requirements` and `## Implementation plan`.
- **Exhausted-exit**: After runner returns with remaining findings, present PR URL + findings → ask: "Continue loop, or accept and close?"
