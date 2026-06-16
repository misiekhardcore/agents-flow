# Changelog

All notable changes to the **agents-flow** plugin are recorded here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.1] - 2026-06-16
### Fixed

- Update token limit for NOTES.md to 2k tokens across multiple skills and documentation
## [2.0.0] - 2026-06-16
### Added

- Add git-cliff changelog handling
- Rebuild define
- Clarify SKILL.md and agent file responsibilities, and document knowledge persistence in AGENTS.md
- Add formatter test workflow and minify markdown tests
- Enhance SKILL.md for clarity and detail in process descriptions
- Rebuild audit-issues
- Update SKILL.md for clarity and consistency - refine description, adjust model type, and streamline process steps
- Rebuild new-skill as Orchestrator- Rewrite SKILL.md as thin Orchestrator with interview flow- Read _shared/AUTHORING.md and references/interview-steps.md at point of need- Consolidate to single minimal template approach- Remove layer: field from frontmatter (handled in #177)Co-authored-by: openhands <openhands@all-hands.dev>
- Add AGENTS.md documentation for plugin commands and conventions
- Create missing agent files for discovery and define
- Add layer declarations to remaining v2 skills
- Split interactive skills by consumption contract (autonomous research + interactive deliberation)
- Rebuild verify and build as v2 L2 sub-skills
- Rebuild find-skills and review as v2 L2 sub-skills
- Rebuild describe and specify as v2 L2 sub-skills
- Create worktree and notes-md L3 skills, update wrap-up and compound
- Enhance SKILL.md files with detailed descriptions and user-invocable flags
- Update SKILL.md files to clarify output and handoff processes
- Add user-invocable frontmatter and caller contracts to simple L2 skills
- Decouple shared docs by moving per-skill details into owning skills- _shared/handoff-artifact.md: Trimmed to protocol-only (five-field format,  shape, precedence, rules). Removed phase-specific heading rules and  final-pass checklist — these are now inline in each producing skill.- _shared/seed-brief.md: Trimmed to universal protocol spec. Payload type  definitions (research, fix, prior-art) and canonical example moved to  skills/specialist-mode/SKILL.md.- skills/discovery/SKILL.md: Added ## Requirements section heading and  final-pass checklist inline.- skills/define/SKILL.md: Cleaned handoff instructions to reference the  five-field format and ## Implementation plan heading.- skills/implement/SKILL.md: Clarified section heading origins (Requirements  from discovery, Implementation plan from define).- skills/specialist-mode/SKILL.md: Added Payload Types section (moved from  seed-brief) and Execution Delta table (seeded vs standalone behavior).- README.md: Added seed-brief.md to the _shared/ protocol table.Co-authored-by: openhands <openhands@all-hands.dev>
- Add compound-on-exit protocol and assessment gate
- Rebuild as L2 specialist with dual-mode seed-brief
- Replace Lightweight/Standard/Deep scope labels with two-mechanism pattern
- Promote behavioral _shared/ files to layer-3 skills
- Author /scope-assessment as shared tier-3 skill

### Changed

- Consolidate all agent files to root agents/ directory with workflow- prefix
- Remove outdated version references from AUTHORING.md
- Rebuild epic-autopilot
- Rebuild issue-autopilot
- Rebuild /new-skill as Orchestrator
- Rebuild /new-skill as Orchestrator
- Rebuild audit-issues as Orchestrator
- Feat/132 implement v2
- Rebuild define
- Remove stale /discovery references and post-redesign leftovers
- Rebuild discover
- Rebuild resolve-pr-feedback
- Rebuild grill-me
- Update bin/list-prune-files to remove dependency on layer: frontmatter field
- Apply dispatch primitives framework — taxonomy, skill reclassification, issue audit
- NOTES.md as orchestrator progress ledger with checkpoint/slice pattern
- Layer-3 boundary realignment: demote seed-brief, worktree, interviewing-rules to _shared/
- Switch license from MIT to PolyForm Noncommercial 1.0.0
- V2 F1: bootstrap v2 branch and AUTHORING.md for tier-3 hierarchy

### Documentation

- Expand AGENTS.md with commit message formatting rules
- Add AGENTS.md with PR formatting conventions
- Update CHANGELOG with handoff-artifact and notes-md demotion

### Fixed

- Add --unreleased flag to git-cliff in release workflow
- Remove stale specialist-mode reference in README protocol table
- Update argument-hint in SKILL.md to include PR-URL option
- Correct AGENTS.md path in CLAUDE.md
- Update skill count in marketplace.json description
- Clarify filing step in compound skill process
- Replace stale specialist-mode reference with implement-runner agent
- Complete v2 terminology cleanup and documentation update
# Changelog

All notable changes to the **agents-flow** plugin are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

GitHub Releases (with auto-generated notes and source tarballs) remain the canonical artifact: <https://github.com/misiekhardcore/agents-flow/releases>. This file mirrors them in repo so changes are visible without leaving the source tree.

## [1.6.2] - 2026-05-15
### Added

- Run /compound at end of stage 4 for epic-level learnings

### Changed

- Release v1.6.2
## [1.6.1] - 2026-05-15
### Changed

- Release v1.6.1

### Fixed

- Move /compound review-time pass from stage 5 to stage 3
## [1.6.0] - 2026-05-15
### Changed

- Release v1.6.0
- Extract procedure to references/procedure.md

### Documentation

- Establish lazy-loading standard for skill reference files

### Fixed

- Enforce worktree creation for all build scopes
## [1.5.1] - 2026-05-15
### Changed

- Release v1.5.1
- Reduce issue-autopilot skill to 50-line cap
- Reduce 9 over-cap skills to 50-line limit
- Reduce build skill to 50-line cap
- Reduce new-skill to 44-line cap, extract Process section
- Reduce epic-autopilot skill to 50-line cap
- Reduce find-skills skill to 50-line cap

### Fixed

- Update dispatch command to use ${PLUGIN_ROOT} for file listing
- Replace [Ref:] shorthand with explicit read instructions across skills
## [1.5.0] - 2026-05-14
### Changed

- Release v1.5.0
- Redesign /prune: drop Rules+Vault lanes, add Dead-state audit
## [1.4.0] - 2026-05-14
### Added

- Add /ship skill — single-issue end-to-end pipeline
- Time-box codebase reading during /define and /discovery

### Changed

- Release v1.4.0
- Add explicit verification step to resolve-pr-feedback

### Documentation

- Add external-audience writing rule
## [1.3.0] - 2026-05-12
### Added

- Extend Authoring Lane to scan _shared/*.md and .claude/**/*.md

### Changed

- Release v1.3.0
- Improve skill authoring quality: conditional when_to_use, modularity, paired prohibitions
## [1.2.0] - 2026-05-07
### Added

- Enrich skill/agent frontmatter — allowed-tools, when_to_use, effort, disable-model-invocation

### Changed

- Release v1.2.0
## [1.1.0] - 2026-05-07
### Added

- Dispatch sub-agents in utility skills + main-thread-overrun guidance
- Add GitHub Actions workflow for linting and formatting
- Initialize project with package.json and package-lock.json
- Extend /prune with empirical AGENTS.md authoring heuristics

### Changed

- Release v1.1.0
- Update SKILL.md files to improve formatting and clarity

### Documentation

- Backfill 1.0.1 and 1.0.2 entries

### Fixed

- EffortLevel→effort migration, argument-hint, description trim, when_to_use
- Require PR creation commands to run from worktree root
- Compact context between build→review→verify cycles
## [1.0.2] - 2026-05-04
### Changed

- Release v1.0.2

### Fixed

- Use self-reference source instead of github+ref
## [1.0.1] - 2026-05-03
### Changed

- Release v1.0.1

### Documentation

- Refresh skill table, /wrap-up shape, and add CHANGELOG

### Fixed

- Refine /implement preflight branch display + orchestrator template terminal-phase carve-out
## [1.0.0] - 2026-05-03
### Added

- /audit-issues skill — detect stale GitHub issues vs. current repo
- Epic-autopilot skill — autonomous epic-to-PR pipeline
- /implement end-to-end refactor — specialist-mode contract, PR-body audit, /wrap-up cleanup utility

### Changed

- Release v1.0.0
- Extend /review to accept external PRs + add docs and architecture personas
