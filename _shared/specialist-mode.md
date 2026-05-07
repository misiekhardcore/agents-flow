# Specialist Mode — Shared Protocol

Logic for standalone vs. orchestrator-invoked (seeded) execution.

## Detection
`specialist_mode = True` if `<seed-brief>` block exists in prompt.
- **Seeded**: Verified fields replace preflights.
- **Standalone**: All prompts active.

## Seed-Brief Contract
**Format**: Raw YAML in XML tag `<seed-brief>`, no inner fence.

|Field|Type|Req|Notes|
|-|-|-|-|
|`preflight_verified`|bool|Yes|Must be `true`|
|`scope_class`|string|Yes|`Lightweight`, `Standard`, or `Deep`|
|`repo`|string|Yes|`owner/repo` (verified vs `git remote -v`)|
|`branch`|string|Yes|`feat/<slug>` (verified vs `git rev-parse`)|
|`active_issue`|int|Yes|GitHub issue ID|
|`payload`|object|Yes|`{ type: fix\|research\|prior-art, ... }` (per `composition.md`)|
|`autonomous`|bool|No|Default `false`. If `true`, suppresses `/implement` exit prompt|

**Failure**: Invalid brief → Fallback to standalone + log failure.

## Execution Delta
Confirmations verifying *state* are skipped; *discovery/rigor* gates remain.

|Specialist|Skipped when Seeded|Always Kept|
|-|-|-|
|`/build`|repo/scope preflights, scope confirmation|design gate|
|`/review`|repo-preflight|severity/depth gates|
|`/verify`|repo-preflight|AC verification rigor|
|`/describe`|internal prior-art search|PPT, grill-me|
|`/specify`|scope/file confirmation|AC derivation gates|
|`/architecture`|codebase/pattern research|architecture session (grill-me/devil's advocate)|
|`/design`|design-space research|interactive session|
|`/implement`|(handled by orchestrator)|exhausted-exit prompt (unless `autonomous: true`)|

## Orchestrator Duties
1. Run repo/scope-preflight once at entry.
2. Pass valid seed-brief (`preflight_verified: true`) to every specialist.
3. Include `repo`, `branch`, `active_issue` for sanity checks.
