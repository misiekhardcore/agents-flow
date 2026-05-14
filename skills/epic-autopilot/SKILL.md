---
name: epic-autopilot
description: Autonomous epic-to-PR pipeline. Chains /discovery → /define → /implement end-to-end for each sub-issue, opening draft PRs.
when_to_use: Use when you have an epic issue number or a free-text description and want the full cycle automated.
argument-hint: "[epic# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read TaskCreate TaskUpdate
---
Autonomous epic-to-PR orchestrator. Takes an epic issue or description and produces draft sub-PRs + epic PR with human gates at Stages 1–3, then autonomous execution through Stage 5.

## Input

- **Positive integer** → existing GitHub epic issue
- **Any other string** → free-text description (triggers `/discovery` to create epic)

## Scope Assessment

Always **Deep** — fanout orchestrator with sub-agent delegation. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn justification.

## Process

Read `references/gates.md` for resume detection, stage gates (Stages 1–3), exit (Stage 5), and resume logic. When entering Stage 4, Read `references/autonomous-phase.md` for branch creation, dependency-tier computation, parallel dispatch, settlement, and epic PR creation.

Stage 0 detects resume point. Stages 1–3 require explicit user approval at gates. Stage 4 autonomous (no prompts). Stage 5 exits.

**Key behaviors:**
- Skip /discovery if epic has ≥3 acceptance criteria
- Skip /define if epic has implementation plan
- Topologically sort sub-issues via Kahn's algorithm (with cycle breaking)
- Dispatch tiers in parallel via Task sub-agents
- Post epic PR with merge order instructions after all sub-tasks settle

## Rules

See `${CLAUDE_PLUGIN_ROOT}/_shared/orchestrator-rules.md` for CWD, delegation, and seed-brief contract.

- Require explicit approval at each gate; silence is not approval
- User must not modify epic/sub-issue bodies during Stage 4
- Branch names follow `feat/epic-<N>-sub-<M>` exactly
- `autonomous: true` reserved for sub-task spawns from this skill only
- `/compound` and `/wrap-up` remain user-invoked utilities
