---
name: epic-autopilot
description: Autonomous epic-to-PR pipeline. Chains /discover → /define → /implement end-to-end for each sub-issue, opening draft PRs.
when_to_use: Use when you have an epic issue number or a free-text description and want the full cycle automated.
argument-hint: "[epic# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Autonomous epic-to-PR pipeline. Takes an epic issue or description and produces draft sub-PRs + epic PR with human gates at Stages 1–3, then autonomous execution through Stage 5.

## Input

- **Positive integer** → existing GitHub epic issue
- **Any other string** → free-text description (triggers `/discover` to create epic)

## Team Shape

Always multi-layer fan-out — dispatches one sub-agent per topological layer of sub-issues. Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` at point of need for spawn cost models.

## Process

Invoke `Skill("orchestrator-rules")` for CWD, delegation, and seed-brief contract.
Invoke `Skill("notes-md")` for NOTES.md lifecycle (create → checkpoint → update → leave).

1. **Stage 0 — Resume detection**: Read `references/detection.md` at point of need to detect prior state and determine entry stage.
2. **Stage 1 — Discovery gate**: Read `references/gates.md` § Stage 1 at point of need. If epic has ≥3 AC, skip to Stage 2. Otherwise invoke `Skill("discover")` with seed-brief containing the description. Require explicit user approval.
3. **Stage 2 — Epic-level /define gate**: Read `references/gates.md` § Stage 2 at point of need. If `## Implementation plan` exists in epic issue body, skip to Stage 3. Otherwise invoke `Skill("define")` with seed-brief containing epic issue and AC. Require explicit user approval. If ≤1 sub-issue, invoke `Skill("implement")` directly and exit.
4. **Stage 3 — Per-sub-issue /define gate**: Read `references/gates.md` § Stage 3 at point of need. For each sub-issue without `## Implementation plan`, invoke `Skill("define")` with seed-brief. Require explicit user approval per sub-issue.
5. **Stage 4 — Autonomous phase**: Read `references/autonomous-phase.md` at point of need. Create epic branch, compute dependency tiers (Kahn's algorithm, cycle breaking), dispatch per tier. For each sub-issue M, spawn `Agent("skills/implement/agents/implement-runner.md")` with comprehensive seed-brief (see § Worker Agent Inventory). Wait for tier settlement. After all tiers settle, create epic PR.
6. **Stage 5 — Exit**: Print summary table to stdout. Invoke `Skill("compound")` for epic-level learnings (compound-on-exit). Merging is left to humans.

## Key behaviors
- Skip /discover if epic has ≥3 acceptance criteria
- Skip /define if epic already has implementation plan
- Topologically sort sub-issues via Kahn's algorithm (with cycle breaking)
- Dispatch tiers in parallel via Task sub-agents
- Post epic PR with merge order instructions after all sub-tasks settle

## Worker Agent Inventory

### implement-runner
- **File**: `skills/implement/agents/implement-runner.md`
- **Contract**: See `## Input (from spawn prompt)` in the agent file.
- **Output**: Draft PR on branch `feat/epic-<N>-sub-<M>` (clean or exhausted-accepted), or FAILED after 2 retries.

## Sub-skills (epic-autopilot owned)

|Skill|Classification|Reference|
|-|-|-|
|Detection|Domain — resume state logic|`references/detection.md`|
|Gates|Domain — stage gate procedures|`references/gates.md`|
|Autonomous Phase|Domain — sub-issue dispatch and epic PR flow|`references/autonomous-phase.md`|

## Rules

- Require explicit approval at each stage gate; silence is not approval
- User must not modify epic/sub-issue bodies during Stage 4
- Branch names follow `feat/epic-<N>-sub-<M>` exactly
- `autonomous: true` reserved for sub-task spawns from this skill only
- Seed-brief every `Agent()` spawn — spawned session has zero context inheritance
- Read reference files at point of need, not unconditionally at SKILL.md top
