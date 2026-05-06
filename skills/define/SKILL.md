---
name: define
description: Full definition phase for a feature. Spawns /architecture and /design to make technical decisions and updates the GitHub issue body.
when_to_use: Use after /discovery has produced an approved issue. Precedes /implement.
argument-hint: "[issue#]"
model: opus
effort: high
---

You are leading the definition phase. Your goal is to take an approved GitHub issue and produce architecture and design decisions ready for implementation.

## Input

A GitHub issue number from /discovery (or provided by the user).

## Scope Assessment

Classify the definition work before dispatching. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the right-sizing rationale.

1. **Lightweight** — single-module technical decision with a clear pattern match already in the codebase; no visual surface; no architectural unknowns.
   - Lead writes an inline architecture summary (3–5 bullets) directly to the issue body. Skip research team and skip `/architecture` as a separate specialist.
2. **Standard** — typical feature with some technical unknowns; may have a visual surface.
   - Research team (both agents) + `/architecture` specialist. Add `/design` when the feature has visual aspects.
3. **Deep** — cross-module, security/payments/privacy, architecture-changing, or migration-bearing.
   - Research team + `/architecture` + `/design` (when applicable) + a second team to critique the plan before finalizing.

Decision tree:

1. Single module, pattern already exists in the codebase, no visual surface, no unknowns? → Lightweight
2. Touches auth/security/payments/privacy, crosses modules, or changes architecture? → Deep
3. Otherwise → Standard

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Research team**: 2 parallel subagents. Comm-pivot ✗ (read-only), disjoint ✓, parallel ✓, payoff ≥3×. Fallback: sequential subagents.
- **Standard definition team**: sequential subagents (architecture → design). Comm-pivot ✗ (strictly ordered), disjoint n/a (sequential), parallel ✗, payoff <3×. Fallback: n/a — no flag dependency.
- **Deep critique team**: TeamCreate. Comm-pivot ✓ (cross-axis critique), disjoint ✓, parallel ✓, payoff ≥3× for high-risk plans. Gate: Deep scope AND security/payments/migration signal. Fallback: sequential subagents.

## Process

1. Read the issue to understand the problem statement and acceptance criteria.

2. **Dispatch 2 parallel research subagents** (one Task tool call per agent in a single message; Standard/Deep only — skip in Lightweight):
   - **Codebase research agent** — scans tech stack, modules, related implementations, naming, existing patterns. Outputs a structured brief.
   - **Patterns/learnings agent** — gathers prior art from, in order: (1) the claude-obsidian vault via `claude-obsidian:wiki-query` if available (concepts/entities/sources/meta); (2) project docs (READMEs, ADRs, `docs/**`); (3) external sources via Context7 when local patterns are thin. If `claude-obsidian` is not installed, step 1 is skipped with a note. Skip external research when internal sources yield 3+ direct pattern examples; always run full research for security/payments/privacy.

   The brief feeds both the architecture and design specialists as seed context.

3. **Run the definition specialists** per the Spawn justification block:
   - **Lightweight**: lead writes the architecture summary inline against the research already in the issue.
   - **Standard**: run Architecture as a sequential subagent seeded with the research brief, then Design as a sequential subagent when the feature has visual aspects.
   - **Deep**: same as Standard, then spawn the critique team (adversarial review, migration safety, rollout risks).

4. The architecture specialist goes first. Once technical decisions are approved by the user, the design specialist (if applicable) works within those constraints. In Deep scope, the critique team runs after both and before user sign-off.

5. See `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md` before updating the issue body or creating sub-issues.

   **Update the GitHub issue body** with decisions. The body is the handoff artifact, single source of truth — always update it in place, never post handoff state as a comment:
   - If the body already has a `## Implementation plan` section, edit it. If not, append one.
   - Record architecture decisions and design decisions (with visuals) inside that section.
   - Create sub-issues with GitHub relationships if the work decomposes.
   - Define the dependency graph — identify what can be parallelized.
   - The updated body is the sole input to `/implement` — a fresh session will read it, not this conversation. Mandatory fields: Acceptance criteria and Constraints. Optional fields (omit heading when empty, no "None" placeholders): Prior decisions, Evidence, Open questions. See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md`.

6. Present all decisions to the user for approval. Do not proceed until sign-off.

7. After sign-off, instruct the user: "Start `/implement` in a fresh session; this one is closed." Do not call `/implement` from within `/define`.

## Rules

- **Require explicit full approval** before finalizing. Partial feedback is NOT approval.
- Spawn primitives and gates per the Spawn justification block above.
- Respect existing codebase patterns unless there's a strong reason to deviate
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol — apply it throughout all user interactions.
