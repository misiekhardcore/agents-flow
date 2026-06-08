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
Lead design team. Goal: Converge on visual and interaction design that fits existing systems. Produces UI/UX design decisions. Hands off via GitHub issue body under `## Implementation plan`. Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for interviewing constraints.

## Specialist Mode
Invoke `Skill("specialist-mode")` at entry.
- **Seeded**: Architecture decisions + AC from seed-brief. Run research, design session, and proposal refinement.
- **Keep**: Prompt user for context. Run research, design session, and proposal refinement.

## I/O
- **Input**: GitHub issue with architecture decisions (from /define).
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
