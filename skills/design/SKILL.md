---
name: design
description: Explore visual and UX design (UI layouts, interaction flows, component structure).
when_to_use: Use to produce UI/UX design decisions. Invoked by /define; can run standalone.
model: sonnet
allowed-tools: Agent Bash Read
layer: 2
user-invocable: true
---
## Role & Constraints
Lead UI/UX design decisions. Goal: Produce visual and interaction design that fits existing systems. Hands off via GitHub issue body under `## Implementation plan`.

## Specialist Mode
Invoke `Skill("specialist-mode")` at entry.
- **Seeded**: Fully autonomous. No user interaction. Produce design decisions and return.
- **Standalone**: Interactive. Prompt user for context. Run research, design session (grill-me + a11y review), and proposal presentation.

## I/O
- **Input**: GitHub issue with architecture decisions.
- **Output**: Design decisions under `## Implementation plan`:
  - Visual mockups/prototypes.
  - Component hierarchy.
  - Interaction flow diagrams.
  - Implementation constraints.

## Process
1. **Constraints Review**: Analyze issue and architecture decisions.
2. **Research**: Explore existing UI patterns, a11y requirements, design system.
3. **Design**: For each component, propose 2-3 visual/interaction approaches:
   - Prototypes (screenshots/code).
   - Wireframes (ASCII/Mermaid).
   - Interaction flows (state machines/sequence).
   - Component hierarchy trees.
4. **Evaluate**: Review proposals for a11y compliance, keyboard nav, screen readers.
5. **Output**: Write design decisions to issue body under `## Implementation plan`.

## Applicability
- **Apply**: Visual aspects (UI, frontend, webview).
- **Skip**: Purely backend/infra work (use `/architecture` instead).

## Rules
- **Consistency**: Follow existing design system/component patterns unless diverging.
