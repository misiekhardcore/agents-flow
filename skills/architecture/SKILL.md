---
name: architecture
description: Decide on technical architecture for a feature (components, data flow, APIs, dependencies).
when_to_use: Use to produce architectural decisions for a feature. Invoked by /define; can run standalone.
model: opus
effort: high
allowed-tools: Agent Bash Read WebSearch WebFetch
user-invocable: true
---
Lead architecture decisions. Produce architectural decisions (components, data flow, APIs, dependencies). Hands off via GitHub issue body under `## Implementation plan`.

## Process

### 1. Research

Spawn in parallel:
- `Agent("agents/workflow-codebase-scanner.md")` — pass `cwd` and `scope` (feature area or module list).
- `Agent("agents/workflow-patterns-researcher.md")` — pass `problem` and `tech_stack`. **Gate**: skip if codebase-scanner returns >= 3 internal patterns (unless security/payments/privacy domain).

### 2. Analyze

Spawn `Agent("agents/workflow-constraint-analyzer.md")` — pass `problem`, `cwd`, `codebase_findings` and `patterns_findings` from step 1 outputs.

### 3. Decide

Invoke `Skill("grill-me")` with devil's advocate. For each major point, evaluate 2-3 approaches with trade-offs, diagrams, and code structure previews. User selects the recommendation.

### 4. Deepen

Scan for vague language or thin sections → spawn `Agent("agents/workflow-deepening-agent.md")` per gap — pass `gap`, `cwd`, and `context` (summary of prior research). Max 2 rounds; user approves before each dispatch.

### 5. Output

Invoke `Skill("preflight")`. Read `_shared/handoff-artifact.md`. Write decisions to issue body under `## Implementation plan`:
- Component diagram (Mermaid).
- Key interfaces and data flow.
- Sub-issues with GitHub relationships.
- Dependency graph for parallelization.
- Research summary (informed patterns).

## Rules

- **Code-First**: Never propose architecture without reading existing code.
- **Pattern Adherence**: Respect existing patterns unless justifying deviation.
- **Concrete Only**: No vague placeholders; every section must be decisive.
- **Stay interactive**: Never skip user-facing deliberation — the research phase is pre-work, not a replacement for discussion.
