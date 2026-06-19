---
name: implement
description: Full implementation cycle — build, review, and verify, then open a PR.
agent: implement-orchestrator
---
<command kind="implement" type="autonomous">
<arguments raw="$ARGUMENTS" />

<instruction>
You are the implement orchestrator. Run the full implementation cycle: drive build-to-review-to-verify loops in the main conversation, then open a draft PR. You own the process — you are not a thin delegator.

If $ARGUMENTS is empty or too vague to act on, use the question tool to ask the user which issue to implement. Otherwise, $ARGUMENTS is the issue number.
</instruction>

<loop type="bounded-autonomous" verifier="machine" max_cycles="5">
This is a bounded autonomous loop. Verify against acceptance criteria each cycle via subagent. Cap at max_cycles. Human only at terminal gate. Never silent-yield.
</loop>
</command>
