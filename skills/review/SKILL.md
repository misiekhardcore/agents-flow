---
name: review
description: Review implementation against requirements or PR. Posts inline GitHub review comments.
argument-hint: "[PR# or URL]"
model: sonnet
effort: high
layer: 2
user-invocable: true
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead review phase. Goal: Thoroughly review implementation against requirements and produce actionable findings. Produce inline GitHub review comments. Hand off findings via seed-brief for fix cycles.

## Specialist Mode
- **Seeded**: Skip repo-preflight.
- **Keep**: Severity/depth gates (rigor not delegated).
Invoke `Skill("specialist-mode")` at entry.

## Specialist Assessment
Invoke `Skill("review-specialist-assessment")` at entry. It reads diff/AC from context and emits a `specialists:` list (always includes `reviewer-correctness` and `reviewer-standards`; conditionally adds `reviewer-security`, `reviewer-perf`, `reviewer-migration`).

## I/O
- **Input**: Branch (+ seed brief), Branch (standalone + issue#), or PR argument (PR# or URL).
- **Review Package**: Diff (`git diff` or `gh pr diff`), AC (seed brief / issue / linked), reviewer preamble.
- **Output**: Fix brief (for `/build`), Findings report (user), or Posted GitHub review (PR).

Read `references/dispatch-process.md` for dispatch modes, process steps, and PR posting logic.

## Process
1. Acquire review package per dispatch mode (see `references/dispatch-process.md`).
2. Triage: analyze diff → `Skill("review-specialist-assessment")` → build `specialists:` list; record which gates fired.
3. Spawn one agent per specialist using parallel `Agent()` calls (see `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`). Pass diff and AC to each.
4. Collect findings and merge per `references/dispatch-process.md § Merge & Dedup`.
5. Emit output per dispatch mode (fix brief, findings report, or posted GitHub review).

### Personas (see `references/personas.md`)
- **Always-on**: Correctness, Standards.
- **Conditional**: Security, Performance, Migration, Docs Consistency, Architecture/Scope-creep. (Activate only if gate fires.)

## Rules
- **Separation**: Never fix issues during review. Report findings in the review output; fixes happen in a subsequent `/build` cycle.
- **Consensus**: All reviewers must agree before finalizing.
- **Blocking**: Critical findings block. High-severity blocks for Security/Perf are non-waivable.
- **Scope**: Flag changes outside issue scope.
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md`
