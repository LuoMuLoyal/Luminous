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
- Today 根页已收口为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作` 结构。
- Medicine 根页已接入 Lucent Phase 2 slot-aware dose-log 合同。
- Forui-first 编码统一性优化完成：Material 组件全面迁移、颜色/排版 token 化。
- `debugPrint` 已全量迁移到 `talker_flutter` 日志基础设施（922 tests passed）。
- 文档治理带有 warning-only 的路径映射检查（`docs/doc-map.yaml` + `tool/check_doc_coverage.dart`）。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
- 延后项：[[00-current/TODO]]
- 变更日志：[[03-logs/MigrationLog]]
- 历史归档：[[04-archive/current-state-archive]]
