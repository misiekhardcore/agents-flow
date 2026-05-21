---
name: design
description: Explore visual and UX design (UI layouts, interaction flows, component structure).
when_to_use: Use to produce UI/UX design decisions. Invoked by /define; can run standalone.
model: sonnet
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead design team. Goal: Converge on visual and interaction design that fits existing systems.

## Specialist Mode
- **Seeded**: Skip design-space research subagent.
- **Keep**: Interactive session (grill-me + a11y review).
- Invoke `Skill("specialist-mode")`

## I/O
- **Input**: GitHub issue with architecture decisions (from /define).
- **Optional**: Research brief (`tech_stack`, `module_map`, `patterns`, etc.). UX researcher skips patterns already covered.
- **Output**: Decisions as issue comments:
  - Visual mockups/prototypes.
  - Component hierarchy.
  - Interaction flow diagrams.
  - Implementation constraints.

## Process
1. **Constraints Review**: Analyze issue and architecture decisions.
2. **Design Session** (Sequential):
   - **UX Researcher** (`haiku`): Explore existing UI patterns, a11y requirements, design system.
   - **Design Proposer** (`sonnet`): Lead interactively via `/grill-me`.
   - **A11y Reviewer** (`haiku`): Evaluate proposals for compliance, keyboard nav, screen readers.
3. **Visual Proposals**: Present 2-3 approaches:
   - Prototypes (screenshots/code).
   - Wireframes (ASCII/Mermaid).
   - Interaction flows (state machines/sequence).
   - Component hierarchy trees.
4. **Selection**: User picks approach → design becomes an implementation constraint.

## Applicability
- **Apply**: Visual aspects (UI, frontend, webview).
- **Skip**: Purely backend/infra work (use `/architecture` instead).

## Rules
- **Consistency**: Follow existing design system/component patterns unless diverging.
- Invoke `Skill("interviewing-rules")`
