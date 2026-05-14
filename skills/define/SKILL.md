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

## Scope Assessment
|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|<= 1 module, pattern exists, no visuals, no unknowns|Inline architecture summary (3-5 bullets). Skip research and `/architecture`.|
|**Standard**|Typical feature, some unknowns, may have visuals|Research team → `/architecture` → `/design` (if visual).|
|**Deep**|Cross-module, security/payments, arch-changing, migration|Research team → `/architecture` → `/design` → critique team.|

**Decision**: 1 module + pattern match → Lightweight; Security/Payments/Arch-change → Deep; else → Standard.

### Spawn Rubric (see `_shared/composition.md`)
- **Research Team**: 2 parallel `sonnet` agents (Codebase + Patterns).
- **Standard Team**: Sequential specialists (Architecture → Design).
- **Deep Team**: Standard + `TeamCreate` critique team (only for high-risk plans).

## Process
1. **Ingestion**: Read issue (problem statement + AC).
2. **Research** (Standard/Deep only): Dispatch parallel agents to produce a research brief (seeds specialists).
3. **Execution**:
   - **Lightweight**: Write summary inline.
   - **Standard**: Architecture → Design (if visual).
   - **Deep**: Architecture → Design → Critique Team.
4. **Sourcing**: Respect sequence: Architecture decisions first → Design works within those constraints.
5. **Handoff**: Update GitHub issue body (single source of truth) per `_shared/handoff-artifact.md`.
   - Edit/Append `## Implementation plan` section.
   - Record decisions, visuals, and sub-issues with relationships.
   - Define dependency graph for parallelization.
   - **Mandatory**: AC and Constraints.
6. **Sign-off**: Require explicit user approval.
7. **Closure**: Instruct user: "Start `/implement` in a fresh session."

## Rules
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Sourcing**: Use `_shared/repo-preflight.md` before updating issue.
- Read `_shared/interviewing-rules.md`
