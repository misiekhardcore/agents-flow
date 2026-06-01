---
name: build-specialist-assessment
description: Assess which specialist agents to activate for a /build invocation.
user-invocable: false
layer: 3
---
Assess which specialist agents are needed for the current build task. Called by `/build` at entry, whether seeded or standalone.

## Input

Read from caller context:
- **Plan / prior art**: architecture decisions and implementation notes (from seed brief `payload.prior_art` or issue `## Implementation plan`)
- **AC**: acceptance criteria from the issue
- **Diff** (if already exists): `git diff` from current worktree branch

## Activation Rules

Evaluate each specialist against the plan, AC, and diff:

|Specialist|Activate when|
|-|-|
|`reviewer-migration`|Plan mentions schema changes, migrations, DB column add/drop, or backwards-compatibility constraints|

**No other specialists are activated for `/build`.** Security, perf, correctness, and standards reviewers belong to `/review`, not `/build`. Build's job is to produce the code; review's job is to judge it.

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: []
# or, if migration gate fires:
specialists: [reviewer-migration]
```

If no gates fire, output `specialists: []`. Never output an empty list as a failure — it is the expected result for most builds.
