---
name: seed-brief
description: Spawn-time context packaging pattern for fan-out to sub-skills and worker agents.
user-invocable: false
layer: 3
---
## Purpose

A **seed-brief** is a payload format that orchestrators use to hand off context to spawned agents or sub-skills at spawn time. It solves the **zero context inheritance** problem: when you spawn a new Claude session with `Agent()` or call a sub-skill, the spawned agent arrives with no knowledge of prior work, decisions, or findings.

The seed-brief packages critical state—scope, repo, branch, active issue, prior art, findings—as raw YAML inside a `<seed-brief>` XML block in the agent's prompt. Specialists detect it, skip redundant research, and proceed with the work.

## When to Use

Use seed-briefs when:
- **Orchestrator spawning a sub-skill** (e.g., `/implement` spawning `/build`, `/review`, `/verify`)
- **Orchestrator spawning a worker agent** via `Agent()` to handle bulk work (research, code reviews, fixups)
- **Autonomous cycles** within a phase (e.g., build → review → verify loops)

Do NOT use for:
- **Mid-cycle state within the same worktree.** Use `.claude/NOTES.md` for findings, failing AC, prior decisions during the same phase.
- **Phase-to-phase handoff.** That lives in the GitHub issue body (## Requirements, ## Implementation plan).

## Format

The seed-brief is raw YAML nested inside an XML tag. The orchestrator embeds it directly in the spawned agent's prompt:

```
<seed-brief>
preflight_verified: true
scope_class: Standard
repo: owner/repo
branch: feat/my-feature
active_issue: 123
payload:
  type: research
  prior_art: "Prior findings and constraints"
  open_questions: "Unresolved questions"
</seed-brief>
```

**Rules:**
- No inner fence (no triple-backtick).
- Raw YAML indentation and syntax.
- Placed in the spawned agent's initial prompt.

## Required Fields

|Field|Type|Notes|
|-|-|-|
|`preflight_verified`|bool|Must be `true`. Orchestrator runs preflights once and verifies repo/branch against `git` before constructing the brief.|
|`scope_class`|string|One of: `Lightweight`, `Standard`, or `Deep`. Determines team shape and specialist behavior.|
|`repo`|string|Format: `owner/repo`. Verified against `git remote -v` by orchestrator before spawning.|
|`branch`|string|Format: `feat/<slug>`. Verified against `git rev-parse --abbrev-ref HEAD` by orchestrator.|
|`active_issue`|int|GitHub issue ID (positive integer). Used for sanity checks and issue-link context.|
|`payload`|object|Research, prior art, findings, or constraints. Shape depends on `payload.type` (see § Payload Types).|
|`autonomous`|bool|Optional; default `false`. If `true`, suppresses exit/continuation prompts in `/implement`.|

## Payload Types

The `payload` field is a dict with a required `type` key and type-specific contents:

### `type: research`
```yaml
payload:
  type: research
  prior_art: "<Issue #N ## Implementation plan (architecture and design from /define)>"
  open_questions: "<Unresolved constraints or empty string>"
```
Used by `/implement` to spawn `/build`, `/review`, `/verify`. Contains high-level architecture decisions and known constraints.

### `type: fix`
```yaml
payload:
  type: fix
  failing_ac: "<Failed acceptance criterion(s)>"
  findings: "file.js:42 — function does not handle edge case\nfile.ts:15 — type mismatch"
  prior_decisions: "<Prior architectural decisions or design constraints>"
```
Used when spawning a specialist to fix a specific failure. Contains line-specific findings and the AC to address.

### `type: prior-art`
```yaml
payload:
  type: prior-art
  problem_domain: "<Brief problem statement>"
  existing_patterns: "<Codebase patterns, libraries, or conventions relevant to this task>"
  constraints: "<Non-negotiable constraints from requirements or architecture>"
```
Used for research or exploration tasks where codebase patterns are critical context.

## Canonical Example

An orchestrator (`/implement`) spawning `/build` with an autonomous cycle:

```
<seed-brief>
preflight_verified: true
scope_class: Standard
repo: misiekhardcore/my-app
branch: feat/csv-export
active_issue: 42
autonomous: true
payload:
  type: research
  prior_art: |
    Issue #42 ## Implementation plan

    ### Architecture Decision
    - CSV export routes through existing ReportExporter service
    - New ExportFormatter module handles CSV serialization
    - UI button added to reports/page.tsx
  open_questions: ""
</seed-brief>
```

Specialist behavior when receiving this brief:
- Skip repo/branch verification (already done; `preflight_verified: true`)
- Skip redundant codebase scan for architecture patterns (prior art provided)
- Proceed directly to implementation
- On exit (if AC met): auto-advance to `/review` without prompting (because `autonomous: true`)

## Orchestrator Duties

1. **Run preflights once at entry:**
   - Verify repo: `git remote -v` matches `owner/repo`
   - Verify branch: `git rev-parse --abbrev-ref HEAD` matches expected branch
   - Run scope assessment (file count, sub-issues, etc.) → determine `scope_class`

2. **Construct seed-brief** with `preflight_verified: true`:
   - Include repo, branch, active_issue for sanity checks in spawned agents
   - Build `payload` from prior research, failing AC, or architectural decisions
   - Set `autonomous: true` only if orchestrator will handle next stage (no user prompt)

3. **Pass to every specialist spawn:**
   - Orchestrator always passes the brief to every sub-skill or worker invocation
   - Specialists detect it and skip redundant research

## Specialist Behavior

When a specialist detects `<seed-brief>` in its prompt:

1. **Parse the brief:** Extract fields and verify `preflight_verified == true`
2. **Skip preflights:** No need to re-verify repo or run scope assessment
3. **Load provided context:** Use `prior_art`, `findings`, `existing_patterns` instead of re-researching
4. **Keep gates:** Do NOT skip discovery, design rigor, or AC verification — these remain required
5. **Handle `autonomous: true`:** If present, auto-advance to next stage on clean pass; suppress exit prompt

**Execution delta (per `Skill("specialist-mode")`):**

|Specialist|Skipped when Seeded|Always Kept|
|-|-|-|
|`/build`|repo/scope preflights, scope confirmation|design gate|
|`/review`|repo-preflight|severity/depth gates|
|`/verify`|repo-preflight|AC verification rigor|
|`/describe`|internal prior-art search|grill-me, devil's advocate|
|`/specify`|scope/file confirmation|AC derivation gates|
|`/architecture`|codebase/pattern research|architecture session|
|`/design`|design-space research|interactive session|
|`/implement`|(handled by orchestrator)|exhausted-exit prompt (unless `autonomous: true`)|

## Failure Mode

**Invalid brief** (missing required fields, `preflight_verified != true`, malformed YAML):
1. Specialist logs the failure
2. Fall back to standalone execution (run all preflights normally)
3. Proceed with work
4. Report findings normally

This prevents a malformed brief from blocking work.

## Rules

- **Orchestrator runs preflight once.** Do not duplicate preflight logic in every specialist.
- **Brief is spawn-time only.** Inter-cycle state (failing tests, code review findings) within the same worktree lives in `.claude/NOTES.md`, not in the brief.
- **No brief bloat.** Cap the brief to required fields only; verbose context overflows token budget.
- **Sanity check every field.** Orchestrator verifies repo and branch against `git` before constructing the brief.
- **Autonomous cycle discipline.** Set `autonomous: true` only if the orchestrator orchestrates the next stage; never set it to suppress user prompts in a top-level skill invocation.
