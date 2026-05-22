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

## Team Shape

Invoke `Skill("scope-assessment")` with work units derived from the problem statement. Dispatch agents based on the result:
- **1-agent result**: `/describe` only.
- **Multi-agent result**: Prior-Art Scout (parallel) + `/describe` (with scout brief) + `/specify`.
- **High-risk domain** (auth/security/payments/arch): `TeamCreate` with flow analyst and adversarial questioner roles.

Determine scope from the problem domain and complexity — not a label.

## Process

Per scope-assessment output:
- **1-agent**: `/describe` → extract AC → issue.
- **Multi-agent**: Prior-Art Scout (parallel) → `/describe` (with scout brief) → `/specify` → issue.
- **High-risk domain**: `TeamCreate` (Describe + Flow-Analyst + Scout in parallel → Adversarial Questioner → Specify last) → issue.

## Issue Creation

Invoke `Skill("preflight")` before `gh issue`.

**Structure** — invoke `Skill("handoff-artifact")` for field list:
- **Preamble**: What, Why, Who (from `/describe`).
- **Requirements**: Acceptance criteria → Constraints → Prior decisions (optional) → Evidence (optional) → Open questions (optional).

Present for approval → sign-off → instruct: "Start `/define` in a fresh session."

## Rules
- **Explicit Approval**: Partial feedback ≠ approval.
- **Exploration**: Time-box codebase reading to 3–5 tool calls, then ask the user a focused question.
- **Persistence**: Prior-Art Scout findings must be persisted in Prior decisions/Evidence fields.
- **Traceability**: Every feature must have one issue and >= 1 closing PR.
- Invoke `Skill("interviewing-rules")`
