# Cross-plugin Coordination

Plugin-specific decisions for `agents-flow` and how it coexists with other tools and plugins.

## Optional `agents-memo` integration

`agents-flow` integrates with `agents-memo` via **runtime detection** — no hard dependency. Vault-aware paths activate when agents-memo is present; otherwise skills fall back inline.

Skills probe for these commands:

- `agents-memo:save` — file structured notes
- `agents-memo:wiki-query` — overlap detection and prior-pattern lookup
- `agents-memo:wiki-lint` — vault health audits

## See also

- [`README.md`](../README.md) — `agents-memo` integration overview
- [`token-budgets.md`](token-budgets.md) — instruction file placement, `@`-import syntax, per-artifact token budgets
