---
name: architecture
description: Decide on technical architecture for a feature (components, data flow, APIs, dependencies).
when_to_use: Use to produce architectural decisions for a feature. Invoked by /define; can run standalone.
model: opus
effort: high
allowed-tools: Agent Bash Read WebSearch WebFetch
layer: 2
user-invocable: true
---
## Role & Constraints
Lead architecture decisions. Goal: Produce architectural decisions (components, data flow, APIs, dependencies). If not specify otherwise, hands off via GitHub issue body under `## Implementation plan`.

## I/O
- **Input**: GitHub issue or problem statement and AC(s).
- **Output**: Architecture decisions under `## Implementation plan`:
  - Component diagram (Mermaid).
  - Key interfaces and data flow.
  - Sub-issues with GitHub relationships.
  - Dependency graph for parallelization.
  - Research summary (informed patterns).

## Process
1. **Research** (spawn parallel sub-agents):
   - **Codebase Agent** (`sonnet`): Scan tech stack, modules, related patterns in the repo.
   - **Patterns Agent** (`sonnet`): Query `claude-obsidian` → project docs → Context7/Web for external patterns.
   - **Gate**: Skip external research if >= 3 internal patterns found (unless security/payments/privacy).
2. **Analyze**: Explore constraints (boundaries, topology, integration). Challenge assumptions (risks, edge cases, scale).
3. **Decide**: Invoke `Skill("grill-me")` with devil's advocate. For each major point, evaluate 2-3 approaches with trade-offs, diagrams, and code structure previews. User selects the recommendation.
4. **Deepen**: Scan for vague language or thin sections → dispatch focused deepening agents (<= 2 rounds, user approves before dispatch).
5. **Output**: Invoke `Skill("preflight")`, read `_shared/handoff-artifact.md`, and write decisions to issue body under `## Implementation plan` if not specified otherwise.

## Rules
- **Code-First**: Never propose architecture without reading existing code.
- **Pattern Adherence**: Respect existing patterns unless justifying deviation.
- **Concrete Only**: No vague placeholders; every section must be decisive.
- **Recommend an answer**: For each component, recommend a preferred approach before asking the user to choose.
- **Stay interactive**: Never skip user-facing deliberation — the research phase is pre-work, not a replacement for discussion.
