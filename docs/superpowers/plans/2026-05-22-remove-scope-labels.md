# Remove Lightweight/Standard/Deep Scope Labels — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the arbitrary three-way `Lightweight | Standard | Deep` scope labels with two focused mechanisms: `scope-assessment` (unchanged) for team shape, and per-skill `*-specialist-assessment` layer-3 skills for specialist activation.

**Architecture:** Each sub-skill (`/build`, `/review`, `/verify`) gets its own new layer-3 assessment skill that reads plan/diff/AC and outputs a flat `specialists:` list. Orchestrators (`/define`, `/discovery`, `/implement`) drop their L/S/D tables and pass `payload` context instead of `scope_class`. Five reusable specialist agent files in `agents/` replace the inline persona logic currently embedded in reference files.

**Tech Stack:** Markdown skill files, YAML frontmatter, `agents/` flat directory at plugin root.

**Spec:** `docs/superpowers/specs/2026-05-22-remove-scope-labels-design.md`

---

## File Map

|File|Action|Responsibility|
|-|-|-|
|`skills/seed-brief/SKILL.md`|Modify|Remove `scope_class` from Required Fields table and canonical example|
|`skills/specialist-mode/SKILL.md`|Modify|Remove `scope_class` from contract table; update execution delta table|
|`skills/build/SKILL.md`|Modify|Remove L/S/D table; add `build-specialist-assessment` invocation|
|`skills/build/references/scope.md`|Delete|Replaced by `build-specialist-assessment`|
|`skills/review/SKILL.md`|Modify|Remove L/S/D table ref; add `review-specialist-assessment` invocation|
|`skills/review/references/dispatch-process.md`|Modify|Remove Scope Assessment section|
|`skills/verify/SKILL.md`|Modify|Remove L/S/D table; add `verify-specialist-assessment` invocation|
|`skills/define/SKILL.md`|Modify|Remove L/S/D table; invoke `scope-assessment` instead|
|`skills/discovery/SKILL.md`|Modify|Remove L/S/D table; invoke `scope-assessment` instead|
|`skills/implement/SKILL.md`|Modify|Remove L/S/D table ref|
|`skills/implement/references/scope-cycles.md`|Modify|Remove L/S/D criteria table|
|`skills/build-specialist-assessment/SKILL.md`|Create|New layer-3 skill|
|`skills/review-specialist-assessment/SKILL.md`|Create|New layer-3 skill|
|`skills/verify-specialist-assessment/SKILL.md`|Create|New layer-3 skill|
|`agents/reviewer-security.md`|Create|Specialist agent|
|`agents/reviewer-perf.md`|Create|Specialist agent|
|`agents/reviewer-migration.md`|Create|Specialist agent|
|`agents/reviewer-correctness.md`|Create|Specialist agent|
|`agents/reviewer-standards.md`|Create|Specialist agent|
|`_templates/AUTHORING.md`|Modify|Document two-mechanism pattern|

---

## Task 1: Remove `scope_class` from seed-brief

**Files:**
- Modify: `skills/seed-brief/SKILL.md`

The `scope_class` field must be removed from the Required Fields table, the Orchestrator Duties section, and both YAML examples.

- [ ] **Step 1: Open the file and locate all `scope_class` occurrences**

Run:
```bash
grep -n "scope_class" skills/seed-brief/SKILL.md
```
Expected output: lines 32, 53, 100, 130 (approximately — verify line numbers).

- [ ] **Step 2: Remove `scope_class` row from Required Fields table**

In `skills/seed-brief/SKILL.md`, delete this row from the `## Required Fields` table:
```
|`scope_class`|string|One of: `Lightweight`, `Standard`, or `Deep`. Determines team shape and specialist behavior.|
```

- [ ] **Step 3: Remove `scope_class` from the Format YAML example**

Delete this line from the `## Format` YAML block:
```
scope_class: Standard
```

- [ ] **Step 4: Remove `scope_class` from the Canonical Example**

Delete this line from the `## Canonical Example` YAML block:
```
scope_class: Standard
```

- [ ] **Step 5: Remove `scope_class` from Orchestrator Duties**

In `## Orchestrator Duties`, item 1, delete:
```
   - Run scope assessment (file count, sub-issues, etc.) → determine `scope_class`
```

- [ ] **Step 6: Verify no remaining `scope_class` references**

