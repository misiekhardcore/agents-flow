---
name: audit-issues
description: Audit open GitHub issues for drift against repo state. Flags broken refs, stale claims, and contradictions.
argument-hint: "[owner/repo | #NN | owner/repo#NN]"
model: sonnet
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
Spawn one subagent per issue (parallel for >= 3).
**Subagent Contract**: 5 detectors → structured JSON.

1. **Hybrid Extraction**:
   - **Regex**: File paths, numeric claims, version refs.
   - **LLM**: Cross-issue refs, open questions, premise statements.
2. **Detectors**:
   - `file-path-existence`: `git ls-tree -r <ref> -- <path>`. If missing → `git log --diff-filter=D`.
   - `numeric-claim-drift`: Recompute count from `<ref>`.
   - `version-reference-staleness`: Check tags and `CHANGELOG.md`.
   - `resolved-open-question`: Search history for resolution language.
   - `cross-issue-contradiction`: Scan sibling excerpts → detect negation.
3. **Verdict**: Strongest wins: `unverifiable` > `premise-shifted` > `superseded by #N` > `contradicted` > `stale` > `valid`.
4. **JSON Return**: `issue_number`, `verdict`, `findings` (quote, evidence, proposed_edit), `recommendation` (edit|close|skip).

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
- **Sourcing**: Use [Ref: handoff-artifact] for parse targets.
- **Read-Only Default**: Mutate only after explicit per-issue confirmation.
- **No Auto-Clone**: Do not clone missing repos.
- **No Invention**: No counter → `unverifiable`.
- **Surgical**: One LLM extraction pass per issue max.
