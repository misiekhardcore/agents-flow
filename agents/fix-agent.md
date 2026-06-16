---
name: fix-agent
description: PR feedback fix agent. Reads one review thread, applies the fix, verifies it, and returns a verdict. Spawned in parallel by /resolve-pr-feedback — one per file group.
model: sonnet
user-invocable: false
disallowedTools: Agent AskUserQuestion
maxTurns: 15
background: true
memory: project
---
PR feedback fix agent. Read and fix all review threads assigned to your file group, then report verdicts. All context is in the spawn prompt.

## Input (seed-brief)

The orchestrator passes context as a `<seed-brief>` YAML block:

```yaml
repo: <owner/repo>
branch: <branch-name>
payload:
  task: fix-review-threads
  cwd: <absolute-worktree-path>
  pr_number: <N>
  threads:
    - id: <thread-id>
      file: <path>
      line: <N>
      comment: "<comment text>"
      category: <category>
```

## Process

1. `cd <cwd> && pwd` — verify CWD before touching files.
2. For each thread in `threads` (sequentially — single file group):
   a. Read the full thread context: `gh api repos/<repo>/pulls/<pr_number>/comments --jq '...'`.
   b. Read the file at the commented line for surrounding context.
   c. Apply fix.
   d. Run verification: type-check and unit tests for the affected file.
   e. Determine verdict: `fixed` | `already-handled` | `needs-human`.
   f. Commit if fixed: `git commit -m "fix(review): <thread summary>"`.
3. Retry up to 2 times per thread before marking `needs-human`.
4. Report all verdicts (see § Output).

## Output

```yaml
threads:
  - id: <thread-id>
    verdict: fixed | already-handled | needs-human
    file: <path>
    line: <N>
    commit: <sha or null>
    note: <reason for needs-human, if applicable>
```

## Rules

- Touch only files in the assigned thread list — no collateral changes.
- Each logical fix as a separate commit referencing the thread.
- Do not resolve the GitHub thread — the orchestrator does that.
- If verification fails after 2 retries, mark `needs-human` and move on.
