# Multi-Skill Composition — Reference

Generic theory behind the applied phase shape in `docs/workflow.md`. Read when authoring an orchestrator skill or composing skills into a new workflow.

**Prerequisite**: `TeamCreate` requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set in the environment. Without it, spawn sub-agents individually or fall back to sequential execution and note the degraded mode explicitly.

## Skill roles

|Role|Definition|Examples|Typical model|
|-|-|-|-|
|**Orchestrator**|Leads a phase; spawns and coordinates specialists; writes the handoff artifact|`/discovery`, `/define`, `/implement`|`opus`|
|**Specialist**|Executes a bounded task; receives a seed brief; reports findings to the orchestrator|`/build`, `/review`, `/verify`, `/architecture`, `/specify`|`sonnet`|
|**Interactive primitive**|Reusable inline behavior; invoked by specialists; no team, no handoff|`/grill-me`|`sonnet`|

An interactive primitive is distinct from a specialist because it has no internal team and produces no handoff artifact. Collapsing it into "specialist" loses the boundary that it is a pure behavior library.

This table uses the three-role abstraction for composition theory. The authoring standard at `${CLAUDE_PLUGIN_ROOT}/_templates/AUTHORING.md` further splits **Orchestrator** into _research-leading_ (owns deep reasoning; spawns a research team) and _coordinator_ (sequences pre-designed sub-skills; no research team), and adds a fifth **Utility** role for user-invocable maintenance skills (`/compound`, `/prune`, `/resolve-pr-feedback`, `/find-skills`) that have no seed-brief contract and no handoff artifact.

## Composition patterns

|Pattern|Shape|When to use|
|-|-|-|
|**Linear**|A → B → C|Strict ordering; each step depends on the previous output|
|**Branch**|A → (B or C)|Mutually exclusive paths driven by a condition (scope class, flag, file type)|
|**Loop**|A → B → A (on fail)|Iterative refinement; fix cycles in `/implement`|
|**Parallel**|A → (B ∥ C) → merge|Independent work streams; requires `TeamCreate`|

Use the cheapest pattern that fits. Parallel adds coordination overhead — prefer linear until independence is confirmed.

## Right-sizing the team

Width (how many specialists) is a separate decision from shape (linear vs parallel). Spawn the fewest specialists the task needs. Every orchestrator starts with a **Scope Assessment** block that classifies the task before dispatching.

Scope is a **cost gradient**, not just a complexity gradient — each step up roughly multiplies token usage:

|Scope|Heuristic|Primitive|~Cost vs single session|
|-|-|-|-|
|**Lightweight**|Single file / tightly scoped / no unknowns|Inline single agent|≈ 1×|
|**Standard**|Multi-file / typical feature / some unknowns|2–3 sequential subagents|≈ 2–4× total|
|**Deep**|Cross-module / security / breaking change / architecture-changing|All specialists, optionally `TeamCreate`|up to ≈ 7×|

