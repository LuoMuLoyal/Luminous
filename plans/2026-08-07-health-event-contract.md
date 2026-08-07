# Health Event Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 建立由用户确认开始和结束、支持每日一次结果确认、能够关联症状记录与短期用药的跨前后端健康事件合同。

**Architecture:** Lucent 新增 `health-events` 所有权模块，持久化事件、每日 check-in 和事件与当前药物的关联；现有 `UserDailyRecord` 与 `UserMedicineDoseLog` 使用可空 `healthEventId` 关联事件。系统提议通过 Today suggestion action 表达，只有显式 API 写入才改变事件状态。Luminous 新增独立 vertical slice，在 Today 提供开始、每日确认和结束入口。

**Tech Stack:** NestJS、Prisma/PostgreSQL、OpenAPI、Jest、Flutter、Riverpod、Freezed、Mockito、Flutter widget tests。

---

**Start gate:** 只有[总计划](2026-08-07-post-0.1.0-product-loop-program.md)的 `0.1.0` release gate 已全部满足，才执行本文件。未发布时停止，不创建 schema 或 API。

## Contract Decisions

- 一个用户同一时刻最多有一个 `active` 健康事件；数据库部分唯一约束在 migration SQL 中保证。
- `HealthEventStatus` 只有 `active`、`ended`；不把系统推测或草稿存成真实事件。
- `HealthEventOutcome` 只有 `improved`、`unchanged`、`worsened`；事件结束必须由用户选择一个结果。
- 每日 check-in 使用同一结果枚举，每个事件每个自然日最多一条，用户可更正。
- `title` 是用户可编辑短标题；`reasonRecordId` 可选地指向触发事件的症状记录。
- 事件可关联多个 `UserCurrentMedicine`；dose log 仍关联具体计划槽位，并额外携带 `healthEventId` 以保留历史归属。
- 时区边界使用用户设置解析自然日；DTO 日期使用 `YYYY-MM-DD`，时间点使用带 offset 的 ISO 8601。

## Task 1 — Add Prisma Models and Migration

**Files:**

- Modify: `Lucent/prisma/schema.prisma`
- Create: migration output under `Lucent/prisma/migrations/` generated with name `add_health_events`

- [ ] 在 `prisma/schema.prisma` 增加三个模型和两个枚举；为 user/status/start、event/date、event/medicine 建立唯一约束或索引。
- [ ] 给 `UserDailyRecord`、`UserMedicineDoseLog` 增加 `healthEventId String?`、relation 和 `[userId, healthEventId]` 索引。
- [ ] 运行 `pnpm exec prisma validate`，确认 relation 与索引声明有效。
- [ ] 运行 `pnpm exec prisma migrate dev --name add_health_events --create-only` 生成 migration；在生成的 SQL 中加入“每用户最多一个 active 事件”的 PostgreSQL partial unique index。
- [ ] 运行 `pnpm prisma:generate`、`pnpm db:migrate:test`，再用 Prisma 测试客户端创建第二个 active 事件，确认数据库唯一约束拒绝该写入。

## Task 2 — Implement the Lucent Ownership Module

**Files:**

- Create: `Lucent/src/modules/health-events/health-events.module.ts`
- Create: `Lucent/src/modules/health-events/health-events.controller.ts`
- Create: `Lucent/src/modules/health-events/index.ts`
- Create: `Lucent/src/modules/health-events/services/events.service.ts`
- Create: `Lucent/src/modules/health-events/services/events.service.spec.ts`
- Create: `Lucent/src/modules/health-events/services/check-ins.service.ts`
- Create: `Lucent/src/modules/health-events/services/check-ins.service.spec.ts`
- Create: `Lucent/src/modules/health-events/repositories/event.repository.ts`
- Create: `Lucent/src/modules/health-events/repositories/prisma-event.repository.ts`
- Modify: `Lucent/src/app.module.ts`

- [ ] 先写 `events.service.spec.ts`：无 active 事件时可创建；已有 active 事件时拒绝；用户只能读取/结束自己的事件；结束时必须有 outcome；结束后不能继续写 check-in。
- [ ] 先写 `check-ins.service.spec.ts`：同一事件同一天 upsert 一条；只接受三种结果；使用用户时区归属日期。
- [ ] 运行两个 spec，确认因为服务尚未实现而失败。
- [ ] 定义 `HealthEventRepositoryPort`，只暴露服务所需的 create/find/update/upsert 操作；Prisma 实现统一应用 `userId` 和 `deletedAt: null`。
- [ ] 实现 `EventsService` 与 `CheckInsService`，把“用户确认”作为唯一状态变更入口，不在服务内自动推断 outcome。
- [ ] 在 `HealthEventsModule` 注册 controller、services 和 repository provider，只导出其他模块确实需要调用的读服务。
- [ ] 在 `src/app.module.ts` 导入模块，并运行两个目标 spec 确认通过。

## Task 3 — Define HTTP DTOs and Ownership-Safe Endpoints

**Files:**

