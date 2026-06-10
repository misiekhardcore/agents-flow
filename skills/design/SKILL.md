---
name: design
description: Explore visual and UX design (UI layouts, interaction flows, component structure).
when_to_use: Use to produce UI/UX design decisions. Invoked by /define; can run standalone.
model: sonnet
allowed-tools: Agent Bash Read
user-invocable: true
---
## Role & Constraints
Lead UI/UX design decisions. Goal: Produce visual and interaction design that fits existing systems. If not specify otherwise, hands off via GitHub issue body under `## Implementation plan`.

## I/O
- **Input**: GitHub issue or architecture decisions.
- **Output**: Design decisions:
  - Visual mockups/prototypes.
  - Component hierarchy.
  - Interaction flow diagrams.
  - Implementation constraints.

## Process
1. **Research** (spawn `Agent("design/agents/ux-researcher.md")`):
   - Pass `component` (target UI component or flow) and `context` (product context and target users).
2. **Design**: For each component, propose 2-3 visual/interaction approaches:
   - Prototypes (screenshots/code).
   - Wireframes (ASCII/Mermaid).
   - Interaction flows (state machines/sequence).
   - Component hierarchy trees.
3. **Evaluate** (spawn `Agent("design/agents/reviewer-a11y.md")`):
   - Pass `component` and `proposals` (list of approach names and descriptions).
   - Present a11y findings alongside proposals. Invoke `Skill("grill-me")` for deliberation. User selects approach.
4. **Output**: Invoke `Skill("preflight")`, read `_shared/handoff-artifact.md`, and write design decisions to issue body under `## Implementation plan` if not specified otherwise.

## Rules
- **Consistency**: Follow existing design system/component patterns unless diverging.
- **Recommend an answer**: For each component, recommend a preferred approach before asking the user to choose.
- **Stay interactive**: Never skip user-facing deliberation — proposals and a11y review are discussion points, not automations.
