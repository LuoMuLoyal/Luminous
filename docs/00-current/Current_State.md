---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-02
---

# Luminous Current State

Last updated: 2026-07-18

本文件是 `00-current/` 目录的索引。具体实现细节由各子文件负责，变更历史见 `03-logs/migration-log/`。

## 当前基线

五 Tab 根页（Today / Record / Medicine / Report / Mine）均已接入 `PageViewState` 统一状态机。未登录态使用 `SignInHintBanner` 轻量提示条而非全屏门控。P0-P2 UI/UX 优化全部完成，当前处于发布验证门阶段。

## 目录索引

### 项目治理与规划

- [[00-current/Project_Governance]] — 维护模式、架构、测试工具链、仓库布局、产品表面、文档治理
- [[00-current/Work_Phase_Guide]] — 阶段总纲（Phase 1-6）
- [[00-current/Next_Plan]] — 下一步实现顺序
- [[00-current/TODO]] — 延后与门控事项

### 技术快照

- [[00-current/Runtime_Snapshot]] — 运行时快照（技术栈、主题设计系统、Token、网络层、测试结构）
- [[00-current/Lucent_Contract_Snapshot]] — Lucent API 合同快照

### UI 页面状态

- [[00-current/Active_Mobile_UI]] — 移动 UI 总览与启动流程
- [[00-current/Active_UI_Today]] — Today 页面
- [[00-current/Active_UI_Record]] — Record 页面
- [[00-current/Active_UI_Medicine]] — Medicine 页面
- [[00-current/Active_UI_Report]] — Report 页面（含 Clinic Summary）
- [[00-current/Active_UI_Mine_Settings]] — Mine / Settings 页面

### 边界

- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[04-archive/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 避错清单：[[02-reference/Project_Guardrails]]
- 操作指南：[[02-reference/how-to/README]]
- 变更日志：[[03-logs/MigrationLog]]
- 历史归档：[[04-archive/current-state-archive]]
