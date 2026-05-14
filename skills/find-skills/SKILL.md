---
name: find-skills
description: Discover and install agent skills when the user asks if Claude can do something or wants to extend capabilities.
when_to_use: Use when the user asks whether Claude can do something or wants to install new skills.
model: haiku
effort: low
allowed-tools: Agent Bash WebFetch WebSearch
---
Discover and install skills from the open agent ecosystem.

Discovery sub-agent (haiku) for search + leaderboard fetch (payoff ≥3×; retrieval-only). Main thread: confirmation + install. Spawn prompt: `cd <cwd> && pwd`.

## When to Use This Skill

Use this skill when the user:
- Asks "how do I do X" where X might be a common task with an existing skill
- Says "find a skill for X" or "is there a skill for X"
- Asks "can you do X" where X is a specialized capability
- Expresses interest in extending agent capabilities or mentions needing help with a specific domain

## The Skills CLI

The Skills CLI (`npx skills`) is the package manager for the open agent skills ecosystem. Key commands:
- `npx skills find [query]` — search for skills
- `npx skills add <package>` — install a skill
- `npx skills check` / `update` — check/update all skills

Browse at https://skills.sh/.

## How to Help Users Find Skills

[Ref: references/search-guide.md]

For search strategy tips, skill categories, and fallback guidance (when no skills are found), [Ref: references/categories.md].
