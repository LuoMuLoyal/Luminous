# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for Luminous.

## What is an ADR?

An ADR captures a significant architectural decision, the context that led to it, the options considered, and the consequences. ADRs provide historical traceability for why the system is built the way it is.

## Naming

```
NNNN-lowercase-title-with-dashes.md
```

- `NNNN`: sequential number, zero-padded (0001, 0002, ...)
- Title: short, descriptive, kebab-case

## Status Values

- `proposed` — under discussion, not yet implemented
- `accepted` — approved and implemented (or planned for implementation)
- `deprecated` — replaced by a newer ADR; reference the superseding ADR
- `superseded` — no longer applicable

## Template

```markdown
# ADR-NNNN: Title

- **Status**: proposed | accepted | deprecated | superseded
- **Date**: YYYY-MM-DD
- **Deciders**: [list]

## Context

What is the issue or decision point? What constraints or forces are at play?

## Decision

What did we decide to do?

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

## Consequences

What becomes easier or harder as a result of this decision?
```

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-riverpod-state-management.md) | Riverpod State Management | accepted | 2026-05-30 |
| [0002](0002-gorouter-navigation.md) | GoRouter Navigation | accepted | 2026-05-30 |
| [0003](0003-freezed-immutable-models.md) | Freezed Immutable Models | accepted | 2026-06-22 |
| [0004](0004-flutter-hooks-migration.md) | flutter_hooks Migration | accepted | 2026-06-28 |
| [0005](0005-melos-monorepo.md) | Melos Monorepo Management | accepted | 2026-06-05 |
