---
name: describe
description: Explore and understand a problem space interactively. Uses visualizations and user stories to build shared understanding.
when_to_use: Use during discovery. Invoked by /discovery; can run standalone before /specify.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
You lead product discovery. Goal: Deeply understand the problem space via interactive exploration and validation.

## Specialist Mode
- **Seeded**: Skip internal prior-art search. Keep PPT and grill-me interactions.
- **Standalone**: Run all steps.
- Invoke `Skill("specialist-mode")`

## Scope Assessment
Read `/references/scope-ppt.md` for scope classification, spawn rubric, and PPT checklist.

## Process

### Standard / Deep
1. **Elicitation**: Ask user for problem/goal.
2. **Exploration**: Dispatch agents → Lead analyst runs interactively via `/grill-me`.
3. **PPT**: Run Product Pressure Test (see `/references/scope-ppt.md`) before synthesizing.
4. **Visualization**: Produce Mermaid/ASCII for user journeys, feature comparisons, system boundaries.
5. **Validation**: Confirm understanding of each visual.
6. **Synthesis**: Create structured problem statement.

### Lightweight
1. Confirm problem/outcome.
2. Brief codebase validation.
3. Direct problem statement production.

## I/O
**Output**: Structured problem statement:
- **What**: 1-2 sentence summary.
- **Why**: Problem it solves.
- **Who**: Target user/persona.
- **Boundaries**: In-scope vs Out-of-scope.

→ Handoff to `/specify` for requirements.

## Rules
- Recommend an answer for every question.
- Invoke `Skill("interviewing-rules")`
