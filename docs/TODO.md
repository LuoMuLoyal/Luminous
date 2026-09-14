---
status: active
owner: frontend
quadrant: reference
updated: 2026-09-14
---

# Luminous TODO

Last updated: 2026-09-14

本文件记录仍缺失或被故意门控的工作。当前实现状态以代码与 `flutter test` 为准；规划以 `plans/` 为准。

## 产品闭环（程序已收口，仅剩延后项）

Product Loop Program（历史决策见已被新产品方向取代的 `0007-event-led-sparse-record-product-loop.md`）已实施完毕，
计划文件已删：健康事件、主动建议、稀疏记录语义、事件优先回顾与隐私克制的闭环测量全部落地，
就诊摘要支持字段级隐私选择与可撤销分享。以下为延后项。

### 平台与验证

- 手机端继续承担当前首发与用户验证；0.1.0 后启动独立 Next.js + Tauri 桌面工作台 MVP，不承诺与手机端功能对等

- 原始健康数据可移植性导出
  - 当前仅能导出就诊报告 PDF；原始 JSON/CSV 导出另行立项，不能继续用 PDF 宣称数据可移植性

- 产品事件漏斗的受保护运营报表
  - 现有聚合 API 暂无消费面；0.1.0 后先做周报或简表，不建设实时 Admin Dashboard

- 纯数字药品查询的精确匹配
  - 当前前后端均不追加不可靠的数字特判；待有可验证的条码/批准文号语义后再立项

- 微博与 Google OAuth 图标
  - 修复登录页两者的图标显示问题

## 2026-09-08 Review 页重组后置依赖登记（Review Page Restructure 波次）

Review 页重组（洞察优先 + 覆盖感知）客户端侧已收口，以下为不在本期客户端范围的
后置依赖，仅登记跟踪；落地后做一次 Wave 2 客户端适配并删除本条。

- Review 洞察的预置上下文入口（agentic 计划承接）
  - 现状：顶栏 [问助手] 为通用 `/assistant` 入口（与 today 同语义），不携带
    「看这个趋势 / 就此回顾问助手」的预置上下文
  - 待 agentic 计划 P1-1/P1-3 预置上下文能力就绪后升级入口，并复核 `ai_summary` /
    `suggestion_history` 组件（P0-7 deferred 标注）是否归档或改在主路径重新启用
- Lucent observed-metric 域迁移（target 2026 Q4）后的 Wave 2 客户端适配
  - 现状：dashboard 维度仅 medication/water/sleep/general；趋势逐日 values 是
    legacy scalar 投影，客户端无法区分「空档=无记录」与「0」；findings/patterns
    无证据引用（record id/日期）与反馈通道
  - 期望：维度扩展（mood/symptom/meal/activity）、逐日 presence（recorded: bool）、
    findings 证据引用与反馈字段；Lucent 侧 contract 变化后 `pnpm export:openapi`
    （Lucent）→ `dart run scripts/contract/bootstrap.dart`（Luminous）→ 按新实体改
    mapper 与 UI（替换 legacy scalar 趋势渲染、趋势空档可视化、证据展开、反馈）

## 2026-09-06 OAuth 登入门槛调整（UI 隐藏 / 全链路移除待办）

- 微信登录与微信身份绑定入口已在 UI 层面隐藏（登录页 `OAuthButtonRow` 与账号设置页
  `LinkedIdentitiesSection`），底层流程与代码全部保留，后续恢复只需改回显示参数。
  - 微信开放平台「网站应用」需企业认证（300 元/年），当前无企业资质故隐藏；
    待有资质后恢复入口并配置 `WECHAT_WEB_*` / `WECHAT_MOBILE_*` 环境变量
