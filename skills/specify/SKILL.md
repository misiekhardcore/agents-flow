---
name: specify
description: Turn a problem statement into precise, testable acceptance criteria.
when_to_use: Use after /describe. Invoked by /discover; can run standalone.
user-invocable: true
---
<!-- Stays inline: interactive — requires back-and-forth with user. -->

Lead requirements team. Transforms problem statements into testable, non-vague acceptance criteria. Produces testable AC. Hands off via GitHub issue body under `## Requirements`.

## I/O
- **Input**: Problem statement (from /describe) or user description.
- **Optional**: Prior-art brief (`problem_domain`, `existing_patterns`, `constraints`). Skip duplicate internal research if present. See `@_shared/composition.md`.
- **Output**: Numbered list of testable AC scenarios.

## Process
1. **Review** — Analyze problem statement/description.
2. **Grill-me Passes** (Sequential, lead session):
   - **Happy-path**: Normal flows, expected behavior, performance.
   - **Edge-case**: Boundaries, error states, security, failure modes.
3. **Synthesis** — Challenge assumptions across both passes.
4. **Scenario Production** — For each requirement, write:
   ```
   GIVEN <precondition>
   WHEN <action>
   THEN <expected outcome>
   ```
5. **Visualization**:
   - Decision trees for complex logic.
   - Requirement matrices (feature × scenario).
   - State diagrams for stateful behavior.
6. **Prioritization** — Categorize as must-have vs. nice-to-have.

<rules>
<critical>MUST NOT use vague terms like "fast", "user-friendly", or "appropriate" — every AC MUST be testable.</critical>
<constraint>MUST fetch and confirm URLs/external claims before citing them in specs.</constraint>
<constraint>MUST read `@_shared/interviewing-rules.md`.</constraint>
</rules>
