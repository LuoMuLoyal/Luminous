---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-11
---

# Work Phase Guide

Last updated: 2026-08-11

本文是 Luminous 的阶段总纲，用来决定每个时期先做什么、暂时不做什么。短期任务放在 `plans/`，完成后删除计划，把稳定事实同步回 `docs/00-current/`。

## 使用规则

- 同一时间只激活一个主要阶段。
- 阶段切换依赖可观察结果，不依赖主观感觉。
- 出现 P0 问题时暂停当前阶段先处理。
- 完成阶段任务后更新当前状态、迁移日志和相关文档。

## 优先级定义

- **P0**：用户可见破损、overflow、崩溃、核心流程不可用、测试门失败。
- **P1**：影响演示可信度的问题——假数据、登录态/空态混乱、硬编码日期、文案未本地化。
- **P2**：长期维护债——Provider 重整、路由拆分、Clock 注入、组件抽象整理、UI 一致性。
- **P3**：扩展探索——新能力、新输入形态、地图/外部服务、非核心垂直场景。

## Phase 1: 迁移落地收敛 ✅ 已完成

Forui 重构后消除可见 UI 破损和迁移噪声。五个 Tab overflow/文本遮挡/交互黑块已修复。

## Phase 2: 移动端 P0 体验打磨 ✅ 已完成

五个 Tab 看起来像同一个产品。每个 Tab 的 signed-out/loading/empty/success/error 状态稳定，文本不溢出，交互元素有明确目标。

## Phase 3: P0 可靠性加固 ✅ 已完成

空 catch 清理、硬编码文案迁移到 ARB/l10n、路由字符串硬编码处理、mock/static 暗示移除。

## Phase 4: 架构收敛 ✅ 已完成

- ADR-0006: `riverpod_generator` 引入，provider 声明风格统一。
- ADR-0007: 网络层职责分离（`AuthInterceptor`/`ErrorInterceptor`/`RetryInterceptor`）。
- ADR-0008: `Result` 类型与统一错误处理（`AppError`/`runGuarded`）。
- ADR-0009: Drift 本地持久化基础设施 + cache-first repository 迁移。
- ADR-0010: `go_router_builder` 类型安全路由全量迁移。
- Repository 接口统一到 `domain/repositories/`，mock 数据移入 `test/helpers/mocks/`。
- 跨 feature presentation 耦合通过 `DataChangeBus` 解耦。
- 巨型文件拆分（`suggestion.dart` 952→125 行）。

## Phase 5: `0.1.0` Release

目标：完成现有版本的真实联调、发布验证和 `0.1.0` 正式发布。

产品方向文档、领域语言、平台冻结边界、ADR 和后续计划已经建立。联调期间不启动健康事件 schema、主动建议重构、数据口径迁移或 Review 重做，但不设发布门禁。

关键边界：

- 手机端是唯一核心产品；桌面端和完整认证 Web 应用冻结但不删除。
- 优先修复阻断 `0.1.0` 联调、验证或发布的问题。
- 当前状态文档必须继续描述真实运行时，不能把产品闭环方向写成已实现能力。

必须运行：

```powershell
flutter analyze --no-pub
flutter test --no-pub
dart run scripts/run_daily_checks.dart
```

需要真实端到端信心时运行：

```powershell
dart run scripts/run_fullstack_checks.dart
```

发布前检查：

- 当前状态文档只描述真实已完成能力。
- `Next_Plan.md` 不保留已完成事项。
- 活跃 `plans/` 中没有已完成但未删除的计划。
- 不把 P2/P3 能力写成当前 P0/P1 承诺。

### P0-P2 UI/UX 优化（2026-07-18 完成）

基于 `plans/2026-07-18-uiux-per-page-optimization.md` 完成全量 UI/UX 优化：

- **P0 数据安全**：身高丢数据修复、通知已读链路反转、删除确认文案修复。
- **P0 死交互/错误路由**：Today 快捷操作路由修复、铃铛红点条件渲染、通知权限 permanentlyDenied 处理、搜索页空壳消除。
- **P0 硬编码文案**：11 项硬编码中文/英文直出/文案错配修复。
- **P0 视觉坍塌**：风险三级颜色体系修复、报告预览评分文案修复、移动端医疗免责声明补齐。
- **P1 体验缺口**：空态体系（横幅 CTA + 时间线空态）、危险操作确认链（6 处二次确认）、表单必填校验。
- **P2 一致性打磨**：错误文案 mapper、日期格式收敛、剩余硬编码文案消除、触控目标与语义补齐、PIN 二次确认、骨架屏与真实版面对齐、桌面月历交互解耦、平板档限宽。

## Phase 6: 产品闭环重构 ← 当前阶段

目标：继续按 [`../../plans/2026-08-07-product-loop-program.md`](../../plans/2026-08-07-product-loop-program.md) 实施事件回顾和隐私克制的产品测量。Health Event Contract、Proactive Suggestion Runtime、Sparse Record Semantics 与 Review Experience 已完成，当前从 Visit Summary and Product Measurement 开始。

进入条件：Health Event Contract、Proactive Suggestion Runtime 和 Sparse Record Semantics 已完成跨前后端合同与验证；当前工作继续在 feature branch 上进行。

## Phase 7: P2/P3 扩展探索

目标：在 P0/P1 闭环稳定后，按 Brainstorm P2/P3 优先级选择明确场景扩展。

候选方向（Brainstorm P2 — 1.1.0）：

- 就诊摘要模板化
- 症状-用药关联时间线
- 记录连续性激励

候选方向（Brainstorm P3 — 1.2.0+）：

- 红旗信号规则
- 智能提醒优先级
- 经设备、地区、系统服务和开发者权限验证后的可选健康数据桥接
- 快捷记录 Widget
- Assistant 嵌入式重构

进入条件：P0+P1 移动端闭环稳定 + 有产品决策、后端合同和验证方式。

## 文档落点

- 阶段总纲：本文。
- 下一步排序：`docs/00-current/Next_Plan.md`。
- 当前事实：`docs/00-current/Current_State.md` 及其子文件。
- 活动执行计划：`plans/*.md`。
- 历史记录：`docs/03-logs/migration-log/YYYY-MM-DD.md`。
- 产品范围：`docs/01-product/`。
- 技术规则和避错清单：`docs/02-reference/Project_Guardrails.md`。
