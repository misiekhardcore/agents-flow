# Multi-Skill Composition — Reference

Framework for orchestrating specialists and managing token/context budgets.

## Roles
- **Orchestrator**: Phase lead. Spawns specialists, coordinates, writes handoff. Model: `opus`.
- **Specialist**: Bounded task. Receives seed-brief, reports findings. Model: `sonnet`.
- **Interactive Primitive**: Inline behavior (e.g., `/grill-me`). No team/handoff. Model: `sonnet`.
- **Utility**: Maintenance (e.g., `/compound`, `/prune`). No seed-brief contract.

## Composition Patterns
- **Linear**: A → B → C (Strict dependency).
- **Branch**: A → (B or C) (Conditional).
- **Loop**: A → B → A (Iterative refinement).
- **Parallel**: A → (B ∥ C) → merge (Independent streams; lead collects and merges reports).

## Team Sizing & Cost
Tally total token usage as ~N × single-session baseline.

|Team Shape|When|Approx Cost|
|-|-|-|
|Inline single agent|Single file, no unknowns|~1×|
|2–3 sequential subagents|Multi-file, typical feature|2–4×|
|All specialists (parallel subagents)|Cross-module, security, arch|~(N+1)× where N = activated specialists|

### Decision Ladder
Escalate only when the lower level is insufficient:

|Level|When|Example|
|-|-|-|
|**Inline**|1-4 items, fit in lead context|Audit 2 open issues|
|**Sub-agent**|>= 5 items or verbose I/O (overrun boundary)|Fan-out across 8 issues|
### Main-Thread Overrun (Delegate when:)
- **Read Sweep**: >= 5 independent files saturate lead context.
- **N-way Fan-out**: N × item_size > context_budget.
- **Verbose I/O**: Pure retrieval/formatting with thin synthesis.

**Spawn Prompt Essentials**: `cd <abs-path> && pwd`, absolute paths, load-bearing findings.

## Seed-Brief Contracts
Passed as raw YAML in `<seed-brief>` tag. Specialist skips research if present.

|Brief Type|Core Fields|
|-|-|
|**Research**|`tech_stack`, `module_map`, `patterns`, `prior_art`, `open_questions`|
|**Prior-Art**|`problem_domain`, `existing_patterns`, `constraints`|
|**Fix**|`failing_ac`, `findings` (`file:line`), `prior_decisions`|

## Handoff vs Seed-Brief
|Feature|Handoff Artifact|Seed Brief|
|-|-|-|
|**Storage**|GitHub Issue (Durable)|In-Context (Ephemeral)|
|**Boundary**|Phase-to-Phase|Intra-Phase (Orch → Spec)|
|**Authority**|AC, prior decisions|Research, prior art, findings|
|**Author**|Phase Orchestrator|Specialists / Research agents|

## Failure Modes
- **Context Bleed**: Specialist output leaks. → Use explicit seed-briefs.
- **Brief Inflation**: Brief becomes too large. → Cap to defined fields.
- **Over-Parallelization**: Contradictory outputs. → Serialize (e.g., Arch before Design).
- **Inline Overrun**: Lead session bloats. → Delegate verbose work to subagent.
- **Subagent Re-research**: Agent re-reads files. → Pass paths/findings in prompt.