- 微博登录入口已在 UI 层面隐藏（登录页 `OAuthButtonRow`），底层流程保留。
  - **全链路移除（未做，保留待办）**：微博不够主流，计划后续彻底删除——
    - Lucent：`src/modules/auth/providers/weibo-oauth.provider.ts`、`oauth.controller.ts`
      的 weibo 端点、`oauth.dto.ts` 的 weibo schema、`oauth.config.ts` 的 weibo 项、
      `EnvKey.WEIBO_*` 环境变量、`state.service.ts` 的 weibo 回跳路径、相关测试；
      重新导出 OpenAPI 并同步 `Lucent/docs/reference/environment-variables.md`
    - Luminous：登录页 `OAuthButtonRow` 的 weibo 按钮/回调区、`oauth_panels.dart` 的
      `OAuthBrandColors.weibo` 与 `showWeibo` 参数、`oauth_login.dart` 的
      `startWeiboLogin` / `completeWeiboLogin`、`auth.dart` 域仓储与数据源的 weibo 方法、
      路由 `/login/oauth/weibo`、l10n fragment 的 `authWeibo*` 文案、`assets/icon/oauth/weibo.svg`、
      相关测试；重新生成 API client 与 l10n

## 延后（有明确原因）

- Review 建议历史与 AI 摘要主路径下线（Review Page Restructure P0-7）
  - `sections/suggestion_history.dart`（`ReviewSuggestionHistorySection` /
    `dedupeTodaySuggestions`）、`sections/ai_summary.dart`
    （`ReviewAiSummarySection`）、`dialogs/suggestion_history_detail_sheet.dart`
    仍被 legacy dashboard 兼容页消费（`legacy_dashboard_compat.dart` /
    `dashboard_view.dart`），有保留价值故不删除；`aiSummariesEnabled` 设置语义
    不变（Today 摘要仍受其门控）
  - 待 agentic 计划统一 AI 数据层（P0-3）后复核是否归档或改在主路径重新启用

- 药箱项「停用/归档」语义（F-2，0.1.0 后）
  - 现状：药箱项只能软删除，短期事件结束后「停药」会丢可见性
  - 方案：增加停用/归档状态，保留历史不出现在当前用药；涉及 health-context API 与药箱 UI
  - 依据：用药改造计划 3.3 节 F-2 与 2026-08-16 决策记录「处方 OCR、药箱停用/归档语义增强均为 0.1.0 后事项」；0.1.0 后按既有 P0→P1→P2 与全局依赖顺序恢复

- Flutter 3.47.1 升级（analyze/APK/Web 已通过，全量测试被语义回归阻塞）
  - 当前 `refactor` 已含全部配置类改动：fluwx 6.0.2 / health 13.3.2 / jpush 3.5.1、AGP 9.1.0 + Gradle 9.3.1 + built-in Kotlin、iOS 15.0 / macOS 12.0 部署目标、CI 版本、`LUMOS_GRADLE_MIRROR=aliyun` 镜像兜底（默认关闭）
  - 阻塞：flutter/flutter#191095 semantics 回归（MergeSemantics 嵌套兄弟 merge 组断言）在 3.47.1 上仍可复现；analyze、Android release、Web release 已通过，待上游修复后重跑全量测试再合并

- forui 0.25.0 toast dismiss 的 dispose-during-notifyListeners 风险
  - 现象：`FToasterEntry.dismiss()` 在 toast 入场动画完成前触发时，forui 非无障碍分支直接 `reverse()`，
    同步走到 dismissed 状态后在通知期间 `dispose()`（无障碍分支用 microtask 规避了同样问题）
  - 影响：连续 `Toast.show` 时旧 toast 可能在入场完成前被 dismiss，调试构建可能触发断言
  - 现状：toast 测试通过先完成入场动画规避；生产未复现，暂不处理，后续升级 forui 时留意
- AI 来源条元数据后端投影（F-14/F-15，0.1.0 后）
  - 现状：来源条组件与前端字段（confidenceNote/sourceVersion）已就绪；Lucent 的 `buildToolDetails` 尚未把摘要工具的 `confidenceNote`/`sourceVersion` 与说明书的批准文号/更新时间投影进 SSE `toolDetails`，前端「数据截至」行与元数据行待数据到达后自动生效
  - 依据：assistant 改造计划 F-14/F-15 P2 子项（实施完毕文件已删）；0.1.0 后按既有顺序恢复

