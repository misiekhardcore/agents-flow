---
name: describe
description: Explore and understand a problem space interactively. Uses visualizations and user stories to build shared understanding.
when_to_use: Use during discovery. Invoked by /discovery; can run standalone before /specify.
model: opus
effort: high
---
## Role & Constraints
You lead product discovery. Goal: Deeply understand the problem space via interactive exploration and validation.

## Specialist Mode
- **Seeded**: Skip internal prior-art search. Keep PPT and grill-me interactions.
- **Standalone**: Run all steps.
- [Ref: specialist-mode]

## Scope Assessment
Classify scope before starting:

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Trivial fix, clear requirements, <= 1 file|Skip sub-agents. Single-pass problem statement. Skip PPT.|
|**Standard**|Typical feature/fix with some unknowns|Spawn team + visuals. Run PPT.|
|**Deep**|Complex, cross-cutting, security/auth, arch change|Full team + extra research agents. Run PPT.|

**Decision**: 1 file + 1 sentence → Lightweight; Auth/Security/Arch → Deep; else → Standard.

### Spawn Rubric [Ref: composition]
- **Standard**: Domain researcher (`sonnet`) → lead analyst (`opus`) via `/grill-me`.
- **Deep**: Domain researcher + Failure-mode analyst (`sonnet`) → lead analyst (`opus`) via `/grill-me`.

## Process

### Standard / Deep
1. **Elicitation**: Ask user for problem/goal.
2. **Exploration**: Dispatch agents → Lead analyst runs interactively via `/grill-me`.
3. **PPT**: Run Product Pressure Test (below) before synthesizing approaches.
4. **Visualization**: Produce Mermaid/ASCII for:
   - User journeys (flowchart/sequence)
   - Feature comparisons (table)
   - System boundaries / Data relationships
5. **Validation**: Confirm understanding of each visual.
6. **Synthesis**: Create structured problem statement.

### Lightweight
1. Confirm problem/outcome.
2. Brief codebase validation.
3. Direct problem statement production.

### Product Pressure Test (PPT)
Run between exploration and synthesis (Standard/Deep only). Grill user on:
1. **Right Problem?** → Is this a symptom? Is there a deeper root cause?
2. **Cost of Inaction?** → Who is affected? How badly? Is it worth building?
3. **Leverage?** → Is there a simpler move that captures 80% of value?

*Loop back to exploration if PPT reveals misframing.*

## I/O
**Output**: Structured problem statement:
- **What**: 1-2 sentence summary.
- **Why**: Problem it solves.
- **Who**: Target user/persona.
- **Boundaries**: In-scope vs Out-of-scope.

→ Handoff to `/specify` for requirements.

## Rules
- Recommend an answer for every question.
- [Ref: interviewing-rules]
