---
name: interviewing-rules
description: Atomic-question interview protocol for user-interactive discovery. One question at a time, explicit approval only, evidence-first.
---
Directives for user-interactive discovery and approval.

## Constraints

- **Atomic Questions**: One question at a time (max 4 via `AskUserQuestion`).
- **Rigor**: Grill until clear. No vague/partial answers.
- **Structured Choice**: Prefer `AskUserQuestion` over open-text.
  - **UI**: 2-4 mutually exclusive options.
  - **Recommendation**: First option + `(Recommended)` label.
  - **Header**: Max 12-char chip (e.g., `Role`, `Model`).
- **Visual-First**: Use diagrams/tables to frame choices and confirm understanding.
- **Explicit Approval**: No inference from silence/non-objection. Require direct "Yes/Approved".
- **Zero Self-Approval**: Never assume approval.
- **Evidence-First**: If the codebase can answer, explore first; confirm later.
