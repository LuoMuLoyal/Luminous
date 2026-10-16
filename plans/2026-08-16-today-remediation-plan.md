# Today 今日建议改造计划

Created: 2026-08-16
Revised: 2026-10-16（按代码现状更新 F-8 剩余项的具体位置与 F-14 依赖；见下）

> **2026-10-16 状态：F-8 剩余项未做（0.1.0 前）；F-14 未开工（0.1.0 后）。**

## 一、剩余改造项(按优先级分组)

### P1（0.1.0 前）

**1. F-8 概览指标 Today 侧剩余修复:completedCount 退役**

- 进展:降级标记已落地——repository 各数据源 try/catch 产出 `_degradedObservedMetric`/`_degradedDashboard`,失败指标显示「暂不可用」而非 0/`--`(`today/data/repositories/lucent.dart`、`domain/entities/dashboard.dart` 的 `TodayObservedMetricState.degraded`、`view_models.dart` 的 `isDegraded` 渲染)。
- **2026-10-16 核实的剩余点**(三处仍消费 legacy 计数,均未迁 observedMetric):
  1. `today/presentation/widgets/shared/view_models.dart:241` —— `_waterOverviewValue` 的第三个分支 `todayWaterOverviewCount(water.completedCount, water.targetCount)`;前两个分支已用 `observedMl`/`observedMetric`,只有 observedMetric 为空时才落到这里。
  2. `today/presentation/widgets/shared/view_models.dart:248` —— `dashboard.water.remainingCount` 供 `buildAiSummaryBullets` 的饮水 bullets(`todayAiSummaryWaterRemaining`)。
  3. `today/domain/entities/dashboard.dart:136` —— `TodayWaterSummary.remainingCount` getter 本身(`targetCount - completedCount`),以及 `completedCount` 字段(`lucent.dart:227` 由 `recordCounts['water']` 填充,`:327` 签出态填 0)。
- 退役口径:问候语已迁 observedMetric(F-9),bullets 与概览兜底按同一口径迁——**不得把 `remainingCount` 当「目标−已喝」再算一遍**,它必须是 observedMetric 的派生展示值。
- observedMetric 口径的权威定义见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开。
- 分工:纯前端 `today` data/domain。

### P2

**2. F-14 Today 侧「环境上下文」消费方式（0.1.0 后）**

后端真实化方案(高德天气/空气 API + Redis 缓存、城市手动选择)见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的天气真实化一节,本文不重复展开。Today 侧只做:
- 移除 `LucentTodayRepository.fetchDashboard` 的硬编码静态填充(花粉 high/紫外线 medium、静态 `mealSuggestion`/`lumiSuggestion`,`lucent.dart`),字段通路保留、以真实数据源重新装配。
- 环境数据**不作为 Today 主卡**,降级为「环境上下文」:进入助手工具与记录上下文(供过敏/感冒场景引用),presentation 层不新增 Today 首屏卡片。
分工:前端删静态填充;装配依赖跨计划高德客户端落地。

## 二、跨计划引用与依赖

- 高德天气/空气 API 真实化(后端客户端、缓存、城市选择):[`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 天气真实化一节;本文只写 Today 侧消费方式(F-14)。通知基础设施/JPush 通道同此计划。
- observedMetric 口径权威定义:[`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) F-5 一节;本文只写 Today 侧修复(F-8)。
- 本计划写全、供他计划引用:**「建议反馈与升级通知机制」**(F-2 反馈闭环、F-7 触发扩展、建议升级通知执行器「前台应用内、后台本地优先、JPush 仅失败/不可达回退、每天最多 1 条」)——health-event 与 mine 计划的通知/反馈需求引用此节,不重复定义;该机制已落地,实现与验证见迁移日志 2026-08-17。
- 后端 API 变更(F-6 DTO、F-1 端点、F-7 触发)后须 `pnpm export:openapi`(Lucent)+ `dart run scripts/contract/bootstrap.dart`(Luminous)。
- 本计划全部面向移动端；桌面高级能力冻结，独立 Next.js + Tauri MVP 于 0.1.0 后启动。

## 三、本计划内执行顺序

1. F-8 剩余项（0.1.0 前）：`remainingCount` 退役,bullets 消费方统一到 observedMetric。
2. F-14（0.1.0 后）：环境装配,随跨计划高德客户端落地。

## 四、已决边界与延期项

- F-16 采用数据层 `degraded` 加页面分 section 状态；服务端分析首屏接入后，前端本地拼装 bullets 退役。空状态是无 LLM、无通知、无观测的冷启动引导。
- 每位用户每天最多一条建议升级通知。前台仅应用内提示；后台本地通知优先，JPush 仅在本地失败或不可达时回退；站内信只记录。R2 事件规则见 health-event 计划。
- 花粉/UV 不采集、不展示；环境只作用户手选城市的真实天气/AQI 上下文，且为 0.1.0 后事项，不作为 Today 主卡。
- F-19 中期结构化入口、F-11 返回路径仅在未来独立任务中评估。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
