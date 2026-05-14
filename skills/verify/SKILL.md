---
name: verify
description: QA verification of implementation against AC. Reports pass/fail per criterion.
argument-hint: "[issue#]"
model: haiku
effort: low
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
## Role & Constraints
Lead verification phase. Goal: Verify every AC from the issue is met with evidence.

## Specialist Mode
- **Seeded**: Skip repo-preflight.
- **Keep**: AC verification rigor (pass/fail evidence is never delegated).
- Read `_shared/specialist-mode.md`

## I/O
- **Input**: Branch + GitHub issue number.
- **Verification Package**: Diff, AC, test commands (type-check, lint, unit, build, e2e).
- **Output**: QA report (pass/fail per AC with evidence).

## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|≤ 3 AC, simple repros, no security/perf|Lead verifies inline|
|**Standard**|≥ 4 AC, or multi-file|QA team, split AC|
|**Deep**|Security/perf-critical, migration|QA team + specialist|

**Decision**: ≤ 3 AC + 1-module → Lightweight; Auth/Security/Migrations/Perf → Deep; else → Standard.

Spawn (Standard/Deep): `TeamCreate` at ≥ 4 AC, else subagents (`haiku`).

## Process

**Lightweight**: Extract AC → run verification chain (type-check, lint, unit, build, e2e) → report pass/fail.

**Standard / Deep**: Split AC across QA team (Deep adds specialist) → each verifies independently → converge on unified report.

## Rules
- **Separation**: Never fix issues during verification. Report failures in the verify output; fixes are a `/build` responsibility.
- **Evidence-Based**: No "it works" — every criterion needs evidence.
- **Feedback Loop**: Any failure → report goes back to `/build` for fixes.
- **Isolation**: Never forward build-session history to QA teammates. Pass only the seed brief and the issue AC to QA agents.