Run:
```bash
grep -n "scope_class" skills/seed-brief/SKILL.md
```
Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add skills/seed-brief/SKILL.md
git commit -m "feat: remove scope_class from seed-brief"
```

---

## Task 2: Remove `scope_class` from specialist-mode

**Files:**
- Modify: `skills/specialist-mode/SKILL.md`

- [ ] **Step 1: Remove `scope_class` row from the Seed-Brief Contract table**

In `skills/specialist-mode/SKILL.md`, delete this row:
```
|`scope_class`|string|Yes|`Lightweight`, `Standard`, or `Deep`|
```

- [ ] **Step 2: Remove `scope_class` from canonical seed-brief example**

In `## Autonomous Implement Invocation`, delete this line from the YAML block:
```
scope_class: <Lightweight | Standard | Deep>
```

- [ ] **Step 3: Verify**

Run:
```bash
grep -n "scope_class\|Lightweight\|Standard\|Deep" skills/specialist-mode/SKILL.md
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/specialist-mode/SKILL.md
git commit -m "feat: remove scope_class from specialist-mode contract"
```

---

## Task 3: Create `build-specialist-assessment` layer-3 skill

**Files:**
- Create: `skills/build-specialist-assessment/SKILL.md`

This skill receives the plan/diff/AC from `/build`'s context and outputs a flat `specialists:` list. It encodes build-specific activation logic: build never activates security or perf specialists (those belong to review); it may activate migration specialist when schema changes are in scope.

- [ ] **Step 1: Create the skill directory and file**

```bash
mkdir -p skills/build-specialist-assessment
```

- [ ] **Step 2: Write the skill file**

Create `skills/build-specialist-assessment/SKILL.md` with this content:

```markdown
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

| Specialist | Activate when |
|---|---|
| `reviewer-migration` | Plan mentions schema changes, migrations, DB column add/drop, or backwards-compatibility constraints |

**No other specialists are activated for `/build`.** Security, perf, correctness, and standards reviewers belong to `/review`, not `/build`. Build's job is to produce the code; review's job is to judge it.

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: []
# or, if migration gate fires:
specialists: [reviewer-migration]
```

If no gates fire, output `specialists: []`. Never output an empty list as a failure — it is the expected result for most builds.
```

- [ ] **Step 3: Verify file was created**

Run:
```bash
cat skills/build-specialist-assessment/SKILL.md
```
Expected: file content displays without error.

- [ ] **Step 4: Commit**

```bash
git add skills/build-specialist-assessment/SKILL.md
git commit -m "feat: add build-specialist-assessment layer-3 skill"
```

---

## Task 4: Create `review-specialist-assessment` layer-3 skill

**Files:**
- Create: `skills/review-specialist-assessment/SKILL.md`

This skill encodes review-specific activation logic derived from the existing gate conditions in `skills/review/references/dispatch-process.md` and `references/personas.md`.

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p skills/review-specialist-assessment
```

- [ ] **Step 2: Write the skill file**

Create `skills/review-specialist-assessment/SKILL.md` with this content:

