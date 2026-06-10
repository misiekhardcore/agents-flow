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
Spawn one `Agent("audit-issues/agents/issue-auditor.md")` per issue in parallel. Pass `cwd`, `issue_number`, `repo`, and `default_branch_ref` to each. Read `references/detectors.md` for detector logic, verdict ranking, and JSON schema.

### Phase 3 — Aggregate & Print
Concatenate JSON reports. Per-issue block: `─── #NN — <title> — verdict: <v> ───` → URL → findings → proposed edit.

### Phase 4 — Interactive Mutation
Walk blocks in order. Prompt based on verdict:
- `valid` → `[s]kip ?`
- `stale`/`contradicted`/`unverifiable` → `[e]dit / [s]kip ?`
- `premise-shifted`/`superseded` → `[e]dit / [c]lose / [s]kip ?`

**Mutation Rules**:
- `e` → Show diff → `gh issue edit`.
- `c` → Post closing comment → `gh issue close`.
- `s` → Advance.

## Rules
- **Sourcing**: Invoke `Read ${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for parse targets.
- **Read-Only Default**: Mutate only after explicit per-issue confirmation.
- **No Auto-Clone**: Do not clone missing repos.
- **No Invention**: No counter → `unverifiable`.
- **Surgical**: One LLM extraction pass per issue max.
