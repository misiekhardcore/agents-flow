---
name: "<skill-name>"
description: "<Does X. Use when Y.>"
model: "<haiku | sonnet | opus>"
# Uncomment only if this skill runs long-form multi-turn research or decision-making:
# effort: high
# Uncomment to pre-approve a narrow tool surface (skips permission prompts; does not restrict access):
# allowed-tools: Read Grep Glob Bash
---

## Input

<!-- What the specialist receives — issue number, problem statement, diff, etc. -->

Optionally: a <research | prior-art | fix> brief from <source skill>. When present, skip internal research and use the brief as starting context. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for the brief field list.

### Spawn justification

If this specialist spawns sub-agents or teams internally, state your choice explicitly: inline, parallel subagents, or TeamCreate. Document the gate conditions from `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` that justify the choice. See `/resolve-pr-feedback`, `/compound` for examples.

## Process

1. Check for a seed brief. If present, skip to step 3.

2. <Internal research — what to scan, what to read. Omit section if no research phase.>

3. <Core task steps — be concrete: what to read, what to produce, what to output.>

4. <Verification or synthesis step.>

## Output

<!-- What the specialist produces — a report, a file, a brief, a review finding, etc. -->

## Rules

- <Rule 1 — non-negotiable constraint>
- <Rule 2>
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol (when the skill interviews the user).
