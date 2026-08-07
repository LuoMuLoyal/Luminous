# Sparse Record Semantics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 让服药、饮水、睡眠和平台导入在 Today、建议、回顾与导出之间共享同一数据语义，并把不完整记录明确表示为 unknown 而不是零或失败。

**Architecture:** Lucent 负责标准化存储与 coverage 计算：服药以计划槽位为单位、饮水以 ml 为规范单位、睡眠以可重叠检查的 episode 表示。所有聚合 DTO 同时返回 value、coverage 和 source。Luminous 快速输入保持低负担，domain mapper 不再从记录数量推断健康值；健康平台导入在不能可靠执行时明确禁用自动同步，并用稳定指纹保留同日多条记录。

**Tech Stack:** NestJS、Prisma、OpenAPI、Jest、Flutter、Riverpod、Freezed、Drift/health adapter、Flutter tests。

---

**Start gate:** 只有[总计划](2026-08-07-post-0.1.0-product-loop-program.md)的 `0.1.0` release gate 与 Health Event Contract 的 API seam 已冻结，才执行本文件。

## Shared Vocabulary

- `unknown`: 没有足够信息判断，不能参与分母或触发不足结论。
- `observedZero`: 用户明确确认值为零；与没有记录不同。
- `coverage`: `sufficient`、`partial`、`none`，每一指标独立计算。
- `source`: `manual`、`health_platform`、`reminder_plan`、`derived`；UI 必须可解释来源。
- `doseSlot`: `reminderId + scheduledFor + scheduledTime`；没有 reminder 的临时服药使用 dose-log ID 自身作为独立槽位。
- `sleepEpisode`: 起止时间、类型 `nightSleep|nap`、可选质量；不得仅以日期为唯一身份。

## Task 1 — Freeze the Semantics With Contract Tests

**Files:**

- Modify: `Lucent/src/modules/reports/dashboard/context.service.spec.ts`
- Modify: `Lucent/src/modules/reports/dashboard/computation.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/record.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/medication.service.spec.ts`
- Create: `Lucent/test/contract/sparse-record-semantics.spec.ts`

- [ ] 增加失败测试：无饮水记录返回 unknown/none，明确 0 ml 返回 observedZero，500 ml 返回 observed value；Today 与 Report 使用同一 ml 总量。
- [ ] 增加失败测试：同药 08:00 taken、20:00 unconfirmed 的 coverage 是 1/2，不是全日完成。
- [ ] 增加失败测试：夜间睡眠和午睡同日均保留，coverage 不因缺少质量字段变成零时长。
- [ ] 运行目标 specs，确认失败点对应现有按条数、nonZeroDays 和 medicine/day 合并逻辑。

## Task 2 — Introduce a Shared Metric Value Contract

**Files:**

- Create: `Lucent/src/common/types/observed-metric.types.ts`
- Modify: `Lucent/src/common/index.ts`
- Modify: `Lucent/src/modules/today-suggestion/types/signal.types.ts`
- Modify: `Lucent/src/modules/reports/dashboard/metrics.types.ts`
- Modify: `Lucent/src/modules/today-analysis/services/pipeline/context.service.ts`
- Modify: `Lucent/src/modules/today-analysis/services/pipeline/context.service.spec.ts`

- [ ] 定义 `ObservedMetric<T>`：`value: T | null`、`state: observed|unknown`、`coverage`、`sources`、`observedCount`、`expectedCount`、`windowStart`、`windowEnd`。
- [ ] 不允许用 `value: 0` 表示 unknown；对无期望次数的饮水和睡眠，`expectedCount` 保持 null。
- [ ] Today suggestion signal、Report metrics 和 Today Analysis context 引用同一类型或同构 mapper，删除各自的隐式 null/zero 转换。
- [ ] 运行 typecheck 和 context spec，确保 enum/string literal 在模块间一致。

## Task 3 — Canonicalize Water to Milliliters

**Files:**

- Modify: `Lucent/src/modules/today-suggestion/services/collectors/record.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/record.service.spec.ts`
- Modify: `Lucent/src/modules/reports/dashboard/context.service.ts`
- Modify: `Lucent/src/modules/reports/dashboard/context.service.spec.ts`
- Modify: `Lucent/src/modules/reports/dashboard/computation.service.ts`
- Modify: `Lucent/src/modules/reports/dashboard/computation.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/rules/lifestyle/water-shortfall.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/rules/lifestyle/water-shortfall.service.spec.ts`

