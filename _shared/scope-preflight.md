# Scope Pre-flight — Shared Protocol

Used by skills performing bulk file edits. Read before modifying 3+ files or actions with unclear blast radius.

## Trigger

Run when either condition holds:
- Proposed change touches **3+ files**.
- User request matches: `audit`, `refactor`, `normalize`, `sweep`, `propagate`, `extract`, `rename`.

## File-list confirmation

Before editing, present the proposed file list:

> I'm about to modify N files:
> - `<path 1>`
> - `<path 2>`
> - ...
>
> Proceed?

Wait for explicit user confirmation. Partial feedback or silence is not approval.

## Refusal

If the user does not confirm, do not edit any of the listed files. Reply:

> Holding off — please clarify which files are in scope.

Re-prompt with a narrowed list when the user provides scope.

## Orchestrator pattern

Orchestrators run this at entry and pass `scope_class` in seed briefs. Specialists skip their own scope confirmations when brief is present.
