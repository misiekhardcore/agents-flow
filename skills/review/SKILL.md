---
name: review
description: Review an implementation against its issue requirements or a PR number/URL. Posts inline GitHub review comments in PR mode.
argument-hint: "[PR# or URL]"
model: sonnet
effort: high
---

You are leading the review phase. Your goal is to thoroughly review the implementation and produce actionable findings.

## Specialist mode

When invoked by `/implement` with a `<seed-brief>` block, skip:
- repo-preflight (already run by the orchestrator; `preflight_verified: true` is in the brief)

Always keep: severity/finding-depth gates — rigor of review is not delegated to the orchestrator.

Without a seed brief, run all prompts as described below. See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

## Input

One of:

1. **Branch with seed brief** — invoked by `/implement`. Reviewed via `git diff main...HEAD`; AC come from the seed brief.
2. **Branch standalone** — invoked directly with no PR argument. Reviewed via `git diff main...HEAD`; if a GitHub issue number is supplied, AC come from `gh issue view <number>`.
3. **PR argument** — a PR number or URL (e.g. `42`, `https://github.com/owner/repo/pull/42`). Reviewed via `gh pr view` and `gh pr diff`; AC come from the linked issue if any.

## Modes

The input determines the dispatch mode. An explicit PR argument always wins over an implicit seed brief.

| Trigger | Source of diff | Source of AC | Output |
|---|---|---|---|
| Branch + seed brief (from `/implement`) | `git diff main...HEAD` | seed brief | **Fix brief** returned to `/build` |
| Branch standalone | `git diff main...HEAD` | `gh issue view <n>` (if supplied) | **Findings report** to the user |
| PR argument | `gh pr view <n>` + `gh pr diff <n>` | linked issue from `gh pr view --json closingIssuesReferences`, if any | **Posted GitHub review** (inline comments + summary), plus a short report to the user |

The fix-brief path is unchanged — `/implement` invocations continue to receive a fix brief via the seed-brief route. PR-mode runs never return a fix brief; there is no `/build` consumer.

## Configuration

- **Standard reviews**: dispatch reviewers with `model: "sonnet"` to get a genuinely different analytical perspective from the implementing session.
- **Deep reviews**: dispatch reviewers with `model: "opus"` for maximum analytical depth.
- The lead agent (you) always runs on the session's current model.

## Context Isolation

Reviewers must operate with fresh context, independent of the implementing session. Before dispatching reviewers:

1. **Prepare the review package** — the package is the sole input to reviewers.
   - **Branch modes:** run `git diff main...HEAD` and capture the output. If a GitHub issue exists, run `gh issue view <number>` and capture its acceptance criteria.
   - **PR mode:** run `gh pr view <n> --json title,body,headRefName,headRefOid,baseRefName,closingIssuesReferences,author`, `gh pr diff <n>`, and — if `closingIssuesReferences` is non-empty — `gh issue view <linked>` for each linked issue. Capture all output. `headRefOid` is the head commit SHA the review will be anchored to in **Posting findings to GitHub** step 4 (`commit_id`). If no linked issue is found, set `no_linked_issue: true` on the review package; when dispatching the architecture/scope-creep persona, pass this flag through so it activates its degraded mode per the rule in `references/personas.md`.
2. **Reviewer preamble** — include this in every reviewer's dispatch: "You are reviewing code you did not write. Base your review ONLY on the diff and acceptance criteria provided below. Do not reference or assume any implementation context beyond what is explicitly given to you."

## Scope Assessment

Before starting, classify the review scope:

1. **Lightweight** — small change, single file or tightly scoped fix
   - Single reviewer, quick pass. No team dispatch.
   - Focus on correctness and obvious issues only.
2. **Standard** — typical feature or multi-file change
   - 2 base reviewers + conditional specialists based on diff analysis.
3. **Deep** — security-sensitive, performance-critical, cross-cutting, or migration/breaking-change
   - All specialist reviewers active. Veto power for security/performance.

Decision tree:

1. Is the diff under ~50 lines and touches one module? → Lightweight
2. Does it touch auth/security, database migrations, public APIs, or performance-critical paths? → Deep
3. Otherwise → Standard

