---
name: review
description: Review implementation against requirements or PR. Posts inline GitHub review comments.
argument-hint: "[PR# or URL]"
model: sonnet
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead review phase. Goal: Thoroughly review implementation and produce actionable findings.

## Specialist Mode
- **Seeded**: Skip repo-preflight.
- **Keep**: Severity/finding-depth gates (rigor is not delegated).
- Invoke `Skill("specialist-mode")`

## I/O
- **Input**: Branch (+ seed brief), Branch (standalone + issue#), or PR argument (PR# or URL).
- **Review Package**: Diff (`git diff` or `gh pr diff`), AC (seed brief / issue / linked), reviewer preamble.
- **Output**: Fix brief (for `/build`), Findings report (user), or Posted GitHub review (PR).

Read `references/dispatch-process.md` for dispatch modes, scope assessment, spawn rubric, process steps, and PR posting logic.

## Personas (see `references/personas.md`)
- **Always-on**: Correctness, Standards.
- **Conditional**: Security, Performance, Migration, Docs Consistency, Architecture/Scope-creep. (Activate only if gate fires).

## Rules
- **Separation**: Never fix issues during review. Report findings in the review output; fixes happen in a subsequent `/build` cycle.
- **Consensus**: All reviewers must agree before finalizing.
- **Blocking**: Critical findings block. Deep mode: High-severity blocks for Security/Perf.
- **Scope**: Flag changes outside issue scope.
- Invoke `Skill("interviewing-rules")`
