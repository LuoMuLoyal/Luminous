# Luminous TODO

Last updated: 2026-07-09

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

## 延后（有明确原因）

- Forui 0.23.0 `FToaster` 的 `_entranceDismissController` LateInitializationError
  - 已通过移除测试树中的 `FToaster`、`AppToast.show` 加 try-catch 降级规避
  - 升级至 Forui 0.24+ 后恢复 toast 测试
- `formz` 表单校验
  - 已尝试,发现该校验并不合适后回退
- `intl.DateFormat` 替代 ISO 字符串
  - `padLeft` 是线协议格式，DateFormat 不适用

## 审查暂缓项（2026-07-07 三审）

以下项经三份审查报告确认后暂缓，有明确原因：

- 超大页面拆分：`login_page.dart`（620+ 行）、`medicine_reminder_edit_page.dart`（400+ 行）— Phase Guide 明确"现在不要做"
- Provider 一致性：`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一 — 非 Phase 2 目标
- 剩余约 15 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

## 语义颜色系统增量清理 (LUM-2026-0709-07 后续)

二维 `SemanticColor` / `SemanticColorPalette` / `SemanticColors` 基础设施已就位，6 个核心 widget 文件已完成 alpha→palette 迁移。剩余约 20 处 `colors.X.withValues(alpha: Y)` 模式（直接 `FColors` 属性访问，非通过 `SemanticColor`）可按 feature 分批迁移：

- `today/` — `components.dart`（3 处 alpha）、`card_style.dart`（4 处 alpha）
- `record/` — `quick_entry_panel.dart`（3 处）、`timeline.dart`（1 处）、`sidebar.dart`（1 处）、`new_entry_panel.dart`（2 处）、`voice_entry_dialog.dart`（3 处）、`image_attachment_field.dart`（1 处）
- `report/` — `findings_section.dart`（1 处剩余）、`metrics_grid.dart`（1 处剩余）
- `search/` — `view.dart`（1 处）、`desktop_tabs.dart`（1 处）、`categories.dart`（1 处）、`source_switch.dart`（1 处）
- `shell/` — `deferred_content.dart`（1 处）

每批独立可测，不阻塞功能。迁移时按映射表替换：`0.04~0.06 → palette.subtle`、`0.08~0.12 → palette.muted`、`0.18~0.25 → palette.border`、无 alpha → palette.solid。

## 实验性功能（稳定版后启动）

- GenUI（Generative UI）渲染引擎
  - 现状：`proposedActions` 已是 GenUI 雏形（4 种固定类型 + 1 个固定卡片 `AssistantProposalCard`）
  - 目标：扩展为开放式 UI 组件 JSON schema，LLM 返回结构化组件树，客户端 `GenUIRenderer` 递归渲染原生 Widget
  - 路径：Phase 2 在 `proposedActions` 里新增 `type: "gen_ui"`，渐进式替代固定卡片
  - 前置条件：稳定版发布后启动，Feature Flags `genUiEnabled` 已就绪
  - 不需要 Firebase，纯客户端渲染 + Lucent 后端 LLM
  - 预估工作量：15-23 个工作日（含 UI Schema 规范、后端 prompt 改造、渲染引擎、基础组件库、Action 回调、流式渲染、测试）

## Not MVP

- Women-health / period management
- Sports recovery
- Specialist health packs
- Smart devices
- Family profiles
- Skin recognition
- Desktop-first workflows

## MVP Gaps To Close

- 当前 frozen mobile MVP 承诺无剩余 blocker
- 移动 MVP 路径现定义为：`record -> summarize -> bounded medicine safety check -> export`
- 对未审核药品有明确不确定性；不声称 broad cross-source normalization 或 unreviewed interaction expansion
- 下列工作属于 post-MVP 产品化或加固，不阻塞 MVP 完成

## MVP Gated But Not Blocking Right Now

- 当前边界之外的额外已审核药品规则扩展
- 跨来源药品归一化与未审核相互作用扩展
- 固定 red-flag 规则、审核过的 offline-care 升级文案、help-resource 完整性
- Agent-assisted support discovery 或 map-backed nearby-care lookup
- 当前边界之外更深的药品安全规则覆盖与更清晰的 unsupported / low-confidence wording
- Report/export finish-pass 客户端清理：
  - 最终状态文案一致性
  - 过期链接处理
  - 一次真实环境验收运行
  - 除非发现真实 bug，否则不重新打开后端/export 范围
- Worker-written reminder delivery history（本地/push/SMS 渠道）
- Environment-driven Today 或 Mine 建议
- 真实药品条码/OCR/拍照/处方识别流程
- 超越竞赛/营销首页的真实认证 Web 报告预览
- 环境驱动的 Today/Mine 建议
- Agent 辅助就医发现
- Today 主动建议卡片后端统一裁决引擎
  - 现状：Today 主/次建议卡由前端硬编码组装，仅支持用药/饮水两类
  - 目标：后端按 `Product_Tab_Component_Blueprint` 支持「明确风险 / 疑似漏服 / 恶化趋势 / 行为建议」四类卡片
  - 规划：`plans/2026-07-09-today-suggestion-engine-backend.md`

## 蓝图差距盘点（2026-07-09）

对照 `Product_Tab_Component_Blueprint` 逐 tab 核查。Today 延后至后端建议引擎就绪后再做，先收口其他四个 tab。

### Record — ✅ 无差距

蓝图 1.0 必做组件全部完成：快速记录区、自然语言候选确认、时间线。

### Medicine — ✅ 无差距

蓝图 1.0 必做组件全部完成：当前用药盒、今日用药区、安全检查摘要。

- **Score Hero 增强项**：`ReportScoreHero` 不在蓝图清单中，作为增强保留，无需改动。


### Today — 延后

- 建议类型模型偏窄、主卡区未细分场景 — 均依赖后端统一建议裁决引擎，延后至后端能力就绪后再做。
- 规划文档：`plans/2026-07-09-today-suggestion-engine-backend.md`
- `TodayRecordHintSection` 作为非蓝图增强保留。


