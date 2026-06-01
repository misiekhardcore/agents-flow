---
name: verify-specialist-assessment
description: Assess which specialist agents to activate for a /verify invocation.
user-invocable: false
layer: 3
---
Assess which specialist agents are needed for the current verification task. Called by `/verify` at entry, whether seeded or standalone.

## Input

Read from caller context:
- **AC**: acceptance criteria from the issue or seed brief
- **Diff**: `git diff` from the feature branch
- **Plan / prior art**: from seed brief `payload.prior_art` or issue `## Implementation plan`

## Activation Rules

|Specialist|Gate|
|-|-|
|`reviewer-migration`|AC or plan mentions migration, rollback, backwards compatibility, or diff contains schema change files|

**No other specialists are activated for `/verify`.** Verify agents confirm pass/fail against AC — they do not re-run security or perf analysis. Those belong to `/review`.

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: []
# or, if migration gate fires:
specialists: [reviewer-migration]
```
