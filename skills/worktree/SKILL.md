---
name: worktree
description: Standard command protocol for creating and managing feature worktrees using `wt` CLI.
user-invocable: false
layer: 3
---
Standard commands for creating and managing feature worktrees using the `wt` CLI.

## Create

```bash
wt switch --create <branch>                        # base defaults to main
wt switch --create <branch> --base <base-branch>   # explicit base
```

`wt switch --create` creates the branch, creates the worktree, sets the upstream tracking branch, and switches into the worktree.

## Verify

```bash
wt list
```

## Remove

Handled by `/wrap-up`. Do not remove manually unless instructed.
