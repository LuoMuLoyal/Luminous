# Work Phase Guide

Last updated: 2026-07-04

本文是 Luminous 的阶段总纲，用来决定每个时期先做什么、暂时不做什么。它不是短期执行计划；
短期任务仍放在 `plans/`，完成后删除计划，并把稳定事实同步回 `docs/00-current/`。

## 使用规则

- 同一时间只激活一个主要阶段，避免把 UI 精修、架构清债、功能扩展混在同一批改动里。
- 阶段切换依赖可观察结果，不依赖主观感觉。
- 如果出现 P0 问题，暂停当前阶段，先处理 P0。
- 完成阶段任务后，更新当前状态、迁移日志和相关产品/参考文档。

## 优先级定义

- P0：用户可见破损、Flutter overflow、崩溃、核心流程不可用、测试门失败。
- P1：影响 MVP 演示可信度的问题，包括明显假数据、登录态/空态混乱、硬编码日期、可见文案未本地化。
- P2：长期维护债，包括 Provider 注入重整、路由拆分、Clock 全量注入、组件抽象整理。
- P3：post-MVP 探索，包括新能力、新输入形态、地图/外部服务、非核心垂直场景。

## Phase 1: 迁移落地收敛

目标：让 Forui 重构后的当前工作树稳定，先消除明显 UI 破损和迁移噪声。

现在应该做：

- 修复五个 Tab 中已经截图确认的可见问题。
- 优先处理 Report 指标卡 overflow、Today 优先事项截断/黑块、加载/空态重复文案。
- 收口当前未提交的基础组件改动，避免继续扩大改动面。
- 每次只改一个小区域，并运行对应 widget/page test。

现在不要做：

- Provider 依赖注入大调整。
- 路由拆分。
- Clock 全量注入。
- 新功能或新外部服务接入。
- 为重复私有 widget 盲目提取共享组件。

退出条件：

- `flutter analyze --no-pub` 通过。
- 相关页面测试通过，至少覆盖 Today / Record / Medicine / Report / Mine 的被改区域。
- 手动或截图确认移动端五个 Tab 无明显 overflow、文本遮挡和交互黑块。
- 当天 migration log 与当前状态文档已同步。

## Phase 2: 移动端 MVP 体验打磨

目标：让五个 Tab 看起来像同一个产品，而不是迁移后拼接的页面集合。

推进顺序：

1. Today：统一摘要、优先事项、主动建议的状态层级。
2. Record：降低快速记录和筛选区的边框噪声，提高时间线扫读性。
3. Medicine：收紧药盒、安全预览、操作列表之间的节奏。
4. Report：统一预览、未登录、未开通、真实报告状态的视觉权重。
5. Mine：压缩未登录解释文本，稳定档案入口和状态概览。

每个 Tab 的完成标准：

- signed-out / loading / empty / success / error 状态都有稳定显示。
- 文本在常见移动宽度下不溢出、不遮挡、不依赖偶然截断。
- 交互元素有明确目标，不把未来能力伪装成当前真实能力。
- 对应页面测试通过。

## Phase 3: MVP 可靠性加固

目标：清理会影响演示可信度和排障能力的问题。

优先处理：

- 空 catch 或异常吞没，至少保留可排查日志或用户反馈路径。
- Mock 硬编码日期，改为相对日期或明确的演示边界。
- 用户可见硬编码文案，迁移到 ARB/l10n。
- 路由字符串硬编码，优先处理登录和主流程路径。
- 仍在真实页面中可见的 mock/static/unsupported 暗示。

暂缓处理：

- 大范围文件拆分。
- 把所有 `DateTime.now()` 一次性替换成注入 Clock。
- 把所有 Provider 一次性切到顶层 override。

退出条件：

- 相关静态扫描项已复核，误报/过时项从活动计划中移除。
- `flutter analyze --no-pub` 和相关测试通过。
- `docs/00-current/TODO.md` 只保留真实仍需延后或门控的事项。

## Phase 4: 架构收敛

目标：在 UI 和 MVP 稳定后，降低长期维护成本。

可进入的前提：

- Phase 1 和 Phase 2 没有剩余 P0/P1。
- 当前工作树已拆成可理解的提交或可审阅 diff。
- 有明确的单一架构主题，不与 UI 精修混做。

候选主题：

- Provider 到 Repository 接口的注入边界。
- Mock repository 移入 test/support 或明确 demo 数据边界。
- Clock provider 注入与时间相关测试。
- `router.dart` 按 feature 拆分。
- 只在行为和 API 真正重复时提取共享 widget。

退出条件：

- 每个架构主题都有独立计划和验证命令。
- 不改变用户可见流程，除非计划明确说明。
- 通过全量 Flutter 测试或等价覆盖。

## Phase 5: Release Gate

目标：准备 v4.0.0 或下一次可演示版本。

必须运行：

```powershell
flutter analyze --no-pub
flutter test --no-pub
dart run tool/run_daily_checks.dart
```

需要真实端到端信心时运行：

```powershell
dart run tool/run_fullstack_checks.dart
```

发布前检查：

- 当前状态文档只描述真实已完成能力。
- `Next_Plan.md` 不保留已完成事项。
- 活跃 `plans/` 中没有已完成但未删除的计划。
- 不把 post-MVP 能力写成当前 MVP 承诺。

## Phase 6: Post-MVP 探索

目标：在核心闭环稳定后，选择一个明确场景扩展，而不是继续堆功能。

候选方向：

- Report drill-down。
- Medicine scan/OCR/barcode/prescription 的真实合同。
- Environment-driven Today/Mine 建议。
- Agent-assisted support discovery。
- 认证 Web 报告预览。

进入条件：

- v4.0.0 移动端闭环已经稳定。
- 有产品决策、后端合同和验证方式。
- 涉及外部服务、资质、计费或凭证时，先单独确认。

## 文档落点

- 阶段总纲：本文。
- 下一步排序：`docs/00-current/Next_Plan.md`。
- 当前事实：`docs/00-current/Current_State.md` 及其子文件。
- 活动执行计划：`plans/*.md`。
- 历史记录：`docs/03-logs/migration-log/YYYY-MM-DD.md`。
- 产品范围：`docs/01-product/`。
- 技术规则和避错清单：`docs/02-reference/Project_Guardrails.md`。
