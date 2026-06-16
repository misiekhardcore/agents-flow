# agents-flow

Skill/agent collection for AI coding agents — a standardized lifecycle for feature development. Compatible with Claude Code and opencode.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'background':'#000','primaryColor':'#ffffff','primaryTextColor':'#000000','primaryBorderColor':'#000000','lineColor':'#000000','textColor':'#000000','titleColor':'#000000','clusterBkg':'#f3f4f6','clusterBorder':'#000000','edgeLabelBackground':'#ffffff'}}}%%
flowchart TB
    subgraph Canvas["Skills flowchart"]
        direction TB
        Start([feature request]) --> Discovery

        subgraph Discovery["/discover — explore & scope"]
            direction LR
            D_Describe["/describe — problem space"]
            D_Specify["/specify — acceptance criteria"]

        end

        subgraph Define["/define — solution architecture"]
            direction LR
            Df_Arch["/architecture — tech decisions"]
            Df_Design["/design — UX/UI"]
        end

        subgraph Implement["/implement — build loop"]
            direction LR
            I_Build["/build — TDD"]
            I_Review["/review — correctness + standards"]
            I_Verify["/verify — AC QA"]
            I_Build --> I_Review --> I_Verify
            I_Verify -.fix brief.-> I_Build
            I_Review -.fix brief.-> I_Build
        end

        Discovery -->|create issue body| Define
        Define -->|issue body| Implement
        Implement --> PR([draft PR])
        PR --> Compound["/compound — capture learnings"]
        PR --> ResolvePR["/resolve-pr-feedback — batch review responses"]
        PR --> WrapUp["/wrap-up — remove worktree + branch"]

        subgraph Meta["Other tools"]
            direction LR
            EpicAutopilot["/epic-autopilot — autonomous epic→PR"]
            IssueAutopilot["/issue-autopilot — single-issue end-to-end"]
            NewSkill["/new-skill"]
            FindSkills["/find-skills"]
            Prune["/prune — audit memory"]
            AuditIssues["/audit-issues — drift-check open issues"]
            GrillMe["/grill-me"]
        end

        GrillMe -.-> D_Describe
        GrillMe -.-> D_Specify
        GrillMe -.-> Df_Arch
        GrillMe -.-> Df_Design
        GrillMe -.-> NewSkill

        subgraph Obsidian["claude-obsidian (optional)"]
            direction LR
            Save["/save"]
            WikiQuery["wiki-query"]
            WikiLint["wiki-lint"]
        end
        Compound -. filing .-> Save
        Df_Arch -. prior patterns .-> WikiQuery
        Define -. prior decisions .-> WikiQuery
        Prune -. vault audit .-> WikiLint
    end

    classDef canvas fill:#ffffff,stroke:#ffffff,color:#000000
    classDef orch fill:#dddddd,stroke:#000000,stroke-width:2px,color:#000000
    classDef spec fill:#eeeeee,stroke:#000000,stroke-width:2px,color:#000000
    classDef prim fill:#a5b4fc,stroke:#000000,stroke-width:2px,color:#000000
    classDef meta fill:#d1d5db,stroke:#000000,stroke-width:2px,color:#000000
    classDef ext  fill:#f9a8d4,stroke:#000000,stroke-width:2px,stroke-dasharray:4 2,color:#000000
    class Canvas canvas
    class Discovery,Define,Implement orch
    class D_Describe,D_Specify,D_Scout,Df_Arch,Df_Design,I_Build,I_Review,I_Verify spec
    class GrillMe,NewSkill,FindSkills,Prune,AuditIssues,WrapUp,Compound,ResolvePR,EpicAutopilot,IssueAutopilot,Save,WikiQuery,WikiLint meta
    class Obsidian ext
