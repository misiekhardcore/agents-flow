---
name: specify
description: Turn a problem statement into precise, testable acceptance criteria.
when_to_use: Use after /describe. Invoked by /discovery; can run standalone.
model: sonnet
---
<!-- Stays inline: interactive — requires back-and-forth with user. -->

## Role & Constraints
Lead requirements team. Goal: Transform problem statements into testable, non-vague AC.

## Specialist Mode
- **Seeded**: Skip scope-class and file-scope confirmations.
- **Keep**: AC derivation gates (quality is not delegated).
- [Ref: specialist-mode]

## I/O
- **Input**: Problem statement (from /describe) or user description.
- **Optional**: Prior-art brief (`problem_domain`, `existing_patterns`, `constraints`). Skip duplicate internal research if present. [Ref: composition]
- **Output**: Numbered list of testable AC scenarios.

## Process
1. **Review**: Analyze problem statement/description.
2. **Grill-me Passes** (Sequential, lead session):
   - **Happy-path**: Normal flows, expected behavior, performance.
   - **Edge-case**: Boundaries, error states, security, failure modes.
3. **Synthesis**: Challenge assumptions across both passes.
4. **Scenario Production**: For each requirement, write:
   ```
   GIVEN <precondition>
   WHEN <action>
   THEN <expected outcome>
   ```
5. **Visualization**:
   - Decision trees for complex logic.
   - Requirement matrices (feature × scenario).
   - State diagrams for stateful behavior.
6. **Prioritization**: Categorize as must-have vs. nice-to-have.

## Rules
- **Zero Vagueness**: No "fast", "user-friendly", or "appropriate". Every AC must be testable.
- **Verification**: Fetch and confirm URLs/external claims before citing in specs.
- [Ref: interviewing-rules]
