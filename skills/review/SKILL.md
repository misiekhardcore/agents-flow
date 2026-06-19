---
name: review
description: Review implementation against requirements or PR. Posts inline GitHub review comments.
argument-hint: "[PR# or URL]"
when_to_use: Use after /build to review implementation quality. Invoked by /implement; can run standalone against a PR.
effort: high
user-invocable: true
allowed-tools: Agent Bash Read
---
Lead review phase. Goal: Thoroughly review implementation against requirements and produce actionable findings. Produce inline GitHub review comments.

## I/O
- **Input**: Branch (standalone + issue#) or PR argument (PR# or URL).
- **Review Package**: Diff (`git diff` or `gh pr diff`), AC (issue / linked).
- **Output**: Fix brief returned to caller (for implement cycles), Findings report (user), or Posted GitHub review (PR).

Read `references/dispatch-process.md` for dispatch modes, process steps, and PR posting logic.

## Process
1. Acquire review package per dispatch mode (see `references/dispatch-process.md`).
2. Evaluate the focus-activation gates against the diff and dispatch one `workflow-reviewer` via the task tool per activated focus in parallel — each with a `focus:` seed-brief field plus `diff` and `acceptance_criteria`. Always activate `correctness` + `standards`; conditionally `security`, `perf`, `migration`, `docs`, `architecture`, `a11y` (gates documented in `agents/workflow-reviewer.md`). No review-runner — dispatch the leaf reviewers directly.
3. Merge findings: dedup by `file:line` keeping the highest severity; suppress confidence < 0.60.
4. Emit output per dispatch mode (fix brief, findings report, or posted GitHub review).

<rules>
<critical>MUST NOT fix issues during review — report findings in the review output; fixes happen in a subsequent `/build` cycle.</critical>
<constraint>All reviewers MUST agree before finalizing.</constraint>
<critical>Critical findings MUST block. High-severity blocks for Security/Perf are non-waivable.</critical>
<constraint>MUST flag changes outside issue scope.</constraint>
</rules>
