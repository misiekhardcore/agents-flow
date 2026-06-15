---
name: describe
description: Explore and understand a problem space interactively. Uses visualizations and user stories to build shared understanding.
when_to_use: Use during discovery. Invoked by /discover; can run standalone before /specify.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read AskUserQuestion
user-invocable: true
---
Lead the user conversation during discovery. Deeply understand the problem space via interactive exploration and validation. Produces structured problem statements (What, Why, Who, Boundaries) with prior-art findings.

Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` — adopt atomic questions, rigor, visual-first, explicit approval.

## I/O

- **Input via seed-brief** (from discover): `domain`, `problem_statement`, `cwd`.
- **Input standalone** (user-invocable): problem statement or issue description.
- **Output**: Structured problem statement:
  - **What**: 1-2 sentence summary.
  - **Why**: Problem it solves.
  - **Who**: Target user/persona.
  - **Boundaries**: In-scope vs Out-of-scope.
  - **Prior art**: Findings from codebase research.
  - **Sub-areas**: Optional — if the problem spans multiple independent domains.

## Process

### 1. Ingestion

If invoked with a seed-brief (from discover), use the provided `domain` and `problem_statement` — skip elicitation. If run standalone, elicit the problem from the user.

### 2. Scope

Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

Read `references/scope.md` for work-unit types. Invoke `Skill("scope-assessment")` with work units derived from the problem. Each independent domain is a work unit. Scope-assessment groups disjoint domains for parallel research.

Read `references/scope-ppt.md` for PPT checklist.

### 3. Research

Per scope-assessment group, spawn in parallel:
- `Agent("describe/agents/domain-researcher.md")` — pass `domain`, `cwd`.
- **Gate** (high-risk only: payments, auth, data migration): also spawn `Agent("describe/agents/flow-analyst.md")` — pass `domain`, `cwd`, and entry points from domain-researcher output.

Collect all findings before proceeding.

### 4. PPT

Run Product Pressure Test via `Skill("grill-me")` with user:
1. **Right Problem?** — Is this a symptom? Deeper root cause?
2. **Cost of Inaction?** — Who is affected? How badly?
3. **Leverage?** — Simpler move that captures 80% of value?

Loop back to research if PPT reveals misframing.

### 5. Visualization and Validation

Produce Mermaid/ASCII diagrams for user journeys, feature comparisons, system boundaries. Confirm understanding of each visual with the user. Grill until alignment.

### 6. Synthesis

Return structured problem statement (What, Why, Who, Boundaries, Prior art, Sub-areas). When invoked by discover, output is returned in chat — discover handles the issue body.

## Rules

- **Stay interactive**: Never skip PPT or visual validation — these are discussion points, not automations.
- **Delegate, don't duplicate**: Research agents own their domain. Collect from agents and use in conversation.