- 助手记忆擦除入口与联动（F-9/F-2 遗留，0.1.0 后）
  - 现状：Lucent `DELETE /assistant/memory` 已就绪（全量擦除）；设置页尚无入口；删除会话不联动清理该会话记忆；`activateConversation` 路径不触发记忆提取（仅「新对话」触发）
  - 方案：设置页 AI 区接入擦除按钮；会话删除时清理其 `AssistantMemory`；激活路径补提取调度

- 助手重生与确认并发线程锁（0.1.0 后）
  - 现状：LangGraph time travel 重生与 confirm（HITL 挂起）并发操作同一线程时无 per-thread 锁，极端并发下可能状态竞争
  - 方案：为 regenerate/confirm 路径加 per-thread 互斥

- `lucent_dashboard.dart` 的 `// ignore_for_file: deprecated_member_use` 与 Q4 observed-metric 迁移强绑定
  - 现状：dashboard 维度仅 medication/water/sleep/general；趋势逐日 values 是 legacy scalar 投影，客户端无法区分「空档=无记录」与「0」；`coverage_strip.dart` 使用 `ReviewObservedMetricCoverage` 枚举消费该投影
  - 目标：2026 Q4 Lucent observed-metric 域迁移后删除 ignore，`coverage_strip.dart` 调用点同步调整
  - 跟踪：`// tracked-by-TODO-ignore-deprecated-metric-migration`

## 2026-08-20 Mine settings P2-1 deferred follow-up

- Lucent `AuthTokenService.listSessions()` 当前将每条会话的 `isCurrent` 固定为 `false`，Luminous 已实现收到 `isCurrent=true` 时撤销后登出的分支，但当前设备无法在会话列表中被标识；后续需在不暴露 refresh token 的前提下补齐服务端当前会话识别。

## 2026-08-23 网络层收口审查遗留（错误迁移 Task 1）

- RetryInterceptor 链级 `retryAfter` 断言缺失：`retryable=false` 已有链级测试证明映射到达策略层，`retryAfter` 延迟优先级仅由 RetryPolicy 单测覆盖；补链级用例需真实计时（易抖），暂缓。
- 畸形错误体端到端暴露形态：畸形 401/503 body 最终以 `DioException(error: FormatException)` 暴露（dio 归一化既有行为）；Auth/Retry 已保证不崩溃且 401 清 session 语义正确，端到端暴露形态属既有设计，后续任务跟踪。

## 2026-08-23 认证迁移审查遗留（错误迁移 Task 2）

- `auth/presentation/providers/sessions.dart` `_revokeFailure` 用 `StackTrace.current` 构造 AsyncError（旧代码保留真实堆栈）：LucentFailure.cause 已携带原 DioException，可调试；真实堆栈透传需在 TaskEither Left 上携带 stackTrace（跨任务架构决策），暂缓，清理旧类型时一并评估。
- `_resolve` 适配器在 `account.dart`/`oauth_login.dart`/`wechat_oauth.dart` 三处重复（4 行同构）：风格级，暂不抽取公共 helper。


## 2026-08-23 scan 迁移审查遗留（错误迁移 Task 4b）

- box_scan AI 流（uploadImage/recognizeMedicine/search 任一 Left → 失败弹窗）无独立 widget 测试：AI 路径涉及真实文件 I/O，按既有排除清单不在 widget 测试覆盖内，仅 repository 层覆盖；如需补需先拆文件 I/O。
- 两页对 network/business 失败展示同一通用文案（分类仅在日志）：迁移前既有行为；未来可考虑按 kind 区分文案（如 auth 失败引导登录）。
- box_scan OCR 路径单个候选 search Left 会中断候选循环（不继续其余候选）：迁移前既有行为，可选优化为跳过失败候选。
- 非 problem+json 错误体导致的 FormatException 从 `.run()` 逃逸时无 repository 层日志（由页面 catch 记录）：mapper 既有行为，页面通用 catch 已吸收，无未处理异常。

