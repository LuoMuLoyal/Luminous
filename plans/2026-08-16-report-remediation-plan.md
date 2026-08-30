# 报告模块(report→review)改造计划

Created: 2026-08-16
Updated: 2026-08-30（R-3/R-4 已完成，仅保留 R-5/R-6）

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/report-报告模块.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 8 位。

## 一、剩余改造项

**R-5 服务端 409 双保险(#15 附注，0.1.0 前）**

- 现状:#15 已修复(主路径无入口 + legacy readiness 门控 + prompt 约束),但后端 `summary/generate*` 端点无服务端「数据不足拒绝」守卫,直接调 API 仍可对空数据生成。
- 方案:服务端对全 insufficient 请求返回 409/空结果,作为客户端 gate 之外的双保险。
- 口径:服务端数据不足拒绝守卫为必做项;当前未实现(仅 prompt 弃权 + fallback abstain 空结果语义,无 409 硬拒绝)。

**R-6 文档漂移更新(#17 附注，0.1.0 前）**

- 现状:`Mock_Or_Deferred.md`「clinic share link 无应用内链接管理,只能重新生成」已过时(分享管理已上线);`Active_UI_Report.md` 对 legacy scalar 的描述与 `context.service.ts` 实际 unknown→0 投影不一致。
- 方案:更新两处文档;legacy scalar 口径描述随 R-4 的 #21 改造完成后自然失效。
- 进展:两处文档均未更新。

## 二、跨计划引用与依赖

- 引用 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md):vital 趋势数据源基建(R-3/R-4 的纵向洞察输入依赖)。
- 引用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md):F-5 一节的 ObservedMetric/覆盖率口径定义(R-3、R-4 之 #21 共用)。
- 引用 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md):#20 Flutter 桌面/Web 大屏趋势比较冻结项；独立 Next.js + Tauri MVP 在 0.1.0 后启动。

## 三、本计划内执行顺序

1. R-5 服务端 409 双保险（必做项）。
2. R-6 文档更新。

## 四、已决边界与保留项

- 0.1.0 前删除服务端 Dashboard 评分计算、PDF 评分卡与 Flutter legacy score 模型；医院 PDF 不保留综合评分。
- 六开关全部真实生效，严格选中边界适用于 API、预览、PDF 和公开分享；原始 JSON/CSV 可移植导出延后至 0.1.0 后 TODO。
- R-5 的服务端数据不足拒绝守卫为必做项；无观测不生成、不通知，单点只陈述事实，不生成趋势结论。
- 桌面/Web 大屏比较不扩展 Flutter 产品面；独立 Next.js + Tauri 桌面 MVP 于 0.1.0 后启动。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
