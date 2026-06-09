# Dispatch and Process for review

## Dispatch Modes

|Trigger|Diff Source|AC Source|Output|
|-|-|-|-|
|Branch Standalone|`git diff`|`gh issue view`|Findings report → User|
|PR Argument|`gh pr diff`|Linked issue|Posted GitHub review|
|Implement cycle|`git diff`|Caller-provided|Fix brief → caller|

## Process

1. **Acquire Review Package** (Context Isolation).
2. **Triage**: Gate evaluation is handled by `review-runner` agent — it reads diff and file paths, activates reviewers, and returns merged findings.
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
