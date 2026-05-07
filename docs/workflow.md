# Development Workflow

Lifecycle walkthrough from discovery to closure.

## Workflow Paths
|Size|Path|Handoff|
|-|-|-|
|**Trivial**|`/implement`|→ PR|
|**Medium**|`/discovery` → `/implement`|Issue Body → PR|
|**Large**|`/discovery` → `/define` → `/implement`|Issue Body → Issue Body → PR|

**State Management**:
- **Inter-phase**: GitHub issue body (5-field structure in `_shared/handoff-artifact.md`).
- **Intra-phase**: `./.claude/NOTES.md` (`_shared/notes-md-protocol.md`).
- **Context Pressure**: [Ref: compaction-protocol] (Edit → Delegate → Compact).

## Phase Details

### 1. `/discovery` (Opus, High)
**Goal**: Vague idea → well-specified GitHub issue.
- **Process**: Classify Scope → Prior-Art Scout → `/describe` ( la-inline) → `/specify` (sequential subagent).
- **Output**: Issue with **Problem statement** + **Handoff block** (AC, Constraints, Decisions, Evidence, Questions).
- **Gate**: Explicit user approval of issue body.
- **Next**: `/define` (Large) or `/implement` (Medium).

### 2. `/define` (Opus, High) — _Large features only_
**Goal**: Approved issue → technical implementation plan.
- **Process**: Research → `/architecture` → `/design` (if visual).
- **Output**: Update issue with `## Implementation plan` (decisions, visuals, sub-issues, dependency graph).
- **Gate**: Explicit user approval of decisions.
- **Next**: `/implement`.

### 3. `/implement` (Sonnet)
**Goal**: Defined issue → ready-to-merge PR.
- **Design Gate**: Verify `## Implementation plan` exists. If absent → prompt for `/define` or trivial downgrade.
- **Cycle**: Autonomous build → review → verify → fix loop (max 3 cycles).
  - `/build`: TDD implementation.
  - `/review`: Isolated specialist review (Correctness, Standards, etc.).
  - `/verify`: QA verification of AC with evidence.
- **Output**: Draft PR.
  - **Body**: `## Summary` → `## Testing notes` → `## Notes` (from NOTES.md harvest).
- **Closure**: `/compound` runs automatically → file learnings to wiki.

### 4. Maintenance & Utilities
- **`/resolve-pr-feedback`**: Triage → Fix → Reply to human review comments.
- **`/compound`**: Extract learnings → `/save` to Obsidian vault.
- **`/prune`**: Audit rules, authoring quality, and vault staleness.
- **`/audit-issues`**: Detect drift between open issues and current repo state.
- **`/wrap-up`**: Clean up worktree and branch.

## Consistency & Memory
- **Sourcing**: Re-runs rewrite regions in place (Problem statement, AC, Implementation plan).
- **Memory Tiers**:
  - **Scratchpad**: In-context (Session).
  - **NOTES.md**: Worktree-local (Phase).
  - **Issue Body**: Remote (Cross-phase).
  - **Vault**: Durable (Cross-feature).
