---
name: audit-issues
description: Audit open GitHub issues for drift against repo state. Flags broken refs, stale claims, and contradictions.
when_to_use: Use when auditing a GitHub repo's open issues for drift, broken refs, or stale claims.
argument-hint: "[owner/repo | #NN | owner/repo#NN]"
allowed-tools: Agent Bash Read
---
Audit open issues for drift against repo state. Product: updated issues themselves (mutate on confirm). Read-only by default — mutate only after explicit per-issue confirmation.

Adopt the "orchestrator-rules" skill for seed-brief contract, CWD verification, and NOTES.md conventions.

## Process

### 1. Ingestion

Resolve target:
- Empty → `owner/repo` from CWD.
- `owner/repo` → use directly.
- `#NN` → resolve repo from CWD (single-issue audit).
- `owner/repo#NN` → split on `#`.

Find local clone at `~/Projects/<repo>`. If missing → abort. Fetch latest default branch via `git fetch origin` (do not check out).

### 2. Init NOTES.md

Create `.claude/NOTES.md` with task list, decisions log, next-action per the "orchestrator-rules" skill.

### 3. Fetch

- Targeted: `gh issue view <NN>` + `gh issue list` (filtered).
- All-open: `gh issue list --state open --limit 0`.

### 4. Audit

Read `references/detectors.md` for detector logic, verdict ranking, and JSON schema — pass pertinent rules into each spawn prompt so workers do not re-read.

Dispatch one `workflow-issue-auditor` via the task tool per issue with a `<seed-brief>` YAML block containing `repo`, `issue_number`, `cwd`, and `default_branch_ref`. Fan-out in parallel for ≥3 issues; run inline for 1–2.

Each agent spawn (via the task tool) includes a `<seed-brief>` YAML block per `_shared/seed-brief.md`.

See `@_shared/composition.md` for spawn cost models.

### 5. Aggregate

Concatenate JSON reports. Per-issue block: `─── #NN — <title> — verdict: <v> ───` → URL → findings → proposed edit.

### 6. Interactive Mutation

Walk blocks in order. Prompt based on verdict:
- `valid` → `[s]kip`
- `stale`/`contradicted`/`unverifiable` → `[e]dit / [s]kip`
- `premise-shifted`/`superseded` → `[e]dit / [c]lose / [s]kip`

Mutation rules:
- `e` → Show diff → `gh issue edit`.
- `c` → Post closing comment → `gh issue close`.
- `s` → Advance.

Require explicit user approval per mutation.

### 7. Sign-off

Require explicit user approval before applying mutations. No unconfirmed mutations.

### 8. Compound on exit

Read `@_shared/compound-on-exit.md`. Invoke the "compound" skill exactly once on clean completion.

## Rules

- **No Auto-Clone**: Do not clone missing repos.
- **No Invention**: No counter → `unverifiable`.
- **Surgical**: One LLM extraction pass per issue max.
- **Point-of-need reads**: Read `references/detectors.md` before step 4 only.
- **NOTES.md**: Checkpoint before every spawn. See the "orchestrator-rules" skill § Progress tracking.
