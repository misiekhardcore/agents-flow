---
name: verify
description: QA verification of implementation against AC. Reports pass/fail per criterion.
argument-hint: "[issue#]"
model: haiku
effort: low
layer: 2
user-invocable: true
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
## Role & Constraints
Lead verification phase. Goal: Verify every AC from the issue is met with evidence. Report pass/fail per criterion. Hand off findings via seed-brief for fix cycles.

## Specialist Mode
- **Seeded**: Skip repo-preflight.
- **Keep**: AC verification rigor (pass/fail evidence never delegated).
Invoke `Skill("specialist-mode")` at entry.

## I/O
- **Input**: Branch + GitHub issue number.
- **Verification Package**: Diff, AC, test commands (type-check, lint, unit, build, e2e).
- **Output**: QA report (pass/fail per AC with evidence).

## Specialist Assessment
Invoke `Skill("verify-specialist-assessment")` at entry. It reads AC and diff from context and emits a `specialists:` list.

## Process
1. Invoke `Skill("scope-assessment")` with work units — one per AC group. Receive agent plan; spawn one QA agent per disjoint group. Add any activated specialists to their relevant groups.
2. Split AC across QA agents per `scope-assessment` output → each verifies independently → converge on unified report. Any activated specialists verify their domain-specific AC alongside the QA agents.

## Rules
- **Separation**: Never fix issues during verification. Report failures in the verify output; fixes are a `/build` responsibility.
- **Evidence-Based**: No "it works" — every criterion needs evidence.
- **Feedback Loop**: Any failure → report goes back to `/build` for fixes.
- **Isolation**: Never forward build-session history to QA teammates. Pass only the seed brief and the issue AC to QA agents.
