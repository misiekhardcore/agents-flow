# Handoff Artifact — Shared Template

Phase-boundary skills (`/discovery`, `/define`) hand off state by updating the GitHub issue body. Read on-demand at handoff steps; do not preload.

`/implement` is terminal — its output is the PR, not an issue body update.

## The five fields

1. **Acceptance criteria** — testable scenarios from `/discovery`, unchanged. One line each. **Mandatory.**
2. **Constraints** — files in scope/out of scope, non-negotiable decisions from `/define`. **Mandatory.**
3. **Prior decisions** — "chose X over Y because Z" entries with links to conversation/code. One line each. *(Optional — omit when empty.)*
4. **Evidence** — links to commits, PRs, benchmarks, reviews, or approvals justifying decisions. *(Optional — omit when empty.)*
5. **Open questions** — things next phase must resolve. Explicit, no "obviously will figure out later". *(Optional — omit when empty.)*

## Shape

Always update the **issue body** in place. Comments are for discussion only — don't encode handoff state in comments.

Fields in order: Acceptance criteria, Constraints, Prior decisions, Evidence, Open questions. Omit optional fields when empty — never write placeholder text ("None", "No open questions").

```markdown
## Implementation plan

**Acceptance criteria** (from /discovery, unchanged)
- AC1: ...
- AC2: ...

**Constraints**
- In scope: <paths>
- Out of scope: <paths>
- Must reuse: <existing module/util>

**Prior decisions** (optional)
- <one-line decision> (why: <rationale>)

**Evidence** (optional)
- <link to commit | PR | benchmark | design review>

**Open questions** (optional)
- <question the next phase must resolve>
```

## Precedence

- **Issue body** — authoritative for cross-phase state (acceptance criteria, locked decisions, handoff fields).
- **`.claude/NOTES.md`** — authoritative for in-flight state within a phase (current task, intra-phase decisions not yet promoted, working questions).

When a phase ends, in-flight state from NOTES.md that the next phase needs is promoted into the issue body.

## Rules

|Phase|Section heading|
|-|-|
|`/discovery`|`## Requirements`|
|`/define`|`## Implementation plan`|

- Name sections by content, not command.
- Update the body in place, not a comment.
- After updating, tell user to start next phase in fresh session. Do not call next skill from within.
- Issue body wins over in-context recall.
- Never include secrets in Evidence links.
- Never drop prior decisions to save space.
- Mandatory: Acceptance criteria, Constraints. Optional: Prior decisions, Evidence, Open questions. Omit headings when empty.

## Final-pass checklist

Before submitting (issue update):

- **Style match** — scan 2 recent examples in the repo; flag drift in heading levels, formatting, or tone. Correct before updating.
- **No duplication** — grep repo and issue body; link existing items, don't duplicate.
- **No unrelated files** — verify every file in `git diff --name-only <base>..HEAD` is in scope. Flag outliers explicitly.
- **No untracked expected files** — run `git status --short`. Surface untracked `.claude/` or `docs/` files to user.
