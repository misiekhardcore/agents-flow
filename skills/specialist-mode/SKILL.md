---
name: specialist-mode
description: Logic for standalone vs. orchestrator-invoked (seeded) execution and seed-brief contract.
user-invocable: false
layer: 3
---
Logic for standalone vs. orchestrator-invoked (seeded) execution.

## Detection

`specialist_mode = True` if `<seed-brief>` block exists in prompt.

- **Seeded**: Verified fields replace preflights.
- **Standalone**: All prompts active.

## Seed-Brief Contract

**Format**: Raw YAML in XML tag `<seed-brief>`, no inner fence.

|Field|Type|Req|Notes|
|-|-|-|-|
|`preflight_verified`|bool|Yes|Must be `true`|
|`repo`|string|Yes|`owner/repo` (verified vs `git remote -v`)|
|`branch`|string|Yes|`feat/<slug>` (verified vs `git rev-parse`)|
|`active_issue`|int|Yes|GitHub issue ID|
|`payload`|object|Yes|`{ type: fix\|research\|prior-art, ... }` (see § Payload Types below)|
|`autonomous`|bool|No|Default `false`. If `true`, suppresses `/implement` exit prompt|

**Failure**: Invalid brief → Fallback to standalone + log failure.

### Payload Types

The `payload` field is a dict with a required `type` key and type-specific contents. Examples:

#### `type: research`

Used to spawn a build or implementation sub-skill. Contains high-level architecture decisions and known constraints. The optional `progress` field carries intra-orchestrator state from NOTES.md so the sub-agent arrives with task context.

```yaml
payload:
  type: research
  prior_art: "<Issue implementation plan, architecture, and design decisions>"
  progress: "<NOTES.md slice — task list subset + decisions; see notes-md-protocol.md § Seed-brief slice>"
  open_questions: "<Unresolved constraints or empty string>"
```

#### `type: fix`

Used when spawning a specialist to fix a specific failure. Contains line-specific findings and the AC to address. The optional `progress` field carries intra-orchestrator state from NOTES.md.

```yaml
payload:
  type: fix
  failing_ac: "<Failed acceptance criterion(s)>"
  findings: "file.js:42 — function does not handle edge case\nfile.ts:15 — type mismatch"
  prior_decisions: "<Prior architectural decisions or design constraints>"
  progress: "<NOTES.md slice — task list subset + decisions; see notes-md-protocol.md § Seed-brief slice>"
```

#### `type: prior-art`

Used for research or exploration tasks where codebase patterns are critical context.

```yaml
payload:
  type: prior-art
  problem_domain: "<Brief problem statement>"
  existing_patterns: "<Codebase patterns, libraries, or conventions relevant to this task>"
  constraints: "<Non-negotiable constraints from requirements or architecture>"
```

## Autonomous Implement Invocation

Canonical seed-brief for orchestrators that spawn `/implement` with `autonomous: true`:

```
<seed-brief>
preflight_verified: true
repo: <owner/repo>
branch: <feat/slug>
active_issue: <issue-number>
autonomous: true
payload:
  type: research
  prior_art: "<Issue #N ## Implementation plan (architecture and design decisions from /define)>"
  open_questions: "<unresolved constraints from /define, or empty>"
</seed-brief>
```

Override only the fields that differ per invocation; all other fields are required as-is.

## Orchestrator Duties

1. Run repo/scope-preflight once at entry.
2. Pass valid seed-brief (`preflight_verified: true`) to every specialist.
3. Include `repo`, `branch`, `active_issue` for sanity checks.
