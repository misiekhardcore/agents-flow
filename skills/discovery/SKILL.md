---
name: discovery
description: Full discovery phase — explore a problem and produce a GitHub issue with AC.
when_to_use: Start of any new feature or vague problem. Precedes /define.
argument-hint: "[issue# | description]"
model: opus
effort: high
allowed-tools: Agent Bash Read
---
## Role & Constraints
Lead discovery phase. Goal: Transform vague ideas into well-specified GitHub issues ready for architecture and implementation.

## Scope Assessment

|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Clear repro, single area|/describe (Lightweight) → issue|
|**Standard**|Typical feature, some unknowns|Team: /describe + /specify + Prior-Art Scout|
|**Deep**|Cross-module, auth/security/payments, arch|Full team + flow analyst + adversarial questioner|

**Decision**: 1-sentence fix + clear repro → Lightweight; Auth/Security/Payments/Arch → Deep; else → Standard.

Spawn: Standard = describe + scout + specify; Deep = TeamCreate with all roles.

## Process

**Lightweight**: `/describe` → quick confirmation → extract AC → issue.

**Standard**: Prior-Art Scout (parallel) → `/describe` (with scout brief) → `/specify` → issue.

**Deep**: TeamCreate (all roles) → Describe/Flow-Analyst/Scout in parallel → Adversarial Questioner challenges → Specify last → issue.

## Issue Creation

Invoke `Skill("preflight")` before `gh issue`.

**Structure** (per `Invoke Skill("handoff-artifact")`):
- **Preamble**: What, Why, Who (from `/describe`).
- **Requirements**: Acceptance criteria → Constraints → Prior decisions (optional) → Evidence (optional) → Open questions (optional).

Present for approval → sign-off → instruct: "Start `/define` in a fresh session."

## Rules
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Persistence**: Prior-Art Scout findings must be persisted in Prior decisions/Evidence fields.
- **Traceability**: Every feature must have one issue and >= 1 closing PR.
- Invoke `Skill("interviewing-rules")`
