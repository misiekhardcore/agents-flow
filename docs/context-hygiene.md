# Context Hygiene

Logic for treating phase boundaries as context resets to prevent reasoning rot.

## Core Rules
1. **Phase Reset**: Reset session at boundaries. Handoff via GitHub issue body.
2. **Context Editing**: Prefer clearing tool results over summarization. Trigger on concept shifts.
3. **Sub-agent Isolation**: Delegate bulk I/O to sub-agents. Lead receives distilled report only.
4. **Durable State**: Persist end-of-phase state to issue body before reset.

## Implementation
- **Sizing**: Treat rot threshold as ~12% of window (~120k for 1M model).
- **Scent of Rot**:
  - File-sweep (>= 5 files).
  - Fan-out (N × item_size > budget).
  - Thin-synthesis (retrieval/formatting only).
  - Verbose-I/O (large output → small field set).

## Handoff Artifact
Fixed shape per `Read _shared/handoff-artifact.md`:
- Acceptance criteria, Constraints, Prior decisions (opt), Evidence (opt), Open questions (opt).

## See also
- `docs/token-budgets.md` for concrete numbers.
- Invoke the "compaction-protocol" skill for in-phase pressure.
