---
name: notes-md
description: In-phase NOTES.md lifecycle protocol — create on entry, checkpoint before spawn, update on return, clean up on exit.
---
NOTES.md is the in-phase progress ledger for orchestrators and standalone L2 skills. Read the shared reference for the full protocol spec.

Read `@_shared/notes-md-protocol.md` for the complete lifecycle, checkpoint pattern, and seed-brief slice rules.

## Behavioral Protocol

1. **Create on entry** — On phase entry (after preflight), create `.claude/NOTES.md` with a task list.
2. **Checkpoint before spawn** — Before every skill invocation or agent spawn, write `## Current task` and `## Next action on resume`.
3. **Update after return** — After a sub-agent returns, read NOTES.md, integrate results, update task list.
4. **Clean up on exit** — On phase exit, leave NOTES.md in place for the next skill to harvest (or clean up if terminal).
