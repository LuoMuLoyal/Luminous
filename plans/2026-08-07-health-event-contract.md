# Health Event Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 建立由用户确认开始和结束、支持每日一次结果确认、能够关联症状记录与短期用药的跨前后端健康事件合同。

**Architecture:** Lucent 新增 `health-events` 所有权模块，持久化事件、每日 check-in 和事件与当前药物的关联；现有 `UserDailyRecord` 与 `UserMedicineDoseLog` 使用可空 `healthEventId` 关联事件。系统提议通过 Today suggestion action 表达，只有显式 API 写入才改变事件状态。Luminous 新增独立 vertical slice，在 Today 提供开始、每日确认和结束入口。

**Tech Stack:** NestJS、Prisma/PostgreSQL、OpenAPI、Jest、Flutter、Riverpod、Freezed、Mockito、Flutter widget tests。

---

**Start gate:** 在[总计划](2026-08-07-product-loop-program.md)的 Pre-conditions 已完成后，才执行本文件。

## Contract Decisions

- 一个用户同一时刻最多有一个 `active` 健康事件；数据库部分唯一约束在 migration SQL 中保证。
- `HealthEventStatus` 只有 `active`、`ended`；不把系统推测或草稿存成真实事件。
- `HealthEventOutcome` 只有 `improved`、`unchanged`、`worsened`；事件结束必须由用户选择一个结果。
- 每日 check-in 使用同一结果枚举，每个事件每个自然日最多一条，用户可更正。
- `title` 是用户可编辑短标题；`reasonRecordId` 可选地指向触发事件的症状记录。
- 事件可关联多个 `UserCurrentMedicine`；dose log 仍关联具体计划槽位，并额外携带 `healthEventId` 以保留历史归属。
- 时区边界使用用户设置解析自然日；DTO 日期使用 `YYYY-MM-DD`，时间点使用带 offset 的 ISO 8601。

## Task 7 — Add Mobile Confirmation UI

**Files:**

- Create: `Luminous/lib/features/health_event/presentation/widgets/sheets/start_event.dart`
- Create: `Luminous/lib/features/health_event/presentation/widgets/sheets/check_in.dart`
- Create: `Luminous/lib/features/health_event/presentation/widgets/sheets/end_event.dart`
- Create: `Luminous/test/health_event/presentation/widgets/sheets/start_event_test.dart`
- Create: `Luminous/test/health_event/presentation/widgets/sheets/check_in_test.dart`
- Create: `Luminous/test/health_event/presentation/widgets/sheets/end_event_test.dart`
- Modify: `Luminous/lib/features/today/presentation/pages/page.dart`
- Modify: `Luminous/lib/features/today/presentation/widgets/views/dashboard_view.dart`
- Modify: `Luminous/lib/l10n/src/today_zh.arb`
- Modify: `Luminous/lib/l10n/src/today_en.arb`
- Modify: `Luminous/docs/02-reference/Localization.md`

- [ ] 先写 widget tests：无事件显示“开始一段健康观察”；active 事件显示今天一次结果入口；结束弹窗强制选择好转/差不多/加重；取消不写入。
- [ ] 开始弹窗只要求短标题，可选关联当前短期药物和触发症状；不要求完整病史。
- [ ] check-in 与结束使用三个固定选项；详细症状、严重程度和备注保持可选，不阻塞提交。
- [ ] 保存成功后刷新 active event、Today dashboard 和相关记录；请求失败保留用户输入并显示可重试错误。
- [ ] 只编辑 `lib/l10n/src/today_*.arb`，运行 `dart scripts/arb_tools.dart merge` 与 `flutter gen-l10n`。
- [ ] 运行三个 widget test 文件，确认交互和可访问语义通过。

## Task 8 — Verify and Document

**Files:**

- Create: `Lucent/docs/00-current/Active_Product_Loop.md`
- Modify: `Lucent/docs/00-current/TODO.md`
- Append: implementation-date file under `Lucent/docs/02-logs/migration-log/`
- Modify: `Luminous/docs/00-current/Active_UI_Today.md`
- Modify: `Luminous/docs/00-current/TODO.md`
- Append: implementation-date file under `Luminous/docs/03-logs/migration-log/`

- [ ] 在 Lucent 运行 `pnpm lint:check && pnpm typecheck && pnpm test && pnpm build && pnpm docs:check`。
- [ ] 在 Luminous 运行 `flutter analyze`、`flutter test`、`dart run scripts/check_doc_coverage.dart --warning-only`。
- [ ] 运行两个仓库的文档链接检查和 `git diff --check`。
- [ ] 手工验证用户 A 无法读取或关联用户 B 的 event ID。
- [ ] 手工验证开始 → check-in → 结束 → 历史读取，确认系统建议没有绕过用户确认写入状态。
- [ ] 更新 current-state 和迁移日志，删除两个任务清单中已经完成的 health-event 条目。
