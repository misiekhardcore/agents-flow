# Scope Assessment and Product Pressure Test

## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Narrow/single-area**|Trivial fix, clear requirements, ≤ 1 file|Skip sub-agents. Single-pass problem statement. Skip PPT.|
|**Multi-area or complex**|Typical feature/fix with some unknowns|Spawn team + visuals. Run PPT.|

**Decision**: 1 file + 1 sentence → Narrow/single-area; complex/cross-cutting → Multi-area or complex; else default to full process.

### Spawn Rubric

Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.
- **Multi-area or complex**: Domain researcher (`sonnet`) → lead analyst (`opus`) via `/grill-me`.
- **With extra complexity**: Domain researcher + Failure-mode analyst (`sonnet`) → lead analyst (`opus`) via `/grill-me`.

## Product Pressure Test (PPT)

Run between exploration and synthesis for multi-area or complex problems. Invoke `Skill('grill-me')` with the user on:

1. **Right Problem?** → Is this a symptom? Is there a deeper root cause?
2. **Cost of Inaction?** → Who is affected? How badly? Is it worth building?
3. **Leverage?** → Is there a simpler move that captures 80% of value?

*Loop back to exploration if PPT reveals misframing.*
