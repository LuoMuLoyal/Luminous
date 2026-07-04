# Luminous Current State

Last updated: 2026-07-04

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理
- [[00-current/Repository_Split]] — 仓库划分
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Work_Phase_Guide]] — 阶段总纲
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 已完成基线

- 历史 completed baselines 与 audit remediation 已归档：[[04-archive/current-state-archive]]
- 文档治理现在带有 warning-only 的路径映射检查：`docs/doc-map.yaml` + `tool/check_doc_coverage.dart`
  会在 `pre-commit` 与 `tool/run_daily_checks.dart` 中提醒本次代码改动需要复核哪些文档。
- Forui-first 编码统一性优化完成：
  - 页面骨架统一：`PageScaffold`（26 子页）+ `AppTopBar`（5 Tab 根页）+ `AuthShell`（5 Auth 页）。
  - Material 组件全面迁移：按钮、进度、InkWell、图标、对话框、输入、选择、列表、卡片、Chip、导航、Tab、Drawer 等。
  - 颜色系统：所有 `Color(0xFF...)` 和 `Theme.of(context).colorScheme.*` 已替换为
    `context.theme.colors.*` / `AppColors` 语义 token。
  - 排版系统：所有 `textTheme.*` 已替换为 `AppTypographyToken`。
  - `Theme.of(context).brightness` 已替换为 `MediaQuery.platformBrightnessOf(context)`。
  - 合理遗留：`showDatePicker`/`showTimePicker`、`FloatingActionButton`、`RefreshIndicator`、
    `Tooltip`（Forui 未提供等效组件或 API 差异较大）。
- 基础组件优化完成：
  - `AppDivider` 支持 `width` 参数，清理冗余默认色调用。
  - `AppStateViews` 拆分为 `app_state_message.dart` + `app_skeleton.dart`，修复 tone 语义，
    `AppInlineSkeletonCircle` 自动 shimmer。
  - `AssistantStateCard` 删除，合并到 `AppStateMessageView(maxWidth: 560)`。
  - `ResponsiveContentFrame` 支持 `padding` 覆盖。
  - `PageScaffold` 支持 `titleWidget` 与 `headerStyle`。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
