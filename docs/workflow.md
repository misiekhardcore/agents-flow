# Development Workflow

Lifecycle walkthrough from discovery to closure.

## Workflow Paths
|Size|Path|Handoff|
|-|-|-|
|**Trivial**|`/implement`|→ PR|
|**Medium**|`/discover` → `/implement`|Issue Body → PR|
|**Large**|`/discover` → `/define` → `/implement`|Issue Body → Issue Body → PR|

**State Management**:
- **Inter-phase**: GitHub issue body (5-field structure — invoke `Read @_shared/handoff-artifact.md`).
- **Intra-phase**: `./.claude/NOTES.md` (invoke `Read @_shared/notes-md-protocol.md`).
- **Context Pressure**: Load the "compaction-protocol" skill for Edit → Delegate → Compact strategy.

## Phase Details

### 1. `/discover`
**Goal**: Vague idea → well-specified GitHub issue.
- **Process**: Discover orchestrator loads describe skill (research, visuals) → specify skill (AC generation).
- **Output**: Issue with **Problem statement** + **Handoff block** (AC, Constraints, Decisions, Evidence, Questions).
- **Gate**: Explicit user approval of issue body.
- **Next**: `/define` (Large) or `/implement` (Medium).

### 2. `/define`
**Goal**: Approved issue → technical implementation plan.
- **Process**: Define orchestrator loads architecture skill → design skill (if visual).
- **Output**: Update issue with `## Implementation plan` (decisions, visuals, sub-issues, dependency graph).
- **Gate**: Explicit user approval of decisions.
- **Next**: `/implement`.

### 3. `/implement`
**Goal**: Defined issue → ready-to-merge PR.
- **Design Gate**: Verify `## Implementation plan` exists. If absent → prompt for `/define` or trivial downgrade.
- **Cycle**: Autonomous build → review → verify → fix loop (max 5 cycles).
   - Build via task tool (`workflow-build-worker`): TDD implementation.
   - Review via task tool (`workflow-review-runner`): isolated specialist review.
   - Verify via task tool (`workflow-verify-runner`): QA verification of AC with evidence.
- **Output**: Draft PR.
  - **Body**: `## Summary` → `## Testing notes` → `## Notes` (from NOTES.md harvest).
- **Closure**: `/compound` runs automatically → file learnings to wiki.

### 4. Maintenance & Utilities
- **`/resolve-pr-feedback`**: Triage → Fix → Reply to human review comments.
- **`/compound`**: Extract learnings → file to wiki (via `/save` when agents-memo is installed).
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
