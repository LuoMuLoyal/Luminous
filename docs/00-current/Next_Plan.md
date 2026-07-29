# Luminous Next Plan

Last updated: 2026-07-18

本文件只记录下一步实现顺序。当前事实见 [[00-current/Current_State]]；变更历史见 [[03-logs/MigrationLog]]。
产品优先级口径以 [[01-product/Product_Brainstorm_2026-07-07]] 为准。

## 当前目标

P0-P2 UI/UX 优化全部完成。当前处于 Phase 5 Release Gate 阶段。下一步运行发布验证门。

长期阶段排序见 [[00-current/Work_Phase_Guide]]。

## 立即下一步

1. **运行发布验证门**
   - `flutter analyze --no-pub`
   - `flutter test --no-pub`
   - `dart run scripts/run_daily_checks.dart`（仓库安全级）
   - 集成测试框架选型暂缓，待评估后引入
2. **助手演进限定在 concrete 场景**
   - 仅当选定具体缺失用户任务时才扩展 tools/proposals
   - Memory 保持可选、显式、用户控制
3. **Web 作为 deliberate 决策保留**
   - `Luminous-site` 是竞赛/营销表面，不是签入式产品壳
   - 如后续需要认证 Web 报告预览，另开专用计划

## 延后但有用

- P2 项（Brainstorm P2 — 1.1.0 候选）：就诊摘要模板化、症状-用药关联时间线、记录连续性激励
- P3 项（Brainstorm P3 — 1.2.0+ 候选）：红旗信号规则、智能提醒优先级、Apple Health 桥接、快捷记录 Widget、Assistant 嵌入式重构
- agent-assisted support discovery 与 map-backed nearby-care lookup
- Today/Mine 使用的环境信号
- Report score/finding/pattern/trend/AI action card drill-down
  - 需要产品决策：detail page vs 筛选 Record tab
- medicine-side scan/OCR/barcode/prescription action 形态
  - 需要产品范围 + 后端合同
- 超越竞赛站的真实认证 Web 报告预览

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
