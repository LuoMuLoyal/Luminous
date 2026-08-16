---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-16
---

# Luminous TODO

Last updated: 2026-08-16

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

## 产品闭环（程序已收口，仅剩延后项）

Product Loop Program（历史决策见已被新产品方向取代的 [[02-reference/adr/0011-event-led-sparse-record-product-loop]]）已实施完毕，
计划文件已删：健康事件、主动建议、稀疏记录语义、事件优先回顾与隐私克制的闭环测量全部落地，
就诊摘要支持字段级隐私选择与可撤销分享。以下为延后项。

### 健康事件与关键确认

- 饮食、饮水、睡眠和心情是健康伙伴纵向理解的平级数据源；覆盖率和来源足够时可进入主动建议闭环，普通笔记默认只作上下文证据

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

- F-14 药品详情页审查 P2-2（2026-08-16 任务 2 审查遗留，待 scan-search 计划决策）
  - 位置：`lib/app/router.dart` `_publicRoutePrefixes` / `_publicRootRoutes`
  - 问题：`/medicine/detail` 未登记为公开路由（后端 `GET /medicines/:id?source=` 为 @Public、页面仅对「加入药箱」做 auth 门控），未登录深链会 redirect 到 `/login`；当前唯一入口（Reminder 详情卡）已 auth 门控，不破坏现有流程
  - 验收：scan-search 计划接线「查看说明书」时决定公开（加入 `_publicRoutePrefixes`）或保持受保护并在入口做 auth 门控，并同步 `docs/02-reference/routing.md` Public Preview 段

- F-3 打卡撤销审查 P2-2（2026-08-16 任务 5 审查遗留）
  - 位置：`core/feedback/toast.dart` 同消息去重分支
  - 问题：1.8s 内连续打卡两槽位时第二次撤销 action 仍是第一槽位闭包（已文档化、反向 planned 幂等）
  - 验收：可接受或为 Toast 增加重放时替换 action 能力

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
