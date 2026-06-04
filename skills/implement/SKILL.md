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
Orchestrate build → review → verify → fix cycles to produce a ready-to-merge PR.

Read `references/scope-cycles.md` for scope assessment table, autonomous cycle detail, PR creation steps, and finalize logic.

## Pre-flight
1. Invoke `Skill("preflight")` at entry (pass `suppress branch line: true`).
2. If >= 3 files changed, run the scope checks within `preflight` again. Pass `preflight_verified: true` in seed-briefs.

## Process

**Autonomy Contract**: Run cycles back-to-back without prompting. Only interrupt after PR is open if (a) clean, (b) 3 cycles exhausted, or (c) blocker hit.

**Trivial** (single work unit, ≤ 50 lines, no logic change): `/build` → inline AC check → PR. Skip `/review` and `/verify` teams. A worktree is still created.

**Multi-unit**: Full Build → Review → Verify cycle per `scope-assessment` output. Repeat up to 3 times until clean or exhausted, then PR creation.

## Rules
- **Zero Prompts**: No prompting between sub-skills.
- **Rigor**: Do not open PR until clean pass OR 3 cycles exhausted.
- **Completeness**: Each cycle must address ALL previous findings.
- **State**: In-phase state in `.claude/NOTES.md`. Issue body stores `## Requirements` and `## Implementation plan`.
- Invoke `Skill("handoff-artifact")`
