# Review Experience Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 保留第五个一级入口和 `/report` 路由兼容，但把用户任务从通用报告迁为以健康事件为主单位的“回顾”，在稀疏数据下仍能回答发生了什么、有什么变化、完成了什么和接下来怎么办。

**Architecture:** Lucent 在现有 reports 模块内新增 event review read model，聚合 Health Event、check-ins、关联记录、dose slots 和 coverage，不创建第二份健康事实。Luminous 暂时保留 `features/report` 目录与 `/report` 路由以降低迁移风险，新增 Review domain entity 和 event-first widgets，逐步停止旧 dashboard 作为首屏。导出和就诊摘要仅作为 More action 链接存在。

**Tech Stack:** NestJS/Prisma/OpenAPI/Jest、Flutter/Riverpod/GoRouter/Freezed/Forui、Flutter widget and golden tests。

---

**Start gate:** 只有[总计划](2026-08-07-product-loop-program.md)中的健康事件、主动重算和稀疏口径三个 checkpoint 已满足，才把第五 Tab 切到新 Review read model。

## Review Contract

- 主单位是一个 health event；时间范围只作为历史筛选，不是首屏必选项。
- 四段固定结构：`whatHappened`、`keyChanges`、`completedActions`、`nextStep`。
- 每一段可独立 available/unknown；任一维度缺失不得锁住整页。
- `keyChanges` 只描述观察到的变化和覆盖率，不宣称药物导致康复或症状因某行为恶化。
- active 事件显示进行中状态和今日 check-in；ended 事件显示用户确认的 outcome。
- 无事件时展示最近已结束事件和可选轻量周回顾；没有足够事实时不生成泛化 AI 文本。

## Task 1 — Add Event Review DTO and Read Service Tests

**Files:**

- Create: `Lucent/src/modules/reports/dto/event-review-response.dto.ts`
- Create: `Lucent/src/modules/reports/dto/event-review-list-query.dto.ts`
- Create: `Lucent/src/modules/reports/services/event-review/review.service.ts`
- Create: `Lucent/src/modules/reports/services/event-review/review.service.spec.ts`
- Modify: `Lucent/src/modules/reports/reports.module.ts`

- [ ] 先写 service spec，固定 active、ended、partial data、no event、foreign event 五种场景。
- [ ] DTO 定义 event identity/status/window/outcome、四段 section、coverage summary、source timestamps 和 available actions。
- [ ] 每个 section 使用 `state: available|unknown`；unknown 带固定 reason code，不返回编造 copy。
- [ ] service 只读 Health Events 所有权服务、daily records、dose logs 和统一 observed metrics；不复制聚合口径。
- [ ] foreign event 返回 not found；soft-deleted records 不参与回顾。
- [ ] 运行 review service spec，确认稀疏 fixture 仍返回事件事实而不是整体 not-ready。

## Task 2 — Build the Four Review Sections

**Files:**

- Create: `Lucent/src/modules/reports/services/event-review/facts.service.ts`
- Create: `Lucent/src/modules/reports/services/event-review/facts.service.spec.ts`
- Create: `Lucent/src/modules/reports/services/event-review/changes.service.ts`
- Create: `Lucent/src/modules/reports/services/event-review/changes.service.spec.ts`
- Create: `Lucent/src/modules/reports/services/event-review/actions.service.ts`
- Create: `Lucent/src/modules/reports/services/event-review/actions.service.spec.ts`
- Create: `Lucent/src/modules/reports/services/event-review/next-step.service.ts`
- Create: `Lucent/src/modules/reports/services/event-review/next-step.service.spec.ts`

- [ ] `facts` 测试覆盖事件起止、用户标题、关联症状次数、关联药物和 check-in 数；不输出自由文本 note。
- [ ] `changes` 测试覆盖 improved/unchanged/worsened check-in 序列、water/sleep 单维趋势和 insufficient coverage；只输出事实性 change code + 参数。
- [ ] `actions` 测试按 dose slot 统计 confirmed/skipped/unconfirmed，并列出用户已完成的 check-in；不把 unconfirmed 算失败。
- [ ] `next-step` 使用固定规则：active 且今日未 check-in → 提醒确认；ended → 显示结果和可选就诊摘要；red flag 只复用已审核静态安全规则。
- [ ] section service 返回结构化 code/arguments，由 Luminous 本地化；首阶段不使用 LLM 填补未知 section。
- [ ] 运行四个 specs，检查每个 unknown 都有明确 coverage/reason。

## Task 3 — Add Review Endpoints Without Breaking Report Compatibility

**Files:**

- Modify: `Lucent/src/modules/reports/reports.controller.ts`
- Modify: `Lucent/src/modules/reports/reports.controller.spec.ts`
- Modify: `Lucent/src/modules/reports/index.ts`
- Modify: `Lucent/docs/openapi.json` (generated)

