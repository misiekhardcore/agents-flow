---
name: resolve-pr-feedback
description: Process PR review feedback in bulk — triage, fix in parallel, and reply with verdicts.
when_to_use: PR has review comments or given thread URL.
argument-hint: "[thread-URL]"
model: sonnet
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Systematically process PR feedback: Triage → Fix → Reply.

## I/O
- **Input**: No arg (all unresolved threads on branch's PR) or thread URL.
- **Pre-flight**: Invoke `Skill("preflight")`. If >= 3 files changed, run the scope checks within `preflight` again.

## Process

### Phase 1 — Fetch
1. **Resolve PR**: URL → owner/repo/number; otherwise `gh pr view`.
2. **Fetch Threads**: Use GraphQL for `isResolved` state. Filter bots, approvals, CI summaries.
3. **Filter**: If URL provided, match `databaseId`.

### Phase 2 — Triage
Classify threads:
- **Status**: `new` | `already-handled` (check diff).
- **Category**: `error-handling`, `validation`, `type-safety`, `naming`, `performance`, `testing`, `security`, `docs`, `style`, `architecture`.
Group by category → Present triage summary to user.

### Phase 3 — Fix
**Conflict Avoidance**: Map threads to files. No two agents on same file in parallel.
**Dispatch**:
- **Fix Agents**: Parallel subagents — one per file group.
- **Execution**: Read comment → read context → implement fix → verify → determine verdict.
- **Retry**: <= 2 cycles per thread → else `needs-human`.
- **Regression**: Run full project test suite after all fix agents complete.

### Phase 4 — Reply
**Delegate reply drafting**: One sub-agent per thread (reply text only). Prompt: `cd <abs-path> && pwd`.
Read `references/verdicts.md` for verdict/reply mapping and mutation logic.

## Output
Summary: Total threads → counts per verdict → commits created → threads needing human attention.

## Rules
- **Additive Only**: No force-push or history rewrite.
- **Context**: Read full thread, not just last comment.
- **Scope**: Flag fixes outside PR scope.
- **Commit**: Each logical fix as separate commit referencing thread.
- **Triage**: Present triage summary before fixes → allow user override.
