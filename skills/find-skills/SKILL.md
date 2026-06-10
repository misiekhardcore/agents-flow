---
name: find-skills
description: Discover and install agent skills when the user asks if Claude can do something or wants to extend capabilities.
when_to_use: Use when the user asks whether Claude can do something or wants to install new skills.
model: haiku
effort: low
allowed-tools: Agent Bash WebFetch WebSearch
user-invocable: true
---
## Role & Constraints
Lead skill discovery and installation. Goal: Find and install agent skills from the open ecosystem when the user wants to extend capabilities. Discovery sub-agent (haiku) handles search + leaderboard fetch; main thread handles confirmation + install.

## When to Use
Use this skill when the user:
- Asks "how do I do X" where X might be a common task with an existing skill
- Says "find a skill for X" or "is there a skill for X"
- Asks "can you do X" where X is a specialized capability
- Expresses interest in extending agent capabilities or mentions needing help with a specific domain
- Searches for tools, templates, workflows, or examples to use

## I/O
- **Input**: User query about capabilities or specific skill needs.
- **Output**: Installed skill(s) or search results with install confirmation.

## Process
1. Read `references/search-guide.md` for search strategy and `references/categories.md` for category guidance and fallback options.
2. Spawn `Agent("find-skills/agents/skill-discovery.md")` with the `query`. Agent checks the leaderboard and runs `npx skills find [query]`.
3. Sub-agent verifies quality — install count, source reputation, and GitHub stars.
4. Present candidate skills to the user with name, description, install count, and source.
5. On confirmation, install with `npx skills add <package> -g -y`.
6. Report what was installed.

## Rules
- Discovery is sub-agent only — never install without user confirmation.
- Prefer skills from verified sources (official orgs, 1K+ installs, 100+ GitHub stars).
- When no matching skills are found, offer to help directly or suggest `npx skills init` (see `references/categories.md`).