- [ ] 先写 controller tests：`GET /reports/reviews/current`、`GET /reports/reviews`、`GET /reports/reviews/:eventId`。
- [ ] current 优先返回 active event，否则最近 ended event；没有事件返回空 envelope，不返回 404 页面错误。
- [ ] list 支持 cursor 和 status，不把 7/30 天作为默认 contract；event detail 只按 event ID。
- [ ] 保留现有 dashboard endpoints 一个兼容周期，不把它们用于新第五 Tab 首屏。
- [ ] 运行 reports controller spec 和 `pnpm export:openapi`；检查旧 endpoint 未意外删除。

## Task 4 — Add Flutter Review Domain and Repository

**Files:**

- Create: `Luminous/lib/features/report/domain/entities/review.dart`
- Create: `Luminous/lib/features/report/domain/repositories/review.dart`
- Create: `Luminous/lib/features/report/data/repositories/lucent_review.dart`
- Create: `Luminous/lib/features/report/data/providers/review.dart`
- Create: `Luminous/lib/features/report/presentation/providers/review.dart`
- Create: `Luminous/test/report/lucent_review_repository_test.dart`
- Create: `Luminous/test/report/review_provider_test.dart`

- [ ] 先运行 `dart run scripts/bootstrap_generated_sources.dart`，再写 mapper tests；不直接修改 generated client。
- [ ] Freezed entity 保留 section state、reason code、coverage 和 source，不把 unknown mapper 成空列表或 0。
- [ ] repository 支持 current/list/detail；provider 以 current event 为主并缓存最近历史列表。
- [ ] 失败时保留最后成功 review 并提供 retry；切换 event ID 时取消旧请求或丢弃旧结果。
- [ ] 运行两个目标 test files。

## Task 5 — Rename the User Task While Preserving the Route

**Files:**

- Modify: `Luminous/lib/app/router.dart`
- Modify: `Luminous/lib/features/report/presentation/pages/page.dart`
- Modify: `Luminous/lib/l10n/src/report_zh.arb`
- Modify: `Luminous/lib/l10n/src/report_en.arb`
- Modify: `Luminous/docs/02-reference/Localization.md`
- Modify: `Luminous/test/app/router_test.dart`
- Modify: `Luminous/test/shell/tab_test.dart`

- [ ] 先写 navigation test：第五 Tab 标签显示“回顾/Review”，`/report` 仍解析到同一个 shell branch，已有 deep link 不重定向失败。
- [ ] 只改用户可见任务名，不大范围重命名 feature 目录、route class 或 telemetry key；代码层重命名留到兼容期结束后评估。
- [ ] 页面 app bar 与 accessibility semantics 使用 Review 文案，旧 Report 文案只保留在导出/历史兼容上下文。
- [ ] 编辑 source ARB fragments，运行 merge 与 gen-l10n，再运行 navigation tests。

## Task 6 — Build the Event-First Mobile View

**Files:**

- Create: `Luminous/lib/features/report/presentation/widgets/views/review_view.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/event_header.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/what_happened.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/key_changes.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/completed_actions.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/next_step.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sections/review_history.dart`
- Create: `Luminous/test/report/widgets/review_view_test.dart`
- Create: `Luminous/test/report/widgets/event_header_test.dart`
- Create: `Luminous/test/report/widgets/review_sections_test.dart`
- Modify: `Luminous/lib/features/report/presentation/pages/page.dart`

- [ ] 先写 widget tests：active、ended、partial、no-event、error-with-cache、loading 六种状态。
- [ ] 首屏按四段顺序渲染；unknown section 显示简短缺失原因，不显示 0 分或“需关注”红色状态。
- [ ] active event header 提供今日 check-in；ended event header 显示 outcome；history 在下方按事件而非按月份组织。
- [ ] no-event 显示最近事件和“开始健康观察”入口；完全没有事件时提供轻量解释，不自动生成周报。
- [ ] 使用移动端约束完成布局；不新增桌面专属 breakpoint 或 sidebar 对等实现。
- [ ] 运行 review view 和各 section widget tests。

## Task 10 — Full Verification and Documentation

**Files:**

- Modify: `Lucent/docs/00-current/Active_Product_Loop.md`
- Modify: `Lucent/docs/00-current/TODO.md`
- Append: implementation-date file under `Lucent/docs/02-logs/migration-log/`
- Modify: `Luminous/docs/00-current/Active_UI_Report.md`
- Modify: `Luminous/docs/00-current/Active_Mobile_UI.md`
- Modify: `Luminous/docs/00-current/TODO.md`
- Modify: `Luminous/ROADMAP.md`
- Append: implementation-date file under `Luminous/docs/03-logs/migration-log/`

- [ ] 在 Lucent 运行 `pnpm lint:check`、`pnpm typecheck`、`pnpm test`、`pnpm build`、`pnpm export:openapi`、`pnpm docs:check`。
- [ ] 在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`、`flutter analyze`、`flutter test`、`dart run scripts/run_daily_checks.dart`、`dart run scripts/check_doc_coverage.dart --warning-only`。
- [ ] 运行两个仓库的文档链接检查和 `git diff --check`。
- [ ] 文档明确 `/report` 是兼容路由、用户任务是 Review、桌面/Web 未做功能对等、旧 dashboard 代码尚未删除。
- [ ] 删除已完成的 Review/Report migration 条目，保留仍未验证的产品假设为后续工作。
