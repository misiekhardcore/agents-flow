# Agent Role Presets

Three reusable presets for opencode agent files. Validated against `references/opencode-config.md`.

## Read-only reviewer/researcher

Role: stateless single-domain executor. Read-only, no user interaction, no subagent spawning.

Tier: **smart**.

```yaml
permission:
  task:
    "*": "deny"
  question: deny
  edit: deny
hidden: true
mode: subagent
```

Tools available: read, grep, glob, bash (read-only — no mutation).

**Exemplar**: `agents/workflow-reviewer.md`, `agents/workflow-researcher.md`.

## Build worker

Role: atomic code-writer in an existing worktree. Writes code, runs tests, commits.

Tier: **fast**.

```yaml
permission:
  task:
    "*": "deny"
  question: deny
hidden: true
mode: subagent
```

**Worktree refusal** (decision 13, AC10): MUST refuse to write outside a worktree.
- On entry: `cd <path> && git rev-parse --show-toplevel` — if not inside a git worktree with branch matching the seed-brief's `branch` field, abort with:
  ```
  ABORT: Not inside the required worktree. The orchestrator must create/verify a worktree before dispatching a build worker.
  ```

**Exemplar**: `agents/workflow-build-worker.md`.

## Orchestrator

Role: primary agent running the main interactive conversation. Owns the loop, delegates domain work.

Tier: **smart**.

```yaml
mode: primary
permission:
  skill:
    "*": "deny"
  question: allow
  task: allow
```

`permission.skill` uses an explicit allowlist referencing skill names from `AGENTS.md` (the S5 #232 skill-name registry). Allowlisted skills are loaded on demand via the skill tool — never inlined.

**Exemplars**: `agents/discover-orchestrator.md`, `agents/define-orchestrator.md`, `agents/implement-orchestrator.md` (S3 #230 PR #247).
