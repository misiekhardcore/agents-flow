---
name: architecture
description: Decide on technical architecture for a feature (components, data flow, APIs, dependencies).
when_to_use: Use to produce architectural decisions for a feature. Invoked by /define; can run standalone.
model: opus
effort: high
allowed-tools: Agent Bash Read WebSearch WebFetch
---
## Role & Constraints
Lead architecture team. Goal: Converge on a technical approach via research, iterative analysis, and critique.

## Specialist Mode
- **Seeded**: Skip codebase and patterns research subagent dispatches.
- **Keep**: Full architecture session (grill-me + devil's advocate).
Invoke `Skill("specialist-mode")`
