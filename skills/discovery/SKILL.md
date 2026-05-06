---
name: discovery
description: Full discovery phase — explore a problem and produce a GitHub issue with acceptance criteria. Use at the start of any new feature.
when_to_use: Use at the start of any new feature or to explore a vague problem statement. Precedes /define. For clearly-specified issues with existing AC, skip to /implement.
argument-hint: "[issue# | description]"
model: opus
effort: high
---

You are leading the discovery phase. Your goal is to take a vague idea and produce a well-specified GitHub issue ready for architecture and implementation.

## Input

A user-provided problem statement (free text), or an existing GitHub issue number to re-run discovery against.

## Scope Assessment

Classify the task before dispatching:

- **Lightweight** — clear repro + single area. Single agent runs /describe (Lightweight) → minimal /specify → issue. No team.
- **Standard** — typical feature with some unknowns. Team with /describe + /specify specialists + Prior-Art Scout.
- **Deep** — cross-module, auth/security/payments, architecture-changing, or multi-team. Full team + flow analyst + Prior-Art Scout + adversarial questioner.

Decision tree:

1. Is the problem statement a single-sentence fix with clear repro in one area? → Lightweight
2. Does it touch auth/security/payments, cross modules, change architecture, or span multiple teams? → Deep
3. Otherwise → Standard

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Standard team**: describe lead-inline + scout parallel subagent + specify sequential subagent. Comm-pivot ✗ (async handoff), disjoint ✓, parallel ✓ scout-only, payoff <3×. Fallback: sequential subagents (scout → describe → specify).
- **Deep team**: TeamCreate. Comm-pivot ✓ (adversarial questioner reacts live), disjoint ✓, parallel ✓, payoff ≥3× cross-module/security. Gate: Deep scope. Fallback: sequential subagents.

## Process

### Standard

1. **Dispatch the Prior-Art Scout as a parallel subagent** (one Task tool call) while beginning the describe flow in the lead session:
   - **Prior-Art Scout** — gathers institutional memory in parallel. Sources, in order:
     1. **The claude-obsidian vault, if available.** If `claude-obsidian:wiki-query` is usable, ask it for concepts/entities/sources/meta relevant to the topic (prior decisions, patterns, bug-fix history). If not installed, record `Vault query skipped — claude-obsidian not installed.` in the brief.
     2. **Past GitHub issues and PRs** via `gh issue list --search "<topic>" --state all` and `gh pr list --search "<topic>" --state all`.
     3. **Project documentation** — ADRs and design notes under `docs/**` and relevant READMEs.

     Output: a structured brief with **Prior decisions**, **Prior attempts and outcomes**, **Related open/closed issues**, **Relevant patterns**. Feeds both describe and specify.

2. **Run /describe in the lead session** (lead-inline) to explore the problem space with the user. When the Prior-Art Scout brief is available, incorporate it as seed context; the lead skips its own prior-art exploration when a brief is provided (mirrors the `/define` → `/architecture` seed-brief contract).

3. Once the problem statement is clear and the user has explicitly approved it, run /specify as a **sequential subagent**, passing findings and the scout brief as seed context. Once acceptance criteria are approved by the user, combine outputs.

### Deep

1. **Spawn an extended discovery team** using TeamCreate with up to five specialists, depending on the complexity of the problem:
   - **Describe specialist** — runs /describe (Deep mode) to explore the problem space
   - **Specify specialist** — runs /specify to produce acceptance criteria
   - **Flow analyst** — maps the end-to-end flow of the change: what systems are touched, what data moves where, what can break. Produces sequence diagrams and dependency maps.
   - **Prior-Art Scout** — same sources and brief format as Standard mode (vault → issues/PRs → docs). For Deep-scope work (security, payments, cross-module), always run all three source layers. Findings feed describe, specify, and the adversarial questioner.
   - **Adversarial questioner** — actively challenges assumptions: what if this fails, what's the migration path, what are the security implications, what happens at scale

2. Describe specialist, flow analyst, and Prior-Art Scout work in parallel. Adversarial questioner waits for all three to complete, then reviews their combined findings and challenges conclusions. Specify specialist works last, incorporating all concerns.

3. The scout brief is passed to `/describe` as seed context — the describe specialist skips its own prior-art exploration when a brief is provided.

### Lightweight

1. Run /describe in Lightweight mode — quick problem confirmation
2. Extract 3-5 core acceptance criteria directly (do not invoke /specify)
3. Skip to issue creation

### Issue Creation (all modes)

See `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md` before any `gh issue` operation.

1. **Create a GitHub issue** (`gh issue create`) as a self-contained brief for the next phase. The issue body has two parts:

   **(a) Problem statement preamble** — `/discovery`-only, not part of the handoff field order. From /describe output: what the user is trying to do, why the current state is inadequate, who is affected. This is the framing the rest of the issue depends on. Subsequent phases do not update this section.

   **(b) Handoff block** — under a `## Requirements` heading, the five fields below, in this order, matching `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md`. Field order is uniform across all phases so the next session can scan-read it. (The issue _title_ is set via `gh issue create --title` and is not part of the body handoff block.)
   - **Acceptance criteria** — from /specify output, as a numbered list of testable scenarios
   - **Constraints** — explicit in/out scope boundaries, non-negotiable decisions surfaced during discovery
   - **Prior decisions** *(optional — omit if empty)* — any decisions already made during discovery (one line each, with rationale)
   - **Evidence** *(optional — omit if empty)* — links to design reviews, benchmarks, prior discussions
   - **Open questions** *(optional — omit if empty)* — things `/define` must resolve

2. Present the issue to the user for approval. Do not proceed until sign-off.

3. After sign-off, tell the user to run `/define` in a fresh session. Do not call `/define` from within `/discovery` — the issue is the handoff artifact, and the next phase must start with clean context.

## Rules

- **Require explicit full approval** before creating the issue. Partial feedback is NOT approval.
- Every feature has at least one issue and at least one PR closing it
- Epics get sub-issues linked with GitHub issue relationships (parent/child)
- The user must approve the issue
- **Prior-Art Scout findings belong in the issue's Prior decisions and Evidence fields during issue creation — never drop them.**
- See `${CLAUDE_PLUGIN_ROOT}/_shared/interviewing-rules.md` for the questioning protocol — apply it throughout all user interactions.