The chosen class is referenced as `scope_class` (one of `"Lightweight"`, `"Standard"`, `"Deep"`) by gates in `references/personas.md`.

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`. Model tiers: see **Configuration** section.

- **Standard**: TeamCreate with `model: "sonnet"` at ≥3 active personas, else 2 parallel subagents with `model: "sonnet"`. Comm-pivot ✓ (converge on disagreements), disjoint ✓, parallel ✓, payoff ≥3× at scale. Gate: ≥3 personas active. Fallback: sequential subagents.
- **Deep**: TeamCreate with `model: "opus"`. All four ✓ across review axes; opus premium justified by criticality. Fallback: sequential subagents.

The two always-on personas (correctness, standards) plus any conditional personas whose gates fire all count toward the ≥3-persona threshold. The two conditional personas added in this skill — **docs consistency** and **architecture / scope-creep** — count alongside the existing security / performance / migration triggers.

## Personas

Reviewer personas, gates, signals, and severity rubric live in `references/personas.md`. The orchestrator decides which to activate based on the scope and the gates defined there.

**Always-on:** correctness, standards.

**Conditional** (each has a signal-based gate in `references/personas.md`):
- security
- performance
- migration
- docs consistency
- architecture / scope-creep

Activate a conditional persona only when its gate fires against the prepared review package. Record which gates fired and why; surface that in the final report.

## Process

### Lightweight

1. Acquire the review package per **Context Isolation** (branch or PR mode).
2. Single-pass review against the AC: obvious bugs, leftover debug code, forgotten TODOs.
3. Report findings (or post them, in PR mode — see **Posting findings to GitHub**).

### Standard

1. Acquire the review package per **Context Isolation**.

2. **Analyze the diff** to determine which conditional personas to activate. Evaluate every gate in `references/personas.md` against the package. Note which fired and why.

3. **Dispatch reviewers** per the Spawn justification gate (TeamCreate at ≥3 active personas with `model: "sonnet"`, else parallel subagents). Include the reviewer preamble from Context Isolation in each reviewer's instructions, plus the persona's prompt from `references/personas.md`.

4. All reviewers work in parallel. Each reviewer:
   - Reads the prepared review package (does **not** run `git diff` again — it operates on the captured diff so PR-mode and branch-mode behave identically)
   - Checks for leftover debug code, forgotten TODOs, or accidental changes
   - Uses superpowers:requesting-code-review as their review framework
   - Reports findings as a structured list with **confidence scoring**:
     ```
     - file:line | issue title | severity (P0-P3) | confidence (0.0-1.0)
     ```
   - Confidence calibration:
     - 0.9+ = would bet on this being a real bug
     - 0.7–0.9 = likely an issue but needs verification
     - 0.5–0.7 = suspicious but could be intentional

5. **Merge and deduplicate findings** across all reviewers:
   - Group findings by file + line_bucket (`floor(line / 3) * 3` — fixed 3-line windows) + normalized title (lowercase, strip trailing punctuation, collapse whitespace)
   - When 2+ reviewers flag the same issue, boost confidence by 0.10 (clamp to 1.0)
   - Suppress findings below the confidence thresholds defined in Rules
   - Merge duplicates into a single finding, noting which reviewers flagged it
   - Suppressed findings are listed in a collapsed "Low-confidence observations" section at the end of the report

6. Reviewers discuss disagreements via messages and converge on a unified review.

7. Emit findings:
   - **Branch + seed brief** → fix brief to `/build`.
   - **Branch standalone** → findings report to the user.
   - **PR argument** → post the review per **Posting findings to GitHub**.

### Deep

1. Acquire the review package per **Context Isolation**.

2. **Spawn an extended review team** using TeamCreate with `model: "opus"`. Activate every always-on persona plus every conditional persona — Deep mode runs them all regardless of gate state, but still records why each gate would have fired (or not) for the report. Include the reviewer preamble from Context Isolation in each reviewer's instructions.

3. All reviewers work in parallel. Each reads the prepared review package and reports structured findings with confidence scoring (same format and calibration as Standard mode).

4. **Merge and deduplicate** — same process as Standard mode.

5. Team converges on a unified review via messages.

6. Emit findings per the same dispatch rules as Standard.

## Posting findings to GitHub

This block runs only when the input was a PR argument. It posts a single GitHub review carrying a summary body plus all inline comments, with idempotency keyed on a hidden fingerprint.

### 1. Fingerprint each finding

For every merged finding, compute:

```
fp = sha256(file + ":" + line_bucket + ":" + normalized_title)[:12]
```

Severity is intentionally **not** part of the fingerprint: idempotency keys on location + title so reruns don't re-post the same finding when severity is recalibrated between runs or when personas disagree on severity.

`line_bucket` and `normalized_title` are the same values used for the in-session merge tuple (Process step 5 above): `line_bucket = floor(line / 3) * 3` (groups lines into fixed 3-line windows so most near-duplicates collide on the same bucket; findings straddling a window boundary, e.g. lines 2 and 4, do not), and `normalized_title` lowercases, strips trailing punctuation, and collapses whitespace. The summary review body gets its own fingerprint:

```
summary_fp = sha256("summary:" + pr_number + ":" + sorted(per_finding_fps).join(","))[:12]
```

### 2. Pre-scan for existing fingerprints

Fetch every existing review comment authored by the runner on this PR, parse the markers, and skip findings whose fingerprint already appears.

```bash
me=$(gh api user --jq .login)
existing=$(gh api "repos/{owner}/{repo}/pulls/{N}/comments" --paginate \
  --jq "[.[]
          | select(.user.login==\"\$me\")
          | .body
          | select(test(\"<!-- review-fp: [a-f0-9]+ -->\"))
          | capture(\"<!-- review-fp: (?<fp>[a-f0-9]+) -->\").fp]")
```

The `select(test(...))` guard skips hand-written reviewer comments that don't carry the marker — without it, `capture` raises on the first non-marker body and aborts the prescan, blocking the post. Filtering by author also avoids colliding with hand-written comments that happen to share file+line+title.

Also fetch existing review summary bodies and skip the entire post if a `<!-- review-summary-fp: <summary_fp> -->` already exists for this PR — a re-run with no new findings is a no-op. The summary lives on the review object itself, not on inline comments, so use `/pulls/{N}/reviews` (not `/pulls/{N}/comments`):

```bash
existing_summary_fps=$(gh api "repos/{owner}/{repo}/pulls/{N}/reviews" --paginate \
  --jq "[.[]
          | select(.user.login==\"\$me\")
          | .body
          | select(test(\"<!-- review-summary-fp: [a-f0-9]+ -->\"))
          | capture(\"<!-- review-summary-fp: (?<fp>[a-f0-9]+) -->\").fp]")
```

Same hardening as the inline-comment prescan (filter by author + `select(test(...))` before `capture`). If `$summary_fp` is in `existing_summary_fps`, exit early without posting.

### 3. Build the review payload

Each inline finding becomes one entry in `comments[]`. The body ends with a hidden marker so future runs can dedup:

```
**[P1, conf 0.85]** Issue title

Optional one-line elaboration.

<!-- review-fp: a1b2c3d4e5f6 -->
```

The summary body lists the **top 3 findings** sorted by severity descending, then confidence descending as tiebreaker. End the summary body with `<!-- review-summary-fp: <summary_fp> -->`.

### 4. Post atomically

Use a single REST call so the review is created with all comments in one transaction (the `gh api` + `jq` body-assembly pattern from `${CLAUDE_PLUGIN_ROOT}/skills/resolve-pr-feedback/SKILL.md`):

```bash
jq -n \
  --arg body "$summary_body" \
  --arg commit "$head_sha" \
  --argjson comments "$comments_json" \
  '{event: "COMMENT", commit_id: $commit, body: $body, comments: $comments}' | \
  gh api repos/{owner}/{repo}/pulls/{N}/reviews --input -
```

`commit_id` is the `headRefOid` captured in **Context Isolation** step 1 — anchoring the review to that SHA prevents 422s and stops inline comments from drifting if the PR head advances mid-run. `event` is `"COMMENT"` (not `"REQUEST_CHANGES"` or `"APPROVE"`) — review-only, no merge gating. Each entry in `$comments_json` carries `path`, `line` (or `start_line`/`line` for ranges), `side`, and `body` with the embedded fingerprint marker.

### 5. Report back to the user

Print:

- The created review URL (`...#pullrequestreview-XXXXX`).
- `posted: N | skipped: M` — N is new findings, M is duplicates skipped via fingerprint.
- The top-3 ranked findings (mirror of the summary body), so the user has them in-session.

No fix brief is returned — there is no `/build` consumer in PR mode.

## Output

A structured review report with:

- Pass/fail per acceptance criterion
- Issues found (with file:line references, severity, and confidence score)
- Which conditional personas were activated and why (Standard) or note that all were active (Deep)
- Recommendations

When returning findings to `/build` (branch + seed brief mode only), package them as a **fix brief**: failing criteria + `file:line` findings + severity + confidence. No session history — `/build` already has the full context and should not re-ingest the review session.

In **PR-argument mode**, the canonical output is the posted GitHub review; the in-session report is a short pointer (review URL, posted/skipped counts, top-3 ranked findings).

## Rules

- Never fix issues during review — separation of concerns.
- All reviewers must agree before the review is finalized.
- All reviewers can block on Critical findings. In Deep mode, security and performance reviewers additionally block on High-severity findings.
- Flag any changes outside the stated scope of the issue.
- Confidence below 0.60 means suppress (0.50 for P0/Critical).
- Always run the merge/dedup step — never present raw duplicates to the user.
- **PR mode is single-repo only.** Treat the worktree's origin as the target; do not accept cross-repo PR URLs.
- **PR mode is review-only.** Never push commits, never auto-fix, never approve or request-changes — `event: "COMMENT"`.
- **PR mode is idempotent.** Always pre-scan for existing fingerprints before posting; re-runs must not duplicate comments.
- **PR mode never returns a fix brief.** The fix-brief path is reserved for the branch + seed-brief invocation from `/implement`.
