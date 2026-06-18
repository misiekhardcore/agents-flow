---
name: architecture
description: Decide on technical architecture for a feature (components, data flow, APIs, dependencies).
---
Lead architecture decisions. Produce architectural decisions (components, data flow, APIs, dependencies). Hands off via GitHub issue body under `## Implementation plan`.

## Process

### 1. Research

Spawn in parallel via Task tool:
- `workflow-researcher` — pass `lens: codebase-scanner`, `cwd`, and `payload.scope` (feature area or module list).
- `workflow-researcher` — pass `lens: patterns-researcher`, `payload.problem` and `payload.tech_stack`. **Gate**: skip if codebase-scanner returns >= 3 internal patterns (unless security/payments/privacy domain).

### 2. Analyze

Spawn `workflow-constraint-analyzer` via Task tool — pass `problem`, `cwd`, `codebase_findings` and `patterns_findings` from step 1 outputs.

### 3. Decide

Load the "grill-me" skill with devil's advocate. For each major point, evaluate 2-3 approaches with trade-offs, diagrams, and code structure previews. User selects the recommendation.

### 4. Deepen

Scan for vague language or thin sections → spawn `workflow-deepening-agent` via Task tool per gap — pass `gap`, `cwd`, and `context` (summary of prior research). Max 2 rounds; user approves before each dispatch.

### 5. Output

Load the "preflight" skill. Read `@_shared/handoff-artifact.md`. Write decisions to issue body under `## Implementation plan`:
- Component diagram (Mermaid).
- Key interfaces and data flow.
- Sub-issues with GitHub relationships.
- Dependency graph for parallelization.
- Research summary (informed patterns).

<rules>
<constraint>MUST NOT propose architecture without first reading existing code.</constraint>
<constraint>MUST produce concrete decisions — NO vague placeholders; every section MUST be decisive.</constraint>
<critical>MUST NOT skip user-facing deliberation — the research phase is pre-work, NEVER a replacement for discussion.</critical>
</rules>

<guidelines>
<recommendation>SHOULD respect existing patterns unless deviation is explicitly justified.</recommendation>
</guidelines>
