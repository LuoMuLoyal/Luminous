# Proactive Suggestion Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 让相关健康事实写入后主动触发有界重算，Today 打开时只读取已生成结果，并修复会让建议资格判断失真的基线、漏服时间和分析陈旧状态。

**Architecture:** Lucent 以领域事件为输入，把同一用户/自然日的突发写入合并为 BullMQ recompute job；worker 执行确定性采集、规则、仲裁与持久化，LLM 文案继续走独立低优先级队列。GET 返回 `ready/stale/pending/failed/empty` 的物化结果，不触发 pipeline。Today Analysis 使用同一失效版本和异步生成策略。Luminous 根据状态刷新，不靠进入页面触发首次生成。

**Tech Stack:** NestJS EventEmitter、BullMQ、Redis、Prisma、Jest fake timers、OpenAPI、Flutter/Riverpod、Flutter tests。

---

**Start gate:** 只有 Health Event Contract 已完成跨前后端合同、真实 PostgreSQL acceptance 和文档 checkpoint，才执行本文件。

## Runtime Invariants

- 记录写入事务成功后才发领域事件；监听器失败不得回滚源记录。
- 同一 `userId + localDate` 在 debounce window 内最多一个待执行 job，重复事件只更新原因集合。
- 规则和仲裁不调用 LLM；建议主卡先使用模板文案落库，LLM 改写异步补全。
- GET 不产生建议、不更新 baseline、不调用 LLM，只读取物化结果并返回状态。
- 过去日期的编辑只重算受影响日期和依赖窗口，不无界重放全部历史。
- `unconfirmed` 不是 `missed`；只有存在计划槽位、已超过宽限期且产品规则明确时才可生成漏服候选。

## Task 3 — Add a Debounced Recompute Queue

**Files:**

- Create: `Lucent/src/modules/today-suggestion/services/recompute/queue.service.ts`
- Create: `Lucent/src/modules/today-suggestion/services/recompute/queue.service.spec.ts`
- Create: `Lucent/src/modules/today-suggestion/services/recompute/trigger.listener.ts`
- Create: `Lucent/src/modules/today-suggestion/services/recompute/trigger.listener.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/today-suggestion.module.ts`
- Modify: `Lucent/src/common/events/domain-events.ts`

- [ ] 先写 queue spec：job id 稳定为 user/date；连续事件只保留一个 delayed job；原因集合合并；新版本递增。
- [ ] 先写 listener spec，覆盖 `DAILY_RECORD_CHANGED`、`DOSE_LOG_CHANGED`、`REMINDER_CHANGED`、`HEALTH_CONTEXT_CHANGED`、`SETTINGS_CHANGED`、`HEALTH_EVENT_CHANGED`。
- [ ] 实现 `RecomputeQueueService.enqueue()`，使用仓库现有 BullMQ config、重试和结构化日志规范，不新建第二套 Redis 客户端。
- [ ] 对无 date 的 context/settings/reminder 事件，使用用户时区的今天；对带 date 的事件保持 payload 日期。
- [ ] listener 先标记 materialization pending，再 enqueue；任一步失败记录 error，不向 emitter 抛出未处理异常。
- [ ] 在 module 注册 queue/listener，运行目标 specs。

## Task 4 — Move Pipeline Execution Into the Worker

**Files:**

- Create: `Lucent/src/modules/today-suggestion/services/recompute/worker.service.ts`
- Create: `Lucent/src/modules/today-suggestion/services/recompute/worker.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/pipeline.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/suggestion.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/suggestion.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/today-suggestion.controller.ts`
- Modify: `Lucent/src/modules/today-suggestion/today-suggestion.controller.spec.ts`

- [ ] 先写 worker spec：采集 → 规则 → 仲裁 → 模板呈现 → cache/persistence → ready；异常时 failed；旧 version 完成时不覆盖新 pending version。
- [ ] 将现有 pipeline 中的纯计算入口保留给 worker，移除 GET path 对 `pipelineService.run()` 的调用。
- [ ] 把 `SuggestionService.generate` 拆成 `readCurrent` 与 worker 调用的 `recompute`；controller GET 只调用 `readCurrent`。
- [ ] 响应 DTO 增加 `materializationStatus`、`sourceVersion`、`computedAt`、`retryAfterSeconds`；pending/failed/empty 均返回稳定 envelope，不用 500 表示“尚未生成”。
- [ ] 当用户首次进入且从未有 materialization 时，GET 返回 empty；账号初始化或事件创建负责 enqueue，GET 不偷偷补算。
- [ ] 运行 worker、service 和 controller specs，确认 GET path mock 中 pipeline 调用次数为零。

## Task 5 — Wire Baseline Observation Into Production

**Files:**

- Modify: `Lucent/src/modules/today-suggestion/services/lifecycle/baseline.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/lifecycle/baseline.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/recompute/worker.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/recompute/worker.service.spec.ts`

- [ ] 先写失败测试：一次成功 recompute 应按具备 coverage 的 signal 调用 `recordObservation`；missing signal 不写 baseline；同日重算幂等。
- [ ] 给 baseline observation 使用 `userId + metric + localDate` 幂等键；若现有存储不能保证，补数据库唯一约束。
- [ ] 仅在 collector 明确给出 observed value 和 coverage sufficient 时写 baseline。
- [ ] 把 baseline 写入放在成功规则计算后；写入失败不丢弃已生成建议，但 materialization 记录固定 error code 供监控。
- [ ] 运行 baseline 与 worker specs，确认现有依赖 baseline 的规则对新用户在积累足够观察后可获得资格。

