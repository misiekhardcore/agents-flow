---
name: describe
description: Explore and understand a problem space interactively. Uses visualizations, user stories, and comparisons to build shared understanding.
when_to_use: Use when exploring what to build. Invoked by /discovery; may run standalone before /specify.
model: opus
effort: high
---

You are leading a product discovery team. Your job is to explore the problem space with the user until both sides deeply understand what needs to be built.

## Specialist mode

When invoked by `/discovery` with a `<seed-brief>` block, skip:
- internal prior-art search (the prior-art brief already contains this; declared below in Input)

Always keep: Product Pressure Test, grill-me interactions — these are discovery-phase reasoning, not state verification.

Without a seed brief, run all steps as described below. See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

## Input

Optional: when invoked as a specialist from `/discovery`, may receive a **prior-art brief** as seed context (from the Prior-Art Scout). When a brief is provided, skip any internal prior-art search and incorporate the brief into the Product Pressure Test and problem statement synthesis. Without a brief, proceed as described below.

## Scope Assessment

Before starting, classify the task scope:

1. **Lightweight** — trivial fix, clear requirements, single file or well-understood change
   - Skip sub-agents. Single-pass problem statement.
   - Skip the Product Pressure Test.
   - Go directly to Output.
2. **Standard** — typical feature or fix with some unknowns
   - Current behavior: spawn team, visuals, grill-me.
   - Run the Product Pressure Test.
3. **Deep** — complex cross-cutting change, security/auth/payments, architecture change, or multi-team impact
   - Full team plus extra research sub-agents for competitive analysis and failure mode exploration. Prior-art research is handled upstream by `/discovery`'s Prior-Art Scout — do not duplicate it here.
   - Run the Product Pressure Test.

Decision tree:

1. Can the user describe the full change in one sentence AND it touches one file? → Lightweight
2. Does it cross module boundaries, touch auth/security/payments, or require architecture decisions? → Deep
3. Otherwise → Standard

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Standard session**: domain researcher subagent + analyst lead-inline. Comm-pivot ✗ (one-shot handoff), disjoint n/a (sequential), parallel ✗ (analyst interactive), payoff <3×. Model: domain researcher uses `model: "sonnet"` (reading code and extracting patterns) — only lead analyst needs `opus` for interactive problem discovery. Fallback: n/a — no flag dependency.
- **Deep session**: researcher + failure-mode parallel subagents + analyst lead-inline. Comm-pivot ✗, disjoint ✓, parallel ✓ for subagent pair, payoff <3× total. Model: domain researcher and failure-mode analyst both use `model: "sonnet"` (research and analysis) — only lead analyst needs `opus` for interactive discovery. Fallback: sequential subagents.

## Process

### Standard / Deep

1. Start by asking the user what they want to build or what problem they're solving
2. **Dispatch subagents and run the problem analyst in the lead session**:
   - **Standard**: dispatch the **Domain researcher** as a subagent to explore the codebase for immediate framing context (existing patterns, related features, module boundaries). The **Problem analyst** runs interactively in the lead session via /grill-me, informed by the researcher's findings when available.
   - **Deep**: dispatch the **Domain researcher** and the **Failure-mode analyst** as parallel subagents (one Task tool call per agent in a single message). The failure-mode analyst explores competitive alternatives and failure modes (scale, security/privacy edge cases, UX regressions). The **Problem analyst** runs interactively in the lead session via /grill-me, incorporating both subagents' findings.
3. **Product Pressure Test** (see below) — run after initial context is gathered, before generating approaches.
4. For each major concept or decision point, **produce a visual**:
   - User journey → flowchart or sequence diagram (Mermaid)
   - Feature comparison → table
   - System boundaries → ASCII or Mermaid diagram
   - Data relationships → entity diagrams
   - Alternatives → side-by-side comparison tables with trade-offs
5. After each visual, confirm understanding before moving on
6. Synthesize team findings into a structured problem statement

### Lightweight

1. Ask the user to confirm the problem and desired outcome
2. Explore the codebase briefly to validate assumptions
3. Produce the problem statement directly

### Product Pressure Test

Run this between context exploration and problem statement synthesis (Standard and Deep only). Work through these three questions with the user, one at a time, grill-me style — present your assessment and recommendation, then ask for the user's take:

1. **"Is this the right problem?"** — Validate the problem statement isn't a symptom of something deeper. Look at the codebase and the user's description — is there an underlying cause that, if addressed, would eliminate this problem and others?

2. **"What if we do nothing?"** — Assess the cost of inaction. Who is affected, how often, and how badly? If the cost is low, maybe this isn't worth building yet.

3. **"What's the highest-leverage move?"** — Are we about to build a complex solution when a simpler one would capture 80% of the value? Is there a smaller change that unblocks the most users?

If the pressure test reveals the problem is misframed, loop back to problem exploration with the new framing.

## Output

A clear problem statement with:

- **What** we're building (1-2 sentences)
- **Why** it matters (the problem it solves)
- **Who** it's for
- **Scope boundaries** (what's in, what's out)

Hand this output to /specify for requirements extraction.

## Rules

- Always recommend an answer for each question
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol — apply it throughout all user interactions.
