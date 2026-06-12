---
name: discover
description: Full discovery phase — explore a problem and produce a GitHub issue with AC.
when_to_use: Start of any new feature or vague problem. Precedes /define.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
Lead discovery phase. Transform vague ideas into well-specified GitHub issues ready for architecture and implementation. Pure orchestrator — delegates all domain work to sub-skills.

Invoke `Skill("orchestrator-rules")` — adopt CWD verification, delegation, seed-brief contract, NOTES.md progress tracking.

## Process

### 1. Ingestion

Read issue (problem statement + AC), if specified. If no issue exists, elicit a one-sentence problem summary from the user.

Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` — adopt atomic questions, rigor, visual-first, explicit approval.

### 2. Init NOTES.md

Create `.claude/NOTES.md` with task list, and next-action per `Skill("orchestrator-rules")`.

### 3. Problem exploration

Invoke `Skill("describe")` with seed-brief containing the problem statement. Describe owns the full user conversation — research, PPT grilling, visualization, problem statement. Returns structured understanding (What, Why, Who, Boundaries, Prior art).

### 4. Acceptance criteria

Invoke `Skill("specify")` with seed-brief containing the problem statement and prior-art findings from describe. Specify derives testable AC via grill-me passes. Returns GIVEN/WHEN/THEN scenarios.

### 5. Review

Verify describe and specify covered all AC. If gaps found, re-delegate. Iterate until explicit user approval.

### 6. Synthesize

Combine output into a cohesive GitHub issue body:
- **Preamble**: What, Why, Who (from describe).
- **`## Requirements`**: Acceptance criteria (from specify) → Constraints → Prior decisions → Evidence → Open questions.

### 7. Handoff

Invoke `Skill("preflight")`. Suppress branch line: true.

Read `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` at this point (point-of-need) — do not preload.

If issue exists, update the body. Otherwise create via `gh issue`.

### 8. Sign-off

Require explicit user approval.

### 9. Compound on exit

Read `${CLAUDE_PLUGIN_ROOT}/_shared/compound-on-exit.md`. Invoke `Skill("compound")` exactly once on clean completion. Then instruct user: "Start `/implement` in a fresh session."

## Rules

- **Delegate, don't duplicate**: Sub-skills own their domain.
- **Explicit approval**: Partial feedback ≠ approval. Require direct "Yes/Approved".
- **Persistence**: Prior-art findings persisted in Prior decisions / Evidence fields.
- **Traceability**: Every feature gets one issue; sub-issues use proper GitHub relationships.
