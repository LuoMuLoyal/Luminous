---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-15
---

# Luminous Current State

Last updated: 2026-08-15

本文件是 `00-current/` 目录的索引。具体实现细节由各子文件负责，变更历史见 `03-logs/migration-log/`。

## 当前基线

五 Tab 根页（Today / Record / Medicine / Report / Mine）均已接入 `PageViewState` 统一状态机。未登录态使用 `SignInHintBanner` 轻量提示条而非全屏门控。P0-P2 UI/UX 优化全部完成，当前处于发布验证门阶段。

Sparse Record Semantics 的后端已提供统一 observed metric OpenAPI 合同；Flutter generated client 与 Today/Report domain mapper 已同步 `value`、`state`、`coverage`、`sources`、计数和时间窗字段。旧 scalar 仍保留兼容回退，quick-entry 已写入 sleep episode 合同并保持临时服药不猜测计划槽位。

### 测试补齐（2026-08-03）

- 全量测试 2870 通过 + 1 跳过（基线 2709 + 1）。
- 行覆盖率 **67.0%**（基线 63.0%，+4.0%）。剔除生成物 `.g.dart`/`.freezed.dart`、进程入口 `main.dart`/`bootstrap.dart`、平台桥接等排除项后，纯业务逻辑覆盖率估计 75-80%。
- 主要补齐模块：scan 页面/OCR (57 用例)、health_data (已提交)、risk_check (已提交)、clinic_summary (已提交)、core/database DAO (3)、change_record_date (3)、version_check (13)、master_detail (6)。
- 跳过项：`command_palette`（initState 中 AppLocalizations.of 触发 debug 断言）、`security_elevation_dialog`（多 Provider 依赖）、search sections / record_access（P2 低优先级）。
- 详见 `docs/03-logs/migration-log/2026-08-03.md`。

## 目录索引

### 项目治理与规划

- [[Project_Governance]] — 维护模式、架构、测试工具链、仓库布局、产品表面、文档治理
- [[Work_Phase_Guide]] — 阶段总纲（Phase 1-6）
- [[Next_Plan]] — 下一步实现顺序
- [[TODO]] — 延后与门控事项

### 技术快照

- [[Runtime_Snapshot]] — 运行时快照（技术栈、主题设计系统、Token、网络层、测试结构）
- [[Lucent_Contract_Snapshot]] — Lucent API 合同快照

### UI 页面状态

- [[Active_Mobile_UI]] — 移动 UI 总览与启动流程
- [[Desktop_UI]] — 现有 Flutter 桌面端 UI 事实（当前不产品化；未来大屏方向另行研究）
- [[Active_UI_Today]] — Today 页面
- [[Active_UI_Record]] — Record 页面
- [[Active_UI_Medicine]] — Medicine 页面
- [[Active_UI_Report]] — Report 页面（含 Clinic Summary）
- [[Active_UI_Mine_Settings]] — Mine / Settings 页面

### 边界

- [[Mock_Or_Deferred]] — Mock 与延后能力
- [[Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 相关文档

- 产品方向：[[Product_Vision]]
- 避错清单：[[Project_Guardrails]]
- 操作指南：[[how-to_README]]
- 变更日志：[[MigrationLog]]
- 历史归档：[[current-state-archive]]
