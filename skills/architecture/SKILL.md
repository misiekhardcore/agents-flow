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
- Read `_shared/specialist-mode.md`

## I/O
- **Input**: GitHub issue with problem statement and AC (from /discovery).
- **Output**: Decisions as issue comments:
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
2. **Architecture Session** (Sequential):
   - **Analyst** (`sonnet`): Explore constraints (boundaries, topology, integration).
   - **Architect** (`opus`): Lead interactively via `/grill-me`.
   - **Devil's Advocate** (`sonnet`): Challenge proposed approach (risks, edge cases, scale).
3. **Decision Presentation**: For each major point, provide 2-3 approaches:
   - Architecture diagram (Mermaid).
   - Trade-off table (Pros/Cons/Complexity/Risk).
   - Code structure preview (dirs/interfaces).
   - Rationale for recommendation.
4. **Deepening**: Scan for vague language or thin sections → dispatch focused deepening agents (<= 2 rounds).

## Rules
- **Code-First**: Never propose architecture without reading existing code.
- **Pattern Adherence**: Respect existing patterns unless justifying deviation.
- **Concrete Only**: No vague placeholders; every section must be decisive.
- Read `_shared/interviewing-rules.md`
