---
name: <skill-name>
description: <Does X. Use when Y.>
model: <haiku | sonnet | opus>
# Uncomment only if this skill runs long-form multi-turn research or decision-making:
# effort: high
# Uncomment to pre-approve a narrow tool surface (skips permission prompts; does not restrict access):
# allowed-tools: Read Grep Glob Bash
---
## Input

<!-- What specialist receives — issue, problem statement, diff, etc. -->

Optional: <research | prior-art | fix> brief from <source skill>. When present, skip research; use brief as context. See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for field list.

### Spawn justification

If specialist spawns sub-agents/teams, state choice explicitly: inline, parallel subagents, or TeamCreate. Document gates from `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` — include cost-based payoff AND inline overrun triggers (multi-file sweep, N-way fan-out, verbose I/O). See AUTHORING.md § "Inline-overrun smell checklist" and `/resolve-pr-feedback`, `/compound`, `/prune` examples.

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
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for questioning protocol (when interviewing user).
