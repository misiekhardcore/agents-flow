---
name: define
description: Lead definition phase. Spawns /architecture and /design to produce technical decisions.
when_to_use: Use after /discovery produces an approved issue with AC. Precedes /implement.
argument-hint: "[issue#]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Phase Lead. Goal: Transform an approved issue into a concrete implementation plan (architecture + design). Orchestrate sub-skills, discuss with the user — delegate domain work, never duplicate it.

## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per distinct module or sub-issue in the issue body. Receive agent plan; dispatch one architecture agent per disjoint group (each spawns `/architecture` as Seeded, then `/design` if visual as Seeded).

For high-risk plans (security, payments, arch-changing scope): add a parallel critique pass after `/architecture` → `/design` using two independent critique subagents whose findings the lead merges. Determine risk from issue AC and scope — not from a label.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process
1. **Ingestion**: Read issue (problem statement + AC).
2. **Delegation**: For each work group, spawn `/architecture` with issue + AC. Sub-agents run autonomously — they produce decisions without user interaction. If visual work, spawn `/design` with architecture decisions.
3. **Review & Discuss**: Present architecture and design decisions to the user. Use `/grill-me` to challenge assumptions. Iterate if needed by respawning sub-agents with updated context.
4. **Synthesize**: Collect final decisions into a cohesive implementation plan.
5. **Handoff**: Update GitHub issue body (single source of truth). Invoke `Read ${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for field list.
   - Edit/Append `## Implementation plan` section.
   - Record decisions, visuals, and sub-issues with relationships.
   - Define dependency graph for parallelization.
   - **Mandatory**: AC and Constraints.
6. **Sign-off**: Require explicit user approval.
7. **Closure**: Instruct user: "Start `/implement` in a fresh session."

## Rules
- **Delegate, don't duplicate**: Sub-skills own their domain work. Do not research or produce architecture/design output yourself.
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Sourcing**: Invoke `Skill("preflight")` before updating issue.
  Suppress branch line: true
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`
