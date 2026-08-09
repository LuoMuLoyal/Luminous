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
