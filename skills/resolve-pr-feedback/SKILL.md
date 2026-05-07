---
name: resolve-pr-feedback
description: Process PR review feedback in bulk — triage, fix in parallel, and reply with verdicts.
when_to_use: PR has review comments or given thread URL.
argument-hint: "[thread-URL]"
model: sonnet
---
## Role & Constraints
Systematically process PR feedback: Triage → Fix → Reply.

## I/O
- **Input**: No arg (all unresolved threads on branch's PR) or thread URL.
- **Pre-flight**: [Ref: repo-preflight]. If >= 3 files, run [Ref: scope-preflight].

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
- **Fix Agents**: TeamCreate (>= 3 file groups) or parallel subagents (>= 2 groups).
- **Execution**: Read comment → read context → implement fix → verify → determine verdict.
- **Retry**: <= 2 cycles per thread → else `needs-human`.
- **Regression**: Run full project test suite after all fix agents complete.

### Phase 4 — Reply
**Delegate reply drafting**: One sub-agent per thread (reply text only — code fixes were grouped by file in Phase 3, and GitHub mutations stay in the main thread). Prompt: `cd <abs-path> && pwd`.
**Verdict & Reply**:
|Verdict|Meaning|Reply|
|-|-|-|
|`fixed`|Exact implementation|"Fixed in {commit_sha}."|
|`fixed-differently`|Addressed via other approach|"Addressed differently: {explanation}. See {commit_sha}."|
|`replied`|Disagree/Clarify|"{explanation}"|
|`not-addressing`|Intentional skip|"Not addressing: {rationale}"|
|`needs-human`|Confidence too low|"Needs human review: {context}"|

**Mutation (main thread)**:
1. Post each drafted reply via `gh api .../replies` (safe body passing).
2. Resolve thread if verdict in {`fixed`, `fixed-differently`, `not-addressing`}.

## Output
Summary: Total threads → counts per verdict → commits created → threads needing human attention.

## Rules
- **Additive Only**: No force-push or history rewrite.
- **Context**: Read full thread, not just last comment.
- **Scope**: Flag fixes outside PR scope.
- **Commit**: Each logical fix as separate commit referencing thread.
- **Triage**: Present triage summary before fixes → allow user override.
