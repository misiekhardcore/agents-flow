# Repository Pre-flight — Shared Protocol

Used for skills that create/edit issues, comments, PRs, or push code. Read before `gh` or `git push` operations.

## Steps

1. Run `git remote -v`, `pwd`, and `git branch --show-current` to detect repo, working directory, and branch.
2. Display detected repo (owner/repo), branch (omit if caller set `Suppress branch line: true`), and working directory.
3. Confirm with user. Default: "Does this match the repo and branch you intend to operate on?" (drop "and branch" if branch was suppressed). Callers may override via `Confirmation prompt:` line.
4. Do not proceed with `gh` or `git push` until user explicitly confirms.

`gh` mutations are public and cross-repo (the `--repo` flag routes silently). Wrong-repo mutations have high blast radius.

## Orchestrator pattern

Orchestrators (e.g., `/implement`) run this at entry and pass `preflight_verified: true` in seed briefs to specialists. Specialists skip this when valid brief is present.
