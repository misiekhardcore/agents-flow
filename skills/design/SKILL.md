---
name: design
description: Explore visual and UX design (UI layouts, interaction flows, component structure).
when_to_use: Use to produce UI/UX design decisions. Invoked by /define; can run standalone.
model: sonnet
allowed-tools: Agent Bash Read
user-invocable: true
---
Lead UI/UX design decisions. Produce visual and interaction design that fits existing systems. Hands off via GitHub issue body under `## Implementation plan`.

## Process

### 1. Research

Spawn `Agent("design/agents/ux-researcher.md")` — pass `component` (target UI component or flow) and `context` (product context and target users).

### 2. Design

For each component, propose 2-3 visual/interaction approaches:
- Prototypes (screenshots/code).
- Wireframes (ASCII/Mermaid).
- Interaction flows (state machines/sequence).
- Component hierarchy trees.

### 3. Evaluate

Spawn `Agent("design/agents/reviewer-a11y.md")` — pass `component` and `proposals` (list of approach names and descriptions).

Present a11y findings alongside proposals. Invoke `Skill("grill-me")` for deliberation. User selects approach.

### 4. Output

Invoke `Skill("preflight")`. Read `_shared/handoff-artifact.md`. Write design decisions to issue body under `## Implementation plan`:
- Visual mockups/prototypes.
- Component hierarchy.
- Interaction flow diagrams.
- Implementation constraints.

## Rules

- **Consistency**: Follow existing design system/component patterns unless diverging.
- **Recommend an answer**: For each component, recommend a preferred approach before asking the user to choose.
- **Stay interactive**: Never skip user-facing deliberation — proposals and a11y review are discussion points, not automations.
