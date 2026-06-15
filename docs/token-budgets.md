# Token Budgets

Concrete budgets and CLAUDE.md placement rules the workflow assumes. Read once when setting up on a new project; revisit when the model starts misbehaving in long sessions.

See [`context-hygiene.md`](context-hygiene.md) for *why* phases reset; this doc gives the concrete numbers.

## The threshold

Context rot — degradation of retrieval, reasoning, instruction-following — kicks in well before the window fills. Anthropic's guidance: treat the rot threshold as roughly **12% of the window** (~120k of a 1M-token model), not the window itself ([Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).

Every budget below is sized so a phase finishes under that threshold with margin.

## Per-artifact budgets

The lifecycle moves state between three artifact tiers. Each has a hard cap:

|Artifact|Cap|Why|
|-|-|-|
|`.claude/NOTES.md` (per session)|**<1k tokens**|Re-read on every resume and before every `/compact`; must fit on one screen|
|GitHub issue body (handoff)|**<2k tokens**|Loaded fully at phase start; the five-field shape in `Read ${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` targets this|
|Seed brief to sub-agent|**<500 tokens**|Brief is objective + constraint + report contract — not session history|
|Sub-agent report to lead|1–2k tokens|Anthropic's reference figure for the isolation pattern|

If any artifact crosses its cap, the cause is usually content belonging elsewhere: a long decision log in NOTES.md belongs in the issue body; a seed brief restating the conversation belongs in the issue body, not the brief.

## Per-phase budgets

Full session context — system prompt + CLAUDE.md + prior turns + tool output — at handoff:

|Phase boundary|Target|Verification|
|-|-|-|
|End of `/discover`|**<15k tokens**|`/context` after issue body is written, before reset|
|End of `/define`|**<15k tokens**|After implementation plan is written into issue|
|End of `/implement`|**<20k tokens**|After draft PR is opened|

These are *targets*, not enforced caps. They signal when a phase is dragging context that should be delegated or reset. Crossing 30k near a phase boundary = bring forward the next reset and harvest into the issue body.

### Verification with `/context`

```
/context
```

Compare system + tools + messages totals against targets. Relevant deltas:

- **System + CLAUDE.md jumps between sessions** → a CLAUDE.md edit grew per-turn cost. Trim or move out.
- **Messages line growing toward 30k inside a phase** → run context editing or delegate bulk lookups to a sub-agent.
- **End-of-phase total over target** → harvest into issue body now; do not carry conversation across boundary.

## CLAUDE.md placement

CLAUDE.md is loaded verbatim every turn. Where it lives determines who pays.

|Path|Loaded by|Lifetime|Use for|
|-|-|-|-|
|`~/.claude/CLAUDE.md`|Every session, every project|User-global|Tone, formatting, global rules, memory pointers|
|`./CLAUDE.md`|Every session in this repo|Project, committed to git|Tech stack, build commands, project invariants, directory map|
|`./CLAUDE.local.md`|Every session in this repo, only this machine|Personal, gitignored|Local overrides, personal scratch rules, machine-specific paths|
|`./<subdir>/CLAUDE.md`|Sessions whose CWD enters that subdir|Subsystem|Subsystem quirks|

All files in the current path stack are loaded additively — every level pays tokens on every turn. Don't duplicate rules across levels.

**Sizing targets** (from Anthropic's [costs guidance](https://code.claude.com/docs/en/costs)):

|Scope|Recommended|Hard cap|
|-|-|-|
|Global `~/.claude/CLAUDE.md`|<50 lines|100 lines|
|Project `./CLAUDE.md`|<200 lines|300 lines|
|Subdirectory|<50 lines|100 lines|

Move anything not used in the majority of sessions: long rule blocks (>50 lines) into a dedicated `REFERENCE.md` read on demand; workflow-specific instructions into skills that load only when invoked.

## `@`-imports

CLAUDE.md supports `@path/to/file` to inline another markdown file at load time. Imports recurse up to **5 hops** ([Memory docs](https://code.claude.com/docs/en/memory)).

```markdown
# CLAUDE.md

Tone and global rules go here directly.

For the full lifecycle walkthrough — only relevant when working in this repo:
@docs/workflow.md

Personal overrides (gitignored, optional):
@CLAUDE.local.md
```

The cost of an `@`-import is identical to inlining the same content — imports are *organization*, not *deferral*. If a doc is only useful sometimes, link it (`See [docs/X.md](...) when ...`) rather than `@`-import it.

## Avoid skill-invocation duplication

Each `/skill` invocation loads the full skill body verbatim. Multiple invocations of the same skill duplicate that body — the model has the content from the first invocation; the second copy adds rot without information. Documented in [anthropics/claude-code#11065](https://github.com/anthropics/claude-code/issues/11065).

**Rule**: invoke each skill **once per task**. Downstream turns reference its outputs — the issue body, NOTES.md, the diff, the previous tool result — not a re-invocation.

**Anti-pattern**:
```
/discover   # writes issue #482
/define      # writes implementation plan to #482
# later, after confusion:
/discover   # re-loads entire skill to "re-check the spec"
```

Fix: read the issue body or NOTES.md instead. The skill body has nothing to add on re-read.

## When to read this doc

- Setting up a new project: pick CLAUDE.md placement and trim the template.
- Model starts confusing phases or re-litigating decisions: check per-phase totals with `/context`.
- A skill author asks "where should this rule live": placement table answers it.
- Reviewing a PR that grows CLAUDE.md by >20 lines: justify against sizing targets.

## See also

- [`context-hygiene.md`](context-hygiene.md) — *why* phases reset and how the four hygiene rules interact.
- [`cross-plugin.md`](cross-plugin.md) — MCP-server sizing.
- Invoke `Read ${CLAUDE_PLUGIN_ROOT}/_shared/notes-md-protocol.md` — `.claude/NOTES.md` shape and update cadence.
- Invoke `Read ${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` — five-field issue-body structure.
- Read `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md` — spawn cost models and parallel sub-agent rubric.

## Sources

- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude Code costs](https://code.claude.com/docs/en/costs)
- [Memory](https://code.claude.com/docs/en/memory) — `@`-import syntax and recursion limit
- [Managing context on the Claude Developer Platform](https://www.anthropic.com/news/context-management)
- [anthropics/claude-code#11065](https://github.com/anthropics/claude-code/issues/11065) — skill-invocation duplication bug report
