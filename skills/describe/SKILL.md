---
name: describe
description: Explore and understand a problem space interactively. Uses visualizations and user stories to build shared understanding.
when_to_use: Use during discovery. Invoked by /discovery; can run standalone before /specify.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read
layer: 2
user-invocable: true
---
Lead product discovery. Explores problems interactively, builds shared understanding via visualizations and user stories, and hands off structured problem statements.

## Role & Constraints
Lead product discovery. Goal: Deeply understand the problem space via interactive exploration and validation. Produces a shared understanding of the problem (user stories, visualizations). If not specify otherwise, hands off via GitHub issue body under `## Requirements`.

## I/O
- **Input**: Problem statement or issue description.
- **Output**: Structured problem statement:
  - **What**: 1-2 sentence summary.
  - **Why**: Problem it solves.
  - **Who**: Target user/persona.
  - **Boundaries**: In-scope vs Out-of-scope.

## Scope Assessment
Read `references/scope-ppt.md` for scope classification and PPT checklist.

## Process

### Multi-area or complex problem
1. **Elicitation**: Ask user for problem/goal if not already provided.
2. **Research** (spawn in parallel):
   - `Agent("describe/agents/domain-researcher.md")` — pass `domain` (the feature domain) and `cwd` (absolute repo root).
   - **Gate** (high-risk only): if high-risk signals are present, also spawn `Agent("describe/agents/flow-analyst.md")` — pass `domain`, `cwd`, and `entry_points` from domain-researcher output.
3. **PPT**: Run Product Pressure Test (see `references/scope-ppt.md`) — invoke `Skill("grill-me")` with user.
4. **Visualization and Validation**: Produce Mermaid/ASCII for user journeys, feature comparisons, system boundaries.Confirm understanding of each visual with the user, grill the user, until alignment is achieved.
5. **Synthesis**: Return structured problem statement.
6. **Output**: Invoke `Skill("preflight")`, read `_shared/handoff-artifact.md`, and write decisions to issue body under `## Requirements` if not specified otherwise.

### Narrow, single-area problem
1. Confirm problem/outcome with user.
2. Brief codebase validation.
3. Direct problem statement production.

## Rules
- **Recommend an answer**: For each component, recommend a preferred approach before asking the user to choose.
- **Stay interactive**: Never skip PPT or visual validation — these are discussion points, not automations.
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`
