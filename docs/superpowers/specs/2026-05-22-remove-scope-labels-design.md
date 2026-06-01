# Design: Remove Lightweight/Standard/Deep Scope Labels

**Date:** 2026-05-22
**Status:** Approved
**Target issues:** #128–#132, #140–#142, #130–#131

---

## Problem

Every skill (build, review, verify, define, discovery, implement) independently defines a three-way `Lightweight | Standard | Deep` scope label and branches on it. These labels conflate two orthogonal concerns:

|Concern|What it drives|
|-|-|
|**Team shape** — how many agents, which spawn primitive|Agent count, subagents vs TeamCreate|
|**Specialist activation** — which domain experts join|Security reviewer, perf reviewer, migration specialist, etc.|

The labels are also arbitrary: they force every case into one of three buckets regardless of actual complexity, and each skill defines its own (slightly inconsistent) criteria.

---

## Design

### Two concerns, two mechanisms

|Concern|New mechanism|
|-|-|
|Team shape|`scope-assessment` (layer-3) — resource-conflict grouping → agent count and spawn primitive|
|Specialist activation|Per-skill layer-3 assessment skill — reads plan/diff/AC, outputs a list of specialist agent names|

### Scope assessment (unchanged)

`scope-assessment` already exists and is correct. It takes `work_units` (each with an `id` and `resources` list), groups by shared resources, and outputs one agent entry per conflict-free group. The algorithm is shared; per-skill variation is only the _work-unit definition_, which each caller documents in its own `references/scope.md`.

### Per-skill specialist assessment (new)

Each sub-skill gets its own layer-3 skill that decides which specialist agents to activate:

|Sub-skill|Layer-3 assessment skill|
|-|-|
|`/review`|`review-specialist-assessment`|
|`/verify`|`verify-specialist-assessment`|
|`/build`|`build-specialist-assessment`|

Each encodes domain-specific activation logic — the same diff/plan/AC that warrants a security reviewer in `/review` does not drive any specialist decision in `/build`'s parallelism split. This is load-bearing per-skill signal (per `boilerplate-signal-vs-waste` wiki page); a shared parameterized skill would lose this distinction.

**Each assessment skill:**

- Receives the plan/diff/AC from its caller's context
- Outputs a flat list of specialist agent names: `specialists: [reviewer-security, reviewer-perf]`
- Is invoked at entry by the sub-skill, whether seeded or standalone

### Specialist definitions (new)

Specialists are custom agent files in `agents/`. Reused across skills.

Initial set:

|Agent file|Role|
|-|-|
|`agents/reviewer-security.md`|Auth, injection, secrets, privilege escalation|
|`agents/reviewer-perf.md`|N+1 queries, memory leaks, hot path regressions|
|`agents/reviewer-migration.md`|Schema migrations, backwards compatibility, rollback safety|
|`agents/reviewer-correctness.md`|Logic errors, edge cases, error handling|
|`agents/reviewer-standards.md`|Code conventions, naming, style|

Each agent file declares its own model, `disallowedTools`, and focused system prompt. New specialists are added as skills are rebuilt — this list is not exhaustive at design time.

### Entry paths for sub-skills

Sub-skills have two entry paths, both supported:

**Seeded** (invoked by an orchestrator with `<seed-brief>`):

1. `Skill("specialist-mode")` detects brief → extracts `preflight_verified`, `repo`, `branch`, `active_issue`; skips repo/scope preflights
2. Sub-skill invokes its own `*-specialist-assessment` with plan/diff/AC from brief payload
3. Proceeds with the resulting `specialists` list

**Standalone** (user invokes sub-skill directly, no seed-brief):

1. `Skill("specialist-mode")` detects no brief → all preflights run
2. Sub-skill invokes its own `*-specialist-assessment` with plan/diff/AC from context
3. Proceeds with the resulting `specialists` list

Both paths converge after specialist assessment. No branching after that point.

### seed-brief schema change

Drop `scope_class`. Orchestrators no longer determine or pass a scope label. The seed-brief shrinks:

**Removed field:**

```yaml
scope_class: Standard # ← removed
```

**No replacement field.** Specialist activation is handled entirely inside each sub-skill via its own assessment skill. Orchestrators pass plan/diff/AC context in `payload` — sub-skills derive specialists from that.

Updated required fields:

|Field|Type|Notes|
|-|-|-|
|`preflight_verified`|bool|Must be `true`|
|`repo`|string|`owner/repo`|
|`branch`|string|`feat/<slug>`|
|`active_issue`|int|GitHub issue ID|
|`payload`|object|`type: research\|fix\|prior-art` with plan/diff/AC content|
|`autonomous`|bool|Optional, default `false`|

### specialist-mode skill change

`specialist-mode` currently detects the seed-brief and reads `scope_class`. After this change:

- Detection logic unchanged
- `scope_class` extraction removed
- Seeded execution delta table updated: remove all rows that mention scope class
- Standalone path: skill runs its own preflights, then delegates to its `*-specialist-assessment`

### Orchestrator skills (implement, define, discovery)

Remove all L/S/D tables and branching. Orchestrators:

1. Run `scope-assessment` to determine agent count and spawn primitive
2. Build seed-brief without `scope_class`
3. Pass plan/AC in `payload` so sub-skills have context for specialist assessment

### AUTHORING.md

Add a section documenting the two-mechanism pattern:

- `scope-assessment` for team shape (shared layer-3, per-caller work-unit definition in `references/scope.md`)
- `*-specialist-assessment` for specialist activation (per-skill layer-3, domain-specific logic)

---

## Files touched

|File|Change|
|-|-|
|`skills/seed-brief/SKILL.md`|Remove `scope_class` field|
|`skills/specialist-mode/SKILL.md`|Remove `scope_class` extraction; update execution delta table|
|`skills/build/SKILL.md` + `references/scope.md`|Remove L/S/D table; invoke `build-specialist-assessment`|
|`skills/review/SKILL.md` + `references/dispatch-process.md`|Remove L/S/D table; invoke `review-specialist-assessment`|
|`skills/verify/SKILL.md`|Remove L/S/D table; invoke `verify-specialist-assessment`|
|`skills/define/SKILL.md`|Remove L/S/D table|
|`skills/discovery/SKILL.md`|Remove L/S/D table|
|`skills/implement/SKILL.md` + `references/scope-cycles.md`|Remove L/S/D table|
|`skills/build-specialist-assessment/SKILL.md`|New layer-3 skill|
|`skills/review-specialist-assessment/SKILL.md`|New layer-3 skill|
|`skills/verify-specialist-assessment/SKILL.md`|New layer-3 skill|
|`agents/reviewer-security.md`|New specialist agent|
|`agents/reviewer-perf.md`|New specialist agent|
|`agents/reviewer-migration.md`|New specialist agent|
|`agents/reviewer-correctness.md`|New specialist agent|
|`agents/reviewer-standards.md`|New specialist agent|
|`_templates/AUTHORING.md`|Document two-mechanism pattern|

---

## What does not change

- `scope-assessment` layer-3 skill — algorithm unchanged; per-skill `references/scope.md` work-unit definitions unchanged
- `seed-brief` format (XML tag, raw YAML, no inner fence) — only `scope_class` field removed
- `specialist-mode` detection logic — seed-brief presence detection unchanged
- Sub-skill entry path for seeded vs standalone — same two paths, just specialist derivation moves into the new assessment skills
- The rebuild issue tracker (#128–#142) — this design feeds into those issues; no new top-level issues needed unless the implementing session decides to split
