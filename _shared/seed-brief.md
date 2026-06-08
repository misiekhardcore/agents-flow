# Seed-Brief — Spawn-time Context Packaging Format

## Purpose

A **seed-brief** is a payload format that orchestrators use to hand off context to spawned agents or sub-skills at spawn time. It solves the **zero context inheritance** problem: when you spawn a new Claude session with `Agent()` or call a sub-skill, the spawned agent arrives with no knowledge of prior work, decisions, or findings.

The seed-brief packages critical state—scope, repo, branch, active issue, prior art, findings—as raw YAML inside a `<seed-brief>` XML block in the agent's prompt. Specialists detect it, skip redundant research, and proceed with the work.

## When to Use

Use seed-briefs when:
- **Orchestrator spawning a sub-skill** to delegate a unit of work
- **Orchestrator spawning a worker agent** via `Agent()` to handle bulk work (research, code reviews, fixups)
- **Autonomous cycles** within a phase

Do NOT use for:
- **Mid-cycle state within the same worktree.** Use `.claude/NOTES.md` for findings, failing AC, prior decisions during the same phase.
- **Phase-to-phase handoff.** That lives in the GitHub issue body (## Requirements, ## Implementation plan).

## Format

The seed-brief is raw YAML nested inside an XML tag. The orchestrator embeds it directly in the spawned agent's prompt:

```
<seed-brief>
preflight_verified: true
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
|`repo`|string|Format: `owner/repo`. Verified against `git remote -v` by orchestrator before spawning.|
|`branch`|string|Format: `feat/<slug>`. Verified against `git rev-parse --abbrev-ref HEAD` by orchestrator.|
|`active_issue`|int|GitHub issue ID (positive integer). Used for sanity checks and issue-link context.|
|`payload`|object|Research, prior art, findings, or constraints. Shape depends on `payload.type` (see `Skill("specialist-mode")` § Payload Types).|
|`autonomous`|bool|Optional; default `false`. If `true`, suppresses exit/continuation prompts in the phase-ending skill.|

Each skill documents its own payload types and usage in its own file. See `Skill("specialist-mode")` for the canonical contract and payload type definitions.

## Orchestrator Duties

1. **Run preflights once at entry:**
   - Verify repo: `git remote -v` matches `owner/repo`
   - Verify branch: `git rev-parse --abbrev-ref HEAD` matches expected branch

2. **Construct seed-brief** with `preflight_verified: true`:
   - Include repo, branch, active_issue for sanity checks in spawned agents
   - Build `payload` from prior research, failing AC, or architectural decisions
   - Include a `progress` slice from NOTES.md (task list subset + decisions) for intra-orchestrator context — see notes-md-protocol.md § Seed-brief slice
   - Set `autonomous: true` only if orchestrator will handle next stage (no user prompt)

3. **Checkpoint NOTES.md before constructing the brief:**
   Write `## Current task` and `## Next action on resume` before every `Skill()` or `Agent()` call so NOTES.md contains enough state to reconstruct if the session dies mid-spawn.

4. **Pass to every specialist spawn:**
   - Orchestrator always passes the brief to every sub-skill or worker invocation
   - Specialists detect it and skip redundant research

## Specialist Behavior

When a specialist detects `<seed-brief>` in its prompt:

1. **Parse the brief:** Extract fields and verify `preflight_verified == true`
2. **Skip preflights:** No need to re-verify repo or run scope assessment
3. **Load provided context:** Use `prior_art`, `findings`, `existing_patterns` instead of re-researching
4. **Keep gates:** Do NOT skip discovery, design rigor, or AC verification — these remain required
5. **Handle `autonomous: true`:** If present, auto-advance to next stage on clean pass; suppress exit prompt

Per-specialist skip/keep details live in each skill's own reference file. See `Skill("specialist-mode")` → Execution Delta for the full table.

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
