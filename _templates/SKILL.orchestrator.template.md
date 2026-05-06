---
name: "<skill-name>"
description: "<Leads the X phase. Use when Y.>"
model: "<opus for research-leading orchestrators; sonnet for coordinator orchestrators>"
# effort: high  # Uncomment for research-leading orchestrators only
---

You are leading the <phase name> phase. Your goal is to <objective>.

<!-- Coordinator variants (e.g. /implement): drop step 2 — upstream phases or sub-skills own research. -->
<!-- Coordinator variants that are terminal phases (e.g. /implement): drop step 5 — output is the PR, not an issue body update. -->

## Input

<!-- What the orchestrator receives — issue number, handoff block, or problem statement. -->

## Scope Assessment

Classify before dispatching. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the right-sizing rationale and cost models.

- **Lightweight** — <heuristic>. Lead runs inline; no team; skip step 2.
- **Standard** — <heuristic>. Core specialists only; optional roles stay dormant.
- **Deep** — <heuristic>. Full team + critique/adversarial pass.

### Spawn justification

Document your choice explicitly. State which rubric factors from composition.md apply (communication pivot, file disjointness, parallelism, wall-clock payoff) and which gate conditions trigger dispatch. See `/discovery`, `/define`, `/implement` for the established pattern.

## Process

1. Read the input and confirm the scope classification.
2. **Dispatch a research team** (TeamCreate; Standard/Deep only — skip in Lightweight):
   - **Codebase research agent** — scans tech stack, modules, patterns. Outputs a research brief.
   - **Patterns/learnings agent** — gathers prior art from the vault (`claude-obsidian:wiki-query` if available), then project docs, then external sources.
3. **Spawn the main team** (TeamCreate), seeded with research output. Width scales with scope — include only the specialists the classification calls for:
   - **Specialist A** — runs /<skill> to <do thing>. Seeded with brief; skips internal research.
   - **Specialist B** — runs /<skill> to <do thing>.
4. <Serialization rule — which specialist goes first and why.>
5. **Write the handoff artifact** — update the GitHub issue body in place with decisions and the five-field block. See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md`.
6. Present output to the user for approval. After sign-off, tell them to start the next phase in a fresh session.

## Output

<!-- Durable artifact — updated issue body, sub-issues, PR, etc. -->

## Rules

- Require explicit approval before finalizing. Silence is NOT approval.
- Spawn research team before the main team in Standard/Deep — never skip the seed-brief gate.
- Lightweight runs inline — never pay coordination overhead for under-a-minute work.
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` and `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md`.
