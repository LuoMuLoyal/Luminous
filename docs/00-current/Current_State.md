# Luminous Current State

Last updated: 2026-07-04

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理
- [[00-current/Repository_Split]] — 仓库划分
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 已完成基线

- 历史 completed baselines 与 audit remediation 已归档：[[04-archive/current-state-archive]]
- 文档治理现在带有 warning-only 的路径映射检查：`docs/doc-map.yaml` + `tool/check_doc_coverage.dart`
  会在 `pre-commit` 与 `tool/run_daily_checks.dart` 中提醒本次代码改动需要复核哪些文档。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
