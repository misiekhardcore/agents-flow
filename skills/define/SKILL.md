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
Phase Lead. Goal: Transform an approved issue into a concrete implementation plan (architecture + design). Orchestrate sub-skills, discuss with the user — delegate domain work, never duplicate it.

## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per distinct module or sub-issue in the issue body. Receive grouping plan.

For high-risk plans (security, payments, arch-changing scope): after architecture + design, spawn in parallel:
  - `Agent("define/agents/critique-agent.md")` — pass `issue`, `architecture_decisions`, `design_decisions`, `scope`, model: `sonnet`
  - `Agent("define/agents/critique-agent.md")` — second independent pass with same input (two perspectives), but model: `haiku`
Merge findings from both critique agents before presenting to user.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models and consumption contract rules.

## Process
1. **Ingestion**: Read issue (problem statement + AC).
2. **Scoping**: Each work unit from the scope assessment is a candidate (group) for delegation to architecture or design.
3. **Delegation** (sequentially, per work, group one by one):
   - **3a**: Invoke `Skill("architecture")` with issue + AC. Get the response in chat, not in GitHub issue.
   - **3b**: If visual work, invoke `Skill("design")` with architecture decisions. Get the response in chat, not in GitHub issue.
4. **Review & Discuss**: Verify all ACs are covered by the collected decisions. Identify conflicts or gaps between architecture and design outputs. If a gap exists, move back to **Delegation** with updated context. Present architecture and design decisions to the user. Invoke `Skill("grill-me")` to challenge assumptions. Re-iterate until the user approves the plan. For high-risk plans, merge findings from parallel critique agents (`Agent("define/agents/critique-agent.md")` × 2).
5. **Synthesize**: Collect final decisions into a cohesive implementation plan.
6. **Handoff**: Update GitHub issue body (single source of truth). Invoke `Read ${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for field list.
   - Edit/Append `## Implementation plan` section.
   - Record decisions, visuals, and sub-issues with relationships.
   - Define dependency graph for parallelization.
   - **Mandatory**: AC and Constraints.
7. **Sign-off**: Require explicit user approval.
8. **Closure**: Invoke `Skill("compound")` with current issue to trigger follow-ups. Then instruct user: "Start `/implement` in a fresh session."

## Rules
- **Delegate, don't duplicate**: Sub-skills own their domain work. Do not research or produce architecture/design output yourself.
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Sourcing**: Invoke `Skill("preflight")` before updating issue.
  Suppress branch line: true
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`
