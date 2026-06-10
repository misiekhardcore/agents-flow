---
name: discovery
description: Full discovery phase — explore a problem and produce a GitHub issue with AC.
when_to_use: Start of any new feature or vague problem. Precedes /define.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead discovery phase. Goal: Transform vague ideas into well-specified GitHub issues ready for architecture and implementation.

## Team Shape

Invoke `Skill("scope-assessment")` with work units derived from the problem statement.

For high-risk plans (security, payments, arch-changing scope): spawn in parallel:
  - `Agent("discovery/agents/flow-analyst.md")` — pass `domain`, `problem_statement`, `ac`, `cwd`
  - `Agent("discovery/agents/adversarial-questioner.md")` — pass `domain`, `problem_statement`, `ac`

Determine scope from the problem domain and complexity — not a label.

## Process

1. **Ingestion**: Read issue (problem statement + AC). If no issue exists, elicit a problem statement from the user.
2. **Scoping**: Each work unit from the scope assessment is a candidate (group) for delegation to
3. **Delegation** (sequentially, per work, group one by one):
   - **3a**: Dispatch `Agent("discovery/agents/prior-art-scout.md")` (parallel sub-agents if multiple work units) with work unit context and `cwd` -> receive prior art findings. Summarize findings for next step.
   - **3b**: Invoke `Skill("describe")` with the research brief in payload. User interaction - PPT, visualization, problem statement validation. Get the response in chat, not in GitHub issue.
    - **3c**: For complex work units, invoke `Skill("specify")` to derive acceptance criteria from the problem statement. Get the response in chat, not in GitHub issue.
4. **Review and decision**: Verify all work units have a problem statement and AC. If multiple approaches exist for a work unit, present them to the user for selection. Re-iterate until you fully understand the problem and receive user approval.
5. **Synthesize**: Combine all work unit outputs into a cohesive GitHub issue body. Ensure the problem statement is clear and concise, and that AC are specific and testable.
6. **Handoff**: Invoke `Skill("preflight")`. Create the issue using `gh issue`.
   Suppress branch line: true

   **Structure** — use `## Requirements` heading. Read `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for field list:
   - **Preamble**: What, Why, Who (from `/describe`).
   - `## Requirements`: Acceptance criteria → Constraints → Prior decisions (optional) → Evidence (optional) → Open questions (optional).
7. **Sign-off**: Require explicit user approval.
8. **Closure**: Invoke `Skill("compound")` with current issue to trigger follow-ups. Then instruct user: "Start `/implement` in a fresh session."

## Rules
- **Delegate, don't duplicate**: Sub-skills own their domain work. Do not research or produce describe/specify output yourself.
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Persistence**: Prior-Art Scout findings must be persisted in Prior decisions/Evidence fields.
- **Traceability**: Every feature must have one issue and can have multiple sub-issues with proper relationships set on github.
- **Sourcing**: Invoke `Skill("preflight")` before creating issue.
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`
