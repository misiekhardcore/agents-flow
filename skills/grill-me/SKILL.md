---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.
when_to_use: Use when the user wants to stress-test a plan, get grilled on a design, or mentions "grill me".
model: sonnet
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

When a question has a bounded set of distinct options (2-4), use the `AskUserQuestion` tool to present them in a picker UI rather than a plain numbered list. Place the recommended option first with ` (Recommended)` appended to its label. Use `multiSelect: true` when choices are not mutually exclusive. Fall back to free-text prompts for open-ended exploration.

If a question can be answered by exploring the codebase, explore the codebase first and ask the question based on your findings if still in doubt.