> Agent teams use approximately 7x more tokens than standard sessions when teammates run in plan mode, because each teammate maintains its own context window and runs as a separate Claude instance.
> — [Anthropic, _Manage costs effectively_](https://docs.anthropic.com/en/docs/claude-code/costs)

In the table above, interpret that quote as an approximate upper bound of **~7× total token usage** versus a single standard session, **not** ~7× additional on top of the baseline.

### What loads into a teammate

Each teammate is a fresh Claude Code instance. At spawn it loads CLAUDE.md (project + global), MCP servers, skills (project + user), and the lead's spawn prompt. The lead's conversation history, files-read cache, and intermediate tool results **do not carry** — which is why N teammates cost ≈ N × single-session baseline.

### TeamCreate decision rubric

Replaces the older "3+ independent files" heuristic. All four criteria should hold before paying the team premium:

1. **Communication pivot** — workers genuinely need to share findings mid-task. If a single synthesizer can merge results at the end, use parallel subagents instead.
2. **File disjointness** — teammates own non-overlapping file sets, or merge conflicts will swallow the speedup.
3. **Classifiably parallel task shape** — sequential / state-dependent reasoning degrades severely under MAS (Google DeepMind / MIT, _Towards a Science of Scaling Agent Systems_, arXiv:2512.08296: 39–70% degradation on PlanCraft, with MAS-Independent at −70%).
4. **Expected wall-clock payoff ≥ 3×** — parallelism buys wall-clock, not tokens. Below 3×, the ~7× premium is not justified.

Counter-evidence: Anthropic's multi-agent research system beat a single agent by >90% on parallelizable research at ~15× tokens. The often-quoted "Princeton NLP: MAS matches single-agent on 64% of benchmarks" line is commonly cited but the provenance is unverified — treat as folklore until pinned down.

Rules:

- Default to the cheapest primitive that fits: inline → subagent → `/batch` or worktrees → `TeamCreate`.
- Collapse adjacent roles when inputs are trivial (e.g., `/verify` on a single AC runs inline — no team split).
- Gate optional specialists on concrete signals (diff patterns, scope class, file paths) — not on orchestrator discretion.
- Never pay coordination overhead for work a single agent completes in under a minute.

### Main-thread overrun

Counter-rule to "default to single-agent": when inline work would dominate the lead's context window, delegating prevents overrun even below the TeamCreate threshold.

**Delegate to a subagent when any of these conditions hold:**

1. **Multi-file read sweep** — the task requires reading ≥5 independent files whose combined output would saturate the lead's context before synthesis (e.g., auditing all SKILL.md files, walking a large dependency graph).
2. **N-way fan-out over independent items** — the task processes N items where each item is self-contained and returns only a short summary (e.g., reply-drafting per PR thread, per-lane audit passes). The `N × item_size > context_budget` shape is the signal, not N alone.
3. **Verbose I/O with thin synthesis** — the work is pure retrieval or formatting (web fetch, CLI parse, file stat) and the lead only needs the distilled result. The lead's intermediate tool-result echo would fill context that adds no reasoning value.

The failure mode is `Inline overrun` in the Failure modes table above. Each `/prune` lane, each `/resolve-pr-feedback` reply, and the `/find-skills` discovery pass are canonical examples.

**What to pass in the spawn prompt** — sub-agents do not inherit the parent's CWD or file-read cache. Every spawn prompt must include:
1. `cd <abs-path> && pwd` — verify CWD before reading any files.
2. The absolute paths or pre-enumerated file lists the sub-agent needs — do not re-derive them from scratch.
3. Prior findings that are load-bearing for the sub-agent's task — no inheritance means no implicit context.

See `skills/discovery/SKILL.md` and `skills/review/SKILL.md` for canonical Scope Assessment blocks. The orchestrator template at `_templates/SKILL.orchestrator.template.md` includes a Scope Assessment stub.

## Structured briefs

A **seed brief** is context passed from an orchestrator to a specialist at spawn time. It replaces the specialist's own research phase when that research has already been done. Three standard forms:

### Research brief

Produced by a codebase/patterns research agent; consumed by `/architecture`, `/design`, or `/build` specialists.

|Field|Content|
|-|-|
|`tech_stack`|Languages, frameworks, key libraries|
|`module_map`|Relevant modules, boundaries, and ownership|
|`patterns`|3+ direct pattern examples from the codebase|
|`prior_art`|Vault concepts/entities or external references|
|`open_questions`|Unresolved constraints the specialist must handle|

### Prior-art brief

Produced by `/discovery`'s **Prior-Art Scout**; consumed by `/describe` and, where applicable, `/specify` (optional).

|Field|Content|
|-|-|
|`problem_domain`|Domain area the feature touches|
|`existing_patterns`|Similar features or prior solutions in the codebase|
|`constraints`|Non-negotiable constraints surfaced during discovery|

### Fix brief

Produced by `/review` or `/verify`; consumed by `/build` for remediation cycles.

|Field|Content|
|-|-|
|`failing_ac`|Which acceptance criteria are not met|
|`findings`|Reviewer findings as `file:line — description`|
|`prior_decisions`|Architectural decisions that must not be reversed|

## Seed-brief contract

When passing a seed brief to a specialist:

1. Pass as structured input at spawn time, not as a conversational message.
2. The specialist checks for the brief at startup. When one is present, it skips its own research phase and uses the brief as starting context.
3. Keep briefs bounded — never pad with information the specialist can find itself.

**Transport format** — raw YAML inside an XML tag, no inner code fence:

```
<seed-brief>
preflight_verified: true
scope_class: Standard
repo: owner/repo
branch: feat/branch-name
active_issue: 42
payload:
  type: fix|research|prior-art
  # type-specific fields from the table above
</seed-brief>
```

The XML tag marks the boundary; the YAML is parseable without a fence. The `payload` envelope decouples brief metadata from the type-specific content. Required fields and validation rules are in `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md`.

`skills/describe/SKILL.md` shows the entry-point pattern — the specialist's `## Input` section declares the seed-brief contract explicitly:

```
Optional: when invoked as a specialist from `/discovery`, may receive a **prior-art brief** as seed context (from the Prior-Art Scout). When a brief is provided, skip any internal prior-art search and incorporate the brief into the Product Pressure Test and problem statement synthesis. Without a brief, proceed as described below.
```

See `${CLAUDE_PLUGIN_ROOT}/_shared/specialist-mode.md` for the detection mechanism, validation rules, skip-list per specialist, and standalone-fallback behavior.

## Hierarchical decomposition

Orchestrators may nest: `/discovery` delegates to `/describe` and `/specify`; `/implement` delegates to `/build`, `/review`, and `/verify`. Rules:

- Maximum two levels of orchestration. Deeper nesting creates brittle context chains.
- Each level owns its own handoff boundary — do not skip levels.
- Sub-orchestrators do not inherit the parent's handoff artifact. Seed them with a brief.
- Task sub-agents are fresh roots; the 2-level cap applies within each sub-agent's lineage, not across the parent's spawn graph.

## Handoff vs. seed brief

||Handoff artifact|Seed brief|
|-|-|-|
|**Stored in**|GitHub issue body (durable)|In-context at spawn (ephemeral)|
|**Crosses**|Phase boundaries (`/discovery` → `/define` → `/implement`)|Intra-phase specialist boundaries|
|**Authoritative for**|Acceptance criteria, prior decisions, open questions|Research context, prior art, fix findings|
|**Written by**|Phase-boundary orchestrators|Research agents, review/verify specialists|

See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for the five-field handoff structure. Seed briefs are ephemeral — only handoff artifacts update the issue body.

## Failure modes

|Mode|Symptom|Mitigation|
|-|-|-|
|**Context bleed**|Specialist output leaks into the next specialist's context|Pass seed briefs explicitly; do not forward full conversation history|
|**Brief inflation**|Seed briefs grow to include everything, defeating compression|Cap briefs to the fields above; omit what the specialist can find itself|
|**Over-parallelization**|Parallel specialists produce contradictory outputs|Serialize when outputs must agree (e.g., architecture before design)|
|**Missing flag**|`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is unset|Fall back to sequential; note degraded mode explicitly|
|**Handoff-brief confusion**|In-phase briefs get written to the issue body|Seed briefs are ephemeral; only handoff artifacts update the issue body|
|**Inline overrun**|Lead session bloats reading large files / verbose tool output|Delegate verbose work to a subagent; only the summary returns to context|
|**Subagent re-research**|Custom subagents start fresh and re-read files the lead loaded|Pass file paths and prior findings in the spawn prompt — no inheritance|
|**Team idle drift**|Teammates left running after the task is done keep burning tokens|Shut down explicitly; idle teammates do not auto-terminate|
|**`/batch` cross-talk**|Batched items try to coordinate via filesystem side effects|Use `TeamCreate` when coordination is required; `/batch` assumes self-contained items|

## See also

- `${CLAUDE_PLUGIN_ROOT}/docs/token-budgets.md` — per-artifact budgets (seed brief <500 tokens, sub-agent report 1–2k tokens) and per-phase context targets that the cost rubric above assumes.
- `${CLAUDE_PLUGIN_ROOT}/docs/context-hygiene.md` — why phases reset and how briefs avoid context bleed across specialist boundaries.
- `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` — five-field issue-body shape that crosses phase boundaries.
