# Luminous Current State

Last updated: 2026-07-09

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。
历史 completed baselines 已归档至 [[04-archive/current-state-archive]]。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理、文档映射、AI 开发工作流
- [[00-current/Repository_Split]] — 仓库划分与生成物边界
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Work_Phase_Guide]] — 阶段总纲
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照（Forui 主题、状态管理、网络层）
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Active_UI_Today]] — Today 页面详细状态
- [[00-current/Active_UI_Record]] — Record 页面详细状态
- [[00-current/Active_UI_Medicine]] — Medicine 页面详细状态
- [[00-current/Active_UI_Report]] — Report 页面详细状态
- [[00-current/Active_UI_Mine_Settings]] — Mine / Settings 页面详细状态
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 当前基线摘要

- 五 Tab 根页（Today / Record / Medicine / Report / Mine）均已接入 `PageViewState` 统一状态机，
  未登录态使用 `SignInHintBanner` 轻量提示条而非全屏门控。
- Today 根页已收口为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作` 结构。建议引擎前端接入 Phase 1-4 已完成：API 客户端生成、Domain 实体层、Remote Data Source 就绪；`todaySuggestionProvider` 升级为 `AsyncNotifier`（含 submitFeedback/dismiss/refresh），主卡/次卡区从 provider 直接取数据；反馈按钮接入 `POST /today/suggestions/:id/feedback`，AI 解释按需加载 `POST /today/suggestions/:id/explain`；主卡证据区改为结构化逐条展示（`_EvidenceList` + `_EvidenceItemRow`），`subtype == 'water'` 建议卡显示 `FDeterminateProgress` 饮水进度条；页面刷新同时 invalidate dashboard + suggestions；废弃的 `priorityItems` / `TodayPriorityItem` / `TodayPriorityItemType` 已彻底删除。
- Medicine 根页已接入 Lucent Phase 2 slot-aware dose-log 合同。
- Forui-first 编码统一性优化完成：Material 组件全面迁移、颜色/排版 token 化。
- `lib/core/design/` 目录架构升级完成：全部 token 类名移除 `App` 前缀，统一为 `Spacing` / `RadiusTokens` / `TypographyToken` / `DurationTokens` / `Breakpoints` / `ResponsiveSizing` / `LayoutScale` + `LayoutScaleResolver`，通过 barrel `design.dart` 统一导出。
- Mine 账号与安全区已包含退出登录 tile（`ConsumerWidget` + `authSessionProvider`）；Report 趋势区已替换为 `fl_chart` 多线折线图，日期标签从 `dashboard.startDate` 动态生成。
- `debugPrint` 已全量迁移到 `talker_flutter` 日志基础设施（922 tests passed）。
- 文档治理使用 `docs/doc-map.yaml` + `tool/check_doc_coverage.dart`：默认阻断模式——有代码变更但无 `docs/` 文件时 `exit(1)`；`--warning-only` 用于日常检查（per-rule 报告缺少的具体文档但不阻断）；`SKIP_DOC_CHECK=1` 可旁路。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
- 延后项：[[00-current/TODO]]
- 变更日志：[[03-logs/MigrationLog]]
- 历史归档：[[04-archive/current-state-archive]]