## 2026-08-23 legal 迁移审查遗留（错误迁移 Task 5c）

- `legal_list_page_test.dart` `pumpPage` 的 `Object? error` 参数现仅作 null 判定标志（传入值被丢弃）：纯遗留装饰，可改 `bool fail`，非必须。

## 2026-08-23 SSE 迁移审查遗留（错误迁移 Task 7）

- `NetworkErrorCode.invalidSsePayload` 运行时已无产生点（枚举 + l10n + pending sync 序列化保留以兼容历史持久化行）：若未来清理 legacy pending-sync 数据后可评估移除。
- `_ErrorSseAdapter` 测试辅助类在 assistant/today/report 三个测试文件各复制一份（沿用每文件自带惯例）：可选收敛到 test/helpers/。

## 2026-09-11 上传链路与主题信号遗留

- `scan` 的 `recognizeMedicine` 仍手写 Dio 解析（等后端补响应 schema）
  - 现状：`uploadImage` 已改走类型化 `files/upload` + 共享直传（见当日迁移日志）；但
    `POST /medicines/recognize` 在 OpenAPI 里同样没有响应 schema，客户端仍手写 Dio +
    `coerceToStringMap` 解 `name` / `approvalNumber`，协议违例只能抛 `StateError` 归
    `Left(unknown)`（`lib/features/scan/data/repositories/scan.dart`）
  - 前置：Lucent 为该端点注册响应 schema 并 `pnpm export:openapi`（已登记在 Lucent `docs/TODO.md`）
  - 方案：契约齐了之后换成类型化客户端，并评估 `lib/core/network/map_utils.dart` 是否还有消费方

- 对象存储的孤儿对象清理（跨仓）
  - 现状：`/user/files/upload` 只签发上传凭证，后端没有删除对象的端点；用户上传头像/附件后放弃
    保存、或替换旧头像，对象会永久留在 bucket 里
  - 方案：Lucent 增加对象删除能力（或将前缀 + 时间的生命周期回收交给存储后端），客户端在
    「替换/移除」路径调用（已登记在 Lucent `docs/TODO.md`）

- `Theme.of(context).brightness` 在本应用深色下恒为 light
  - 现象：应用根是 `material_ui` 的 `MaterialApp`，它的 `Theme` 不是 `flutter/material` 的
    `Theme.of` 能取到的那一个；`material_ui` 自己的 `Theme.of` 与 Forui 的
    `context.theme.colors.brightness` 都正常报 dark（一次性探针实测）
  - 影响：`lib/features/assistant/presentation/widgets/flow_theme_bridge.dart` 的
    `luminousFlowTheme` 用前者选 `FlowColors.light/dark`，其 dark 分支在生产中不可达
    （`test/assistant/flow_theme_bridge_test.dart` 必须额外套一层
    `Theme(data: ThemeData(brightness: dark))` 才测得到），深色下 FlowUI 里未被 bridge 覆盖的
    字段（`primaryContainer` 等）取的是 light 预设
  - 方案：改用 Forui 的 `context.theme.colors.brightness`（当日 assistant 面板改动即用该信号），
    并补一条深色用例

- 登录后守卫重定向未兜住的取证（观察项，未复现）
  - 背景：当日修的「密码登录成功后停在登录页」根因是 `goAfterLogin` 漏传 `fallbackHome`；
    按设计守卫的 `refresh()` 重定向本应兜住，且实测该链路本身是通的，故未能从代码复现该场景
  - 若复现，先查 `AuthSessionNotifier.build` 的 `client.onSessionExpired`：`!isLoading` 时任意
    不可恢复 401 会清空 UI 会话，而登录成功后 `healthContextSnapshotProvider` 失效触发的受保护
    请求正好落在该窗口
  - 方案：复现时先在该回调加日志取证，再决定是否收窄清会话条件

