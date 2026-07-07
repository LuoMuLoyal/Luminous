# Luminous Next Plan

Last updated: 2026-07-07

本文件只记录下一步实现顺序。当前事实见 [[00-current/Current_State]]；变更历史见 [[03-logs/MigrationLog]]。

## 当前目标

**Shipping Luminous 1.0.0**。两个 P0 功能（Medicine 安全检查三层展示 + Report 门控透明度）已完成。剩余 P1 项和发布门待执行。

长期阶段排序见 [[00-current/Work_Phase_Guide]]。当前进入发布前收敛期：完成 P1 体验优化后运行发布门。

## 立即下一步

1. **P1 体验优化**
   - Today 信息密度收窄（Brainstorm A 项）
   - Record 快速入口动态排序（Brainstorm C 项）
   - Mine 档案完整度提示（Brainstorm E 项）
2. **运行完整 1.0.0 验证门**
   - `dart run tool/run_daily_checks.dart`（仓库安全级）
   - 集成测试框架选型暂缓，待评估后引入
3. **门通过后打 1.0.0 tag**
4. **助手演进限定在 concrete 场景**
   - 仅当选定具体缺失用户任务时才扩展 tools/proposals
   - Memory 保持可选、显式、用户控制
5. **Web 作为 deliberate 决策保留**
   - `Luminous-site` 是竞赛/营销表面，不是签入式产品壳
   - 如后续需要认证 Web 报告预览，另开专用计划

## 延后但有用

- agent-assisted support discovery 与 map-backed nearby-care lookup
- Today/Mine 使用的环境信号
- Report score/finding/pattern/trend/AI action card drill-down
  - 需要产品决策：detail page vs 筛选 Record tab
- medicine-side scan/OCR/barcode/prescription action 形态
  - 需要产品范围 + 后端合同
- 超越竞赛站的真实认证 Web 报告预览
- 通过 Apple Health / Health Connect 的系统健康桥接

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

- `Lucent/docs/public/reminder-contract.md` — 提醒边界
- `Lucent/docs/public/environment-contract.md` — 环境快照边界
- `Lucent/docs/public/data-sources.md` — 药品数据源/导入策略
- `Lucent/docs/public/mine-settings-contract.md` — 导出/状态/支持资源边界
