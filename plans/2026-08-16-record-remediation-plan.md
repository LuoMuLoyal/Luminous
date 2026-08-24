# 日常记录(Record,含餐食分析)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/record-日常记录与餐食分析.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考——速览表统计口径自相矛盾(22 项 vs 21 项),本文一律不引用其统计数字)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 6 位。

## 一、剩余改造项(按优先级分组)

### P1-3 餐食分析分层触发(懒触发，调研 §1 改造建议，0.1.0 后)

- 现状:任何带 1 张图片的 meal 记录都自动排队完整链路(vision + 分解 2 次 LLM 调用),`worker.service.ts` 全量执行。
- 方案:保存后自动执行一次低成本 vision 识别(产出 `mealDescription` + `foodItems[]`);菜品分解与 grounding 推迟到用户查看详情、要求精确营养或候选洞察确有需要时再触发。worker 按 `analysisStatus` 分阶段推进,`analysis_failed` 兜底语义不变。
- 涉及文件:Lucent `services/meal-analysis/worker.service.ts`、`vision.service.ts`、`records.service.ts`(详情触发入口);客户端详情页摘要卡增加「分析中/可深入分析」状态展示(`widgets/meal/analysis_summary_card.dart`)。
- 分工:后端改 worker 分段调度与按需触发端点;客户端改详情页状态与触发调用。
- 依赖:无；餐食分层触发为 0.1.0 后事项。

### P1-4 vital 时间序列基建(体重/血糖/血压统一)(调研 §2.6，已决策，0.1.0 后)

> 本节为跨计划共享基建的权威定义,health-event 计划(C-1 `weightKg`)与 report 计划(纵向洞察周/月单维趋势)引用本节,不在各自计划重复展开。

- 现状:vital 已有完整表单创建与真落库(后端 kind 枚举与 Prisma `DailyRecordKind` 对应),但无时间序列维度;档案字段 `weightKg` 是单点基线。
- 方案:
  - 档案字段 `weightKg` 保留为当前基线;新增体重时间序列记录,来源 = 手动录入 + 已接入的平台导入。
  - 体重、血糖趋势、血压合并为统一「vital 时间序列」基建:同一查询/聚合路径产出单维趋势(带覆盖率标注,沿用稀疏语义:unknown 天不绘点、不静默归零)。
  - 趋势消费方:纵向洞察周/月单维趋势(report 计划)、桌面趋势图(P2-3,同源)。
  - 体重记录入口放进记录页快捷记录(quick-entry 面板新增/替换入口,复用现有偏好基建)。
- 涉及文件:Lucent `daily-records`(vital 聚合查询)、趋势输出契约;客户端 `lib/features/record/`(quick-entry 入口、vital 表单复用)、趋势数据层(替换 `_staticTrends`,见 P2-3)。
- 分工:后端出统一 vital 时间序列查询/聚合(带 `ObservedMetric` 式覆盖率);客户端接入 quick-entry 与趋势展示。
- 依赖:ObservedMetric 口径统一(见「二、跨计划引用」);平台导入通道依赖 health-event/mine 侧既有桥接能力。

### P2-3 桌面趋势图真实数据化(调研 §4.2，桌面高级能力冻结)

- 现状:`lucent.dart` 的 `_staticTrends` 含一条硬编码血糖序列(`[5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9]`),全库无任何 widget 引用 `RecordTrend`,属死代码与误导性数据资产。
- 方案:不删除,改造——将硬编码序列替换为真实 vital 时间序列查询(P1-4 同源),unknown 天不绘点;`_staticTrends` 与 `RecordTrend` 相关定义替换为真实查询函数,严禁硬编码样本点。作为桌面「大屏纵向阅读」资产保留。
- 挂起:桌面/Web 形态待 ADR-0012,见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md),本文不展开形态决策。
- 依赖:P1-4(vital 时间序列基建);ADR-0012。

### P2-4 桌面月历服务端标记(调研 §4.3，桌面高级能力冻结)

- 现状:`Active_UI_Record.md` 声称「同月时使用父组件传入的 days(含服务端标记)」,实际 `fetchDashboard.monthDays` 来自 `_staticMonthDays`(仅选中/今天高亮),文档言过其实。
- 方案:改造为真实服务端标记,复用 daily records 按日聚合(与 P2-3 同源);同步修正 `Active_UI_Record.md` 表述。
- 挂起:随桌面/Web 调研启用,见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)。
- 依赖:ADR-0012;summary 接线可提供聚合路径参考。

## 二、跨计划引用与依赖

- **ObservedMetric 口径统一**:`summarizeWaterMetrics`/`toObservedWaterMetric`(Lucent `common`)四处共用 mapper 的口径统一方案见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开;P1-4 的 vital 趋势输出沿用该口径。
- **桌面/Web 形态挂起**:P2-3、P2-4 不再扩展 Flutter 产品面；桌面高级能力继续冻结，本文不展开。
- **被引用**:本文档「P1-4 vital 时间序列基建」一节为共享基建定义,health-event 计划(C-1 `weightKg`)与 report 计划(纵向洞察趋势)引用本节。
- **契约**:本计划不改 OpenAPI 契约;若 P1-4 新增 vital 趋势端点,需走 `pnpm export:openapi` + `dart run scripts/bootstrap_generated_sources.dart` 标准流程。

## 三、本计划内执行顺序

1. P1-3、P1-4（0.1.0 后）：餐食分层与 vital 时间序列按既有 P1 和依赖顺序恢复。
2. P2-3、P2-4：桌面高级能力冻结。

## 四、已决边界与延期项

- 饮水目标唯一来自 `user-settings`；`ObservedMetric` 仅来自记录事实，未知不得以 0 代替。
- Today 联动由 Lucent 计算门控：近 7 天至少 3 条有效记录，或相对个人基线变化至少 50%；所有来源共享每天 3 次分析预算。
- 餐食分层分析、vital 时间序列（含体重）为 0.1.0 后；Flutter 桌面趋势图与月历能力冻结。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
- 调研文档全文无工作量(人日)估算,本计划同样不做估算。
