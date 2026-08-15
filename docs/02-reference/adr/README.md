# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for Luminous.

## What is an ADR?

An ADR captures a significant architectural decision, the context that led to it, the options
considered, and the consequences. ADRs provide historical traceability for why the system is built
the way it is.

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

| Option   | Pros | Cons |
| -------- | ---- | ---- |
| Option A | ...  | ...  |
| Option B | ...  | ...  |

## Consequences

What becomes easier or harder as a result of this decision?
```

## Index

- [0001](0001-riverpod-state-management.md)
  - Title: Riverpod State Management
  - Status: accepted
  - Date: 2026-05-30
- [0002](0002-gorouter-navigation.md)
  - Title: GoRouter Navigation
  - Status: accepted
  - Date: 2026-05-30
- [0003](0003-freezed-immutable-models.md)
  - Title: Freezed Immutable Models
  - Status: accepted
  - Date: 2026-06-22
- [0004](0004-flutter-hooks-migration.md)
  - Title: flutter_hooks Migration
  - Status: accepted
  - Date: 2026-06-28
- [0005](0005-melos-monorepo.md)
  - Title: Melos Monorepo Management
  - Status: accepted
  - Date: 2026-06-05
- [0006](0006-riverpod-generator-and-auth-guard.md)
  - Title: riverpod_generator 与 Auth-Guarded Provider 工厂
  - Status: accepted
  - Date: 2026-07-10
- [0007](0007-network-layer-separation.md)
  - Title: 网络层职责分离 — LucentDioClient 拆分与 API 访问简化
  - Status: accepted
  - Date: 2026-07-10
- [0008](0008-result-type-and-error-handling.md)
  - Title: Result 类型与统一错误处理
  - Status: accepted
  - Date: 2026-07-10
- [0009](0009-local-persistence-drift.md)
  - Title: 本地持久化与离线策略 — Drift
  - Status: accepted
  - Date: 2026-07-10
- [0010](0010-type-safe-routing-go-router-builder.md)
  - Title: 类型安全路由 — go_router_builder
  - Status: accepted
  - Date: 2026-07-10
- [0011](0011-event-led-sparse-record-product-loop.md)
  - Title: 事件期优先且允许稀疏记录的产品闭环
  - Status: superseded（2026-08-15 被长期健康伙伴方向取代）
  - Date: 2026-08-07
- [0012](0012-desktop-independent-web-product-route.md)
  - Title: 桌面端采用独立 Web 产品路线
  - Status: proposed
  - Date: 2026-08-15
