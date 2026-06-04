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
Phase Lead. Goal: Transform an approved issue into a concrete implementation plan (architecture + design).

## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per distinct module or sub-issue in the issue body. Receive agent plan; dispatch one research/architecture agent per disjoint group.

For high-risk plans (security, payments, arch-changing scope): add a critique pass after `/architecture` → `/design` using a `TeamCreate` critique team. Determine risk from issue AC and scope — not from a label.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process
1. **Ingestion**: Read issue (problem statement + AC).
2. **Research** (multi-area only): Dispatch parallel agents to produce a research brief (seeds specialists).
3. **Execution**:
   - **Narrow scope**: Write architecture summary inline.
   - **Multi-area**: Architecture → Design (if visual).
   - **High-risk domain**: Architecture → Design → Critique Team.
4. **Sourcing**: Respect sequence: Architecture decisions first → Design works within those constraints.
5. **Handoff**: Update GitHub issue body (single source of truth). Invoke `Skill("handoff-artifact")` for field list.
   - Edit/Append `## Implementation plan` section.
   - Record decisions, visuals, and sub-issues with relationships.
   - Define dependency graph for parallelization.
   - **Mandatory**: AC and Constraints.
6. **Sign-off**: Require explicit user approval.
7. **Closure**: Instruct user: "Start `/implement` in a fresh session."

## Rules
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Sourcing**: Invoke `Skill("preflight")` before updating issue.
  Suppress branch line: true
- Invoke `Skill("interviewing-rules")`