## 2026-09-11 助手流式排查遗留（Web 端无逐字流式）

- Web 端 `ResponseType.stream` 不真正流式：dio 的 Web 适配器（`dio_web_adapter`）用 XHR +
  `responseType = 'arraybuffer'`，整流 body 到齐后才交给 SSE 解析器，因此 Flutter Web 上助手回答
  是「一次性出现」，`streamingDraft` 的逐字追加只在原生端生效。
  - 现状：2026-09-11 已解除 Web XHR 的 10s 总超时（见当日迁移日志），功能可用但无流式体验；
    assistant / reports / today-analysis 三条 SSE 共用同一客户端，同等受影响。
  - 方案：为 SSE 单独提供 fetch + ReadableStream 的 `HttpClientAdapter`（或 Web 分支改用
    EventSource / `package:http` BrowserClient），需评估与鉴权拦截器、401 刷新路径的兼容性。

## 2026-09-02 代码审查遗留（08-30 / 09-01 review）

- range_picker_dialog 结果返回路径的 no_direct_navigator 豁免（09-01 审查 #3）
  - 现状：11 处 `Navigator.of(dialogContext).pop(value)` 是
    `showModalBottomSheet` / `showFDialog` 结果返回的惯用法（await 拿值），功能正确；
    `no_direct_navigator` 在观察模式下命中但暂不 block（白名单仅 core/router 与 shell）
  - 方案：lint 接入 CI（`--fatal`）前重构为弹层关闭专用封装，或把 dialog 结果返回路径
    加入 lint 白名单并附 `// allowed: dialog result return path` 注释；
    白名单不应扩大到普通导航

- archive 归档文档的 auth_form_mixin 旧路径与退役 wikilink（09-01 审查 #4，经维护者决定保留豁免）
  - 现状：`docs/archive/2026-08-31-doc-governance/` 下 Design_System_Components.md 与
    Project_Guardrails.md 仍引用 `providers/shared/auth_form_mixin.dart` 旧路径（实际文件
    已迁至 `.../shared/form_mixin.dart`）；Design_System_Components.md 还含指向
    Design_System 与 Design_System_Migration 的两个退役 wikilink（09ca01f8 迁移遗留）；
    `scripts/docs/links.dart` 的 `exemptRepoPaths` 豁免条目保留
  - 方案：下次触碰该归档目录时一并修正两处旧路径、把 wikilink 改为相对 markdown 链接，
    然后从 `exemptRepoPaths` 删除豁免条目（注意：归档文档进入变更集即触发 links check
    全量扫描，须一次性清干净）

- trend 图表零值与无数据的视觉区分（08-30 审查 W-1）
  - 现状：unknown 天不再补零后，用户主动记录的合法零值贴 X 轴，与「无数据」视觉难区分；
    `ReviewTrendSection` 仅由 legacy preview/dashboard_view 装配；若把
    `observedMetric == null` 纳入空态判定，会在旧后端 scalar 兼容路径（observedMetric
    可空）误伤有数据的曲线
  - 方案：先确认 backend 对 zero-value 与 no-observation 的表达口径，再决定空态判定与
    图例文案（走 l10n + 同步 localization.md），并补 widget test 锁定
    `values:[0,0,0]` + observedMetric(observedCount=3) 不走空态

## 审查暂缓项

- Toast 同消息重放「有 action ↔ 无 action」切换时 suffix 不重建（已限定为既有已知限制并在 `core/feedback/toast.dart` 注释说明）。验收：可接受或为 Toast 增加重建能力。

- 超大文件拆分暂缓（Phase Guide 明确"现在不要做"）：`record/presentation/pages/detail.dart`（853 行）、`record/presentation/widgets/sections/quick_entry_panel.dart`（565 行）、`record/presentation/pages/edit.dart`（511 行）、`report/presentation/pages/page.dart`（438 行）、`settings/presentation/pages/page.dart`（184 行）
- 剩余约 80 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

## 实验性功能（当前冻结）

