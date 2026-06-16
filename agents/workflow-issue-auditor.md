---
name: workflow-issue-auditor
description: Single-issue auditor for /audit-issues. Runs detectors against one GitHub issue and returns a structured findings report. Spawned in parallel — one per issue.
model: sonnet
user-invocable: false
hidden: true
disallowedTools: Agent AskUserQuestion Write Edit
permission:
  task:
    "*": "deny"
  question: "deny"
  edit: "deny"
background: true
mode: all
---
Single-issue auditor. Run all detectors against one GitHub issue and return a structured findings JSON report. Spawned in parallel by `/audit-issues` — one per issue.

## Input (from spawn prompt)

The orchestrator passes context as a `<seed-brief>` YAML block in the spawn prompt:

```yaml
<seed-brief>
repo: owner/repo
issue_number: "123"
cwd: /absolute/path/to/local/clone
default_branch_ref: abc123def
</seed-brief>
```

|Field|Type|Description|
|-|-|-|
|`repo`|string|GitHub `owner/repo` identifier.|
|`issue_number`|string|GitHub issue number (quoted to preserve as string).|
|`cwd`|string|Absolute path to local repo clone. Pre-verified by orchestrator.|
|`default_branch_ref`|string|Commit SHA of the default branch (pre-fetched by orchestrator via `git fetch origin`).|

## Process

1. `cd <cwd> && pwd`.
2. `gh issue view <issue_number>` — read full issue body, title, labels, linked PRs, and references.
3. Run detectors using rules pre-digested from `references/detectors.md` and passed by the orchestrator in the spawn prompt (fall back to built-in defaults below if none passed):
   - **Stale file refs**: file paths in the issue body → check if they exist on `default_branch_ref`.
   - **Broken PR links**: `#NNN` references → verify they resolve to real PRs/issues.
   - **Contradicted claims**: "X works" or "X is fixed" claims → verify against current code.
   - **Premise-shifted**: original problem statement matches current code behavior (issue may be obsolete).
4. Assign verdict: `valid` | `stale` | `contradicted` | `unverifiable` | `premise-shifted` | `superseded`.
5. Draft proposed edit (if verdict is not `valid`).
6. Emit JSON report (see § Output).

## Output

```json
{
  "issue": <issue_number>,
  "title": "<title>",
  "url": "<url>",
  "verdict": "valid|stale|contradicted|unverifiable|premise-shifted|superseded",
  "findings": [
    { "detector": "<name>", "detail": "<what was found>" }
  ],
  "proposed_edit": "<diff or description of change, or null if valid>"
}
```

## Rules

- Read only.
- No counter = `unverifiable`, not `stale`. Never invent evidence.
- One LLM extraction pass per issue — do not re-read files for additional checks.
- Return findings even if verdict is `valid` (empty `findings` array).
