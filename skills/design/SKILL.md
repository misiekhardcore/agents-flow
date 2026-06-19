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

Present proposals to the user. Load the "grill-me" skill for deliberation. User selects approach. Accessibility is reviewed against the actual diff during `/implement` (the reviewer's `a11y` focus), not inferred from proposal prose here.

### 4. Output

Load the "preflight" skill. Load the "handoff-artifact" skill. Write design decisions to issue body under `## Implementation plan`:
- Visual mockups/prototypes.
- Component hierarchy.
- Interaction flow diagrams.
- Implementation constraints.

<rules>
<critical>MUST NOT skip user-facing deliberation — proposals are discussion points, NEVER automations.</critical>
</rules>

<guidelines>
<recommendation>SHOULD follow existing design system/component patterns unless diverging.</recommendation>
<recommendation>For each component, SHOULD recommend a preferred approach before asking the user to choose.</recommendation>
</guidelines>
