---
name: review-specialist-assessment
description: Assess which specialist agents to activate for a /review invocation.
user-invocable: false
layer: 3
---
Assess which specialist agents are needed for the current review task. Called by `/review` at entry, whether seeded or standalone.

## Input

Read from caller context:
- **Diff**: `git diff` or `gh pr diff`
- **AC**: from seed brief or linked issue
- **File paths**: from the diff

## Activation Rules

Always activate:
- `reviewer-correctness`
- `reviewer-standards`

Activate conditionally:

|Specialist|Gate|
|-|-|
|`reviewer-security`|Diff contains 2+ of: `auth`, `token`, `session`, `permission`, `password`, `cookie`, `csrf`, `cors` co-occurring in the same file — OR — file paths match `**/auth/**`, `**/security/**`, `**/middleware/**`|
|`reviewer-perf`|Diff touches database queries, loops over collections > 100 items, caching logic, or file paths match `**/db/**`, `**/repository/**`, `**/query/**`|
|`reviewer-migration`|Diff contains migration files, schema changes, or `ALTER TABLE` / `CREATE TABLE` / column add/drop statements|

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: [reviewer-correctness, reviewer-standards]
# or with conditionals:
specialists: [reviewer-correctness, reviewer-standards, reviewer-security, reviewer-perf]
```

List is always sorted alphabetically.
