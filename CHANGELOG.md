# Changelog

All notable changes to the **claude-workflow** plugin are recorded here. The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Semantic Versioning](https://semver.org/).

GitHub Releases (with auto-generated notes and source tarballs) remain the canonical artifact: <https://github.com/misiekhardcore/claude-workflow/releases>. This file mirrors them in repo so changes are visible without leaving the source tree.

## [Unreleased]

### Changed

- **NOTES.md protocol broadened** -- ownership model shifted from "orchestrator-only" to ownership-transfer (orchestrator owns before spawn / after return, sub-skill owns during execution). Standalone L2 skills now use NOTES.md for their own multi-step tracking. Adds Orchestrator Checkpoint pattern (create on entry, checkpoint before spawn, update on return) and Seed-brief Slice pattern (progress field in seed-brief payload). (#v2/orchestrator-progress-ledger)

- **Terminology standardized** -- all "tier" references in shared docs renamed to "layer" for consistency with the three-layer taxonomy. Affected files: _shared/notes-md-protocol.md (memory tier -> memory layer), README.md.

- **Shared docs decoupled from skill names** -- removed hardcoded /build, /review, /verify, /implement, etc. references from 7 shared/protocol files. Skills are now referenced generically by role rather than by command name.

- **Layer-3 boundary realignment** - five skills demoted from layer-3 (`Skill()` invocation) to `_shared/` reference docs (`Read`):
  - `seed-brief` -> `_shared/seed-brief.md` - spawn-time context packaging format (data structure spec, not behavioral protocol)
  - `worktree` -> `_shared/worktree-protocol.md` - `wt` CLI command reference (command cheat sheet, not behavioral protocol)
  - `interviewing-rules` -> `_shared/interviewing-rules.md` - one-question-at-a-time user-interaction rules (interaction pattern, not cross-skill behavioral contract)
  - `handoff-artifact` -> `_shared/handoff-artifact.md` - cross-phase handoff protocol for GitHub issue body (reference doc, not invoked skill)
  - `notes-md` -> `_shared/notes-md-protocol.md` - in-phase memory layer lifecycle and structure (reference doc, not invoked skill)
  - All callers updated from `Invoke \`Skill("name")\`` to `Read \`${CLAUDE_PLUGIN_ROOT}/_shared/<name>.md\``.
  - `_templates/AUTHORING.md` decision rule refined with concrete examples; `_shared/` catalogue expanded.
  - `skills/scope-assessment/SKILL.md` gained missing `layer: 3` frontmatter.

### Added

- **`_shared/orchestrator-rules.md`** - new shared protocol extracting rules common to all pipeline orchestrators: CWD verification, delegation (no reimplemented sub-skill logic), no-autonomous-merge, and seed-brief contract. Replaces duplicated rules in `/issue-autopilot` and `/epic-autopilot`.

- **`/issue-autopilot` skill** - new single-issue end-to-end pipeline that chains `/define` -> `/implement` -> `/resolve-pr-feedback` (looped to zero unresolved threads) -> `/compound` -> `/wrap-up`. State-based resume on re-invocation: each `/issue-autopilot <N>` call reads current issue/PR state and runs only the next applicable phase. Introduced as a new sibling skill rather than extending `/epic-autopilot` to keep the linear single-issue state machine separate from epic fanout logic. (#92)

- **`agents/` directory** - new top-level directory for reusable agent definitions, mirroring the claude-obsidian pattern. Seeded with `agents/prune-lane.md`: a single-lane audit worker for `/prune` that documents the spawn-prompt contract (CWD verification, pre-enumerated file list, structured report output). (#76)

### Renamed

- **`/discovery` → `/discover`** — **breaking change**: existing `CLAUDE.md` references to `/discovery` will stop working. Update all occurrences manually; no compatibility shim is provided.

### Changed

- **`/prune` dispatches one Task sub-agent per lane** — rules, authoring, and vault lanes now run as parallel Task sub-agents. The main thread enumerates files and dispatches once, then aggregates the three lane reports. Prevents inline overrun on large skill plugin directories. Every spawn prompt includes `cd <abs-path> && pwd` CWD verification. (#76)

- **`/resolve-pr-feedback` fix-dispatch threshold lowered to ≥2 file groups** — previously TeamCreate was gated at ≥3 groups; parallel subagents now trigger at ≥2 non-overlapping file groups. Reply drafting is always delegated (one sub-agent per thread) — pure I/O with no synthesis on the main thread. Spawn prompts include CWD verification. (#76)

- **`/find-skills` delegates search to a research sub-agent** — the leaderboard check + CLI search pass is delegated to a haiku-model Task sub-agent; the main thread receives a list of candidate skills with one-line summaries and handles install confirmation and execution. Prevents verbose web-fetch results from bloating the main context. (#76)

- **`/wrap-up`, `/grill-me`, `/specify` stay inline** — one-line rationale comments added to each SKILL.md: wrap-up (destructive sequential / low context cost), grill-me (interactive primitive), specify (interactive). No behavior change. (#76)

- **`_shared/composition.md` — "Main-thread overrun" sub-section added** — counter-rule to "default to single-agent" for three trigger shapes: multi-file read sweep (≥5 files), N-way fan-out over independent items, and verbose-I/O with thin synthesis. Includes concrete spawn-prompt requirements (CWD verification, pre-enumerated paths, prior findings). References the existing `Inline overrun` failure-mode row. (#76)

- **`_templates/AUTHORING.md` — inline-overrun smell checklist added** — four smells (file-sweep, fan-out, thin-synthesis, verbose-tool-output) with a remediation note. Placed in the Parallelism decision section so new skills are reviewed for delegation gaps at authoring time. (#76)

- **`_templates/SKILL.orchestrator.template.md` — Spawn justification stub updated** — "inline overrun" listed as a valid dispatch trigger alongside cost-based parallelism, with a reference to the new composition.md sub-section. (#76)

- **`effortLevel` → `effort` migration** — all 6 skills that declared `effortLevel: high` (architecture, define, describe, discovery, epic-autopilot, review) now use the correct harness field `effort: high`. Templates (`SKILL.specialist.template.md`, `SKILL.orchestrator.template.md`) and plugin guidance (`CLAUDE.md`, `AUTHORING.md`) updated in lockstep. Previously `effortLevel: high` was silently ignored; `effort: high` now enables the intended higher-effort execution.

- **`AUTHORING.md` frontmatter table expanded** — `effortLevel` row replaced by `effort` (`low|medium|high|xhigh|max`); new rows added for `when_to_use`, `argument-hint`, `user-invocable`, and `disable-model-invocation`. Notes added for the 1,536-char combined `description + when_to_use` cap and the upstream `argument-hint` autocomplete bug ([anthropics/claude-code#46626](https://github.com/anthropics/claude-code/issues/46626)). Canonical frontmatter field order documented.

- **`argument-hint` added** to 8 positional-argument skills: build (`[issue#]`), implement (`[issue#]`), review (`[PR# or URL]`), resolve-pr-feedback (`[thread-URL]`), audit-issues (`[owner/repo | #NN | owner/repo#NN]`), epic-autopilot (`[epic# | description]`), discovery (`[issue# | description]`), define (`[issue#]`).

- **Descriptions trimmed to ≤150 chars** across 13 skills (prune, review, new-skill, grill-me, define, epic-autopilot, resolve-pr-feedback, verify, build, describe, wrap-up, architecture, design). Trigger-phrase content relocated to `when_to_use`; other overflow moved to skill body. No information discarded.

- **`when_to_use` field added** to describe, discovery, specify, define (disambiguation guidance), and additionally to build, epic-autopilot, grill-me, prune, resolve-pr-feedback, wrap-up (trigger-phrase overflow from trimmed descriptions).

- **`/new-skill` scaffolder updated** — step (e) renamed to `effort`, two new interview questions added: (f) `argument-hint` (free-text positional-arg hint; asked after description) and user-invocable follow-up in step (c) for Specialist/Primitive roles. Generation step updated to emit all four new fields in canonical order.

- **Frontmatter field order normalized** across all SKILL.md files to canonical order: `name → description → when_to_use → argument-hint → model → effort → allowed-tools → user-invocable → disable-model-invocation`.

## [1.0.2] — 2026-05-04

### Fixed

- **`marketplace.json` source format** — switched the single plugin entry from a github-ref object (`{ "source": "github", "repo": "misiekhardcore/claude-workflow", "ref": "main" }`) to the canonical self-reference form (`"source": "./"`). The github-ref form forced the plugin loader to perform a second clone (separate from the marketplace clone) into a versioned cache directory, and that step was failing silently across version bumps — `installed_plugins.json` would record the new version and a fresh `lastUpdated` timestamp, but the cache directory under `~/.claude/plugins/cache/claude-workflow/` would not exist on disk and `gitCommitSha` never advanced past the v0.7.0 commit. Existing broken installs may need to remove the `claude-workflow@claude-workflow` entry from `installed_plugins.json` and reinstall once. (#65)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v1.0.1...v1.0.2)

## [1.0.1] — 2026-05-03

### Fixed

- **`/implement` preflight branch display** refined; orchestrator template carves out a terminal-phase exception so `/implement` is correctly treated as the terminal step in the seed-brief contract introduced in 1.0.0. (#64)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v1.0.0...v1.0.1)

## [1.0.0] — 2026-05-03

First major release. Locks in the specialist-mode contract that lets orchestrators drive the build → review → verify loop autonomously, repurposes `/wrap-up` from an audit step into a worktree-cleanup utility, and adds two new skills: `/epic-autopilot` (autonomous epic-to-PR pipeline) and `/audit-issues` (drift-check for open GitHub issues).

### Added

- **`/audit-issues`** skill — drift-checks open GitHub issues in a target repo against the current local working tree. Five detectors (file-path-existence, numeric-claim-drift, version-reference-staleness, resolved-open-question, cross-issue-contradiction), a verdict taxonomy (`unverifiable` > `premise-shifted` > `superseded by #N` > `contradicted` > `stale` > `valid`), and per-issue interactive `[e]dit / [c]lose / [s]kip` actions. Mutates only after explicit confirmation. Requires a local clone at `~/Projects/<repo>`. (#61)
- **`/epic-autopilot`** skill — five-stage orchestrator that chains `/discovery → /define → /implement` end-to-end for each sub-issue of an epic. Human gates after `/discovery`, after the epic-level `/define`, and after each per-sub-issue `/define`; afterwards the autonomous phase opens the epic branch, computes a Kahn topological sort of dependencies, dispatches per-tier `Task` subagents in parallel, retries-once on failure, and opens draft sub-PRs plus a top-level epic PR. Resumable from any stage via markers in the epic issue body. (#60)
- **`/review`** can now accept a PR number or URL as input (in addition to the existing branch-only mode) and post findings as inline GitHub comments + summary review, idempotent via fingerprint markers. Two new conditional personas: docs consistency and architecture / scope-creep. The fix-brief path inside `/implement` is unchanged. (#59)
- **`autonomous: true`** seed-brief flag — when an orchestrator passes it, `/implement` skips the exhausted-exit prompt and accepts unconditionally, surfacing findings into the PR body's `## Notes`. Used by `/epic-autopilot`'s autonomous phase. (#60)

### Changed — breaking

- **`/wrap-up` repurposed** as a user-invoked cleanup utility: removes the feature worktree, deletes the branch, clears NOTES.md. State machine refuses outright on the default branch or out-of-tree paths; on a dirty worktree, surfaces unpushed/uncommitted state and requires a proceed-anyway confirmation. **No longer drafts an audit block** — that responsibility moved into `/implement`'s PR-body harvest. (#58)
- **`_shared/handoff-artifact.md`** trimmed to two phase-boundary skills (`/discovery`, `/define`); `/implement` and `/wrap-up` are no longer phase-boundary skills. (#58)

### Changed

- **`/implement` end-to-end refactor** — introduced the `_shared/specialist-mode.md` contract (seed-brief detection, transport format, required fields, per-specialist skip-list) so orchestrators can drive `/build`, `/review`, `/verify`, `/describe`, `/specify`, `/architecture`, `/design` autonomously without re-running preflight per specialist. Audit content (assumptions, uncertainties, follow-ups, outstanding findings) is now harvested from `./.claude/NOTES.md` into the PR body's `## Notes` section before the PR opens — `/implement` is the terminal phase, its output is the PR, not an issue body update. (#58)

### Documentation

- README skill table refreshed with `/audit-issues` and `/epic-autopilot`; `/wrap-up` description updated; flowchart adjusted (epic-autopilot in Other tools, audit-issues alongside it).
- `docs/workflow.md` Step 6 rewritten for the new `/wrap-up` shape; added Maintenance section for `/audit-issues` and an Autonomous-variant section for `/epic-autopilot`; PR-body wording table now documents the `## Summary / ## Testing notes / ## Notes` template and the NOTES.md harvest.
- New `CHANGELOG.md` mirroring GitHub Releases history in-repo.

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.7.0...v1.0.0)

## [0.7.0] — 2026-04-27

### Added

- **`_shared/repo-preflight.md`** extracted from inline 4-step stanzas in `/build` and `/resolve-pr-feedback`; wired into `/discovery` (before `gh issue create`) and `/define` (before issue body update / sub-issue creation), closing the wrong-repo-mutation gap. (#55)
- **`_shared/scope-preflight.md`** with trigger conditions (≥3 files or audit/refactor/normalize/sweep/propagate/extract/rename verbs) and file-list confirmation/refusal templates; wired into `/build` and `/resolve-pr-feedback`. (#55)

### Changed

- **`/resolve-pr-feedback`** now resolves PR review threads via GraphQL `resolveReviewThread` for `fixed`, `fixed-differently`, and `not-addressing` verdicts; leaves `needs-human` and `replied` unresolved. (#56)
- **`/specify`** requires fetch-and-confirm before treating any URL or external claim as authoritative; prohibits pasting unverified citations into spec/issue bodies. (#56)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.6.0...v0.7.0)

## [0.6.0] — 2026-04-26

### Added

- **`docs/token-budgets.md`** — per-artifact and per-phase token budgets, the context-rot threshold (~12% of window), CLAUDE.md placement and `@`-import syntax, and the skill-invocation duplication anti-pattern. Cross-referenced from `README.md`, `CLAUDE.md`, `_shared/composition.md`, `_shared/notes-md-protocol.md`, `docs/context-hygiene.md`, and `docs/cross-plugin.md`. (#52)
- **`docs/cross-plugin.md`** — ecosystem coordination guide covering MCP scope (shared vs. plugin-bundled), inter-plugin dependency declarations, and CLAUDE.md layering across `~/.claude/CLAUDE.md`, `./CLAUDE.md`, and `./CLAUDE.local.md`. Documents the decision to keep `claude-obsidian` optional via runtime detection. (#50)
- **`${CLAUDE_PLUGIN_DATA}`** documented in `_templates/AUTHORING.md` for persistent plugin state that survives updates, with the diff-then-install pattern for dependency caching. (#48)

### Changed

- **Spawn-site audit** across all skills against the TeamCreate rubric in `_shared/composition.md`. Most spawn sites collapsed from `TeamCreate` to subagent fan-out where mid-task communication wasn't needed; remaining `TeamCreate` invocations now carry explicit justifications. (#47)
- **Specialist spawn-site model tiers** — `/describe`, `/architecture`, `/design`, `/verify`, `/review` now name explicit `model:` per spawn site (sonnet for research/analysis, haiku for structured QA, opus reserved for lead-interactive and critical work). (#49)
- **`_templates/AUTHORING.md`** — added "Parallelism decision" section linking to the composition rubric; orchestrator and specialist templates now require a Scope Assessment + Parallelism choice / spawn justification block. `/new-skill` interview asks an explicit parallelism question (no-parallelism / subagents / TeamCreate) before writing the skill. Added "Progressive disclosure via `references/`" section with a worked split rule. (#51)
- **`/find-skills`** and **`/compound`** split out reference material into `references/` subdirectories per the new progressive-disclosure pattern, reducing main SKILL.md footprints by ~30%. (#51)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.5.0...v0.6.0)

## [0.5.0] — 2026-04-25

### Added

- **TeamCreate decision rubric** in `_shared/composition.md` — cost model (~7× tokens per Anthropic /en/costs), criteria for choosing `TeamCreate` over sub-agents (≥3 genuinely parallel sub-tasks with disjoint files and ≥3× wall-clock payoff), and worked examples. (#46)

### Changed

- **Skill descriptions trimmed to ≤150 chars** across the plugin so they fit in `claude plugin list` output without truncation. (#45)
- **Release workflow** — version lockstep documented: `.claude-plugin/plugin.json` and both `metadata.version` + `plugins[0].version` in `.claude-plugin/marketplace.json` must agree, bumped together by the `Release` workflow. (#44)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.4.0...v0.5.0)

## [0.4.0] — 2026-04-23

### Added

- **Release workflow** (`.github/workflows/release.yml`) — `workflow_dispatch` with `patch | minor | major` bump; computes version, updates `plugin.json` + `marketplace.json` in lockstep, commits, tags, and creates a GitHub release with auto-generated notes and a source tarball. (#38)
- **`/implement` design-before-build gate** — for `Standard` and `Deep` scope, `/implement` requires architecture decisions to be cross-phase verified before `/build` runs; design gate stays live even in specialist mode. (#20)
- **`/build` and `/resolve-pr-feedback` repo pre-flight echo** — explicit confirmation step before any `git` or `gh` mutation, gating against wrong-repo writes. (#21)
- **Final-pass checklist** in `_shared/handoff-artifact.md` — last-mile checklist for the handoff author. (#22)

### Changed

- **Issue/PR sections use human-readable headings** (e.g. "Acceptance criteria") instead of machine-style placeholders. (#32)
- **Empty handoff sections omitted** rather than rendered with `None` placeholders, keeping bodies clean. (#28)

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.3.0...v0.4.0)

## [0.3.0] — 2026-04-20

### Added

- **`_shared/composition.md`** — four composition patterns (linear / branch / loop / parallel), three skill roles (orchestrator / specialist / primitive), and three structured briefs (research / prior-art / fix) with contracts and failure modes.
- **Role-specific templates** — `SKILL.template.md` split into `SKILL.orchestrator.template.md`, `SKILL.specialist.template.md`, `SKILL.primitive.template.md`, each under 50 lines.
- **`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`** prerequisite documented in `README.md` and `CLAUDE.md` for parallel composition.

### Changed

- **`/specify`** and **`/design`** document optional prior-art and research brief inputs.
- **`/new-skill`** asks about role and routes to the appropriate role-specific template.
- **`AUTHORING.md`** gains a skill-types table and composition-patterns subsection.
- **`docs/workflow.md`** cross-links to `composition.md`.
- Stale references fixed in `docs/workflow.md`, `SKILL.template.md` frontmatter, and several skill files. (#12)

Closes #13, #11.

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.2.0...v0.3.0)

## [0.2.0] — 2026-04-17

### Changed — breaking

- **Decoupled from the vault path.** All 36 hardcoded `memory/wiki/` references removed across 9 files. Skills now speak `claude-obsidian`'s vocabulary (vault, hot cache, log, concept/entity/source notes, session archive) instead of filesystem paths.
- **`/compound`** drafts a structured note and files it via `claude-obsidian:save` when the plugin is available; otherwise emits the note inline.
- **`/prune`** splits into a CLAUDE.md+auto-memory lane that always runs, and a vault lane delegated to `wiki-lint` when `claude-obsidian` is installed.
- **`/architecture`** and **`/define`** query the vault for prior patterns via `wiki-query` when available.

### Added

- **`docs/context-hygiene.md`** — the "Context Hygiene Between Workflow Phases" rationale moved into the plugin so it travels with the workflow regardless of whether any vault is installed.
- **README**: "Optional: claude-obsidian integration" section.

### Migration

No migration is needed if you don't have `claude-obsidian` — skills just skip the vault lanes. To opt in, install `claude-obsidian` and run `/wiki` once to bootstrap a vault; the delegation kicks in automatically.

Closes #9.

[Full diff](https://github.com/misiekhardcore/claude-workflow/compare/v0.1.0...v0.2.0)

## [0.1.0] — 2026-04-17

First tagged public release.

### Added

- **17 workflow skills**: `/discovery`, `/define`, `/architecture`, `/design`, `/describe`, `/specify`, `/implement`, `/build`, `/review`, `/verify`, `/wrap-up`, `/compound`, `/prune`, `/find-skills`, `/grill-me`, `/resolve-pr-feedback`, `/new-skill`.
- **4 shared protocols** under `_shared/`: `handoff-artifact.md`, `interviewing-rules.md`, `notes-md-protocol.md`, `compaction-protocol.md`.
- **Authoring standard**: `_templates/SKILL.template.md`, `_templates/AUTHORING.md`, and the interactive `/new-skill` scaffolder.
- **Self-marketplace**: `.claude-plugin/marketplace.json` + `plugin.json` shipped in-repo so the repo installs via a single `marketplace add`.

[v0.1.0 release tag](https://github.com/misiekhardcore/claude-workflow/releases/tag/v0.1.0)
