---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-07
---

# Luminous Next Plan

Last updated: 2026-08-09

本文件只记录下一步实现顺序。当前事实见 [[00-current/Current_State]]；变更历史见 [[03-logs/MigrationLog]]。
产品优先级以 [[02-reference/adr/0011-event-led-sparse-record-product-loop]] 和仓库根目录 `CONTEXT.md` 为准；历史 brainstorm 只用于追溯。

## 当前目标

当前目标是完成 `Health Event Contract` 的 Task 8 acceptance verification。跨前后端合同、Today 手机端确认入口、自动化检查和文档对齐已完成；真实数据库 A/B ownership 与 start → check-in → end → history 流程仍待本地 PostgreSQL 可用后验证。通过后再进入 `Proactive Suggestion Runtime`。

长期阶段排序见 [[00-current/Work_Phase_Guide]]。

## 立即下一步

1. **完成 Health Event Contract acceptance verification**
   - 启动可用的本地 PostgreSQL/test runtime，验证用户 A 无法读取或关联用户 B 的 event ID
   - 验证开始 → check-in → 结束 → 历史读取，确认系统建议没有绕过用户确认写入状态
2. **通过 acceptance 后执行 Proactive Suggestion Runtime**
   - 子计划：[`../../plans/2026-08-07-proactive-suggestion-runtime.md`](../../plans/2026-08-07-proactive-suggestion-runtime.md)
   - 先冻结健康事件写入后的 domain-event payload、去重、冷却和失败降级边界
   - 再让记录写入触发服务端有界重算，Today 只读取已有结果并呈现陈旧/失败状态
3. **继续冻结非核心平台**
   - 手机端是唯一核心产品
   - 桌面端和完整认证 Web 应用保留现有代码，但不继续功能对等、发行或产品化
   - `Luminous-website` 是竞赛/营销表面，不是签入式产品壳

## 延后但有用

- P2 项（Brainstorm P2 — 1.1.0 候选）：就诊摘要模板化、症状-用药关联时间线、记录连续性激励
- P3 项（Brainstorm P3 — 1.2.0+ 候选）：红旗信号规则、智能提醒优先级、可验证平台范围内的健康数据桥接、快捷记录 Widget、Assistant 嵌入式重构
- agent-assisted support discovery 与 map-backed nearby-care lookup
- Today/Mine 使用的环境信号
- medicine-side scan/OCR/barcode/prescription action 形态
  - 需要产品范围 + 后端合同

## 用药安全后续

1. **Allergy severity null-handling** — `severity == null` 但 `reaction == 'anaphylaxis'`
2. **CN medicine interaction gap** — CN 来源药品对 interaction checker 不可见
3. **Avoid-tier escalation policy** — 结构化 `avoid` 结论保持低于 red-flag
4. **Duplicate cross-language matching** — 「对乙酰氨基酚」vs "paracetamol"
5. **DrugBank synonym over-generalization** — 不同 NSAIDs 共享同义词

## 不要现在开始

- 独立 More tab 或通用 utility hub
- 女性健康或经期管理
- 运动恢复
- 专家健康包
- 智能设备或家庭档案
- 桌面端功能对等、发行或产品化
- 完整认证 Web 应用继续扩展
- 皮肤识别或报告照片导入
- medicine-side OCR/barcode/photo/prescription 识别 UI 或合同
- 真实 FCM/APNs push 投递
- 真实 SMS 投递
- 后端提醒投递 worker
- 未明确批准的付费或需要资质的外部服务
- 目标 Today/Mine job 明确前的 environment 前端连线

## 合同引用

- `Lucent/docs/01-reference/contracts/reminder-contract.md` — 提醒边界
- `Lucent/docs/01-reference/contracts/environment-contract.md` — 环境快照边界
- `Lucent/docs/01-reference/contracts/data-sources.md` — 药品数据源/导入策略
- `Lucent/docs/01-reference/contracts/mine-settings-contract.md` — 导出/状态/支持资源边界
