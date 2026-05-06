---
name: prune
description: Audit CLAUDE.md rules, AGENTS.md / SKILL.md authoring quality, and (optionally) the claude-obsidian vault for staleness.
when_to_use: Use monthly or after major refactors. Vault-internal health (orphans, broken links, frontmatter gaps) is delegated to claude-obsidian's wiki-lint when available.
model: haiku
---

You are auditing the project's Claude Code rules and documentation for staleness and authoring quality.

This skill has three lanes:

- **Rules lane** — always runs. Audits `CLAUDE.md`, imported files, and the harness's auto-memory.
- **Authoring lane** — always runs. Checks `CLAUDE.md` / `AGENTS.md` / `SKILL.md` files for structural quality issues grounded in the Augment Code empirical study on AGENTS.md authoring.
- **Vault lane** — optional. If the `claude-obsidian` plugin is installed, delegates the vault audit to its `wiki-lint` command and folds the findings in. If not, the vault lane is skipped with a one-line note.

## Process

### Rules lane (always)

1. **Gather all rule sources:**
   - `~/.claude/CLAUDE.md` (global)
   - Any `@imported` files referenced in CLAUDE.md
   - Project-level `CLAUDE.md` (if exists in cwd)
   - `~/.claude/projects/<project>/memory/MEMORY.md` + topic files — Claude Code's built-in auto memory (per-user, harness-managed). Group these together when reporting; do not propose edits inside `MEMORY.md` itself unless it is clearly stale, since the harness rewrites it.

2. **For each rule or guidance item, assess:**
   - Does the tool/command it references still exist? (e.g., if a rule references `yarn lint`, does the project still use yarn?)
   - Does the pattern it describes still apply? (e.g., if a rule says "use X pattern for Y", does Y still exist in the codebase?)
   - Has it been superseded by a newer rule or convention?
   - Is it redundant with built-in Claude Code behavior?

3. **For each auto-memory file:**
   - Is the information still accurate? (check against current state)
   - Is it redundant with what's already in CLAUDE.md or the codebase?

### Authoring lane (always)

**Discovery — enumerate files in scope before running checks:**
- `CLAUDE.md` files: global `~/.claude/CLAUDE.md`, project-root `CLAUDE.md`, and any subdirectory `CLAUDE.md` files (e.g., `src/CLAUDE.md`).
- `AGENTS.md` files: project-root `AGENTS.md` and any subdirectory `AGENTS.md` files. Also check `GEMINI.md` — it is the Gemini CLI equivalent of `AGENTS.md` and follows the same authoring rules.
- `SKILL.md` files: enumerate all `SKILL.md` files under `.claude/skills/` and any active skill plugin directories (e.g., `~/.claude/plugins/cache/*/skills/*/SKILL.md`).

Use `find` (or equivalent) to enumerate, then classify each file by its path position (global / project-root / subdirectory) for the length-triage cap lookup.

For each discovered file, run the five checks below. Each finding must cite its empirical source so the user can judge whether to act on it.

4. **Length triage** — Count the file's total lines. Flag if it exceeds the applicable cap:
   - Global `~/.claude/CLAUDE.md`: 50 lines
   - Project-root `CLAUDE.md` / `AGENTS.md`: 200 lines
   - Subdirectory `CLAUDE.md` / `AGENTS.md`: 50 lines
   - `SKILL.md` (any location): skip the length check — skill files have no empirically-derived cap and are expected to be longer than agent-config files.

   Configurable: if the user has specified a different cap, use that instead.

   *Citation: project sizing guidance (progressive disclosure — 100–150 line main file + on-demand reference docs delivered +10–15% across benchmark metrics).*

5. **Unpaired "don't" detector** — Scan every line whose content, after stripping any leading list marker (`- `, `* `, `+ `, or `N. `), starts with `Don't`, `Avoid`, or `Never`. For each, look for a paired `Do`, `✅`, `Use`, or `Prefer` line (also after stripping list markers) within a configurable window (default: 3 lines after). List every unpaired entry with file path and line number.

   *Citation: Augment Code empirical study — "pair every 'don't' with a 'do'"; warning-only documentation underperforms paired guidance.*

6. **Warning-stack threshold** — Count total "don't"-style lines per file. A line counts if its content, after stripping any leading list marker (`- `, `* `, `+ `, or `N. `), starts with `Don't`, `Avoid`, or `Never`:
   - `> 10` → warning; cite the excessive-warnings anti-pattern.
   - `> 30` → error; cite the finding that 30+ "don't" rules roughly doubled PR time and dropped `completeness` 20% on simple tasks.

   *Citation: Augment Code empirical study.*

7. **Architecture-overview smell** — Find section headings containing `Architecture`, `How it works`, `Background`, or `Overview` (case-insensitive). If the section body exceeds 30 lines, flag it as a candidate for relocation to a load-on-demand reference file linked from the main doc.

   *Citation: Augment Code empirical study — long architecture-overview sections caused agents to read 12 docs and burn 80K tokens before editing, dropping `completeness` 25%.*

8. **Decision-table candidates** — Scan for prose runs matching the shape "Use X for A, use Y for B, …" with 3 or more branches. Surface these as candidates for conversion to a decision table (yes/no matrix or two-column table).

   *Citation: Augment Code empirical study — decision tables added +25% on `best_practices` in affected areas.*

### Vault lane (optional — claude-obsidian)

9. **If `claude-obsidian:wiki-lint` is available:**
   - Invoke it. It handles vault-structural checks (orphans, broken wikilinks, missing frontmatter fields, stale claims) — don't duplicate that work here.
   - Additionally ask it (or use `claude-obsidian:wiki-query`) to flag concept/entity/source notes whose described problem, pattern, or root cause may no longer apply given recent code changes. That semantic check is the piece unique to `/prune`.
   - Fold the returned findings into the audit report as a separate section titled "Vault (via wiki-lint)".

10. **If `claude-obsidian` is not installed:**
    - Skip step 9.
    - Add a single line to the report: `Vault audit skipped — install claude-obsidian (claude plugin marketplace add AgriciDaniel/claude-obsidian) to enable.`

### Classification

11. **Classify each rules-lane item:**
    - **Current** — still relevant, keep as-is
    - **Stale** — references things that no longer exist, recommend removal
    - **Superseded** — replaced by a newer rule/doc, recommend consolidation
    - **Unclear** — cannot determine relevance, flag for human review

## Output

An audit report with:

- Total rules/docs audited
- Items by classification (current / stale / superseded / unclear) for the rules lane
- **Authoring-quality findings** — grouped by file, one sub-section per check that produced findings; omit checks with no findings. Each finding includes file path, line number (where applicable), the specific issue, and its citation.
- The vault lane's findings (or the "skipped" line) as a separate section
- Specific recommendations for each non-current item
- Suggested edits (but do NOT apply them without user approval)

## Rules

- Never delete rules or docs automatically — present recommendations and wait for approval.
- When in doubt, classify as "unclear" rather than "stale".
- Check the actual codebase, not just the rule text — a rule might reference an outdated name but the intent is still valid.
- Do not scan vault files directly. The vault's structure is the `claude-obsidian` plugin's responsibility; this skill calls into it rather than walking paths.
- Authoring-lane checks are non-destructive — list findings only; do not rewrite files.
- Omit authoring-lane check sub-sections that have no findings; do not emit empty sections.
