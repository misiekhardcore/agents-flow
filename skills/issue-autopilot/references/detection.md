# Issue-Autopilot: State Detection

## Stage 0 — Resume detection

On every invocation:

1. Run `${CLAUDE_PLUGIN_ROOT}/_shared/repo-preflight.md`. Echo resolved `owner/repo` back to the user. Pause for confirmation.
2. Detect current state using the commands in **State detection** below.
3. Consult the **Resume state machine** to determine which stage to enter.

## Resume state machine

| State on entry | Stage |
|-|-|
| Issue closed, no open PR | Refuse: print state, exit |
| Issue lacks `## Implementation plan` | Stage 1 — Define gate |
| Plan present, branch `feat/issue-<N>` absent, no open PR | Stage 2 — Implement |
| Branch and open PR exist, PR not merged, unresolved threads > 0 | Stage 3 — Resolve PR feedback loop |
| Branch and open PR exist, PR not merged, unresolved threads == 0 | Stage 4 — Zero unresolved, awaiting merge |
| PR merged | Stage 5 — Post-merge |

## State detection

```bash
# Issue state and body
gh issue view <N> --json state,body

# Open PR on branch
gh pr list --head feat/issue-<N> --json number,url,state,reviewThreads

# Unresolved thread count (once PR# is known)
gh pr view <PR#> --json reviewThreads \
  --jq '[.reviewThreads[] | select(.isResolved == false)] | length'
```