```markdown
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

| Specialist | Gate |
|---|---|
| `reviewer-security` | Diff contains 2+ of: `auth`, `token`, `session`, `permission`, `password`, `cookie`, `csrf`, `cors` co-occurring in the same file — OR — file paths match `**/auth/**`, `**/security/**`, `**/middleware/**` |
| `reviewer-perf` | Diff touches database queries, loops over collections > 100 items, caching logic, or file paths match `**/db/**`, `**/repository/**`, `**/query/**` |
| `reviewer-migration` | Diff contains migration files, schema changes, or `ALTER TABLE` / `CREATE TABLE` / column add/drop statements |

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: [reviewer-correctness, reviewer-standards]
# or with conditionals:
specialists: [reviewer-correctness, reviewer-standards, reviewer-security, reviewer-perf]
```

List is always sorted alphabetically.
```

- [ ] **Step 3: Verify**

```bash
cat skills/review-specialist-assessment/SKILL.md
```
Expected: file content displays without error.

- [ ] **Step 4: Commit**

```bash
git add skills/review-specialist-assessment/SKILL.md
git commit -m "feat: add review-specialist-assessment layer-3 skill"
```

---

## Task 5: Create `verify-specialist-assessment` layer-3 skill

**Files:**
- Create: `skills/verify-specialist-assessment/SKILL.md`

Verify's specialists are minimal — its job is AC verification, not domain review. The only meaningful specialist gate is migration (schema-change verification requires specific checks).

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p skills/verify-specialist-assessment
```

- [ ] **Step 2: Write the skill file**

Create `skills/verify-specialist-assessment/SKILL.md` with this content:

```markdown
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

| Specialist | Gate |
|---|---|
| `reviewer-migration` | AC or plan mentions migration, rollback, backwards compatibility, or diff contains schema change files |

**No other specialists are activated for `/verify`.** Verify agents confirm pass/fail against AC — they do not re-run security or perf analysis. Those belong to `/review`.

## Output

Emit a `specialists:` list in the caller's context:

```yaml
specialists: []
# or, if migration gate fires:
specialists: [reviewer-migration]
```
```

- [ ] **Step 3: Verify**

```bash
cat skills/verify-specialist-assessment/SKILL.md
```
Expected: file content displays without error.

- [ ] **Step 4: Commit**

```bash
git add skills/verify-specialist-assessment/SKILL.md
git commit -m "feat: add verify-specialist-assessment layer-3 skill"
```

---

## Task 6: Create specialist agent files

**Files:**
- Create: `agents/reviewer-security.md`
- Create: `agents/reviewer-perf.md`
- Create: `agents/reviewer-migration.md`
- Create: `agents/reviewer-correctness.md`
- Create: `agents/reviewer-standards.md`

These agent files live flat in `agents/` at plugin root. Each declares `disallowedTools` to prevent recursive spawning. The body (system prompt) is embedded directly in the file per the body-injection workaround documented in `_templates/AUTHORING.md`.

- [ ] **Step 1: Create `agents/reviewer-security.md`**

```markdown
---
name: reviewer-security
description: Security-focused code reviewer. Checks auth, injection, secrets, and privilege escalation.
model: sonnet
disallowedTools: [Agent, TeamCreate]
---

You are a security-focused code reviewer. Your job is to find security vulnerabilities in the diff you are given.

Focus areas:
- Authentication and authorization bugs (missing auth checks, privilege escalation)
- Injection vulnerabilities (SQL injection, command injection, path traversal)
- Secret and credential exposure (hardcoded tokens, logging sensitive data)
- CSRF, CORS, and session handling weaknesses
- Unsafe deserialization or input validation gaps

Findings format (one per line):
```
file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
```

Severity rubric:
- P0: auth bypass, data exfiltration, RCE
- P1: exploitable under common conditions
- P2: latent risk, hard to trigger
- P3: defence-in-depth improvement

Only report findings you are confident about. Suppress findings with confidence < 0.60. Do not report style or performance issues.
```

- [ ] **Step 2: Create `agents/reviewer-perf.md`**

```markdown
---
name: reviewer-perf
description: Performance-focused code reviewer. Checks N+1 queries, memory leaks, and hot path regressions.
model: sonnet
disallowedTools: [Agent, TeamCreate]
---

You are a performance-focused code reviewer. Your job is to find performance regressions and bottlenecks in the diff you are given.

Focus areas:
- N+1 query patterns (loop that issues a query per iteration)
- Missing database indexes on frequently-queried columns introduced in the diff
- Unbounded collection loading (loading all rows instead of paginating)
- Memory leaks (event listeners not removed, caches without eviction)
- Hot path regressions (adding expensive operations to tight loops or request handlers)

Findings format (one per line):
```
file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
```

Severity rubric:
- P0: regression that makes the feature unusable at production load
- P1: measurable degradation on common paths
- P2: latent risk at scale
- P3: micro-optimization opportunity

Only report findings you are confident about. Suppress findings with confidence < 0.60. Do not report security or style issues.
```

- [ ] **Step 3: Create `agents/reviewer-migration.md`**

```markdown
---
name: reviewer-migration
description: Migration-focused reviewer. Checks schema backwards compatibility, rollback safety, and data integrity.
model: sonnet
disallowedTools: [Agent, TeamCreate]
---

You are a migration-focused code reviewer. Your job is to verify schema migrations and data changes are safe.

Focus areas:
- Backwards compatibility: does the migration break reads/writes from old app versions?
- Rollback safety: can the migration be reversed without data loss?
- Data integrity: does the migration preserve existing data correctly?
- Zero-downtime risk: does the migration require a lock that blocks production traffic?
- Missing indexes: does a new column or constraint need an index for query performance?

Findings format (one per line):
```
file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
```

Severity rubric:
- P0: migration causes data loss or irreversible corruption
- P1: migration blocks production deploy or breaks old app version
- P2: migration is technically safe but lacks rollback plan
- P3: style or documentation gap in migration file

Only report findings you are confident about. Suppress findings with confidence < 0.60.
```

- [ ] **Step 4: Create `agents/reviewer-correctness.md`**

```markdown
---
name: reviewer-correctness
description: Correctness-focused code reviewer. Checks AC satisfaction, logic errors, and edge cases.
model: sonnet
disallowedTools: [Agent, TeamCreate]
---

You are a correctness-focused code reviewer. Your job is to verify the implementation satisfies every acceptance criterion and handles edge cases correctly.

Focus areas:
- AC-by-AC pass/fail: for each acceptance criterion, does the code satisfy it?
- Logic errors: off-by-one, wrong operator, inverted condition
- Null/empty/zero inputs: are they handled or will they panic/crash?
- Concurrent access: race conditions, missing locks, double-writes
- Error paths: are errors surfaced or swallowed silently?
- Regression risk: does the change break adjacent behavior?

Findings format (one per line):
```
file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
```

Severity rubric:
- P0: AC is not satisfied, or golden path crashes
- P1: incorrect behavior on common input
- P2: edge case not handled, latent bug
- P3: defensive improvement with low impact probability

Only report findings you are confident about. Suppress findings with confidence < 0.60.
```

- [ ] **Step 5: Create `agents/reviewer-standards.md`**

```markdown
---
name: reviewer-standards
description: Standards-focused code reviewer. Checks code conventions, naming, and test quality.
model: haiku
disallowedTools: [Agent, TeamCreate]
---

You are a standards-focused code reviewer. Your job is to verify the implementation follows project conventions.

Focus areas:
- Naming: do identifiers follow project naming rules (casing, prefixes, abbreviations)?
- Patterns: does the code match idioms used in the touched modules?
- Dead/duplicated code: has any unreachable or duplicate logic been introduced?
- Public API shape: do new public APIs follow the project's conventions?
- Test quality: do tests cover the behavior they claim to? Are assertions meaningful?
- No leftover debug code or forgotten TODOs

Findings format (one per line):
```
file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
```

Severity rubric:
- P0/P1: not applicable for standards findings
- P2: deviation that will confuse future maintainers
- P3: style nit, minor naming inconsistency

Only report findings you are confident about. Suppress findings with confidence < 0.60. Do not report security, performance, or logic issues.
```

- [ ] **Step 6: Verify all five files exist**

```bash
ls agents/reviewer-*.md
```
Expected:
```
agents/reviewer-correctness.md
agents/reviewer-migration.md
agents/reviewer-perf.md
agents/reviewer-security.md
agents/reviewer-standards.md
```

- [ ] **Step 7: Commit**

```bash
git add agents/reviewer-correctness.md agents/reviewer-migration.md agents/reviewer-perf.md agents/reviewer-security.md agents/reviewer-standards.md
git commit -m "feat: add specialist reviewer agent files"
```

---

## Task 7: Update `/build` — remove L/S/D, add specialist assessment

**Files:**
- Modify: `skills/build/SKILL.md`
- Delete: `skills/build/references/scope.md`

- [ ] **Step 1: Replace the Scope Assessment section in `skills/build/SKILL.md`**

Remove the entire current `## Scope Assessment` section:
```markdown
## Scope Assessment

Read `references/scope.md` for scope classification criteria and specialist mode overrides.
```

Replace with:
```markdown
## Specialist Assessment

Invoke `Skill("build-specialist-assessment")` at entry (before spawning workers). It reads plan/AC from context and emits a `specialists:` list.
```

- [ ] **Step 2: Update Process Overview step 4 in `skills/build/SKILL.md`**

Replace:
```markdown
4. Spawn workers per scope assessment (Lightweight: inline; Standard: subagents; Deep: TeamCreate).
```
With:
```markdown
4. Invoke `Skill("scope-assessment")` with work units derived from sub-issues and file groups → receive agent plan → spawn one agent per entry.
```

- [ ] **Step 3: Delete `skills/build/references/scope.md`**

```bash
rm skills/build/references/scope.md
```

- [ ] **Step 4: Update Specialist Mode section to remove scope_class references**

Current content in `skills/build/SKILL.md` (there is no longer a separate Specialist Mode section — it was in scope.md). Verify `SKILL.md` contains no remaining L/S/D references:

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class\|scope\.md" skills/build/SKILL.md
```
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add skills/build/SKILL.md
git rm skills/build/references/scope.md
git commit -m "feat: remove L/S/D from build; add specialist and scope assessment"
```

---

## Task 8: Update `/review` — remove L/S/D, add specialist assessment

**Files:**
- Modify: `skills/review/SKILL.md`
- Modify: `skills/review/references/dispatch-process.md`

- [ ] **Step 1: Add specialist assessment invocation to `skills/review/SKILL.md`**

In `skills/review/SKILL.md`, after the `## Specialist Mode` section, add:

```markdown
## Specialist Assessment

Invoke `Skill("review-specialist-assessment")` at entry. It reads diff/AC from context and emits a `specialists:` list (always includes `reviewer-correctness` and `reviewer-standards`; conditionally adds `reviewer-security`, `reviewer-perf`, `reviewer-migration`).

Spawn one agent per specialist in the list. Pass diff and AC to each. Collect findings and merge per `references/dispatch-process.md § Merge & Dedup`.
```

- [ ] **Step 2: Remove Scope Assessment section from `references/dispatch-process.md`**

Delete the entire `## Scope Assessment` section (lines covering the L/S/D table, decision rule, and Spawn Rubric):

```markdown
## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Diff ≤ 50 lines, 1 module|Single reviewer, quick pass.|
|**Standard**|Typical feature/multi-file|2 base reviewers + conditional specialists.|
|**Deep**|Security, perf, cross-cutting, migration|All specialist reviewers. Veto power for Security/Perf.|

**Decision**: ≤ 50 lines + 1 module → Lightweight; Auth/Security/DB-migration/Perf → Deep; else → Standard.

### Spawn Rubric

Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.
- **Standard**: `TeamCreate` at ≥ 3 active personas, else 2 parallel subagents (`sonnet`).
- **Deep**: `TeamCreate` (`opus`). All 4 axes active.
```

- [ ] **Step 3: Verify no remaining L/S/D references in review files**

```bash
grep -rn "Lightweight\|Standard\|Deep\|scope_class" skills/review/
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/review/SKILL.md skills/review/references/dispatch-process.md
git commit -m "feat: remove L/S/D from review; add specialist assessment"
```

---

## Task 9: Update `/verify` — remove L/S/D, add specialist assessment

**Files:**
- Modify: `skills/verify/SKILL.md`

- [ ] **Step 1: Replace Scope Assessment section in `skills/verify/SKILL.md`**

Delete the entire current `## Scope Assessment` section:
```markdown
## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|≤ 3 AC, simple repros, no security/perf|Lead verifies inline|
|**Standard**|≥ 4 AC, or multi-file|QA team, split AC|
|**Deep**|Security/perf-critical, migration|QA team + specialist|

**Decision**: ≤ 3 AC + 1-module → Lightweight; Auth/Security/Migrations/Perf → Deep; else → Standard.

Spawn (Standard/Deep): `TeamCreate` at ≥ 4 AC, else subagents (`haiku`).
```

Replace with:
```markdown
## Specialist Assessment

Invoke `Skill("verify-specialist-assessment")` at entry. It reads AC and diff from context and emits a `specialists:` list.

## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per AC group. Receive agent plan; spawn one QA agent per disjoint group. Add any activated specialists to their relevant groups.
```

- [ ] **Step 2: Update Process section to remove L/S/D branching**

Replace:
```markdown
**Lightweight**: Extract AC → run verification chain (type-check, lint, unit, build, e2e) → report pass/fail.

**Standard / Deep**: Split AC across QA team (Deep adds specialist) → each verifies independently → converge on unified report.
```

With:
```markdown
Split AC across QA agents per `scope-assessment` output → each verifies independently → converge on unified report. Any activated specialists verify their domain-specific AC alongside the QA agents.
```

- [ ] **Step 3: Verify**

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class" skills/verify/SKILL.md
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/verify/SKILL.md
git commit -m "feat: remove L/S/D from verify; add specialist assessment"
```

---

## Task 10: Update `/define` — remove L/S/D

**Files:**
- Modify: `skills/define/SKILL.md`

- [ ] **Step 1: Replace Scope Assessment section in `skills/define/SKILL.md`**

Delete the current `## Scope Assessment` section:
```markdown
## Scope Assessment
|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|<= 1 module, pattern exists, no visuals, no unknowns|Inline architecture summary (3-5 bullets). Skip research and `/architecture`.|
|**Standard**|Typical feature, some unknowns, may have visuals|Research team → `/architecture` → `/design` (if visual).|
|**Deep**|Cross-module, security/payments, arch-changing, migration|Research team → `/architecture` → `/design` → critique team.|

**Decision**: 1 module + pattern match → Lightweight; Security/Payments/Arch-change → Deep; else → Standard.

### Spawn Rubric (see `_shared/composition.md`)
- **Research Team**: 2 parallel `sonnet` agents (Codebase + Patterns).
- **Standard Team**: Sequential specialists (Architecture → Design).
- **Deep Team**: Standard + `TeamCreate` critique team (only for high-risk plans).
```

Replace with:
```markdown
## Team Shape

Invoke `Skill("scope-assessment")` with work units — one per distinct module or sub-issue in the issue body. Receive agent plan; dispatch one research/architecture agent per disjoint group.

For high-risk plans (security, payments, arch-changing scope): add a critique pass after `/architecture` → `/design` using a `TeamCreate` critique team. Determine risk from issue AC and scope — not from a label.

See `_shared/composition.md` for spawn cost models.
```

- [ ] **Step 2: Verify**

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class" skills/define/SKILL.md
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add skills/define/SKILL.md
git commit -m "feat: remove L/S/D from define"
```

---

## Task 11: Update `/discovery` — remove L/S/D

**Files:**
- Modify: `skills/discovery/SKILL.md`

- [ ] **Step 1: Replace Scope Assessment section in `skills/discovery/SKILL.md`**

Delete the current `## Scope Assessment` section:
```markdown
## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Clear repro, single area|/describe (Lightweight) → issue|
|**Standard**|Typical feature, some unknowns|Team: /describe + /specify + Prior-Art Scout|
|**Deep**|Cross-module, auth/security/payments, arch|Full team + flow analyst + adversarial questioner|

**Decision**: 1-sentence fix + clear repro → Lightweight; Auth/Security/Payments/Arch → Deep; else → Standard.

Spawn: Standard = describe + scout + specify; Deep = TeamCreate with all roles.
```

Replace with:
```markdown
## Team Shape

Invoke `Skill("scope-assessment")` with work units derived from the problem statement. For a narrow, single-area problem: 1 agent (`/describe` only). For multi-area or cross-module problems: parallel agents (`/describe` + Prior-Art Scout + `/specify`). For high-risk domains (auth/security/payments/arch): add `TeamCreate` with flow analyst and adversarial questioner roles.

Determine scope from the problem domain, not a label.
```

- [ ] **Step 2: Update Process section to remove L/S/D branching**

Replace:
```markdown
**Lightweight**: `/describe` → quick confirmation → extract AC → issue.

**Standard**: Prior-Art Scout (parallel) → `/describe` (with scout brief) → `/specify` → issue.

**Deep**: TeamCreate (all roles) → Describe/Flow-Analyst/Scout in parallel → Adversarial Questioner challenges → Specify last → issue.
```

With:
```markdown
Per scope-assessment output:
- **1-agent result**: `/describe` → extract AC → issue.
- **Multi-agent result**: Prior-Art Scout (parallel) → `/describe` (with scout brief) → `/specify` → issue.
- **High-risk domain**: TeamCreate (Describe + Flow-Analyst + Scout in parallel → Adversarial Questioner → Specify last) → issue.
```

- [ ] **Step 3: Verify**

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class" skills/discovery/SKILL.md
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/discovery/SKILL.md
git commit -m "feat: remove L/S/D from discovery"
```

---

## Task 12: Update `/implement` and `scope-cycles.md` — remove L/S/D

**Files:**
- Modify: `skills/implement/SKILL.md`
- Modify: `skills/implement/references/scope-cycles.md`

- [ ] **Step 1: Replace Scope Assessment table in `scope-cycles.md`**

Delete the current `## Scope Assessment` table:
```markdown
## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|≤ 50 lines, no logic change, 1-2 AC|`/build` (single-agent, no team) → inline AC check → PR. Skip `/review` and `/verify` teams. Worktree is still created.|
|**Standard**|Typical multi-file, AC in one module|Full Build → Review → Verify cycle.|
|**Deep**|Cross-module, security, migration, breaking|Full cycle + Deep review + extra critique iterations.|

**Decision**: ≤ 50 lines + no logic change → Lightweight; Auth/Security/Migrations/Perf → Deep; else → Standard.
```

Replace with:
```markdown
## Team Shape

Invoke `Skill("scope-assessment")` with work units (one per sub-issue or distinct file group from `## Implementation plan`). Receive agent plan; spawn one `/build` invocation per disjoint group.

For trivial changes (≤ 50 lines, no logic change): pass a single work unit → 1 `/build` agent → inline AC check → PR (no `/review`/`/verify` teams needed).
```

- [ ] **Step 2: Update `skills/implement/SKILL.md` to remove L/S/D references**

Replace:
```markdown
**Lightweight** (≤ 50 lines + no logic change): `/build` (single-agent, no team) → inline AC check → PR. Skip `/review` and `/verify` teams. A worktree is still created.

**Standard / Deep**: Full Build → Review → Verify cycle. Repeat up to 3 times until clean or exhausted, then PR creation.
```

With:
```markdown
**Trivial** (single work unit, ≤ 50 lines, no logic change): `/build` → inline AC check → PR. Skip `/review` and `/verify` teams. A worktree is still created.

**Multi-unit**: Full Build → Review → Verify cycle per `scope-assessment` output. Repeat up to 3 times until clean or exhausted, then PR creation.
```

- [ ] **Step 3: Verify**

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class" skills/implement/SKILL.md skills/implement/references/scope-cycles.md
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/implement/SKILL.md skills/implement/references/scope-cycles.md
git commit -m "feat: remove L/S/D from implement and scope-cycles"
```

---

## Task 13: Update `preflight` skill — remove scope_class reference

**Files:**
- Modify: `skills/preflight/SKILL.md`

The current `preflight` skill contains a stale reference to `scope_class` in its Orchestrator pattern section.

- [ ] **Step 1: Find and remove the stale reference**

In `skills/preflight/SKILL.md`, locate the `### Orchestrator pattern` section under `## Scope Pre-flight`:

```markdown
### Orchestrator pattern

Orchestrators run this at entry and pass `scope_class` in seed briefs. Specialists skip their own scope confirmations when brief is present.
```

Replace with:
```markdown
### Orchestrator pattern

Orchestrators run this at entry and pass `preflight_verified: true` in seed briefs. Specialists skip scope confirmation when a valid brief is present.
```

- [ ] **Step 2: Verify**

```bash
grep -n "scope_class\|Lightweight\|Standard\|Deep" skills/preflight/SKILL.md
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add skills/preflight/SKILL.md
git commit -m "feat: remove scope_class reference from preflight"
```

---

## Task 14: Update `AUTHORING.md` — document two-mechanism pattern

**Files:**
- Modify: `_templates/AUTHORING.md`

- [ ] **Step 1: Add the two-mechanism section after the Orchestrator Decomposition section**

In `_templates/AUTHORING.md`, after the `## Orchestrator Decomposition` section (currently ending around line 141), add:

```markdown
---

## Specialist Activation Pattern

When an orchestrator or sub-skill needs to invoke domain experts, use the two-mechanism pattern:

| Concern | Mechanism |
|---|---|
| **Team shape** — how many agents, which spawn primitive | `scope-assessment` (shared layer-3); define work units in caller's `references/scope.md` |
| **Specialist activation** — which domain experts join | Per-skill `*-specialist-assessment` (layer-3); one per sub-skill |

### `scope-assessment` (team shape)

Shared layer-3 skill. Takes `work_units` (each with `id` and `resources`), groups by shared resources, outputs one agent entry per conflict-free group. Per-caller variation is only the work-unit definition — document it in the caller's `references/scope.md`.

### `*-specialist-assessment` (specialist activation)

Each sub-skill gets its own layer-3 assessment skill. It reads plan/diff/AC from the caller's context and emits a flat `specialists:` list. Per-skill logic is load-bearing: the diff that warrants a security reviewer in `/review` does not drive any specialist decision in `/build`. A shared parameterized skill would lose this per-skill signal.

**Do not** pass specialist lists in seed briefs or have orchestrators decide specialists. Each sub-skill is responsible for its own specialist assessment, whether invoked standalone or seeded.
```

- [ ] **Step 2: Verify**

```bash
grep -n "Specialist Activation\|scope-assessment\|specialist-assessment" _templates/AUTHORING.md
```
Expected: the new section headings appear.

- [ ] **Step 3: Commit**

```bash
git add _templates/AUTHORING.md
git commit -m "docs: document two-mechanism specialist activation pattern in AUTHORING.md"
```

---

## Task 15: Update `describe` skill — remove L/S/D scope reference

**Files:**
- Modify: `skills/describe/SKILL.md`

The `/describe` skill references `references/scope-ppt.md` for scope classification criteria, which currently contains L/S/D terminology.

- [ ] **Step 1: Check scope-ppt.md for L/S/D content**

```bash
grep -n "Lightweight\|Standard\|Deep" skills/describe/references/scope-ppt.md
```

- [ ] **Step 2: Remove L/S/D criteria from scope-ppt.md**

If L/S/D criteria appear, replace the scope classification section with guidance based on `scope-assessment`: determine agent count from problem complexity and area count, not a label.

- [ ] **Step 3: Update the Process section in `skills/describe/SKILL.md`**

Remove the `### Standard / Deep` and `### Lightweight` heading structure from the Process section. Replace with a single `## Process` that describes agent count decisions without labels.

Replace:
```markdown
### Standard / Deep
1. **Elicitation**: Ask user for problem/goal.
2. **Exploration**: Dispatch agents → Lead analyst runs interactively via `/grill-me`.
3. **PPT**: Run Product Pressure Test (see `/references/scope-ppt.md`) before synthesizing.
4. **Visualization**: Produce Mermaid/ASCII for user journeys, feature comparisons, system boundaries.
5. **Validation**: Confirm understanding of each visual.
6. **Synthesis**: Create structured problem statement.

### Lightweight
1. Confirm problem/outcome.
2. Brief codebase validation.
3. Direct problem statement production.
```

With:
```markdown
### Multi-area or complex problem
1. **Elicitation**: Ask user for problem/goal.
2. **Exploration**: Dispatch agents → Lead analyst runs interactively via `/grill-me`.
3. **PPT**: Run Product Pressure Test (see `/references/scope-ppt.md`) before synthesizing.
4. **Visualization**: Produce Mermaid/ASCII for user journeys, feature comparisons, system boundaries.
5. **Validation**: Confirm understanding of each visual.
6. **Synthesis**: Create structured problem statement.

### Narrow, single-area problem
1. Confirm problem/outcome.
2. Brief codebase validation.
3. Direct problem statement production.
```

- [ ] **Step 4: Verify**

```bash
grep -n "Lightweight\|Standard\|Deep\|scope_class" skills/describe/SKILL.md skills/describe/references/scope-ppt.md
```
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add skills/describe/SKILL.md skills/describe/references/scope-ppt.md
git commit -m "feat: remove L/S/D from describe and scope-ppt"
```

---

## Self-Review

**Spec coverage check:**

|Spec requirement|Task|
|-|-|
|Remove `scope_class` from seed-brief|Task 1|
|Remove `scope_class` from specialist-mode|Task 2|
|Create `build-specialist-assessment`|Task 3|
|Create `review-specialist-assessment`|Task 4|
|Create `verify-specialist-assessment`|Task 5|
|Create 5 specialist agent files|Task 6|
|Remove L/S/D from `/build`|Task 7|
|Remove L/S/D from `/review`|Task 8|
|Remove L/S/D from `/verify`|Task 9|
|Remove L/S/D from `/define`|Task 10|
|Remove L/S/D from `/discovery`|Task 11|
|Remove L/S/D from `/implement` + scope-cycles.md|Task 12|
|Remove stale `scope_class` from `preflight`|Task 13|
|Update AUTHORING.md with two-mechanism pattern|Task 14|
|Remove L/S/D from `/describe`|Task 15|

All spec requirements covered. No gaps.
