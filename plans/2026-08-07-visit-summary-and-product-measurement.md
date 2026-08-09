# Visit Summary and Product Measurement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 把就诊摘要、PDF 和分享降级为“回顾 > 更多”中的可选工具，同时用不包含健康内容的最小行为信号验证事件—建议—回顾闭环是否真实发生。

**Architecture:** Clinic Summary 继续属于 Lucent reports 模块，但使用 event/date scope、字段选择和可撤销 share record，而不是静态 profile 拼接与临时 cache。产品行为事件进入独立低敏表，只接收固定 event name、surface、success 和有限枚举，不接收症状、药名、note、URL token 或自由文本。Luminous 只在用户真实看到或操作成功后上报，不以按钮点击预先计成功。

**Tech Stack:** NestJS、Prisma/PostgreSQL、Redis、PDF queue、OpenAPI、Jest、Flutter/Riverpod、Flutter tests。

---

**Start gate:** 只有[总计划](2026-08-07-product-loop-program.md)中的 Review primary path 已完成并通过内部验证，才实施本文件；导出与分享不得反向阻塞核心闭环发布。

## Measurement Boundary

允许的产品事件：

- `health_event_started`
- `health_event_ended`
- `health_event_outcome_confirmed`
- `suggestion_impression`
- `suggestion_actioned`
- `review_opened`
- `visit_summary_previewed`
- `visit_summary_exported`
- `visit_summary_share_created`
- `visit_summary_share_opened`
- `visit_summary_share_revoked`

允许属性只有 `surface`、`result`、`eventStatus`、`suggestionRuleCode`、`appVersion`、`platform`、`occurredAt`。禁止属性包括 symptom/title/note/medicineName、记录 value、PDF URL、share token、设备广告 ID 和任意自由文本。

原始产品事件保留 90 天后删除；只保留不含 userId 的按日聚合。账户删除时立即删除该用户尚未过期的原始产品事件。

## Task 1 — Lock Down Existing Clinic Summary Defects With Tests

**Files:**

- Modify: `Lucent/src/modules/reports/services/clinic-summary/summary.service.spec.ts`
- Modify: `Lucent/src/modules/reports/reports.controller.spec.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/pdf.service.spec.ts`

- [ ] 增加失败测试：请求 7 天不得返回 `last_30_days`；findings 从真实 event review/metrics 生成而不是永远空；water/dose/sleep 使用统一 coverage。
- [ ] 增加失败测试：share URL 必须包含实际公开 controller 路由 `/user/reports/clinic-summary/shared/:token`。
- [ ] 增加失败测试：取消选择的字段不得进入 preview、PDF 或 shared response。
- [ ] 增加失败测试：过期或撤销 token 返回 not found；成功打开记录 accessedAt/accessCount。
- [ ] 运行三个 spec 文件，确认每个已知缺口有独立失败用例。

## Task 2 — Persist Revocable Clinic Shares

**Files:**

- Modify: `Lucent/prisma/schema.prisma`
- Modify: migration output under `Lucent/prisma/migrations/` created with migration name `persist_clinic_summary_shares`
- Create: `Lucent/src/modules/reports/services/clinic-summary/share.service.ts`
- Create: `Lucent/src/modules/reports/services/clinic-summary/share.service.spec.ts`
- Modify: `Lucent/src/modules/reports/reports.module.ts`

- [ ] 新增 `UserClinicSummaryShare`：userId、tokenHash、eventId/dateFrom/dateTo、selectedFields、expiresAt、revokedAt、firstAccessedAt、lastAccessedAt、accessCount、createdAt；数据库不保存明文 token。
- [ ] 先写 share service specs：创建时只返回一次明文 token；读取使用 hash；过期/撤销拒绝；访问计数原子递增；用户只能撤销自己的 share。
- [ ] `selectedFields` 只接受固定 enum 数组，拒绝未知字段和空选择。
- [ ] share response 每次从当前授权范围构建；不得把完整摘要 JSON 永久缓存成绕过字段控制的副本。
- [ ] 运行 Prisma generate 和 share service specs。

## Task 3 — Make the Visit Summary Problem-Oriented

**Files:**

- Modify: `Lucent/src/modules/reports/dto/clinic-summary-response.dto.ts`
- Create: `Lucent/src/modules/reports/dto/clinic-summary-request.dto.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/summary.service.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/summary.service.spec.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/pdf.service.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/pdf.service.spec.ts`

