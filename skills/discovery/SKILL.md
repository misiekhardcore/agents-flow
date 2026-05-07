---
name: discovery
description: Full discovery phase — explore a problem and produce a GitHub issue with AC.
when_to_use: Start of any new feature or vague problem. Precedes /define.
argument-hint: "[issue# | description]"
model: opus
effort: high
---
## Role & Constraints
Lead discovery phase. Goal: Transform vague ideas into well-specified GitHub issues ready for architecture and implementation.

## Scope Assessment
|Scope|Criteria|Action|
|-|-|-|
|**Lightweight**|Clear repro, single area|/describe (Lightweight) → minimal /specify → issue. No team.|
|**Standard**|Typical feature, some unknowns|Team: /describe + /specify specialists + Prior-Art Scout.|
|**Deep**|Cross-module, auth/security/payments, arch-changing|Full team + flow analyst + Prior-Art Scout + adversarial questioner.|

**Decision**: 1-sentence fix + clear repro → Lightweight; Auth/Security/Payments/Arch-change → Deep; else → Standard.

### Spawn Rubric [Ref: composition]
- **Standard**: describe (lead-inline) + scout (parallel subagent) + specify (sequential subagent).
- **Deep**: `TeamCreate`. Adversarial questioner reacts live.

## Process

### Standard
1. **Prior-Art Scout** (Parallel subagent): Gather institutional memory from Vault → Issues/PRs → Docs. Output: structured brief (Prior decisions, Attempts, Patterns).
2. **Explore** (Lead-inline): Run `/describe`. Incorporate scout brief as seed context → skip internal prior-art research.
3. **Specify** (Sequential subagent): After problem statement is approved, run `/specify` seeded with findings + scout brief.

### Deep
1. **TeamCreate**: Describe, Specify, Flow Analyst, Prior-Art Scout, Adversarial Questioner.
2. **Execution**: Describe, Flow Analyst, and Scout run in parallel. Adversarial Questioner reviews combined findings → challenges conclusions. Specify specialist runs last, incorporating all concerns.
3. **Sourcing**: Scout brief seeds `/describe` → skip internal prior-art exploration.

### Lightweight
1. `/describe` (Lightweight mode) → quick problem confirmation.
2. Extract 3-5 core AC directly (skip `/specify`).
3. Issue creation.

## Issue Creation
Run [Ref: repo-preflight] before `gh issue`.

**Structure**:
1. **Preamble**: From `/describe` output (What, Why, Who).
2. **Handoff Block** (`## Requirements`): Fields per [Ref: handoff-artifact] in this order:
   - **Acceptance criteria** (numbered testable scenarios)
   - **Constraints** (in/out scope, non-negotiable decisions)
   - **Prior decisions** (optional: decision + rationale)
   - **Evidence** (optional: links/benchmarks)
   - **Open questions** (optional: for `/define`)

**Closing**: Present for approval → sign-off → instruct user: "Start `/define` in a fresh session."

## Rules
- **Explicit Approval**: Partial feedback ≠ approval.
- **Traceability**: Every feature must have one issue and >= 1 closing PR.
- **Persistence**: Prior-Art Scout findings must be persisted in Prior decisions/Evidence fields.
- [Ref: interviewing-rules]
