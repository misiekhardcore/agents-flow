# Issue-Autopilot: Stage 1 — Define Gate

## Stage 1 — Define gate

**Entry condition**: Issue lacks `## Implementation plan` in its body.

1. Invoke the "define" skill with seed-brief handoff (`issue: <N>`). `/define` produces architecture and design decisions and writes `## Implementation plan` into the issue body.
2. `/define` pauses for its own user-approval gate — do not add a second gate.
3. After `/define` exits, print:

   > Definition complete. Re-invoke `/issue-autopilot <N>` to continue to implementation.

4. **Exit.** User re-invokes after reviewing the plan.
