---
name: review
description: Review implementation against requirements or PR. Posts inline GitHub review comments.
argument-hint: "[PR# or URL]"
model: sonnet
effort: high
---
## Role & Constraints
Lead review phase. Goal: Thoroughly review implementation and produce actionable findings.

## Specialist Mode
- **Seeded**: Skip repo-preflight.
- **Keep**: Severity/finding-depth gates (rigor is not delegated).
- [Ref: specialist-mode]

## I/O
- **Input**: Branch (+ seed brief), Branch (standalone + issue#), or PR argument (PR# or URL).
- **Review Package** (Sole input to reviewers):
  - Diff: `git diff main...HEAD` or `gh pr diff <n>`.
  - AC: From seed brief, `gh issue view <n>`, or linked issue.
  - Reviewer Preamble: "Review code you did not write. Base review ONLY on provided diff and AC."
- **Output**: Fix brief (for `/build`), Findings report (user), or Posted GitHub review (PR).

## Dispatch Modes
|Trigger|Diff Source|AC Source|Output|
|-|-|-|-|
|Branch + Seed|`git diff`|Seed brief|Fix brief → `/build`|
|Branch Standalone|`git diff`|`gh issue view`|Findings report → User|
|PR Argument|`gh pr diff`|Linked issue|Posted GitHub review|

## Scope Assessment
|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Diff <= 50 lines, 1 module|Single reviewer, quick pass.|
|**Standard**|Typical feature/multi-file|2 base reviewers + conditional specialists.|
|**Deep**|Security, perf, cross-cutting, migration|All specialist reviewers. Veto power for Security/Perf.|

**Decision**: <= 50 lines + 1 module → Lightweight; Auth/Security/DB-migration/Perf → Deep; else → Standard.

### Spawn Rubric [Ref: composition]
- **Standard**: `TeamCreate` at >= 3 active personas, else 2 parallel subagents (`sonnet`).
- **Deep**: `TeamCreate` (`opus`). All 4 axes active.

## Personas [Ref: references/personas.md]
- **Always-on**: Correctness, Standards.
- **Conditional**: Security, Performance, Migration, Docs Consistency, Architecture/Scope-creep. (Activate only if gate fires).

## Process
1. **Acquire Review Package** (Context Isolation).
2. **Triage**: Analyze diff → activate conditional personas → record why gates fired.
3. **Review**: Reviewers work in parallel → use `superpowers:requesting-code-review`.
4. **Findings Format**: `file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)`.
5. **Merge & Dedup**:
   - Group by `file` + `line_bucket` (3-line windows) + `normalized_title`.
   - Boost confidence by 0.10 if 2+ reviewers flag.
   - Suppress if confidence < 0.60 (or 0.50 for P0).
6. **Emit**: Per Dispatch Mode.

## PR Mode: Idempotent Posting
1. **Fingerprint**: `fp = sha256(file:line_bucket:normalized_title)[:12]`.
2. **Pre-scan**: Fetch existing comments by runner → skip if `<!-- review-fp: <fp> -->` exists.
3. **Payload**:
   - Inline findings: `**[P1, conf 0.85]** Title \n\n Elaboration \n\n <!-- review-fp: <fp> -->`.
   - Summary: Top 3 findings sorted by severity → confidence. End with `<!-- review-summary-fp: <sum_fp> -->`.
4. **Post**: Atomic REST call via `gh api repos/.../reviews`. `event: "COMMENT"`. Anchor to `headRefOid` (SHA).

## Rules
- **Separation**: Never fix issues during review.
- **Consensus**: All reviewers must agree before finalizing.
- **Blocking**: Critical findings block. Deep mode: High-severity blocks for Security/Perf.
- **Scope**: Flag changes outside issue scope.
- [Ref: interviewing-rules]