- GenUI（Generative UI）渲染引擎
  - 现状：`proposedActions` 已是 GenUI 雏形（4 种固定类型 + 1 个固定卡片 `AssistantProposalCard`）
  - 历史设想：扩展为开放式 UI 组件 JSON schema，由客户端渲染结构化组件树；该设想未获当前用户任务支持
  - 决策：保留现有方向与 Feature Flag，不删除，也不在当前阶段推进；重新启动需单独证明用户任务和受控渲染边界

## Not in P0-P3 Scope

- Women-health / period management
- Sports recovery
- Specialist health packs
- Smart devices
- Family profiles
- Skin recognition
- Desktop-first workflows

## P2/P3 Gated But Not Blocking Right Now

- 当前边界之外的额外已审核药品规则扩展
- 跨来源药品归一化与未审核相互作用扩展
- 固定 red-flag 规则、审核过的 offline-care 升级文案、help-resource 完整性
- Agent-assisted support discovery 或 map-backed nearby-care lookup
- 当前边界之外更深的药品安全规则覆盖与更清晰的 unsupported / low-confidence wording
- Environment-driven Today 或 Mine 建议
- 真实药品条码/OCR/拍照/处方识别流程

## 2026-08-31 文档治理归并（Mock_Or_Deferred / Next_Plan 承接）

- 用药安全后续（原 Next_Plan）：Allergy severity null-handling（`severity == null` 但 `reaction == 'anaphylaxis'`）；CN 来源药品对 interaction checker 不可见；Avoid-tier 升级策略（结构化 `avoid` 结论保持低于 red-flag）；跨语言重复匹配（「对乙酰氨基酚」vs "paracetamol"）；DrugBank 同义词过度泛化（不同 NSAIDs 共享同义词）
- 通知通道边界：真实 FCM/APNs 厂商直推与真实 SMS 投递均不启动（JPush 条件回退已实现：本地通知优先，能力上报后仅本地不可达/未确认时后台 JPush；提醒投递历史 in_app/local/push 三通道已落库，SMS 通道仍无）
- 独立 More tab 或通用 utility hub：不启动
- 未明确批准的付费或需要资质的外部服务：不启动
- 轻量心情记录连线：延后但保留
- 导出生命周期刻意轻量：无页内请求历史列表、无显式重试队列、clinic share link 无应用内链接管理（只能重新生成）

## 2026-08-31 文档治理遗留（doc-governance-overhaul 收尾）

- doc-map 退役两周观察期：pre-commit 已降级 report-only；观察确认 `scripts/docs/verify.dart --verify`（结构）+ `scripts/docs/links.dart`（正文路径）覆盖原 doc-touch 保护价值后，移除 `scripts/docs/verify.dart` 的映射检查、pre-commit 的 `--staged` 报告步骤与 `docs/doc-map.yaml` 本体
- 七规则观察期收敛（`tool/luminous_lints`，warn 观察基线 245 处：no_direct_navigator 113、layered_import 64、no_bang_on_response_data 37、enum_parse_unknown_branch 20、no_raw_datetime_parse 8、first_where_requires_or_else 3、empty_catch_requires_comment 0）：各规则清零后按计划逐条转 error（`--fatal` 门禁接入 pre-push）
- 七规则 IDE 插件集成：主包依赖图 freezed 钉 analyzer 12.x，而 analysis server 要求插件与其内置 analyzer 一致（14.1.0）；主包升级兼容 analyzer 14 后在 `analysis_options.yaml` 的 `plugins:` 接入 `luminous_lints`（当前仅 CLI 观察）

## 2026-09-12 头像计划的唯一写入路径

- 账号页 `/account` 与 Profile 页 `/profile` 都曾能改头像 URL；两处 URL 文本输入已全部退役，头像只能经 Profile 的 `showAvatarActionsDialog`（查看/拍照/相册/移除）+ 本地草稿 + 预签名上传写入。不要新增第三条头像写入路径，也不要把 URL 文本输入加回来。
