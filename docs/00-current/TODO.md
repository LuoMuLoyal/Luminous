---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-23
---

# Luminous TODO

Last updated: 2026-08-23

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

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

## 延后（有明确原因）

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
- `formz` 表单校验
  - 已尝试，发现该校验并不合适后回退
- `intl.DateFormat` 替代 ISO 字符串
  - `padLeft` 是线协议格式，DateFormat 不适用

- AI 来源条元数据后端投影（F-14/F-15，0.1.0 后）
  - 现状：来源条组件与前端字段（confidenceNote/sourceVersion）已就绪；Lucent 的 `buildToolDetails` 尚未把摘要工具的 `confidenceNote`/`sourceVersion` 与说明书的批准文号/更新时间投影进 SSE `toolDetails`，前端「数据截至」行与元数据行待数据到达后自动生效
  - 依据：assistant 改造计划 F-14/F-15 P2 子项（实施完毕文件已删）；0.1.0 后按既有顺序恢复

- 助手记忆擦除入口与联动（F-9/F-2 遗留，0.1.0 后）
  - 现状：Lucent `DELETE /assistant/memory` 已就绪（全量擦除）；设置页尚无入口；删除会话不联动清理该会话记忆；`activateConversation` 路径不触发记忆提取（仅「新对话」触发）
  - 方案：设置页 AI 区接入擦除按钮；会话删除时清理其 `AssistantMemory`；激活路径补提取调度

- 助手重生与确认并发线程锁（0.1.0 后）
  - 现状：LangGraph time travel 重生与 confirm（HITL 挂起）并发操作同一线程时无 per-thread 锁，极端并发下可能状态竞争
  - 方案：为 regenerate/confirm 路径加 per-thread 互斥

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