- Create: `Lucent/src/modules/health-events/dto/create-event.dto.ts`
- Create: `Lucent/src/modules/health-events/dto/end-event.dto.ts`
- Create: `Lucent/src/modules/health-events/dto/upsert-check-in.dto.ts`
- Create: `Lucent/src/modules/health-events/dto/event-response.dto.ts`
- Create: `Lucent/src/modules/health-events/dto/event-list-query.dto.ts`
- Create: `Lucent/src/modules/health-events/health-events.controller.spec.ts`
- Modify: `Lucent/src/modules/health-events/health-events.controller.ts`

- [ ] 先写 controller spec 覆盖 `POST /health-events`、`GET /health-events/active`、`GET /health-events`、`GET /health-events/:id`、`PUT /health-events/:id/check-ins/:date`、`POST /health-events/:id/end`。
- [ ] 为创建 DTO 限制短标题长度，允许可选 `reasonRecordId` 与 `currentMedicineIds`；为结束和 check-in DTO 使用枚举校验。
- [ ] 响应 DTO 显式返回 `status`、`startedAt`、`endedAt`、`outcome`、当日 check-in、关联 medicine IDs 和 coverage；不回传自由文本记录 payload。
- [ ] 所有 detail/write endpoint 先按 `userId` 做所有权检查；非法跨用户 ID 返回现有统一 not-found 语义。
- [ ] 运行 `pnpm test -- src/modules/health-events/health-events.controller.spec.ts`，确认全部通过。

## Task 4 — Connect Existing Records Without Silent Association

**Files:**

- Modify: `Lucent/src/modules/daily-records/dto/create-record.dto.ts`
- Modify: `Lucent/src/modules/daily-records/dto/update-record.dto.ts`
- Modify: `Lucent/src/modules/daily-records/services/records.service.ts`
- Modify: `Lucent/src/modules/daily-records/services/records.service.spec.ts`
- Modify: `Lucent/src/modules/medicine-dose-logs/dto/create-dose-log.dto.ts`
- Modify: `Lucent/src/modules/medicine-dose-logs/dto/mark-dose-log.dto.ts`
- Modify: `Lucent/src/modules/medicine-dose-logs/services/dose-logs.service.ts`
- Modify: `Lucent/src/modules/medicine-dose-logs/services/dose-logs.service.spec.ts`

- [ ] 先增加失败测试：传入 `healthEventId` 时必须属于当前用户且为 active；省略时保持 null，不自动关联“最近事件”。
- [ ] 在 daily record create/update 与 dose log create/mark DTO 增加可选 UUID `healthEventId`。
- [ ] 通过 `health-events` 模块导出的 ownership service 验证关联，不允许业务模块直接访问 health event Prisma model。
- [ ] 编辑已有记录时保留原关联，只有显式字段才改变；结束事件后仍允许读取历史关联但不允许新关联。
- [ ] 运行两个 service spec 文件，确认所有新旧测试通过。

## Task 5 — Emit the Health Event Domain Event

**Files:**

- Modify: `Lucent/src/common/events/domain-events.ts`
- Modify: `Lucent/src/modules/health-events/services/events.service.ts`
- Modify: `Lucent/src/modules/health-events/services/check-ins.service.ts`
- Modify: `Lucent/src/modules/health-events/services/events.service.spec.ts`
- Modify: `Lucent/src/modules/health-events/services/check-ins.service.spec.ts`

- [ ] 为 `HEALTH_EVENT_CHANGED = 'health-event.changed'` 和 `{ userId, eventId, date, change }` payload 先写 emitter 断言。
- [ ] 只在事务成功后为 create/end/check-in emit；失败写入不得发事件。
- [ ] 把事件加入 `DomainEventName` union，确保后续主动重算可以类型安全订阅。
- [ ] 运行 health-events service specs，验证每种成功写入恰好 emit 一次。

## Task 6 — Export OpenAPI and Add the Flutter Domain Slice

**Files:**

- Modify: `Lucent/docs/openapi.json` (generated)
- Create: `Luminous/lib/features/health_event/domain/entities/health_event.dart`
- Create: `Luminous/lib/features/health_event/domain/repositories/health_event.dart`
- Create: `Luminous/lib/features/health_event/data/repositories/lucent.dart`
- Create: `Luminous/lib/features/health_event/data/providers/health_event.dart`
- Create: `Luminous/lib/features/health_event/presentation/providers/active_event.dart`
- Create: `Luminous/test/health_event/data/repositories/lucent_test.dart`
- Create: `Luminous/test/health_event/presentation/providers/active_event_test.dart`

- [ ] 在 Lucent 运行 `pnpm export:openapi`，检查新增 endpoint 和 enum 字面量正确。
- [ ] 在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`，只通过生成流程更新 API client。
- [ ] 先写 repository 测试，覆盖 response mapper、active 为 404/空的转换、create/check-in/end 失败传播。
- [ ] 建立 Freezed `HealthEvent`、`HealthEventOutcome`、`HealthEventStatus`；领域层不导入 generated API 类型。
- [ ] 实现 `HealthEventRepository` 接口与 Lucent adapter，再实现 `activeHealthEventProvider` 的 loading/data/error 和显式 refresh。
- [ ] 运行 `flutter test test/features/health_event`，确认 repository/provider 测试通过。

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
