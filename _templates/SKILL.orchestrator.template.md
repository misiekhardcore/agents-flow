---
name: <skill-name>
description: <Leads the X phase. Use when Y.>
model: <opus for research-leading orchestrators; sonnet for coordinator orchestrators>
# effort: high  # Uncomment for research-leading orchestrators only
---
You are leading the <phase name> phase. Your goal is to <objective>.

<!-- Coordinator: drop step 2. Terminal: drop step 5. -->

## Input

<!-- What the orchestrator receives — issue number, handoff block, or problem statement. -->

## Scope Assessment

Classify before dispatching per `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` (cost models).

- **Lightweight** — <heuristic>. Lead inline; no team; skip step 2.
- **Standard** — <heuristic>. Core specialists; optional dormant.
- **Deep** — <heuristic>. Full team + critique/adversarial.

### Spawn justification

Document choice explicitly. State which rubric factors apply (comm pivot, disjoint, parallel, payoff) and which gates trigger dispatch. Triggers: parallelism payoff AND/OR inline overrun (multi-file sweep, N-way fan-out, verbose I/O). See `/discovery`, `/define`, `/implement` patterns.

## Process

1. Read input; confirm scope classification.
2. **Research team** (TeamCreate; Standard/Deep only):
   - **Codebase research** — tech stack, modules, patterns. Outputs research brief.
   - **Prior art** — vault, project docs, external sources.
3. **Main team** (TeamCreate), seeded with research. Width = scope. Include only needed specialists:
   - **Specialist A** — `/<skill>` to <do thing>. Seeded; skips research.
   - **Specialist B** — `/<skill>` to <do thing>.
4. <Serialization rule — which specialist first and why.>
5. **Handoff artifact** — update GitHub issue body in place with decisions and five-field block.
6. Present output; require explicit approval. After sign-off, tell user to start next phase fresh.

## Output

<!-- Durable artifact — issue body update, sub-issues, PR, etc. -->

## Rules

- Require explicit approval. Silence is NOT approval.
- Research team before main team in Standard/Deep. Never skip seed-brief gate.
- Lightweight inline. Never pay overhead for <1 min work.
- See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` and `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`.
