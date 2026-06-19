---
name: epic-autopilot
description: Autonomous epic-to-PR pipeline. Chains /discover → /define → /implement end-to-end for each sub-issue, opening draft PRs.
when_to_use: Use when you have an epic issue number or a free-text description and want the full cycle automated.
argument-hint: "[epic# | description]"
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Autonomous epic-to-PR orchestrator. Takes an epic issue or description and produces draft sub-PRs + epic PR with human gates at Stages 1–3, then autonomous execution through Stage 5.

## Input

- **Positive integer** → existing GitHub epic issue
- **Any other string** → free-text description (triggers `/discover` to create epic)

## Team Shape

Always multi-layer fan-out — dispatches one sub-agent per topological layer of sub-issues. Read `@_shared/composition.md` at point of need for spawn cost models.

## Process

Invoke the "orchestrator-rules" skill for CWD, delegation, and seed-brief contract.
Invoke the "notes-md" skill for NOTES.md lifecycle (create → checkpoint → update → leave).

### 1. Detection (Stage 0)

Invoke the "preflight" skill. Echo resolved `owner/repo`. Read `references/detection.md` at point of need to detect prior state and determine entry stage. Create `.claude/NOTES.md` with task list and next action.

### 2. Discovery gate (Stage 1)

Read `references/gates.md` § Stage 1 at point of need. If epic has ≥3 AC, skip to Stage 2. Otherwise invoke the "discover" skill with seed-brief handoff. Require explicit user approval.

### 3. Epic-level define gate (Stage 2)

Read `references/gates.md` § Stage 2 at point of need. If `## Implementation plan` exists in epic issue body, skip to Stage 3. Otherwise invoke the "define" skill with seed-brief handoff. Require explicit user approval. If ≤1 sub-issue, invoke the "implement" skill directly and exit.

### 4. Per-sub-issue define gate (Stage 3)

Read `references/gates.md` § Stage 3 at point of need. For each sub-issue without `## Implementation plan`, invoke the "define" skill with seed-brief handoff. Require explicit user approval per sub-issue.

### 5. Autonomous phase (Stage 4)

Read `references/autonomous-phase.md` at point of need. Checkpoint NOTES.md. Create epic branch, compute dependency tiers (Kahn's algorithm, cycle breaking), dispatch per tier. For each sub-issue M, checkpoint NOTES.md then dispatch `workflow-implement-runner` via the task tool with seed-brief per `references/autonomous-phase.md` § seed brief. Wait for tier settlement. After all tiers settle, create epic PR.

### 6. Exit (Stage 5)

Print summary table to stdout. Invoke the "compound" skill for epic-level learnings (compound-on-exit). Merging is left to humans.

## Key behaviors
- Skip /discover if epic has ≥3 acceptance criteria
- Skip /define if epic already has implementation plan
- Topologically sort sub-issues via Kahn's algorithm (with cycle breaking)
- Dispatch tiers in parallel via Task sub-agents
- Post epic PR with merge order instructions after all sub-tasks settle

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
- Seed-brief every agent spawn (via the task tool) — spawned session has zero context inheritance
- Read reference files at point of need, not unconditionally at SKILL.md top
