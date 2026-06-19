# Issue-Autopilot: Stage 3 — Resolve PR Feedback

## Stage 3 — Resolve PR feedback loop

**Entry condition**: Branch `feat/issue-<N>` exists, open PR on that branch, PR not merged, unresolved review threads > 0.

1. Record initial unresolved thread count:

   ```bash
   gh pr view <PR#> --json reviewThreads --jq '[.reviewThreads[] | select(.isResolved == false)] | length'
   ```

2. Echo resolved repo `owner/repo` before the cross-repo mutation.

3. Invoke the "resolve-pr-feedback" skill with seed-brief handoff, where `<PR#>` is the PR number detected in Stage 0 (processes all unresolved threads on this PR).

4. After the "resolve-pr-feedback" skill exits, record final unresolved count via the same command.

5. Apply **loop-break heuristic** (priority order):

   |Result|Action|
   |-|-|
   |The "resolve-pr-feedback" skill returned any `needs-human` verdicts|Print needs-human summary listing remaining threads and verdicts. Exit with: "Needs human review — see threads above. Re-invoke `/issue-autopilot <N>` after addressing them."|
   |Final count == 0|Invoke the "compound" skill (review-time pass). Then proceed immediately to Stage 4 in this invocation.|
   |Final count > 0 and decreased|Print "Partial progress: `<before>` → `<after>` unresolved threads. Re-invoke `/issue-autopilot <N>` after the next review pass." Exit.|
   |Final count > 0 and unchanged|Print needs-human summary listing remaining threads. Exit with: "Needs human review — see threads above. Re-invoke `/issue-autopilot <N>` after addressing them."|