- [ ] request DTO 允许二选一 scope：`eventId` 或 `dateFrom/dateTo`；event scope 优先，日期范围限制在产品既有安全上限。
- [ ] response 明确 `scopeLabel`、真实 start/end、selectedFields、coverage、generatedAt；移除硬编码 `last_30_days`。
- [ ] findings 只复用 event review 的结构化事实与 change code；coverage 不足时输出“资料不足”，不补泛化 AI 结论。
- [ ] preview、PDF、share 使用同一个 selected-field view model，避免三个路径字段漂移。
- [ ] PDF 页脚说明资料来自用户记录、可能不完整、不能代替诊断；不声称医生已查看。
- [ ] 运行 summary/pdf specs，比较同一 request 三个输出路径的字段集合。

## Task 4 — Correct and Extend the HTTP API

**Files:**

- Modify: `Lucent/src/modules/reports/reports.controller.ts`
- Modify: `Lucent/src/modules/reports/reports.controller.spec.ts`
- Modify: `Lucent/docs/openapi.json` (generated)

- [ ] preview/share/export endpoints 使用同一 request DTO；公开读取 endpoint 保持无需登录但只凭高熵 token。
- [ ] 新增 `DELETE /reports/clinic-summary/shares/:shareId`，按当前 user 撤销。
- [ ] share create 返回正确 `/user/reports/clinic-summary/shared/:token` URL；base URL 使用现有配置，不硬编码域名。
- [ ] shared GET 成功后记录访问；PDF GET 也记录访问且不重复泄露 token 到结构化日志。
- [ ] 运行 controller specs 与 `pnpm export:openapi`，检查 public/private auth decorators 正确。

## Task 5 — Add a Privacy-Minimal Product Event Store

**Files:**

- Modify: `Lucent/prisma/schema.prisma`
- Modify: migration output under `Lucent/prisma/migrations/` created with migration name `add_product_events`
- Create: `Lucent/src/modules/product-events/product-events.module.ts`
- Create: `Lucent/src/modules/product-events/product-events.controller.ts`
- Create: `Lucent/src/modules/product-events/index.ts`
- Create: `Lucent/src/modules/product-events/dto/create-product-event.dto.ts`
- Create: `Lucent/src/modules/product-events/services/events.service.ts`
- Create: `Lucent/src/modules/product-events/services/events.service.spec.ts`
- Modify: `Lucent/src/app.module.ts`

- [ ] 新增 `UserProductEvent`：id、userId、name enum、surface enum、result enum、eventStatus nullable、suggestionRuleCode nullable、appVersion、platform enum、occurredAt、createdAt；不提供 metadata JSON。
- [ ] 先写 DTO/service tests：只允许白名单字段；额外字段在 validation whitelist 下被拒绝；批量上报有条数限制；同一 client event ID 幂等。
- [ ] 对 `suggestionRuleCode` 只允许服务端 registry 中已知的非敏感 rule code，不接受自由字符串。
- [ ] controller 只接受当前登录用户，不允许 client 提交 userId；保留策略与现有隐私删除流程绑定。
- [ ] 模块只写原始事件，不在请求内做昂贵聚合；运行 service/controller specs。

## Task 6 — Emit Server-Authoritative Events

**Files:**

- Modify: `Lucent/src/modules/health-events/services/events.service.ts`
- Modify: `Lucent/src/modules/health-events/services/check-ins.service.ts`
- Modify: `Lucent/src/modules/today-suggestion/services/feedback/recorder.service.ts`
- Modify: `Lucent/src/modules/reports/services/clinic-summary/share.service.ts`
- Modify: corresponding co-located spec files

- [ ] health event start/end/outcome 只由成功事务后的服务端路径记录；客户端不得重复上报这些权威事件。
- [ ] suggestion actioned 只在 feedback/action 写入成功后记录，包含固定 rule code，不包含 suggestion copy。
- [ ] share created/opened/revoked 由 share service 记录；公开打开的事件归属 share owner，但不保存访问者 IP 到 product event。
- [ ] 产品事件写入失败只记录低敏错误并计 metric，不回滚用户主操作。
- [ ] 运行所有对应 service specs，确认主事务失败时不记录成功事件。

## Task 7 — Add Client Measurement at Actual Success Boundaries

**Files:**

- Create: `Luminous/lib/core/analytics/product_event.dart`
- Create: `Luminous/lib/core/analytics/product_event_service.dart`
- Create: `Luminous/test/core/analytics/product_event_service_test.dart`
- Modify: `Luminous/lib/features/today/presentation/widgets/sections/suggestion_primary_card.dart`
- Modify: `Luminous/lib/features/report/presentation/pages/page.dart`
- Modify: `Luminous/lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`
- Modify: `Luminous/lib/features/report/presentation/widgets/sections/export.dart`
- Modify: `Luminous/test/today/suggestion_section_test.dart`
- Modify: `Luminous/test/report/page_test.dart`
- Modify: `Luminous/test/report/clinic_summary_provider_test.dart`

