# Seed-Brief — Spawn-time Context Packaging Format

## Purpose

A **seed-brief** is a payload format that orchestrators use to hand off context to spawned agents or sub-skills at spawn time. It solves the **zero context inheritance** problem: when you spawn a new Claude session with `Agent()` or call a sub-skill, the spawned agent arrives with no knowledge of prior work, decisions, or findings.

The seed-brief packages critical state—scope, repo, branch, active issue, prior art, findings—as raw YAML inside a `<seed-brief>` XML block in the agent's prompt. Agents use it to arrive with full context without re-researching — no detection or mode-switching required.

## When to Use

Use seed-briefs when spawning worker agents via `Agent()` to hand off context at spawn time.

Do NOT use for:
- **Mid-cycle state within the same worktree.** Use `.claude/NOTES.md` for findings, failing AC, prior decisions during the same phase.
- **Phase-to-phase handoff.** That lives in the GitHub issue body (## Requirements, ## Implementation plan).

## Format

The seed-brief is raw YAML nested inside an XML tag. The orchestrator embeds it directly in the spawned agent's prompt:

```
<seed-brief>
repo: owner/repo
branch: feat/my-feature
payload:
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
|`repo`|string|Format: `owner/repo`. Verified against `git remote -v` by orchestrator before spawning.|
|`branch`|string|Format: `feat/<slug>`. Verified against `git rev-parse --abbrev-ref HEAD` by orchestrator.|
|`payload`|object|Research, prior art, findings, or constraints. Shape depends on context.|

## Orchestrator Duties

1. **Run repo/scope-preflight once at entry.**
2. **Construct seed-brief** with `repo`, `branch`, `active_issue`, and `payload`.
3. **Checkpoint NOTES.md before constructing the brief.**
   Write `## Current task` and `## Next action on resume` before every `Skill()` or `Agent()` call so NOTES.md contains enough state to reconstruct if the session dies mid-spawn.
4. **Pass to every agent spawn.**

## Rules

- **Caller-side only.** Seed-brief is a spawn-time packaging convention; receivers do not detect or parse it as a mode switch.
- **Brief is spawn-time only.** Inter-cycle state (failing tests, code review findings) within the same worktree lives in `.claude/NOTES.md`, not in the brief.
- **No brief bloat.** Cap the brief to required fields only; verbose context overflows token budget.
- **Sanity check every field.** Orchestrator verifies repo and branch against `git` before constructing the brief.
