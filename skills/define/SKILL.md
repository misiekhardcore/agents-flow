---
name: define
description: Lead definition phase. Resolves architecture and design technical decisions.
when_to_use: Use after /discovery produces an approved issue with AC. Precedes /implement.
argument-hint: "[issue#]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Phase Lead. Transform an approved issue into a concrete implementation plan (architecture + design). Orchestrate sub-skills, discuss with user — delegate domain work, never duplicate it.

Adopt `Skill("orchestrator-rules")` for checkpoint, NOTES.md, and seed-brief conventions.

## Input
Issue number with acceptance criteria from /discovery. Read body at entry; reference-read issue on demand throughout.

## Team Shape
Invoke `Skill("scope-assessment")` with work units (one per distinct module or sub-issue). Receive agent plan — one agent per disjoint group. No preset agent count; width matches scope.

Dispatch workers sequentially per group:
- **`Skill("architecture")`** (layer 2) — per group with issue + AC. Response in chat.
- **`Skill("design")`** (layer 2) — per group with arch decisions, if visual work. Response in chat.

For high-risk plans (security, payments, arch-changing scope): spawn `Agent("define/agents/critique-agent.md")` with seed-brief containing `issue`, `architecture_decisions`, `design_decisions`, and `scope`. One pass; critique-agent defines its own depth. Merge findings before presenting to user.

Each `Agent()` spawn includes a `<seed-brief>` YAML block per `_shared/seed-brief.md`.

### Critique-agent I/O contract
- **Input (seed-brief)**: `issue`, `architecture_decisions`, `design_decisions`, `scope`
- **Output**: Structured report — `Decisions reviewed`, `Gaps found`, `Risks` (severity), `Trade-offs not discussed`, `Recommendations` (prioritized)
- **Contract**: Read-only. One independent pass. Spawned for high-risk plans only.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process
1. **Ingestion** — Read issue body; build work-unit list for scope-assessment.
2. **Init NOTES.md** — Create `.claude/NOTES.md` with task list, decisions log, next-action per `Skill("orchestrator-rules")`.
3. **Scope** — Invoke `Skill("scope-assessment")` with work units. Receive agent plan.
4. **Delegate** — Sequentially per group:
   - **(a)** `Skill("architecture")` with issue + AC.
   - **(b)** `Skill("design")` with architecture decisions (if visual work).
   - Checkpoint NOTES.md before each spawn; update on return.
5. **Review** — Verify all ACs covered. Check for gaps; re-delegate if needed. Present to user. Invoke `Skill("grill-me")` to challenge assumptions. Iterate until explicit approval.
6. **Critique** — If high-risk: spawn critique-agent with seed-brief. Merge findings, present, get approval.
7. **Synthesize** — Collect final decisions into a cohesive implementation plan.
8. **Handoff** — Invoke `Skill("preflight")`. Read `_shared/handoff-artifact.md`. Update issue body with `## Implementation plan` section:
   - Acceptance criteria (unchanged), Constraints, Prior decisions, Evidence, Open questions.
   - Dependency graph for parallelization.
9. **Sign-off** — Require explicit user approval.
10. **Compound-on-exit** — Read `_shared/compound-on-exit.md`. Invoke `Skill("compound")` once on clean completion. Then instruct user: "Start `/implement` in a fresh session."

## Output
Issue body `## Implementation plan` section per `_shared/handoff-artifact.md` (five-field block).

## Rules
- **Delegate, don't duplicate**: Sub-skills own their domain work. Do not produce architecture/design output yourself.
- **Seed-brief every Agent()**: All agent spawns include `<seed-brief>` with repo, branch, payload. See `_shared/seed-brief.md`.
- **Point-of-need reads**: Read `_shared/handoff-artifact.md` at step 8, `_shared/interviewing-rules.md` at step 5, `_shared/compound-on-exit.md` at step 10. Do not preload.
- **Explicit approval**: Silence ≠ approval. Require direct confirmation.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask focused question.

- **NOTES.md**: Checkpoint before every spawn. See `Skill("orchestrator-rules")` § Progress tracking.
