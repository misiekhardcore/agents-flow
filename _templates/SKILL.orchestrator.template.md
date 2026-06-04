---
name: <skill-name>
description: <Leads the X phase. Use when Y.>
# when_to_use: <routing hint — when should this skill be invoked?>
# argument-hint: "[arg]"  # Uncomment if skill accepts a positional argument
model: <opus for research-leading orchestrators; sonnet for coordinator orchestrators>
# effort: high  # Uncomment for research-leading orchestrators only
# allowed-tools: Agent Bash Read  # Uncomment to restrict tool surface (pre-approves narrow set; does not block access)
# user-invocable: false  # Uncomment to hide from slash-command menu
# disable-model-invocation: true  # Uncomment for pipeline orchestrators that only sequence sub-skills without their own reasoning
---
You are leading the <phase name> phase. Your goal is to <objective>.

<!-- Coordinator: drop step 2. Terminal: drop step 5. -->

## Input

<!-- What the orchestrator receives — issue number, handoff block, or problem statement. -->

## Team Shape

Invoke `Skill("scope-assessment")` with work units (one per sub-issue, module, or bounded task). Receive agent plan; dispatch one agent per disjoint group.

For high-risk domains (auth/security/payments/arch-changing): add a critique pass after the main team. Determine risk from AC — not from a label.

See `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` for spawn cost models.

## Process

1. Read input; build work-unit list for `scope-assessment`.
2. **Research team** (TeamCreate; multi-area only):
   - **Codebase research** — tech stack, modules, patterns. Outputs research brief.
   - **Prior art** — vault, project docs, external sources.
3. **Main team** (TeamCreate), seeded with research. Width = scope. Include only needed specialists:
   - **Specialist A** — `/<skill>` to <do thing>. Seeded; skips research.
   - **Specialist B** — `/<skill>` to <do thing>.
4. <Serialization rule — which specialist first and why.>
5. **Handoff artifact** — update GitHub issue body in place with decisions and five-field block.
6. Present output; require explicit approval. After sign-off, tell user to start next phase fresh.

## Output

<!-- Durable artifact — issue body update, sub-issues, PR, etc. -->

## Rules

- Require explicit approval. Silence is NOT approval.
- Research team before main team for multi-area work. Never skip seed-brief gate.
- Single work unit: code inline. Never pay overhead for <1 min work.
- Invoke `Skill("handoff-artifact")` and `Skill("interviewing-rules")`.
