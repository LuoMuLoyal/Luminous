# Today 今日建议改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/today-今日建议.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 4 位。

## 一、目标与范围

范围:`Luminous/lib/features/today/`、`Luminous/lib/features/health_context/`(含联动的 `health_event`、`record` quick-entry);后端 `Lucent/src/modules/today-suggestion/`、`Lucent/src/modules/today-analysis/`。

目标:

- 补上最大的产品缺口:让服务端事件驱动的 Today Analysis 物化结果出现在首屏(F-6 前端接线 + F-7 触发边界扩展),使「主动分析」闭环——已处置(F-6/F-7 均已落地)。
- 修掉语义裂缝:问候语饮水口径(F-9)、页级状态锁(F-16)、指标降级标记(F-8)、启发式信号规则降级(F-19)——F-9/F-16/F-19 已处置;F-8 降级标记已落地,`remainingCount` 退役未完成(见 §三)。
- 清掉竞赛期残留:静态环境数据、硬编码药名枚举、静态 recommendations 端点(F-14/F-18),按真实化方向改造,不删除——F-18 已处置;F-14 环境装配为 0.1.0 后。
- 把 6 个「保留」项附带的小修(skip_dose 接线、静默刷新、观察项反馈入口、重试提示、一键饮水接线、死字段接真实未读数)全部落地——已处置。
- 本计划拥有并写全「建议反馈与升级通知机制」一节(F-2 反馈闭环、F-7 物化扩展、建议升级通知执行器),health-event 与 mine 计划引用此节——已处置(落地记录见迁移日志 2026-08-17)。

## 二、保留不动(清单)

- F-1 主建议卡主体:规则引擎→物化→只读 GET 链路、结构化证据、边界文案、LLM 不可用时人工审校模板回退(仅 secondaryActions `skip_dose` 列入改造,已处置)。
- F-3 建议卡 AI 解释:按需 LLM、失败回退原文并如实标记 `aiGenerated: false`(仅重试策略小修列入改造,已处置)。
- F-4 materialization 五态呈现与缓存兜底:ready/stale/pending/failed/empty 如实区分、旧卡保留、DataChangeBus 去抖刷新——同时作为 F-6 改造复用的模式蓝本。
- F-11 轻动作区 5 个快捷入口:纯导航、路由真实；返回路径维持现状，不另立项。
- F-13 baseline observation:只收录 observed 且 coverage sufficient 的值,连续 2 天门控趋势规则。
- F-17 建议卡曝光测量:`suggestion_impression` 视口内首次上报、去重防重。
- F-20 health_context 快照层:cache-first + pending_sync 队列 + SyncWorker 真实重放,是多域共同事实底座。

## 三、改造项(按优先级分组)

### P1（0.1.0 前）

**1. F-8 概览指标 Today 侧剩余修复:completedCount 退役**

- 进展:降级标记已落地——repository 各数据源 try/catch 产出 `_degradedObservedMetric`/`_degradedDashboard`,失败指标显示「暂不可用」而非 0/`--`(`today/data/repositories/lucent.dart`、`domain/entities/dashboard.dart` 的 `TodayObservedMetricState.degraded`、`view_models.dart` 的 `isDegraded` 渲染)。
- 剩余:`TodayWaterSummary.remainingCount`(目标次数−记录条数,`domain/entities/dashboard.dart`)逐步下线,`buildAiSummaryBullets` 与 `_waterOverviewValue` 兜底仍消费 `remainingCount`/`completedCount`——问候语已迁 observedMetric(F-9),bullets 消费方未迁。
- observedMetric 口径的权威定义见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开。
- 分工:纯前端 `today` data/domain。

### P2

**2. F-14 Today 侧「环境上下文」消费方式（0.1.0 后）**

后端真实化方案(高德天气/空气 API + Redis 缓存、城市手动选择)见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的天气真实化一节,本文不重复展开。Today 侧只做:
- 移除 `LucentTodayRepository.fetchDashboard` 的硬编码静态填充(花粉 high/紫外线 medium、静态 `mealSuggestion`/`lumiSuggestion`,`lucent.dart`),字段通路保留、以真实数据源重新装配。
- 环境数据**不作为 Today 主卡**,降级为「环境上下文」:进入助手工具与记录上下文(供过敏/感冒场景引用),presentation 层不新增 Today 首屏卡片。
分工:前端删静态填充;装配依赖跨计划高德客户端落地。

## 四、跨计划引用与依赖

- 高德天气/空气 API 真实化(后端客户端、缓存、城市选择):[`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 天气真实化一节;本文只写 Today 侧消费方式(F-14)。通知基础设施/JPush 通道同此计划。
- observedMetric 口径权威定义:[`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) F-5 一节;本文只写 Today 侧修复(F-8)。
- 本计划写全、供他计划引用:**「建议反馈与升级通知机制」**(F-2 反馈闭环、F-7 触发扩展、建议升级通知执行器「前台应用内、后台本地优先、JPush 仅失败/不可达回退、每天最多 1 条」)——health-event 与 mine 计划的通知/反馈需求引用此节,不重复定义;该机制已落地,实现与验证见迁移日志 2026-08-17。
- 后端 API 变更(F-6 DTO、F-1 端点、F-7 触发)后须 `pnpm export:openapi`(Lucent)+ `dart run scripts/bootstrap_generated_sources.dart`(Luminous)。
- 本计划全部面向移动端；桌面高级能力冻结，独立 Next.js + Tauri MVP 于 0.1.0 后启动。

## 五、本计划内执行顺序

1. F-8 剩余项（0.1.0 前）：`remainingCount` 退役,bullets 消费方统一到 observedMetric。
2. F-14（0.1.0 后）：环境装配,随跨计划高德客户端落地。

## 六、已决边界与延期项

- F-16 采用数据层 `degraded` 加页面分 section 状态；服务端分析首屏接入后，前端本地拼装 bullets 退役。空状态是无 LLM、无通知、无观测的冷启动引导。
- 每位用户每天最多一条建议升级通知。前台仅应用内提示；后台本地通知优先，JPush 仅在本地失败或不可达时回退；站内信只记录。R2 事件规则见 health-event 计划。
- 花粉/UV 不采集、不展示；环境只作用户手选城市的真实天气/AQI 上下文，且为 0.1.0 后事项，不作为 Today 主卡。
- F-19 中期结构化入口、F-11 返回路径仅在未来独立任务中评估。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
