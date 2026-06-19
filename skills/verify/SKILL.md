---
name: verify
description: QA verification of implementation against AC. Reports pass/fail per criterion.
argument-hint: "[issue#]"
when_to_use: Use after /build to verify all acceptance criteria are met. Invoked by /implement; can run standalone.
effort: low
user-invocable: true
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Lead verification phase. Goal: Verify every AC from the issue is met with evidence. Report pass/fail per criterion.

## I/O
- **Input**: Branch + GitHub issue number.
- **Verification Package**: Diff, AC, test commands (type-check, lint, unit, build, e2e).
- **Output**: QA report (pass/fail per AC with evidence) returned to caller.

## Process
1. Acquire verification package: `git diff` for diff, `gh issue view` for AC.
2. Group the acceptance criteria into disjoint domain groups (API, UI, DB, auth, …) and dispatch one `workflow-reviewer` via the task tool with `focus: correctness` per group in parallel (pass the group as `acceptance_criteria` + `diff`). If the AC or plan mention migration/rollback/backwards-compatibility or the diff contains schema changes, also dispatch `workflow-reviewer` via the task tool with `focus: migration`. No verify-runner — dispatch leaf reviewers directly.
3. Merge: any P0 finding (P0 = "AC not satisfied / golden path crash") in any group → overall FAIL; no P0 findings → overall PASS. Emit unified report ordered by AC group.

<rules>
<critical>MUST NOT fix issues during verification — report failures in the verify output; fixes are a `/build` responsibility.</critical>
<constraint>MUST be evidence-based: NO "it works" — every criterion MUST have evidence.</constraint>
<constraint>Any failure MUST send the report back to `/build` for fixes.</constraint>
<constraint>MUST pass only the AC group and diff to each reviewer — NEVER the full build session history.</constraint>
</rules>