- [ ] 定义封闭 `ProductEvent` union 和 typed properties，不提供 `Map<String, dynamic>` 公共入口。
- [ ] impression 只在卡片进入可见区域且本 session 尚未记录时上报；build/rebuild 不重复计数。
- [ ] review_opened 在 review 数据实际呈现后记录，不在导航点击时记录。
- [ ] preview/export 只在服务端成功响应后记录；失败记录 `result: failure`，不得计为 exported。
- [ ] 离线事件进入现有安全同步队列，重试使用 client event ID 幂等；队列 payload 通过测试证明不含禁止字段。
- [ ] 运行 core analytics 和相关 widget tests。

## Task 8 — Add Field-Level Privacy UI and Share Revocation

**Files:**

- Modify: `Luminous/lib/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`
- Modify: `Luminous/lib/features/report/presentation/widgets/shared/clinic_summary_content.dart`
- Create: `Luminous/lib/features/report/presentation/widgets/sheets/share_management.dart`
- Modify: `Luminous/lib/features/report/presentation/providers/clinic_summary.dart`
- Modify: `Luminous/test/report/clinic_summary_content_test.dart`
- Modify: `Luminous/test/report/clinic_summary_provider_test.dart`
- Create: `Luminous/test/report/share_management_test.dart`

- [ ] 先写 widget tests：用户可逐项选择事件概况、症状变化、用药槽位、饮水、睡眠、备注；默认不选择自由文本备注。
- [ ] preview 根据选择即时更新，未选择字段在 request、PDF、share 中都不存在。
- [ ] 创建 share 前明确显示到期时间和“链接持有者可查看”；创建后提供复制与撤销，不暗示医生已收到。
- [ ] share management 显示 created/expires/access count/last accessed，不显示访问者身份推断。
- [ ] 运行 clinic summary 和 share management widget tests。

## Task 9 — Define the First Product Loop Queries

**Files:**

- Create: `Lucent/src/modules/product-events/services/funnel.service.ts`
- Create: `Lucent/src/modules/product-events/services/funnel.service.spec.ts`
- Create: `Lucent/src/modules/product-events/dto/funnel-response.dto.ts`
- Modify: `Lucent/src/modules/product-events/product-events.controller.ts`

- [ ] 只为内部管理员提供聚合 endpoint；复用现有 admin guard，不开放逐用户事件列表。
- [ ] 输出按天聚合的 event started → suggestion impression/actioned → event ended/outcome → review opened；小样本低于固定阈值时不返回分组细节。
- [ ] 单独输出 optional visit summary preview/export/share/open，不把它作为核心漏斗成功条件。
- [ ] 测试跨用户聚合、日期范围上限、无健康内容字段和未授权拒绝。
- [ ] 记录率指标以保存成功为分子，不再使用 quick-entry tap count。

## Task 10 — Security, Retention, Verification, and Documentation

**Files:**

- Create: `Lucent/docs/01-reference/data-retention.md`
- Modify: `Lucent/docs/README.md`
- Modify: `Lucent/docs/00-current/Active_Product_Loop.md`
- Modify: `Lucent/docs/00-current/TODO.md`
- Append: implementation-date file under `Lucent/docs/02-logs/migration-log/`
- Modify: `Luminous/docs/01-product/Product_Safety_Privacy.md`
- Modify: `Luminous/docs/00-current/Active_UI_Report.md`
- Modify: `Luminous/docs/00-current/TODO.md`
- Append: implementation-date file under `Luminous/docs/03-logs/migration-log/`

- [ ] 将 product-event retention 和 account deletion 行为写入 `data-retention.md`，并从 `Lucent/docs/README.md` 链接该文档。
- [ ] 运行安全测试，确认 logs、Sentry breadcrumbs、metrics labels 和 product events 均不出现明文 token、症状、药名或 note。
- [ ] 在 Lucent 运行 `pnpm lint:check`、`pnpm typecheck`、`pnpm test`、`pnpm build`、`pnpm export:openapi`、`pnpm docs:check`。
- [ ] 在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`、`flutter analyze`、`flutter test`、`dart run scripts/run_daily_checks.dart`、`dart run scripts/check_doc_coverage.dart --warning-only`。
- [ ] 集成验证 preview → selected fields → PDF → share → public open → access count → revoke；撤销后 Web/PDF 均不可访问。
- [ ] 对一个测试事件验证核心漏斗与 optional export 指标分别统计，导出为零不影响核心闭环成功。
- [ ] 运行两个仓库文档链接检查和 `git diff --check`，更新 current-state、迁移日志和剩余工作。
