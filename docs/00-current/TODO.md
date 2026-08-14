---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-14
---

# Luminous TODO

Last updated: 2026-08-14

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

## 产品闭环（程序已收口，仅剩延后项）

Product Loop Program（决策依据 [[02-reference/adr/0011-event-led-sparse-record-product-loop]]）已实施完毕，
计划文件已删：健康事件、主动建议、稀疏记录语义、事件优先回顾与隐私克制的闭环测量全部落地，
就诊摘要支持字段级隐私选择与可撤销分享。以下为延后项与合同债。

### 健康事件与关键确认

- 饮食、心情和普通笔记保留录入与回看，退出首阶段主动建议闭环；数据足够时也只能先作为观察项

### 平台与验证

- 桌面端和完整认证 Web 应用冻结：保留代码，不继续功能对等、发行或产品化；手机端是唯一核心产品，`Luminous-website` 继续承担官网和竞赛展示

## 延后（有明确原因）

- AI 会话重命名与删除
  - 当前客户端只支持新建、加载和切换会话；等待后端提供会话标题更新与删除 API 后再实现

- AI 消息 Markdown 模板升级
  - 当前只使用基础 `MarkdownBody` 样式；后续统一设计标题、列表、代码块、引用、表格和链接的视觉模板

- AI 消息操作按钮完善
  - 复制已可用（Clipboard + toast）；重新生成/重新发送仍是上下文菜单占位（`message_bubble.dart` 的 `onPress: null`），
    需后端 controller 支持后接线（Lucent assistant 尚无 regenerate/resend 接口）

- forui 0.25.0 toast dismiss 的 dispose-during-notifyListeners 风险
  - 现象：`FToasterEntry.dismiss()` 在 toast 入场动画完成前触发时，forui 非无障碍分支直接 `reverse()`，
    同步走到 dismissed 状态后在通知期间 `dispose()`（无障碍分支用 microtask 规避了同样问题）
  - 影响：连续 `Toast.show` 时旧 toast 可能在入场完成前被 dismiss，调试构建可能触发断言
  - 现状：toast 测试通过先完成入场动画规避；生产未复现，暂不处理，后续升级 forui 时留意
- `formz` 表单校验
  - 已尝试，发现该校验并不合适后回退
- `intl.DateFormat` 替代 ISO 字符串
  - `padLeft` 是线协议格式，DateFormat 不适用

## 审查暂缓项

- 超大文件拆分暂缓（Phase Guide 明确"现在不要做"）：`record/presentation/pages/detail.dart`（853 行）、`record/presentation/widgets/sections/quick_entry_panel.dart`（565 行）、`record/presentation/pages/edit.dart`（511 行）、`report/presentation/pages/page.dart`（438 行）、`settings/presentation/pages/page.dart`（184 行）
- 剩余约 80 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

## 实验性功能（稳定版后启动）

- GenUI（Generative UI）渲染引擎
  - 现状：`proposedActions` 已是 GenUI 雏形（4 种固定类型 + 1 个固定卡片 `AssistantProposalCard`）
  - 目标：扩展为开放式 UI 组件 JSON schema，LLM 返回结构化组件树，客户端 `GenUIRenderer` 递归渲染原生 Widget
  - 路径：Phase 2 在 `proposedActions` 里新增 `type: "gen_ui"`，渐进式替代固定卡片
  - 前置条件：稳定版发布后启动，Feature Flags `genUiEnabled` 已就绪
  - 不需要 Firebase，纯客户端渲染 + Lucent 后端 LLM
  - 预估工作量：15-23 个工作日

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
- Worker-written reminder delivery history（本地/push/SMS 渠道）
- Environment-driven Today 或 Mine 建议
- 真实药品条码/OCR/拍照/处方识别流程
