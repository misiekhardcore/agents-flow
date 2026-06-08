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
Lead architecture decisions. Goal: Produce architectural decisions (components, data flow, APIs, dependencies). Hands off via GitHub issue body under `## Implementation plan`.

## Specialist Mode
Invoke `Skill("specialist-mode")` at entry.
- **Seeded**: Fully autonomous. No user interaction. Produce decisions and return.
- **Standalone**: Interactive. Prompt user for issue. Run research, architecture session (grill-me + devil's advocate), and decision presentation.

## I/O
- **Input**: GitHub issue with problem statement and AC(s).
- **Output**: Architecture decisions under `## Implementation plan`:
  - Component diagram (Mermaid).
  - Key interfaces and data flow.
  - Sub-issues with GitHub relationships.
  - Dependency graph for parallelization.
  - Research summary (informed patterns).

## Process
1. **Research** (Parallel, `sonnet`):
   - **Codebase Agent**: Scan tech stack, modules, related patterns.
   - **Patterns Agent**: Query `claude-obsidian` → Project docs → Context7/Web.
   - **Gate**: Skip external research if >= 3 internal patterns found (unless security/payments/privacy).
2. **Analyze**: Explore constraints (boundaries, topology, integration). Challenge assumptions (risks, edge cases, scale).
3. **Decide**: For each major point, evaluate 2-3 approaches with trade-offs, diagrams, and code structure previews. Pick the recommendation.
4. **Deepen**: Scan for vague language or thin sections → dispatch focused deepening agents (<= 2 rounds).
5. **Output**: Write decisions to issue body under `## Implementation plan`.

## Rules
- **Code-First**: Never propose architecture without reading existing code.
- **Pattern Adherence**: Respect existing patterns unless justifying deviation.
- **Concrete Only**: No vague placeholders; every section must be decisive.
