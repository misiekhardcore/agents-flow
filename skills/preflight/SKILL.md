---
name: preflight
description: Repository and scope verification protocol before mutations or bulk file edits.
when_to_use: "Invoke before `gh` or `git push` operations. Apply scope checks when modifying 3+ files or request matches: audit, refactor, normalize, sweep, propagate, extract, rename."
user-invocable: false
compatibility: claude-code opencode
---
## Repository Pre-flight

Used for skills that create/edit issues, comments, PRs, or push code. Invoke before `gh` or `git push` operations.

### Steps

1. Run `git remote -v`, `pwd`, and `git branch --show-current` to detect repo, working directory, and branch.
2. Display detected repo (owner/repo), branch (omit if caller set `Suppress branch line: true`), and working directory.
3. Confirm with user. Default: "Does this match the repo and branch you intend to operate on?" (drop "and branch" if branch was suppressed). Callers may override via `Confirmation prompt:` line.
4. Do not proceed with `gh` or `git push` until user explicitly confirms.

`gh` mutations are public and cross-repo (the `--repo` flag routes silently). Wrong-repo mutations have high blast radius.

### Orchestrator pattern

Orchestrators (e.g., `/implement`) run this once at entry. Worker agents spawned by the orchestrator do not re-run preflight — callers run it once and trust their own verification.

## Scope Pre-flight

Used by skills performing bulk file edits. Apply when modifying 3+ files or actions with unclear blast radius.

### File-list confirmation

Before editing, present the proposed file list:

> I'm about to modify N files:
> - `<path 1>`
> - `<path 2>`
> - ...
>
> Proceed?

Wait for explicit user confirmation. Partial feedback or silence is not approval.

### Refusal

If the user does not confirm, do not edit any of the listed files. Reply:

> Holding off — please clarify which files are in scope.

Re-prompt with a narrowed list when the user provides scope.