- [ ] 建立参数化测试覆盖 `ml`、`L` 和缺失/非法单位；合法值统一转为整数 ml，非法值计入 ignoredCount 而非零。
- [ ] Today collector 和 Report context 共用一个纯 mapper，删除按 water record count 计算摄入量的路径。
- [ ] Report computation 不再把无记录日加入 0L 平均值，也不以 `nonZeroDays` 排除用户明确记录的 0 ml。
- [ ] water-shortfall rule 只有 coverage sufficient 且目标来源明确时才有资格；partial/none 返回 abstain reason。
- [ ] 运行四组 specs，确认 Today、Report 和 rule 对相同 fixture 返回相同 ml 与 coverage。

## Task 4 — Preserve Medication Reminder Slots End to End

**Files:**

- Modify: `Lucent/src/modules/medicine-dose-logs/services/dose-logs.service.ts`
- Modify: `Lucent/src/modules/medicine-dose-logs/services/dose-logs.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/medication.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/medication.service.spec.ts`
- Modify: `Lucent/src/modules/reports/dashboard/context.service.ts`
- Modify: `Lucent/src/modules/reports/dashboard/context.service.spec.ts`
- Modify: `Lucent/src/modules/reports/dashboard/computation.service.ts`
- Modify: `Lucent/src/modules/reports/dashboard/computation.service.spec.ts`

- [ ] 先写两槽位矩阵测试：taken/taken、taken/skipped、taken/unconfirmed、skipped/unconfirmed、全 unknown。
- [ ] 统一 slot identity；有 reminder 时以 reminder/date/time 唯一，无 reminder 时每条临时 log 独立，不按 medicineId/day 合并。
- [ ] `planned` 在 UI/合同中映射为 `unconfirmed`；只有明确用户操作写 taken/skipped，系统不得自动把 planned 改为 missed。
- [ ] dashboard adherence 只在存在计划槽位时计算，分子为 taken，skipped 和 overdue-unconfirmed 各自保留计数；无计划返回 unknown。
- [ ] 运行 medicine dose、collector、dashboard specs，确认任一槽位状态不污染同药其他槽位。

## Task 5 — Represent Night Sleep and Naps as Episodes

**Files:**

- Modify: `Lucent/src/modules/daily-records/dto/create-record.dto.ts`
- Modify: `Lucent/src/modules/daily-records/dto/update-record.dto.ts`
- Modify: `Lucent/src/modules/daily-records/services/records.service.ts`
- Modify: `Lucent/src/modules/daily-records/services/records.service.spec.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/record.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/collectors/record.service.spec.ts`

- [ ] 为 sleep payload 增加 schema tests：`sleepType`、`startedAt`、`endedAt`、`durationMinutes`、可选 `quality`；结束必须晚于开始且 duration 容许明确的跨午夜。
- [ ] 在保持旧记录可读的 mapper 中，将现有 date/duration payload 迁为 `nightSleep` fallback，不回写历史数据。
- [ ] collector 分别返回 night total、nap total、all-sleep total 和 coverage；午睡不覆盖夜间睡眠。
- [ ] overlap 只标记 data-quality warning，不静默删除任一 episode。
- [ ] 运行 daily-record 和 collector specs，包含跨午夜夜睡与同日下午两段午睡。

## Task 6 — Expose Coverage and Sources Through OpenAPI

**Files:**

- Modify: `Lucent/src/modules/reports/dto/report-dashboard-response.dto.ts`
- Modify: `Lucent/src/modules/today-suggestion/dto/suggestion-response.dto.ts`
- Modify: `Lucent/src/modules/today-analysis/dto/analysis-response.dto.ts`
- Modify: `Lucent/docs/openapi.json` (generated)

