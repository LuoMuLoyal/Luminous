---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-15
---

# Luminous Next Plan

Last updated: 2026-08-15

本文件只记录下一步实现顺序。当前事实见 [[00-current/Current_State]]；变更历史见 [[03-logs/MigrationLog]]。
产品优先级以 [[01-product/Product_Vision]] 和仓库根目录 `CONTEXT.md` 为准；ADR-0011 与历史 brainstorm 只用于追溯已经完成的事件闭环。

## 当前目标

产品闭环程序（`Health Event Contract`、`Proactive Suggestion Runtime`、`Sparse Record Semantics`、`Review Experience`、`Visit Summary and Product Measurement`）已全部实施完毕，计划文件已删（实施完毕文件已删）：健康事件跨前后端合同、主动重算、Today 只读物化、统一稀疏数据语义、事件优先回顾主路径与可撤销分享、字段级隐私、隐私克制的闭环测量（客户端四个成功边界事件 + 服务端权威事件 + 管理员漏斗）均已落地并通过全量验证。

当前目标转为 **0.1.0 发布验证**（按仓库根 `ROADMAP.md`「Current Release → 0.1.0」）：只修阻断集成/发布的缺陷，跑完整移动端与全栈发布门禁。长期阶段排序见 [[00-current/Work_Phase_Guide]]。

## 立即下一步

1. **执行 0.1.0 发布验证**
   - 全移动端 + 全栈发布门禁（`flutter analyze` / `flutter test` / daily checks / 双仓 docs 检查）
   - 只修阻断当前集成或发布的问题，方向文档与运行时差异保持明确标注
2. **保持当前发布表面，调研未来大屏角色**
   - 手机端是当前首发与用户验证表面，不再写成永久唯一产品表面
   - 桌面端和 Web 端不做机械功能对等；“大屏阅读、比较和理解纵向健康信息”的用户任务及 Next.js + Tauri 2 候选路线等待独立调研
   - `Luminous-website` 是竞赛/营销表面，不是签入式产品壳
3. **延后项按优先级推进**（见 [[00-current/TODO]] 与 ROADMAP P2/P3）：AI 会话重命名与删除、就诊摘要模板化、症状-用药关联时间线等

## 延后但有用

- P2 项（Brainstorm P2 — 1.1.0 候选）：就诊摘要模板化、症状-用药关联时间线、暂停后恢复与低负担记录反馈
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
- 未完成用户任务与技术路线调研前，启动桌面/Web 产品化或承诺与手机端功能对等
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
