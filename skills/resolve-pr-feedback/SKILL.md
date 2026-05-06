---
name: resolve-pr-feedback
description: Process PR review feedback in bulk — fetch unresolved threads, triage by category, fix in parallel, and reply with verdicts.
when_to_use: Use when a PR has review comments to address or when given a specific review thread URL.
argument-hint: "[thread-URL]"
model: sonnet
---

You are leading the PR feedback resolution process. Your job is to systematically process review feedback on a pull request — triage it, fix what can be fixed, and reply with clear verdicts.

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Fix team**: TeamCreate at ≥3 file groups, else parallel subagents. Comm-pivot ✓ at scale (cross-thread regressions), disjoint ✓ (mapped pre-dispatch), parallel ✓, payoff ≥3× at ≥3 groups. Gate: ≥3 non-overlapping file groups. Fallback: parallel subagents or sequential.

## Input

Either:
- No argument → process all unresolved threads on the current branch's PR
- A thread URL → process that single thread

## Process

### Phase 0 — Pre-flight

See `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md`.
Confirmation prompt: "Does this match the repo where you want to resolve PR feedback?"

If the trigger conditions in `${CLAUDE_PLUGIN_ROOT}/_shared/scope-preflight.md` apply, run that preflight before making bulk file edits.

### Phase 1 — Fetch

1. Determine the current PR:
   - If a URL was provided, extract owner/repo and PR number from it
   - Otherwise, use `gh pr view --json number,url` to get the current branch's PR
2. Fetch **review threads with resolution state** via GraphQL (REST's `pulls/{n}/reviews` returns top-level reviews, not threads, and never exposes `isResolved`):

   ```bash
   gh api graphql -F owner={owner} -F repo={repo} -F number={number} -f query='
     query($owner:String!, $repo:String!, $number:Int!) {
       repository(owner:$owner, name:$repo) {
         pullRequest(number:$number) {
           reviewThreads(first:100) {
             nodes {
               id
               isResolved
               isOutdated
               path
               line
               comments(first:50) {
                 nodes { id databaseId body author { login } createdAt url }
               }
             }
           }
         }
       }
     }'
   ```

3. Fetch top-level PR conversation comments (not attached to a thread): `gh api repos/{owner}/{repo}/issues/{number}/comments`
4. Filter out noise:
   - Threads where `isResolved: true` (skip unless the user explicitly asked to re-open)
   - Bot-generated comments (dependabot, CI bots, linters) — match by `author.login`
   - Pure approval comments with no actionable content
   - CI status summaries
5. If a specific thread URL was given, filter to just that thread by matching its `databaseId` against the URL's anchor.

### Phase 2 — Triage

Classify each remaining thread:

**Status classification:**
- **new** — not yet addressed in code
- **already-handled** — the code already reflects this feedback (check git diff)

**Concern category** (assign one):
- `error-handling` — missing or incorrect error handling
- `validation` — input validation, bounds checking
- `type-safety` — type issues, unsafe casts, missing types
- `naming` — variable/function/class naming
- `performance` — performance concerns, N+1 queries, unnecessary computation
- `testing` — missing tests, test quality, coverage
- `security` — security vulnerabilities, auth issues
- `docs` — documentation, comments, JSDoc
- `style` — formatting, code style, conventions
- `architecture` — design patterns, separation of concerns, coupling

Group threads by concern category. Present the triage summary to the user before proceeding.

### Phase 3 — Fix

**Conflict avoidance:** Before dispatching, map each thread to the file(s) it affects. No two agents may work on the same file in parallel. Threads touching the same file are handled sequentially within one agent.

**Dispatch fix agents** per the Spawn justification gate (TeamCreate at ≥3 file groups, else parallel subagents):
- One worker per non-overlapping file group
- Each receives its assigned threads and the full PR diff for context
- Each agent:
  1. Reads the review comment carefully
  2. Reads the relevant code in context (not just the diff line)
  3. Implements the fix
  4. Runs relevant tests to verify the fix doesn't break anything
  5. Determines a verdict (see Phase 4)

**Bounded retry:** Each thread gets a maximum of 2 fix-verify cycles. If the fix doesn't verify after 2 attempts, escalate as `needs-human`.

**Cross-thread regression check:** After all fix agents complete, run the project's test suite to catch cross-thread regressions before replying.

### Phase 4 — Reply

Each thread gets a verdict:

| Verdict | Meaning | Reply template |
|---|---|---|
| `fixed` | Implemented exactly as requested | "Fixed in {commit_sha}." |
| `fixed-differently` | Addressed the concern but with a different approach | "Addressed differently: {explanation}. See {commit_sha}." |
| `replied` | Disagree or need clarification — no code change | "{explanation}" |
| `not-addressing` | Intentionally not changing — with rationale | "Not addressing: {rationale}" |
| `needs-human` | Cannot resolve confidently — escalating | "Needs human review: {context}" |

Post replies on the PR using safe body passing to avoid shell injection:
```bash
jq -n --arg body "{reply}" '{"body": $body}' | \
  gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies --input -
```

After posting the reply, resolve the thread for verdicts `fixed`, `fixed-differently`, and `not-addressing`. Leave `needs-human` and `replied` unresolved — an open thread is the correct signal that human follow-up is still needed.

```bash
gh api graphql -f threadId="{thread_node_id}" -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: { threadId: $threadId }) {
      thread { id isResolved }
    }
  }'
```

Use `-f` (string) not `-F` (typed) for `threadId` — GitHub node IDs are base64 strings; `-F` would coerce incorrectly.

### Needs-Human Escalation

Before escalating, perform a full investigation:

1. Understand the reviewer's concern completely — re-read the full thread context
2. Explore the codebase for related patterns and precedent
3. Identify at least 2 options for addressing the concern
4. Assess tradeoffs of each option

Present to the user:
- The reviewer's concern (quoted)
- Options with tradeoffs
- Your recommendation
- Why you couldn't resolve it automatically

## Output

A resolution summary:
- Total threads: N
- Fixed: N | Fixed differently: N | Replied: N | Not addressing: N | Needs human: N
- Commits created: list with short descriptions
- Threads requiring human attention: list with context

## Rules

- Never force-push or rewrite history — only additive commits
- Read the full thread context before fixing, not just the last comment
- Respect the reviewer's intent, not just their literal words
- If a fix touches code outside the PR's scope, flag it rather than silently expanding scope
- Commit each logical fix separately with a descriptive message referencing the review thread
- Present the triage summary before starting fixes — let the user override verdicts
