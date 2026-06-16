---
name: define
description: Lead definition phase. Resolves architecture and design technical decisions.
when_to_use: Use after /discover produces an approved issue with AC. Precedes /implement.
argument-hint: "[issue#]"
model: opus
effort: high
allowed-tools: Agent Bash Read
compatibility: claude-code opencode
---
Lead definition phase. Transform an approved issue into a concrete implementation plan (architecture + design).

Adopt `Skill("orchestrator-rules")` for checkpoint, NOTES.md, and seed-brief conventions.

Read `references/scope.md` for work-unit types.

## Process

### 1. Ingestion

Read issue body with acceptance criteria. Build work-unit list for scope-assessment. Reference-read issue on demand throughout.

### 2. Init NOTES.md

Create `.claude/NOTES.md` with task list, decisions log, next-action per `Skill("orchestrator-rules")`.

### 3. Scope

Invoke `Skill("scope-assessment")` with work units (one per distinct module or sub-issue). Receive agent plan — one agent per disjoint group. No preset agent count; width matches scope.

### 4. Architecture & Design

Dispatch workers sequentially per group:
- **`Skill("architecture")`** (`sonnet`) — per group with issue + AC. Response in chat.
- **`Skill("design")`** (`sonnet`) — per group with arch decisions, if visual work. Response in chat.

Checkpoint NOTES.md before each spawn; update on return. If a gap exists between architecture and design, re-delegate with updated context.

### 5. Review & Discuss

Verify all ACs covered. Present to user. Invoke `Skill("grill-me")` to challenge assumptions. Iterate until explicit approval.

### 6. Critique (high-risk only)

For high-risk plans (security, payments, arch-changing scope): after architecture + design, spawn in parallel:
- `Agent("agents/workflow-critique-agent.md")` with `sonnet`
- `Agent("agents/workflow-critique-agent.md")` with `haiku` (second independent pass, two perspectives)

Each with seed-brief containing `issue`, `architecture_decisions`, `design_decisions`, and `scope`. Each `Agent()` spawn includes a `<seed-brief>` YAML block per `_shared/seed-brief.md`. Merge findings from both before presenting to user. Get approval.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

### 7. Synthesize

Collect final decisions into a cohesive implementation plan.

### 8. Handoff

Invoke `Skill("preflight")`. Read `_shared/handoff-artifact.md`.

Update issue body with `## Implementation plan` section:
- Acceptance criteria (unchanged), Constraints, Prior decisions, Evidence, Open questions.
- Record decisions, visuals, and sub-issues with relationships.
- Define dependency graph for parallelization.

### 9. Sign-off

Require explicit user approval.

### 10. Compound on exit

Read `${CLAUDE_PLUGIN_ROOT}/_shared/compound-on-exit.md`. Invoke `Skill("compound")` exactly once on clean completion. Then instruct user: "Start `/implement` in a fresh session."

## Rules

- **Delegate, don't duplicate**: Sub-skills own their domain work. Do not produce architecture/design output yourself.
- **Explicit approval**: Silence ≠ approval. Require direct confirmation.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask focused question.
