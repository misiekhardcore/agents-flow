# RFC 2119 + XML Tag Style Guide

## Purpose

RFC 2119 keywords + XML tags structure agent artifact prompts so the model parses role boundaries, rules, and output formats reliably — at zero tooling cost. Tags shape how an agent behaves; they must never leak into what it says to the user.

## Tag Palette (6 Families)

|Family|Tags|Purpose|
|-|-|-|
|`<rules>`|`<rules>`, `<constraint>`, `<critical>`|MUST-level requirements — hard stops, invariants, non-negotiables|
|`<constraints>`|`<constraints>`, `<limitation>`, `<boundary>`|MUST NOT / scope boundaries — what the agent must not do|
|`<guidelines>`|`<guidelines>`, `<recommendation>`, `<best-practice>`|SHOULD/MAY-level — recommended patterns, soft rules|
|`<context>`|`<context>`, `<background>`, `<rationale>`, `<why>`|Prose context — the "why" behind the rules|
|`<example>`|`<example>`, `<counterexample>`, `<template>`|Illustrative — concrete do/don't samples|
|`<output>`|`<output>`, `<format>`, `<schema>`|Output contract — expected shape of the result|

This is a recommended palette, not a closed contract. Artifacts may add purpose-specific tags as needed.

## Placement Rules

- **Wrap only major prose sections.** Use tags to delimit significant semantic blocks (e.g., the rules block, the constraints block, the output format). Do not tag every sentence.
- **Never wrap frontmatter.** Frontmatter is mechanically parsed; tags belong in the prose body.
- **Maximum 3–4 tag nesting levels.** Deeply nested tags degrade prompt quality. Flatten where possible.
- **"Enhance, not obscure."** If a tag makes the prompt harder for a human or model to read, restructure.

## RFC 2119 Mapping

|Keyword|Tag family|When to use|
|-|-|-|
|MUST / MUST NOT|`<rules>` or `<constraints>`|Hard requirements, invariants, security boundaries|
|SHOULD / SHOULD NOT|`<guidelines>`|Recommended but not absolute; deviation requires rationale|
|MAY / OPTIONAL|`<guidelines>`|Permissive — agent may choose|

## CAPS-is-Normative Convention

Capitalized RFC 2119 keywords (MUST, MUST NOT, SHOULD, SHOULD NOT, MAY) are normative when used inside tag-delimited sections. Outside tags, CAPS carries no special semantics — write normally.

## Structure Must Not Leak Into Voice

The XML structure is for the model's consumption only. The artifact's user-facing output must read naturally — no tag syntax, no RFC 2119 jargon, no structural markup in delivered responses. This is the "enhance not obscure" rule applied to output: the agent uses tags to organize its own reasoning; the user sees clean prose.

## Preamble (Optional)

Artifacts MAY include a preamble before the first tagged section. When present it sets scope, audience, or invocation context. When absent — also valid; the tag-delimited body stands alone. Omission saves per-artifact tokens.

## Token Budget Mitigation

Wrapping only major prose sections (per Placement Rules above) keeps the tag overhead low. Tagged sections survive minification (`bin/minify-md`) intact because they are semantic markers, not formatting.

## Opencode Integration Note

opencode does not perform any tag parsing. The whole body — tags included — is opaque prompt text passed to the model. The convention is pure prompt-engineering. No tag-handling code, no parser, no schema is needed in the tool integration.
