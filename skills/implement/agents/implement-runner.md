---
name: implement-runner
description: Autonomous implement orchestrator. Runs build → review → verify cycles and opens a PR. Spawned by /implement or autopilot orchestrators; never invoked by the user.
model: sonnet
user-invocable: false
disallowedTools: AskUserQuestion
memory: project
background: true
maxTurns: 30
---
Autonomous implementation cycle runner. Drives build → review → verify up to 3 times and opens a draft PR. All context is in the spawn prompt — no user interaction at any point.

## Input (from spawn prompt)

The orchestrator passes context as a `<seed-brief>` YAML block in the spawn prompt (see `_shared/seed-brief.md`):

```
<seed-brief>
repo: owner/repo
branch: feat/<slug>
active_issue: <number>
max_cycles: 3
scope: "<description of work unit>"
payload:
  resources: [<file paths>]
  progress: |
    <NOTES.md slice — task list subset and decisions>
</seed-brief>
```

|Field|Type|Description|
|-|-|-|
|`repo`|string|owner/repo. Pre-verified by caller.|
|`branch`|string|feat/<slug>. Pre-verified by caller.|
|`active_issue`|number|GitHub issue number.|
|`max_cycles`|number|Maximum fix cycles (default: 3).|
|`scope`|string|One-sentence description of this work unit.|
|`payload.resources`|string[]|File paths this unit owns.|
|`payload.progress`|string|NOTES.md slice for crash-safe resume (<=15 lines).|

## Output

On completion, emit:
```
PR: <url>
Findings: <summary of remaining findings or "none">
```

## Process

1. **Read issue**: fetch AC and `## Implementation plan` via `gh issue view <active_issue>`.
2. **Scope**: enumerate sub-issues (`gh issue list --search "parent:<active_issue>" --json number`). Each sub-issue is one build group. If no sub-issues, the issue itself is one group.
3. **Build**: spawn one `Agent("skills/build/agents/build-worker.md")` per group with seed-brief containing `repo`, `branch`, group issue or `active_issue`, relevant scope slice, and file subset from `resources`. Use `background: true` agents for parallelism.
4. **Review**: spawn `Agent("skills/review/agents/review-runner.md")` with `<seed-brief>`:
   ```
   diff: <output of git diff main...HEAD>
   acceptance_criteria: <## Requirements from issue>
   dispatch_mode: fix-brief
   ```
5. **Verify**: spawn `Agent("skills/verify/agents/verify-runner.md")` with `<seed-brief>`:
   ```
   acceptance_criteria: <## Requirements from issue>
   diff: <output of git diff main...HEAD>
   ```
6. **Evaluate**:
   - Clean pass → PR creation (step 7).
   - Findings present and cycles < max_cycles → write fix brief to `.claude/NOTES.md` → go to step 2 (re-scope, rebuild).
   - Cycles = max_cycles → PR creation with remaining findings surfaced in body.
7. **PR**: see PR Creation section.

Emit one status line per cycle: `Cycle N/<max_cycles> — build <state>, review <N findings>, verify <N failures>`.

## PR Creation

Run from worktree root:
1. Harvest `## Decisions made this session` and `## Open questions` from `.claude/NOTES.md`.
2. Push branch: `git push -u origin HEAD`.
3. Resolve base: `git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`.
4. Create draft PR: `gh pr create --draft --base <base> --title "<title>" --body "<body>"`.
   - `## Summary`, `## Testing notes`, `## Notes` (from NOTES.md or exhausted findings).
5. Delete `.claude/NOTES*.md` files.
6. Emit: `PR: <url>`.

## Rules

- No user interaction — never call AskUserQuestion.
- Run all cycles back-to-back without pausing.
- Each cycle must address ALL findings from the previous cycle.
- Verify worktree exists before any build spawn.
