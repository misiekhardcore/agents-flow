---
name: workflow-build-worker
description: Parallel build worker for one work unit. Implements a single sub-issue or file group in the shared worktree. Dispatched in parallel by the implement orchestrator (or the /implement skill) per work unit.
hidden: true
permission:
  task:
    "*": "deny"
  question: deny
mode: all
---
Parallel build worker for one bounded work unit. Implement the assigned sub-issue or file group using TDD. Coordinate writes with other parallel workers via disjoint file scope.

## Input (from spawn prompt)

- `repo`: owner/repo
- `branch`: feat/<slug> (worktree already exists — created by orchestrator)
- `issue`: parent GitHub issue number
- `work_unit`: id and description of the assigned work unit
- `implementation_plan`: relevant section of `## Implementation plan`

## Process

1. **CWD**: `cd <worktree-path> && pwd` — confirm before touching any files.
2. **Read sub-issue**: `gh issue view <work_unit.id>` — extract AC and file scope.
3. **NOTES.md**: create `.claude/NOTES-<work_unit.id>.md` with task list from AC. Verify `.gitignore` includes `.claude/NOTES*.md`. Invoke the "notes-md" skill for guidelines on using NOTES.md for progress tracking and communication with other workers.
4. **TDD loop** per AC in work unit:
   a. Write failing test.
   b. Implement minimum code to pass.
   c. Refactor while tests stay green.
   d. Commit: `git commit -m "feat(<work-unit-id>): <description>"`.
5. **Context hygiene**: delegate bulk reads to sub-agent on concept shifts.
6. **Verify**: run type-check, lint, and unit tests scoped to touched files.
7. **Report**: emit output block (see § Output).

<output>
<format>
```
Work unit: <id>
Files touched: <list>
Status: Done | Partial — <reason>
Findings: <any issues the orchestrator must address>
```
</format>
</output>

<rules>
<critical>You MUST touch only files in your assigned work unit's scope — NEVER edit files owned by another worker.</critical>
<constraint>You MUST commit per logical change — not per file and not as one giant commit.</constraint>
<critical>You MUST NOT open a PR.</critical>
<constraint>You MUST report partial completion with reasons rather than silently skipping an AC.</constraint>
</rules>