```

**Legend**: phase orchestrators (gray subgraphs) spawn specialists (light nodes) that do the bounded work. Plugin-level tools run outside the phase lifecycle. The claude-obsidian subgraph shows integrations that activate only when installed.

## Install

### Claude Code
```bash
claude plugin marketplace add misiekhardcore/agents-flow
claude plugin install agents-flow@agents-flow
```

Then enable it in your project or globally in Claude Code settings.

### OpenCode
Add to your `opencode.jsonc`:
```jsonc
{
  "skills": {
    "paths": ["./skills"]
  }
}
```

## Skills

|Skill|Description|
|-|-|
|`/discover`|Explore a problem and produce a GitHub issue with acceptance criteria|
|`/define`|Plan architecture and design; produces the implementation handoff|
|`/implement`|Full build→review→verify cycle, ends with a draft PR|
|`/epic-autopilot`|Autonomous epic→PR pipeline; chains `/discover → /define → /implement` per sub-issue|
|`/issue-autopilot`|Single-issue end-to-end pipeline: `/define` → `/implement` → `/resolve-pr-feedback` → `/compound` → `/wrap-up`|
|`/build`|Code against an issue's acceptance criteria using TDD|
|`/review`|Review an implementation or external PR; correctness, standards, and conditional specialists|
|`/verify`|QA verification of every acceptance criterion|
|`/describe`|Explore and understand a problem space interactively|
|`/specify`|Turn a problem statement into testable acceptance criteria|
|`/architecture`|Decide on technical architecture — components, data flow, trade-offs|
|`/design`|Visual and UX design decisions — layouts, interaction flows|
|`/grill-me`|Relentless interviewing to stress-test a plan or design|
|`/compound`|Capture learnings as structured wiki notes|
|`/wrap-up`|Post-PR cleanup: remove feature worktree, delete branch, clear NOTES.md|
|`/prune`|Audit AGENTS.md, SKILL.md, and memory for staleness|
|`/audit-issues`|Drift-check open GitHub issues against the current repo state|
|`/find-skills`|Discover and install skills from the ecosystem|
|`/resolve-pr-feedback`|Process PR review feedback in bulk|
|`/new-skill`|Scaffold a new skill conforming to this authoring standard|

## Optional: claude-obsidian integration

When installed and bootstrapped, several skills light up vault-aware paths:

- `/compound` files captures via `/save` instead of reporting inline.
- `/prune` delegates vault audit to `wiki-lint`.
- `/architecture` and `/define` query the vault for prior patterns/decisions.

Without `claude-obsidian`, every skill still runs; vault operations are skipped with a note, and `/compound` emits a structured Markdown block for manual capture. No hard dependency.

## Workflow paths

|Task size|Path|
|-|-|
|Trivial fix|`/implement` directly|
|Medium feature|`/discover` → `/implement`|
|Large feature / epic|`/discover` → `/define` → `/implement`|

Full lifecycle walkthrough: [`docs/workflow.md`](docs/workflow.md)

## Token budgets and instruction file placement

Per-artifact and per-phase token budgets, context-rot threshold, instruction file placement, and `@`-import syntax: [`docs/token-budgets.md`](docs/token-budgets.md). Context-hygiene rationale: [`docs/context-hygiene.md`](docs/context-hygiene.md).

## Ecosystem

Multi-plugin coordination: MCP scope, inter-plugin dependencies, optional `claude-obsidian` integration via runtime detection: [`docs/cross-plugin.md`](docs/cross-plugin.md).

## Authoring standard

- **Templates**: role-specific skeletons in `_templates/`
- **Convention doc**: `_shared/AUTHORING.md` — skill types, frontmatter, `_shared/` references
- **Scaffolder**: `/new-skill` — interactive generator

Shared protocols at `_shared/`:

|File|Purpose|
|-|-|
|`compaction-protocol.md`|Context editing → delegation → /compact order|
|`composition.md`|Multi-skill composition patterns and contracts|
|`handoff-artifact.md`|Five-field GitHub issue handoff protocol; per-skill section headings defined in each producing skill|
|`interviewing-rules.md`|One-question-at-a-time interview protocol|
|`notes-md-protocol.md`|In-phase NOTES.md memory layer|
|`orchestrator-rules.md`|Shared rules for pipeline orchestrators: CWD verification, delegation, no-autonomous-merge, seed-brief contract|
|`seed-brief.md`|Spawn-time context packaging (YAML-in-XML) for orchestrator→specialist handoff|

## Releasing

Versions in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (both `metadata.version` and `plugins[0].version`) must agree. Trigger the **Release** workflow via `workflow_dispatch` to bump all three in lockstep, commit, tag, and publish.

Per-release notes with full diffs: [GitHub Releases](https://github.com/misiekhardcore/agents-flow/releases). In-repo summary: [`CHANGELOG.md`](CHANGELOG.md).

## License

[PolyForm Noncommercial License 1.0.0](LICENSE) — free for personal and open-source use; commercial use requires a separate agreement.
