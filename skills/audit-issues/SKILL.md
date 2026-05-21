---
name: audit-issues
description: Audit open GitHub issues for drift against repo state. Flags broken refs, stale claims, and contradictions.
when_to_use: Use when auditing a GitHub repo's open issues for drift, broken refs, or stale claims.
argument-hint: "[owner/repo | #NN | owner/repo#NN]"
model: sonnet
allowed-tools: Bash Read
---
## Role & Constraints
Audit open issues for drift. Product: Updated issues themselves (mutate on confirm).

## I/O
- **Target Resolution**:
  - Empty → `owner/repo` from cwd.
  - `owner/repo` → Use directly.
  - `#NN` → Resolve repo from cwd.
  - `owner/repo#NN` → Split on `#`.
- **Sourcing**: Must find local clone at `~/Projects/<repo>`. If missing → abort.
- **Ref**: Pull latest default branch (`origin/HEAD`) via `git fetch`. Do not check out.

## Process

### Phase 1 — Fetch
- **Targeted**: `gh issue view <NN>` + `gh issue list` (filtered).
- **All-Open**: `gh issue list --state open --limit 0`.
- Abort if issue is `closed`.

### Phase 2 — Per-Issue Audit (Subagent Fan-out)
Read `_shared/detectors.md` for detector logic, verdict ranking, and JSON schema.
