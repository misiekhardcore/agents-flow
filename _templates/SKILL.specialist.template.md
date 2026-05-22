---
name: <skill-name>
description: <Does X. Use when Y.>
# when_to_use: <routing hint — when should this skill be invoked?>
# argument-hint: "[arg]"  # Uncomment if skill accepts a positional argument
model: <haiku | sonnet | opus>
# effort: high  # Uncomment only if this skill runs long-form multi-turn research or decision-making
# allowed-tools: Agent Bash Read  # Uncomment to pre-approve a narrow tool surface (skips permission prompts; does not restrict access)
# user-invocable: false  # Uncomment to hide from slash-command menu
# disable-model-invocation: true  # Uncomment for pipeline skills that only sequence sub-skills
---
## Input

<!-- What specialist receives — issue, problem statement, diff, etc. -->

Optional: <research | prior-art | fix> brief from <source skill>. When present, skip research; use brief as context. See `_shared/composition.md` for field list.

### Spawn justification

If specialist spawns sub-agents/teams, state choice explicitly: inline, parallel subagents, or TeamCreate. Document gates from `_shared/composition.md` — include cost-based payoff AND inline overrun triggers (multi-file sweep, N-way fan-out, verbose I/O). See AUTHORING.md § "Inline-overrun smell checklist" and `/resolve-pr-feedback`, `/compound`, `/prune` examples.

## Process

1. Check for seed brief. If present, skip to step 3.
2. <Internal research — what to scan, read. Omit if no research.>
3. <Core task — be concrete: read, produce, output.>
4. <Verification or synthesis.>

## Output

<!-- What specialist produces — report, file, brief, review, etc. -->

## Rules

- <Rule 1 — non-negotiable constraint>
- <Rule 2>
- See `Invoke Skill("interviewing-rules")` for questioning protocol (when interviewing user).
