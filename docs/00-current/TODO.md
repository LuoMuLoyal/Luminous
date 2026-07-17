# Luminous TODO

Last updated: 2026-07-15

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

- 超大文件拆分暂缓（Phase Guide 明确"现在不要做"）：`quick_entry_panel.dart`（685 行）、`record/edit.dart`（646 行）、`settings/page.dart`（638 行）、`record/detail.dart`（570 行）、`report/page.dart`（559 行）、`mobile_drugbox.dart`（546 行）、`conversation.dart`（542 行）。`suggestion.dart`（原 952 行）已拆分为 4 个文件（主文件降至 125 行）
- 剩余约 15 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

## 审查后续关注项（2026-07-11 回查 → 7-15 细化）

以下项来自 7-11 审查回查报告，代码层面问题已全部修复。

## 语义颜色系统增量清理 (LUM-2026-0709-07 后续)

二维 `SemanticColor` / `SemanticColorPalette` / `SemanticColors` 基础设施已就位。全部 feature 的 `colors.X.withValues(alpha: Y)` 模式和 `.resolve(colors)` 桥接方法已迁移到 `SemanticColor` palette 预计算色调。迁移映射表：`0.04~0.06 → palette.subtle`、`0.08~0.12 → palette.muted`、`0.18~0.25 → palette.border`、无 alpha → `palette.solid`。范围外 alpha 值使用 `SemanticColor.X.solid(context).withValues(alpha: Y)`。

### 残留无法迁移项

以下 `withValues(alpha:)` 调用因无 `SemanticColor` 等价物而保留：

| 文件 | 代码 | 原因 |
|---|---|---|
| `medicine/presentation/widgets/risk/risk_red_flag.dart:77` | `colors.background.withValues(alpha: 0.84)` | `background` 无 SemanticColor 映射 |
| `mine/presentation/widgets/shared/components.dart:32` | `colors.background.withValues(alpha: 0.72)` | 同上 |
| `record/presentation/widgets/shared/components.dart:196` | `color.withValues(alpha: 0.7)` | `color` 是 raw `Color` 参数，非 `SemanticColor` |
| `record/presentation/widgets/dialogs/voice_entry_dialog.dart:250` | `(primaryColor or colors.foreground).withValues(alpha: 0.2)` | 条件 boxShadow 色，两分支类型不同 |
| `lib/theme/styles/button_styles.dart:147` | `colors.destructive.withValues(alpha: 0.5)` | Forui CLI 生成，不修改 |

## 实验性功能（稳定版后启动）

- GenUI（Generative UI）渲染引擎
  - 现状：`proposedActions` 已是 GenUI 雏形（4 种固定类型 + 1 个固定卡片 `AssistantProposalCard`）
  - 目标：扩展为开放式 UI 组件 JSON schema，LLM 返回结构化组件树，客户端 `GenUIRenderer` 递归渲染原生 Widget
  - 路径：Phase 2 在 `proposedActions` 里新增 `type: "gen_ui"`，渐进式替代固定卡片
  - 前置条件：稳定版发布后启动，Feature Flags `genUiEnabled` 已就绪
  - 不需要 Firebase，纯客户端渲染 + Lucent 后端 LLM
  - 预估工作量：15-23 个工作日（含 UI Schema 规范、后端 prompt 改造、渲染引擎、基础组件库、Action 回调、流式渲染、测试）

## Not in P0-P3 Scope

- Women-health / period management
- Sports recovery
- Specialist health packs
- Smart devices
- Family profiles
- Skin recognition
- Desktop-first workflows

## P0/P1 Gaps To Close

- 当前 P0 两项已完成，P1 三项待执行
- 核心闭环路径现定义为：`record -> summarize -> bounded medicine safety check -> export`
- 对未审核药品有明确不确定性；不声称 broad cross-source normalization 或 unreviewed interaction expansion
- 下列工作属于 P2/P3 产品化或加固，不阻塞 P0/P1 完成

## P2/P3 Gated But Not Blocking Right Now

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

## 蓝图差距盘点（2026-07-09）

对照 `Product_Tab_Component_Blueprint` 逐 tab 核查。Today 建议引擎已完成后端实现 + 前端接入，收口其他四个 tab。

### Record — ✅ 无差距

蓝图 1.0 必做组件全部完成：快速记录区、自然语言候选确认、时间线。

### Medicine — ✅ 无差距

蓝图 1.0 必做组件全部完成：当前用药盒、今日用药区、安全检查摘要。

- **Score Hero 增强项**：`ReportScoreHero` 不在蓝图清单中，作为增强保留，无需改动。


### Today — ✅ 无差距
