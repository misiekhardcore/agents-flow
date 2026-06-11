---
name: audit-issues
description: Audit open GitHub issues for drift against repo state. Flags broken refs, stale claims, and contradictions.
when_to_use: Use when auditing a GitHub repo's open issues for drift, broken refs, or stale claims.
argument-hint: "[owner/repo | #NN | owner/repo#NN]"
model: sonnet
allowed-tools: Agent Bash Read
---
## Role & Constraints
Audit open issues for drift. Product: Updated issues themselves (mutate on confirm).
Read-only default: mutate only after explicit per-issue confirmation.

## Input

Target resolution:
- Empty → `owner/repo` from cwd.
- `owner/repo` → Use directly.
- `#NN` → Resolve repo from cwd (single-issue audit).
- `owner/repo#NN` → Split on `#`.

- **Sourcing**: Must find local clone at `~/Projects/<repo>`. If missing → abort.
- **Ref**: Fetch latest default branch via `git fetch origin` (do not check out).

## Team Shape

Invoke `Skill("orchestrator-rules")` for CWD verification, delegation, and seed-brief contract.

Dispatch one `Agent("audit-issues/agents/issue-auditor.md")` per issue with a seed-brief containing `repo`, `issue_number`, `cwd`, and `default_branch_ref`. Fan-out in parallel for ≥3 issues; run inline for 1–2.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process

### Phase 1 — Fetch
- **Targeted**: `gh issue view <NN>` + `gh issue list` (filtered).
- **All-Open**: `gh issue list --state open --limit 0`.
- Abort if issue is `closed`.

### Phase 2 — Per-Issue Audit
Read `references/detectors.md` for detector logic, verdict ranking, and JSON schema — pass pertinent rules into each spawn prompt so workers do not re-read.

Spawn one agent per issue:
```
Agent("audit-issues/agents/issue-auditor.md") with prompt containing seed-brief:
<seed-brief>
repo: owner/repo
issue_number: "123"
cwd: /path/to/clone
default_branch_ref: abc123def
</seed-brief>
```

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

## Output

Updated GitHub issues (mutated on confirm). No durable handoff artifact — this phase is terminal.

## Rules
- **No Auto-Clone**: Do not clone missing repos.
- **No Invention**: No counter → `unverifiable`.
- **Surgical**: One LLM extraction pass per issue max.
- **Point-of-need reads**: Read `_shared/handoff-artifact.md` only when parsing handoff targets. Read `references/detectors.md` before Phase 2 only.
