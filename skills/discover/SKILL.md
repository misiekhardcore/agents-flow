---
name: discover
description: Full discovery phase — explore a problem and produce a GitHub issue with AC.
when_to_use: Start of any new feature or vague problem. Precedes /define.
argument-hint: "[issue# | description]"
effort: high
allowed-tools: Agent Bash Read
---
Lead discovery phase. Transform vague ideas into well-specified GitHub issues ready for architecture and implementation. Pure orchestrator — delegates all domain work to sub-skills.

Invoke the "orchestrator-rules" skill — adopt CWD verification, delegation, seed-brief contract, NOTES.md progress tracking.

## Process

### 1. Ingestion

Read issue (problem statement + AC), if specified. If no issue exists, elicit a one-sentence problem summary from the user.

Read `@_shared/interviewing-rules.md` — adopt atomic questions, rigor, visual-first, explicit approval.

### 2. Init NOTES.md

Create `.claude/NOTES.md` with task list, and next-action per the "orchestrator-rules" skill.

### 3. Problem exploration

Invoke the "describe" skill with seed-brief containing the problem statement. Describe owns the full user conversation — research, PPT grilling, visualization, problem statement. Returns structured understanding (What, Why, Who, Boundaries, Prior art).

### 4. Acceptance criteria

Invoke the "specify" skill with seed-brief containing the problem statement and prior-art findings from describe. Specify derives testable AC via grill-me passes. Returns GIVEN/WHEN/THEN scenarios.

### 5. Review

Verify describe and specify covered all AC. If gaps found, re-delegate. Iterate until explicit user approval.

### 6. Synthesize

Combine output into a cohesive GitHub issue body:
- **Preamble**: What, Why, Who (from describe).
- **`## Requirements`**: Acceptance criteria (from specify) → Constraints → Prior decisions → Evidence → Open questions.

### 7. Handoff

Invoke the "preflight" skill. Suppress branch line: true.

Read `@_shared/handoff-artifact.md` at this point (point-of-need) — do not preload.

If issue exists, update the body. Otherwise create via `gh issue`.

### 8. Sign-off

Require explicit user approval.

### 9. Compound on exit

Read `@_shared/compound-on-exit.md`. Invoke the "compound" skill exactly once on clean completion. Then instruct user: "Start `/implement` in a fresh session."

<rules>
<constraint>MUST delegate, not duplicate: sub-skills own their domain.</constraint>
<critical>MUST require a direct "Yes/Approved" — partial feedback is NEVER approval.</critical>
<constraint>MUST persist prior-art findings in the Prior decisions / Evidence fields.</constraint>
<constraint>Every feature MUST get exactly one issue; sub-issues MUST use proper GitHub relationships.</constraint>
</rules>