- [ ] 为 water、medication、sleep DTO 增加同构 coverage/source/state 字段，并在 Swagger decorators 中枚举所有字面量。
- [ ] 保留旧 scalar 字段一个兼容周期，但标为 deprecated；新 Flutter 代码只读取 observed metric object。
- [ ] 运行 controller specs 和 `pnpm export:openapi`，人工检查 unknown 不会被 schema default 成 0。
- [ ] 在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`，确认生成类型保持 nullable 和 enum。

## Task 7 — Update Mobile Quick Entry and Domain Mappers

**Files:**

- Modify: `Luminous/lib/features/record/presentation/quick_entry/water_flow.dart`
- Modify: `Luminous/lib/features/record/application/usecases/quick_entry_sleep.dart`
- Modify: `Luminous/lib/features/record/presentation/quick_entry/sleep_flow.dart`
- Modify: `Luminous/lib/features/record/presentation/quick_entry/medication_flow.dart`
- Modify: `Luminous/lib/features/today/domain/entities/dashboard.dart`
- Modify: `Luminous/lib/features/report/domain/entities/dashboard.dart`
- Modify: `Luminous/lib/features/today/data/repositories/lucent.dart`
- Modify: `Luminous/lib/features/report/data/repositories/lucent.dart`
- Modify: `Luminous/test/record/quick_entry/water_flow_test.dart`
- Modify: `Luminous/test/record/quick_entry/sleep_flow_test.dart`
- Modify: `Luminous/test/record/quick_entry/medication_flow_test.dart`
- Modify: `Luminous/test/today/domain/entities/dashboard_test.dart`
- Modify: `Luminous/test/today/repository_test.dart`
- Modify: `Luminous/test/report/domain/entities/dashboard_test.dart`
- Modify: `Luminous/test/report/repository_test.dart`

- [ ] 先写 widget/use-case tests：饮水默认一键保存 ml 且可改容量；睡眠弹窗选择夜睡/午睡并可输入近似时长/质量；服药按具体槽位确认。
- [ ] water quick flow 只有服务端保存成功后才发布 DataChangeBus 和成功测量，不以打开/点击计成功。
- [ ] sleep use case 写 episode payload，不再用同日单条 identity 覆盖午睡。
- [ ] medication flow 必须携带 reminderId、scheduledFor、scheduledTime；找不到槽位时显示临时服药路径，不猜测最近提醒。
- [ ] Today/Report domain entity 显式表达 unknown、coverage、sources，移除 mapper 内 `null ?? 0`。
- [ ] 运行上述三个 feature 目录的目标测试。

## Task 8 — Make Health Platform Import Honest and Lossless

**Files:**

- Modify: `Luminous/lib/features/health_data/data/repositories/health_sync.dart`
- Modify: `Luminous/lib/features/health_data/data/mappers/health_record_mapper.dart`
- Modify: `Luminous/lib/features/health_data/presentation/providers/health_auto_sync.dart`
- Modify: `Luminous/lib/features/health_data/presentation/pages/health_sync.dart`
- Modify: `Luminous/test/health_data/health_sync_repository_test.dart`
- Modify: `Luminous/test/health_data/health_sync_providers_test.dart`

- [ ] 先写去重回归测试：同日同 source 的两次饮水和两个 sleep episode 都保留；同一 external ID 重试只保存一次。
- [ ] 指纹优先使用平台 external ID；没有时使用 kind/source/start/end/value/unit 的稳定 hash，不再使用 `kind|date|source`。
- [ ] 若 app 没有后台 executor 或平台能力不可验证，auto-sync provider 返回 `unsupported/notConfigured` 并禁用开关；不得只存一个本地 true。
- [ ] 页面显示具体可用性原因，不把 Apple Health/Health Connect 描述为所有手机可用。
- [ ] 运行 health_data 目标 tests，并在一台实际具备权限的设备上验证导入；未验证厂商保持 unsupported。

## Task 9 — Localization, Documentation, and Verification

**Files:**

- Modify: relevant fragments under `Luminous/lib/l10n/src/`
- Modify: `Luminous/docs/02-reference/Localization.md`
- Modify: `Lucent/docs/00-current/Active_Product_Loop.md`
- Modify: `Lucent/docs/00-current/TODO.md`
- Modify: `Luminous/docs/00-current/Active_UI_Record.md`
- Modify: `Luminous/docs/00-current/Active_UI_Report.md`
- Modify: `Luminous/docs/00-current/TODO.md`
- Append: implementation-date migration logs in both repositories

- [ ] 更新 source ARB fragments 后运行 `dart scripts/arb_tools.dart merge` 与 `flutter gen-l10n`；不直接编辑 `app_*.arb`。
- [ ] 在 Lucent 运行 `pnpm lint:check`、`pnpm typecheck`、`pnpm test`、`pnpm build`、`pnpm export:openapi`、`pnpm docs:check`。
- [ ] 在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`、`flutter analyze`、`flutter test`、`dart run scripts/check_doc_coverage.dart --warning-only`。
- [ ] 对同一 fixture 比较 Today、Suggestion、Review/Report 和 Clinic Summary 的 water ml、dose slots、sleep episodes 与 coverage，结果必须一致。
- [ ] 运行两个仓库的文档链接检查和 `git diff --check`，更新 current-state、迁移日志并删除已完成条目。
