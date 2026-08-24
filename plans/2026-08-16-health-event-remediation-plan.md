# 健康事件与健康档案(health-event)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/health-event-健康事件与健康档案.md`(已审阅;内容以逐功能分析为准改写,速览表仅作参考——该调研文档无结尾汇总章节,分期以速览表 P0/P1/P2 框架为准)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 7 位。

## 一、剩余改造项(均为 0.1.0 后)

### 1. H-4 事件类型 kind 改造为回顾区筛选标签（0.1.0 后）

- 现状:契约与表有 `kind`(`symptom | other`),但 `StartEventSheet` 无选择入口,后端 `EventsService.create` 与 controller `toItem` 均 `kind ?? symptom` 兜底,kind 不产生任何行为差异。
- 改造方案:kind 字段保留(不删字段、不删 `kind === 'other'` 跳过建议重算分支),改造为 Review 历史区「按事件类型筛选」标签——按 kind 过滤历史列表,纯 UI、零后端改造。涉及 `report/presentation/widgets/sections/review_history.dart` 筛选行与 `reviewEventKindLabel` 展示。
- 前后端分工:纯前端;后端 `GET /reports/reviews` 已返回 kind,无需改动。
- 依赖:无。中期增强「症状标签集合」(创建时勾选症状、与记录页症状库联动)为 0.1.0 后事项。

### 2. C-1 `weightKg` 改造为体重记录维度（0.1.0 后）

- 现状:weightKg 仅 user-health-context 自读写,后端无业务消费,前端只展示/计数(半用)。
- 改造方案:档案字段保留为当前基线,新增体重时间序列记录(手动 + 平台导入),入口放记录页快捷记录;时间序列与血糖、血压合并为「vital 时间序列」基建,进纵向洞察周/月单维趋势(带覆盖率标注)。
- 前后端分工:后端提供 vital 时间序列读写与覆盖率标注;前端提供记录页入口与 Mine 展示改造。
- 依赖:vital 时间序列基建(含 ObservedMetric 口径)归属 record 与 medicine 计划——基建方案见 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md) 的 vital 基建一节,ObservedMetric 口径见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开。

### 3. C-1 `conditions` 进助手上下文 + 事件创建可选关联（0.1.0 后）

- 现状:conditions 进 risk check LLM 上下文与就诊摘要,但无规则单独消费(半用)。
- 改造方案:保留为档案字段;助手 `get_user_profile` 等 read tool 可读疾病史以回答「结合我的情况」类问题;事件创建(`StartEventSheet` + `EventsService.create`)增加可选关联入口。**不进药物风险判断**，待规则库成熟后以独立任务评估。
- 前后端分工:后端 assistant read tool 与事件关联字段;前端创建表单与展示。
- 依赖:无(不依赖其他计划)。

### 不排期(如实记录,不占 P0/P1/P2 改造位)

- C-1 `emergencyContactName/Phone`:僵尸字段,标注延后,**不排期**。
- C-1 `extras`:自由扩展槽死字段,归档保留、标注不接入主路径,**不排期**。
- H-7 标题更正端点:设计如此不做;仅当真实用户反馈标题笔误高频时,再补 P2 最小端点(仅 title、事件进行中可改)。

## 二、跨计划引用与依赖

- vital 时间序列基建(C-1 weightKg 依赖):见 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md) 的 vital 基建一节。
- ObservedMetric 口径(vital 趋势数据口径):见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节。
- Review 职责改版为日/周/月洞察、事件成为专题视图(H-8 定位补充):归属 report 计划([`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md)),本计划只标注依赖、不承担该项;事件详情接线(H-6)已随改造项 2 落地,与 report 计划的 Review 信息架构改版不再有落地顺序耦合。
- 本计划拥有并写全的横切资产:档案字段逐字段处置决策(改造项 1/2/3 与不排期清单;改造项 6 C-3 已处置,决策执行记录见迁移日志 2026-08-20)。
- 桌面/Web 形态不再扩展 Flutter 产品面；独立 Next.js + Tauri MVP 在 0.1.0 后启动，不展开。

## 三、本计划内执行顺序

0.1.0 前任务已全部完成（改造项 6 C-3 已处置）。改造项 1(H-4)、2(weightKg) 与 3(conditions)均为 0.1.0 后，按既有 P1 及依赖顺序恢复。

## 四、已决边界与延期项

- R2 事件期为创建日至结束日；未结束事件持续有效。仅连续 3 天中至少 2 次 check-in「加重」，或新增症状记录时可触发。健康建议升级通知每天最多一条。
- Lucent 权威计算档案完整度、缺口与 `ObservedMetric`；客户端只展示。硬编码假过敏在 0.1.0 前移除，不再以 0 代替未知。
- H-4 事件类型/症状标签、体重时间序列和 `conditions` 扩展均为 0.1.0 后；药物风险中使用 conditions、red flag 对齐、标题更正与选项预读重试继续留待独立任务。
- 新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
