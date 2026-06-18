---
name: design
description: Explore visual and UX design (UI layouts, interaction flows, component structure).
---
Lead UI/UX design decisions. Produce visual and interaction design that fits existing systems. Hands off via GitHub issue body under `## Implementation plan`.

## Process

### 1. Research

Spawn `workflow-researcher` via Task tool — pass `lens: ux-researcher`, `payload.component` (target UI component or flow), and `payload.context` (product context and target users).

### 2. Design

For each component, propose 2-3 visual/interaction approaches:
- Prototypes (screenshots/code).
- Wireframes (ASCII/Mermaid).
- Interaction flows (state machines/sequence).
- Component hierarchy trees.

### 3. Evaluate

Spawn `workflow-reviewer` via Task tool — pass `focus: a11y`, `payload.component` and `payload.proposals` (list of approach names and descriptions).

Present a11y findings alongside proposals. Load the "grill-me" skill for deliberation. User selects approach.

### 4. Output

Load the "preflight" skill. Read `@_shared/handoff-artifact.md`. Write design decisions to issue body under `## Implementation plan`:
- Visual mockups/prototypes.
- Component hierarchy.
- Interaction flow diagrams.
- Implementation constraints.

## Rules

- **Consistency**: Follow existing design system/component patterns unless diverging.
- **Recommend an answer**: For each component, recommend a preferred approach before asking the user to choose.
- **Stay interactive**: Never skip user-facing deliberation — proposals and a11y review are discussion points, not automations.
