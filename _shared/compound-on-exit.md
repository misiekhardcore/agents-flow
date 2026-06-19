# Compound on Exit — Protocol

Phase-ending orchestrators invoke `/compound` once upon clean completion to capture session learnings into persistent wiki.

## Directive

After the final phase completes, invoke the "compound" skill.

## Scope

- **Condition**: Clean completion only. No invocation on abort, refusal, or early exit.
- **Frequency**: Exactly once per orchestrator run.
- **Exclusion**: Post-session utility skills do not invoke `/compound`.

## Assessment Gate

`/compound` self-assesses whether the session contains learnings worth capturing. If not, it exits silently. The orchestrator does not gate this decision.
