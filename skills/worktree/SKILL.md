---
name: worktree
description: Worktree lifecycle protocol — always create a worktree before writing code, remove after PR is open.
user-invocable: false
---
Always create a git worktree before writing code. Read the shared reference for the full CLI reference.

Read `${CLAUDE_PLUGIN_ROOT}/_shared/worktree-protocol.md` for `wt` CLI commands and worktree management.

## Behavioral Protocol

1. **Create before writing** — Always create a dedicated worktree via `wt create <branch>` before making any code changes.
2. **Remove after PR** — After a PR is open (or merged), clean up the worktree via `wt remove`.
3. **Protect default branches** — Never create worktrees from or operate on default branches (main/master).
4. **Dirty detection** — Check for uncommitted changes before removal. Refuse destructive removal if dirty unless explicitly confirmed.