## Task 6 — Fix the Missed-Dose Clock and Slot Evaluation

**Files:**

- Modify: `Lucent/src/modules/today-suggestion/services/collectors/medication.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/medication.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/rules/medication/missed-dose.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/rules/medication/missed-dose.service.spec.ts`

- [ ] 先增加回归测试：本地日期 2026-08-07、当前时间 10:00、08:00 槽位在宽限期后为 overdue；10:30 槽位不是；未提供计划时间不伪造 missed。
- [ ] 注入仓库现有 clock/`now()` seam，使用用户时区把 `scheduledFor + scheduledTime` 组合成时间点，不再从 date-only 午夜计算 nowMinutes。
- [ ] collector 逐槽位返回 `planned/taken/skipped/unconfirmed/overdueUnconfirmed`，不按 medicineId 折叠完成状态。
- [ ] missed-dose rule 只消费 `overdueUnconfirmed`，并在 copy 中使用“尚未确认”而非断言“漏服”。
- [ ] 运行 collector 和 rule specs，包含一天同药两次、一服一未确认的用例。

## Task 7 — Make Today Analysis Event-Driven but Cost-Bounded

**Files:**

- Create: `Lucent/src/modules/today-analysis/services/recompute/trigger.listener.ts`
- Create: `Lucent/src/modules/today-analysis/services/recompute/trigger.listener.spec.ts`
- Modify: `Lucent/src/modules/today-analysis/services/analysis-queue.service.ts`
- Modify: `Lucent/src/modules/today-analysis/services/analysis-queue.service.spec.ts`
- Modify: `Lucent/src/modules/today-analysis/services/analysis.service.ts`
- Modify: `Lucent/src/modules/today-analysis/services/analysis.service.spec.ts`
- Modify: `Lucent/src/modules/today-analysis/today-analysis.controller.ts`

- [ ] 先写 listener/queue tests：只有 health-event start/end、症状 check-in、关键药物状态和服务端 suggestion 版本变化触发；普通饮食/心情/笔记不触发 LLM 分析。
- [ ] 使用 user/date/version job id 合并触发，并设置每日最大生成次数；超过上限时保持 stale，不反复收费。
- [ ] 保存最后成功 analysis 的 sourceVersion/computedAt；GET 返回现有值及 stale 状态，不 POST 时才首次生成。
- [ ] 保留显式用户刷新 endpoint，但增加冷却时间和幂等保护。
- [ ] 运行 today-analysis specs，确认普通记录事件不进入 LLM queue。

## Task 8 — Adapt the Flutter Today State Machine

**Files:**

- Modify: `Luminous/lib/features/today/domain/entities/suggestion.dart`
- Modify: `Luminous/lib/features/today/data/repositories/lucent.dart`
- Modify: `Luminous/lib/features/today/presentation/providers/suggestion.dart`
- Modify: `Luminous/lib/features/today/presentation/widgets/sections/suggestion_state_views.dart`
- Modify: `Luminous/lib/features/today/presentation/widgets/sections/suggestion.dart`
- Modify: `Luminous/test/today/repository_test.dart`
- Modify: `Luminous/test/today/presentation/providers/suggestion_provider_test.dart`
- Modify: `Luminous/test/today/suggestion_section_test.dart`

- [ ] 先写 mapper/provider/widget 失败测试，覆盖 ready、stale、pending、failed、empty。
- [ ] repository 将 generated DTO 转为 domain status，UI 不解析 error message 判断状态。
- [ ] pending 显示现有内容加轻量“正在更新”；stale 保留旧内容并标注更新时间；failed 保留旧内容和重试；empty 不显示伪造建议。
- [ ] 监听 DataChangeBus 只触发延迟 refetch，不调用 generate endpoint；应用 resume 时检查 sourceVersion。
- [ ] 运行目标 Flutter tests，确认保存记录后不会由客户端发起首次生成 POST。

## Task 9 — Observability, Full Verification, and Documentation

**Files:**

- Modify: `Lucent/src/common/metrics/metrics.service.ts`
- Modify: `Lucent/src/common/metrics/metrics.service.spec.ts`
- Create: `Lucent/docs/00-current/Active_Product_Loop.md`
- Modify: `Lucent/docs/00-current/TODO.md`
- Append: implementation-date file under `Lucent/docs/02-logs/migration-log/`
- Modify: `Luminous/docs/00-current/Active_UI_Today.md`
- Modify: `Luminous/docs/00-current/TODO.md`
- Append: implementation-date file under `Luminous/docs/03-logs/migration-log/`

- [ ] 增加固定低基数 metrics：enqueue total、dedupe total、job duration、ready/failed total、stale age；label 不包含 userId 或健康内容。
- [ ] 在 Lucent 运行 `pnpm lint:check`、`pnpm typecheck`、`pnpm test`、`pnpm build`、`pnpm docs:check`。
- [ ] 在 Luminous 运行 `flutter analyze`、`flutter test`、`dart run scripts/check_doc_coverage.dart --warning-only`。
- [ ] 集成验证：关闭 Luminous，写入一条相关记录，等待 worker 完成，再打开 Today；首个 GET 已返回 ready 或 stale 的已有结果。
- [ ] 集成验证：快速连续保存 10 次，只观察到一个合并 job，最终 computedVersion 等于最新 sourceVersion。
- [ ] 更新 current-state、迁移日志和任务清单，明确 Today GET 已变为只读以及失败回退语义。
