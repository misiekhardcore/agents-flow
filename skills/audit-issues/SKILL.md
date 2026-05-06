---
name: audit-issues
description: Audit open GitHub issues for staleness vs. current repo state. Flags broken file refs, stale counts, resolved questions, cross-issue contradictions.
argument-hint: "[owner/repo | #NN | owner/repo#NN]"
model: sonnet
---

You are auditing open GitHub issues for drift against the current state of their repository. Issues queued weeks or months ago accumulate broken file references, stale numeric claims, version references, resolved open questions, and cross-issue contradictions; this skill detects that drift and offers per-issue fix-or-close actions.

This is a read-first, mutate-on-confirm utility. The product is the **updated set of issues themselves** — there is no parallel report artifact.

### Spawn justification

Rubric: `${CLAUDE_PLUGIN_ROOT}/_shared/composition.md`.

- **Per-issue audit fan-out**: one Task subagent per audited issue, each running extraction + the five verifiers and returning a structured JSON report; lead aggregates and prints. Comm-pivot ✗ (subagents do not need to share findings mid-task — cross-issue checks use the upfront issue-list snapshot the lead passes in), disjoint ✓ (each subagent owns one issue body + the read-only repo tree), parallel ✓ (extraction + gh/grep verification per issue is independent), payoff ≥3× (sequential ≈ 30–60s for ~15 issues; parallel ≈ one issue's wall time). Model: sonnet — issue prose extraction needs comprehension, not deep reasoning. Fallback: n/a — no flag dependency (parallel subagents do not require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

Skip the fan-out when only one issue is targeted (`#NN` form) — run extraction + verification inline.

## Input

Positional argument forms (no flags):

| Form | Meaning |
|------|---------|
| _(empty)_ | Audit all open issues in the repo of the current working directory. |
| `owner/repo` | Audit all open issues in `owner/repo`. |
| `#NN` | Audit a single issue in the current repo. |
| `#NN #MM …` | Audit a specific subset in the current repo. |
| `owner/repo#NN` | Audit a single issue in a different repo. |

Filters like `--label` and `--since` were rejected during `/define` — real triage targets a specific repo or specific issue numbers, not slices of label space. Add only when a concrete use case demands it.

## Process

### Phase 0 — Target resolution and local-clone gate

1. Parse the argument into `(owner, repo, issue_numbers | null)`.
   - Empty arg → resolve `owner/repo` from `git remote -v` in cwd; `issue_numbers = null`.
   - `owner/repo` form → use directly; `issue_numbers = null`.
   - `#NN[ #MM …]` → resolve repo from cwd; `issue_numbers = [NN, …]`.
   - `owner/repo#NN` → split on `#`; `issue_numbers = [NN]`.
2. Resolve the local working tree:
   - Default location: `~/Projects/<repo>` (the directory part after the slash).
   - Verify the directory exists and `git remote -v` inside it points at `git@github.com:<owner>/<repo>.git` (or the https equivalent).
3. **If the local working tree is missing or points at a different remote**, abort with the exact message:

   ```
   audit-issues: local clone of <owner>/<repo> not found at ~/Projects/<repo>.
   clone owner/repo first, then re-run.
   ```

   Do not auto-clone. Do not fall back to a degraded mode that audits without repo state — the verifiers depend on the working tree.
4. Pull the latest default branch:
   - Run `git -C <local-tree> fetch --quiet origin`. If fetch **fails** (no network, auth error), warn: `audit-issues: fetch failed — auditing against cached HEAD (results may be stale)` and continue.
   - Run `git -C <local-tree> rev-parse --abbrev-ref origin/HEAD` to identify the default branch (e.g. `origin/main`). If rev-parse fails (no `origin/HEAD`), abort: `audit-issues: cannot determine default branch in <local-tree>; run 'git remote set-head origin -a' and retry.`
   - **Never check out** the default branch — the user may be on a feature branch with uncommitted work. Instead, all verifiers read from the fetched ref (`origin/HEAD`) directly via `git show <ref>:<path>`, `git ls-tree <ref> -- <path>`, and `git -C <local-tree> log <ref>` rather than from the working directory.
   - Bind `<default-ref>` (the resolved `origin/<default>` value) into the subagent seed (Phase 2). All detector commands below substitute `<default-ref>` for the explicit ref argument.

### Phase 1 — Fetch issues once at the lead

The lead fetches enough state for both the audited issues and the sibling-excerpt seed used by `cross-issue-contradiction`. The fetch shape depends on whether `issue_numbers` is set:

**Targeted form (`#NN`, `#NN #MM …`, `owner/repo#NN`)** — fetch the requested issues directly so a `--limit` cap can never silently drop them:

```bash
# Per requested number — runs in parallel:
gh issue view <NN> --repo <owner>/<repo> \
  --json number,title,body,labels,updatedAt,createdAt,url,state

# Plus one sibling-excerpt fetch for cross-issue checks (paginated, --limit 0 = unbounded):
gh issue list --repo <owner>/<repo> --state open --limit 0 \
  --json number,title,body,updatedAt
```

If any requested issue's state is `closed`, abort with `audit-issues: #<NN> is closed; auditing closed issues is out of scope for v1.` rather than silently skipping.

**All-open form (empty arg or `owner/repo`)** — single paginated fetch:

```bash
gh issue list --repo <owner>/<repo> --state open --limit 0 \
  --json number,title,body,labels,updatedAt,createdAt,url
```

`--limit 0` instructs `gh` to paginate until exhausted. Never use a finite `--limit` — repos with hundreds of open issues will silently truncate, and a `#NN` request whose target falls outside the page is the worst-case failure mode.

Skip closed issues in the seed set. Auditing closed issues is explicitly out of scope for v1.

### Phase 2 — Per-issue audit (subagent fan-out)

**Single-issue shortcut:** If targeting exactly one issue (`len(issue_numbers) == 1`), run the subagent contract below inline — no Task dispatch. Otherwise, spawn one Task subagent per issue in a single parallel message.

Seed each execution (inline or subagent) with:

- The full body of its assigned issue.
- The titles + numbers + 1-line `Prior decisions` excerpts of every other open issue in the repo (for cross-issue checks). Cap each excerpt to keep the brief bounded — full bodies are redundant.
- The absolute path of the local working tree.
- The verifier contract below.

#### Subagent contract

Each subagent runs five detectors against its issue body and returns a structured JSON report. Treat the issue body as the source of claims; treat the fetched `<default-ref>` (Phase 0) as ground truth — never the user's working-tree checkout, which may be a feature branch.

**Step 1 — Hybrid claim extraction.**

Regex pass (deterministic, runs first):

| Claim type | Pattern intent | Examples |
|------------|---------------|----------|
| File path | `` `path/like/this.ext` `` in inline code, or bare paths (no backticks) whose first segment matches a top-level directory in the local working tree (`ls -d <tree>/*/` filtered to non-hidden dirs — e.g. `skills/`, `_shared/`, `docs/`) | `` `skills/prune/SKILL.md` ``, `_shared/handoff-artifact.md` |
| Numeric claim | "<number> <plural noun>" tied to a repo concept (skills, files, agents, lines, etc.) | "11 skills", "6 detectors" |
| Version reference | `vX.Y[.Z]`, "the X.Y MCP purge", or pinned package versions | "v1.0.0", "after the v1.0.0 MCP purge" |

LLM pass (one call per issue, runs second; grounded in the regex output to reduce hallucination):

| Claim type | What the LLM extracts |
|------------|----------------------|
| Cross-issue reference | `#NN` mentions in *Prior decisions* / body, with the surrounding clause that states the dependency |
| Open question | Bullets under an *Open questions* heading, or sentences phrased as unresolved decisions |
| Premise statement | The "Motivation" or "Context" claim describing the gap the issue addresses |

The LLM extraction returns the strict JSON schema below — subagents must validate before printing.

**Step 2 — Run the five detectors.**

| Detector | Verifier action | Finding shape |
|----------|----------------|---------------|
| `file-path-existence` | For each extracted path, test `git -C <local-tree> ls-tree -r --name-only <default-ref> -- <path>` (path-existence on the fetched default branch — independent of the user's current checkout). If missing, also `git -C <local-tree> log <default-ref> --diff-filter=D --name-only -- <path>` to recover the deletion commit. | `quote`, `path`, `evidence` (deletion commit SHA + date if known, else `not found`) |
| `numeric-claim-drift` | For each numeric claim, recompute the count from `<default-ref>`. Counting strategy by noun: `skills` → `git -C <local-tree> ls-tree -d --name-only <default-ref> skills/ \| wc -l`; `agents`/`hooks`/`commands` → `git show <default-ref>:<config-path>` then grep; otherwise use the noun's nearest natural counter. If the verifier cannot pick a counter, mark the finding as `unverifiable` and skip — do not invent a number. | `quote`, `claimed`, `actual`, `counter_used` |
| `version-reference-staleness` | For each version reference, check `git -C <local-tree> tag --list` (tags are not branch-scoped) and `git show <default-ref>:CHANGELOG.md` (if present) for the current version. Flag when the issue references a version that is no longer the latest **and** the surrounding clause asserts something tense-sensitive ("after the v1.0.0 purge", "as of v1.2"). | `quote`, `referenced_version`, `current_version` |
| `resolved-open-question` | For each open-question bullet, search the issue's full history for resolution language. Lower bound for `git log --since=...` is **`min(issue.createdAt, oldest_comment_timestamp)`**, not `issue.updatedAt` (which can be bumped by unrelated label/body activity after the resolution landed). Use `git -C <local-tree> log <default-ref> --since=<lower-bound> --grep=<keyword>` plus `gh issue view <NN> --json comments,createdAt`. Flag only when there is a positively-phrased commit subject or comment ("decided X", "resolved: Y") — do not flag from absence of activity. | `quote`, `evidence` (commit SHA or comment URL) |
| `cross-issue-contradiction` | Scan **every** sibling excerpt in the seeded set, not only siblings already linked as `#NN` from this issue's body — unlinked contradictions are the dominant stale-state case. For each sibling whose excerpt asserts something covering this issue's claim domain (same module path, same numeric noun, same decision topic), check whether the excerpt directly negates this issue's claim. Never refetch full issue bodies. If the excerpt is too condensed to confirm or deny, return that finding as `unverifiable` rather than speculating. Findings include both the explicit `#NN` references (high-precision) and the broad scan (high-recall); deduplicate by sibling number. | `quote`, `sibling_issue`, `sibling_quote`, `match_kind` (`linked` \| `unlinked`) |

**Step 3 — Assign a verdict.**

| Triggering finding(s) | Verdict |
|----------------------|---------|
| Any detector or validation error prevents reliable completion | `unverifiable` |
| No findings | `valid` |
| Any of: file-path / numeric / version / open-question | `stale` |
| Any cross-issue-contradiction | `contradicted` |
| Sibling issue claims to subsume this issue's scope | `superseded by #N` |
| ≥3 distinct detector categories firing | `premise-shifted` |

When multiple verdicts could apply, pick the strongest in this order: `unverifiable` > `premise-shifted` > `superseded by #N` > `contradicted` > `stale` > `valid`.

**Step 4 — Return JSON.**

```yaml
issue_number: 42
verdict: valid | stale | contradicted | superseded by #N | premise-shifted | unverifiable
findings:
  - detector: file-path-existence | numeric-claim-drift | version-reference-staleness | resolved-open-question | cross-issue-contradiction
    quote: "<verbatim from issue body, ≤200 chars>"
    evidence:
      # detector-specific fields from the table above
    proposed_edit: "<one-line concrete edit, or null when verdict is superseded/premise-shifted>"
recommendation: edit | close | skip
```

`recommendation` mapping: any `proposed_edit` populated → `edit`; verdict `premise-shifted` or `superseded by #N` and no fixable proposed edits → `close`; verdict `valid` → `skip`.

Subagents that fail validation must return `verdict: unverifiable` with the validation error in `findings[0].evidence` rather than inventing a partial report. The lead surfaces unverifiable issues at the end of the run; the user decides whether to retry.

Invariant check before returning: `verdict: valid` requires `findings: []` and `recommendation: skip`. Any report where `verdict: valid` but findings are non-empty or recommendation is not `skip` is itself a validation error — return `verdict: unverifiable` instead.

### Phase 3 — Aggregate and print

The lead concatenates the subagent JSON reports in issue-number order and prints a per-issue block to stdout. Block shape:

```
─── #42 — <issue title> — verdict: stale ─────────────────────────
url: https://github.com/<owner>/<repo>/issues/42
findings (3):
  [file-path-existence] "<quote>"
    path: skills/foo/SKILL.md (deleted 2026-04-12, abc1234)
    proposed_edit: remove the "Files touched" line referencing skills/foo/SKILL.md

  [numeric-claim-drift] "11 skills"
    actual: 14 (counter: ls -d skills/*/)
    proposed_edit: update "11 skills" → "14 skills"

  [resolved-open-question] "Should we add a --label filter?"
    evidence: comment https://github.com/<owner>/<repo>/issues/42#issuecomment-…
    proposed_edit: remove the question — answered "no" in the linked comment

recommendation: edit
```

End with a one-line summary: `audit-issues: <total> issues — <valid> valid, <stale> stale, <contradicted> contradicted, <superseded> superseded, <premise-shifted> premise-shifted, <unverifiable> unverifiable`.

### Phase 4 — Interactive `[e]dit / [c]lose / [s]kip`

Walk the per-issue blocks in order. After each block, prompt **with the option set parametric on verdict** — never show `[c]lose` for verdicts that cannot close.

| Verdict | Prompt shown |
|---------|--------------|
| `valid` | `[s]kip ?` (no findings to edit; nothing to close) |
| `stale`, `contradicted`, `unverifiable` | `[e]dit / [s]kip ?` |
| `premise-shifted`, `superseded by #N` | `[e]dit / [c]lose / [s]kip ?` |

Rules for the prompt:

- Closeable verdict set is exactly `{premise-shifted, superseded by #N}`. Reject `c` keystrokes when the verdict is outside that set, even if a stray `c` is entered.
- `e` triggers an edit preview: show the diff between the current body and the proposed body (with each `proposed_edit` applied), then ask `apply? [y/n]`. On `y`, run `gh issue edit <NN> --repo <owner>/<repo> --body-file <tempfile>`. On `n`, return to the `[e]/[c]/[s]` prompt for that issue.
- `c` triggers a close preview: show the closing comment (auto-drafted from the verdict + linked sibling for `superseded by #N`, or the firing detector summary for `premise-shifted`), then ask `close? [y/n]`. On `y`, post the comment via `--body-file` (safe for quotes, newlines, backticks, shell metacharacters) **then** close — `gh issue close` itself has no `--body-file` flag, so the post-and-close split is the only safe pattern:
  ```bash
  tmp=$(mktemp); printf '%s' "$body" > "$tmp"
  gh issue comment <NN> --repo <owner>/<repo> --body-file "$tmp"
  gh issue close   <NN> --repo <owner>/<repo> --reason "not planned"
  rm -f "$tmp"
  ```
  Mirrors the body-passing pattern in `skills/resolve-pr-feedback/SKILL.md`. Never use `gh issue close --comment "$body"` — inline interpolation breaks on metacharacters in the generated text. On `n`, return to the prompt.
- `s` advances to the next issue with no mutation.

Emit a final per-issue summary line after the loop: `<applied edits>/<offered edits> applied, <closed>/<offered closes> closed, <skipped>` so the user can confirm the mutations match their intent.

## Output

- Per-issue stdout blocks (Phase 3) followed by the audit summary line.
- Whatever issue-body edits and closes the user confirms in Phase 4 — the durable artifact lives on GitHub, not in this skill's output.

No `AUDIT.md`, no `--save` flag. Producing a parallel report would just re-create the staleness problem one level up.

## Rules

- The handoff-artifact section names (`Acceptance criteria`, `Constraints`, `Prior decisions`, `Evidence`, `Open questions`) are the parse target for both regex and LLM extraction. See `${CLAUDE_PLUGIN_ROOT}/_shared/handoff-artifact.md` for the canonical shape — issues authored before that convention may use older headings; fall back to scanning the whole body when the headings are missing.
- Read-only by default. The only mutations are `gh issue edit` and `gh issue close`, and only after explicit per-issue user confirmation.
- Never auto-clone. The local-clone gate is hard — exit with the documented message and let the user clone.
- Never invent a count. If a numeric claim has no obvious counter, mark the finding `unverifiable` and move on.
- Never propose an edit without a quote. Every finding cites a verbatim span from the issue body so the user can locate the change in the diff preview.
- One LLM extraction pass per issue, max. Repeated calls inflate token cost without improving recall — tune the schema instead.
- `gh` invocation patterns mirror `skills/resolve-pr-feedback/SKILL.md`; the audit-classify-recommend shape mirrors `skills/prune/SKILL.md`. Reuse those conventions rather than inventing new ones.
- Premise-supersession (the inferential "this issue's gap is already closed by intervening commits" detector) is deferred to v2. Do not approximate it with the v1 detectors.
