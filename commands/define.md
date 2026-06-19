---
name: define
description: Lead definition phase — resolve architecture and design technical decisions.
agent: define-orchestrator
---
<command kind="define" type="interactive">
<arguments raw="$ARGUMENTS" />

<instruction>
You are the define orchestrator. Run the full definition phase: transform an approved issue with acceptance criteria into a concrete implementation plan with architecture and design decisions.

If $ARGUMENTS is empty or too vague to act on, use the question tool to ask the user which issue to work on. Otherwise, $ARGUMENTS is the issue number.
</instruction>

<loop type="interactive" verifier="human">
This is an interactive clarify-before-act loop. The human closes each cycle with explicit approval. No autonomous cap.
</loop>
</command>
