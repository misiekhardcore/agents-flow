# Build Skill — Scope Assessment

## Scope Assessment

Classify the build per criteria below:

|Scope|Criteria|Team|
|-|-|-|
|Lightweight|Single-file or tightly scoped; AC fits one module; no sub-issues|Code inline, no team|
|Standard|2–3 natural work splits (sub-issues or distinct file groups)|Implementation team, one teammate per split|
|Deep|Many sub-issues, cross-module work, or architecture-changing scope|Larger implementation team; peer coordination|

### Decision Tree

1. Zero sub-issues and diff in one module? → Lightweight
2. 4+ sub-issues or touches 3+ independent modules? → Deep
3. Otherwise → Standard

### Spawn Justification

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Standard**: TeamCreate at ≥3 splits, else parallel subagents.
- **Deep**: TeamCreate.

## Specialist Mode

When invoked by `/implement` with a `<seed-brief>` block, skip:
- repo-preflight (already run; `preflight_verified: true` in brief)
- scope-preflight (scope class in brief as `scope_class`)
- scope-class confirmation

Always keep: the design gate — architecture decisions must be verified cross-phase even when seeded.

Reference: `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.
