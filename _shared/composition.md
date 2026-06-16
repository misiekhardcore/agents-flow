# Multi-Skill Composition — Reference

Framework for orchestrating specialists and managing token/context budgets.

## Roles
- **Orchestrator**: Phase lead. Spawns workers, coordinates, writes handoff. Model: `opus`.
- **Worker**: Background/isolated task execution. Receives input in spawn prompt, does the work, reports findings. Model: `sonnet` or `haiku`.
- **Interaction**: Inline user-interaction behavior (e.g., `/grill-me`). No delegation. Model: `sonnet`.
- **Protocol**: Behavioral rules adopted by calling agent, not spawned. No seed-brief contract.

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

## Consumption Contracts

Every skill has a primary consumption contract. Callers must use the correct invocation mechanism.

|Contract|Invocation|Session|User Interaction|Examples|
|-|-|-|-|-|
|**Runner (autonomous)**|`Agent("agents/runner.md")`|Isolated|None|`implement-runner`, `review-runner`|
|**Worker (autonomous)**|`Agent("agents/worker.md")`|Isolated|Parallel|`build-worker`, `reviewer-correctness`|
|**Shell (interactive)**|`Skill("name")`|Caller's session|Full|`implement`, `build`, `review`, `audit-issues`, `find-skills`|
|**Worker Skill**|`Skill("name")` + `context: fork`|Isolated|Task confirmations only|`compound`, `verify`, `scope-assessment`|

> **Protocol skills** (`user-invocable: false`) are adopted by the calling agent — never `Skill()`-invoked.

### Rules

- **If a skill needs both research and interaction: split it.** Do not add mode-switching inside a single skill. The interactive phases are run in main context, while the research phases or other non-interactive tasks are handled by autonomous sub-agents. Either create sub-skills or spawn agents internally from the interactive skill as needed.
- **Interactive skills may internally spawn autonomous Agents.** This is an implementation detail invisible to the caller.
- **Never spawn an interactive skill as `Agent()`** — the user must be present for deliberation.

## Input Contracts
Spawn-time context is passed directly in the Agent() prompt. See `_shared/seed-brief.md` for the YAML packaging convention.
- **Single input** → one-line inline in spawn prompt.
- **Multiple inputs** → structured YAML block in spawn prompt.

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
