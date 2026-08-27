# 报告模块(report)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/report-报告模块.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 8 位。

## 一、剩余改造项(按优先级分组)

### P1（0.1.0 前）

**R-3 周/月纵向洞察生成器(#14，0.1.0 前）**

- 进展:服务端口径与客户端死代码清理已落地(Lucent `9549f48c` 换 prompt/schema 弃权口径与 `coverage/observedPattern/lowRiskAction/disclaimer` 输出、`copy.service.ts` 全 insufficient → abstain;Luminous `eec70285` 删非流式 `generate()`,展示层改三段渲染);**客户端装配已完成**(新建 `ReviewAiSummarySection` 装入 Review 主路径,不再依赖 `ReportDashboard` 实体)。
- 剩余:vital 趋势数据源依赖 record 计划 vital 基建与 medicine 计划 F-5 口径;日/周/月范围切换与趋势图表装配见 R-4 #19。

### P2（legacy 打包，0.1.0 前）

**R-4 legacy 改造包(#19-#22 打包，0.1.0 前）**

- 进展:#20 已落地(Lucent `912c8efa` 移除 `buildScore` 与 DTO score 输出、Luminous `68d42f47` 移除评分卡与 score 引用);客户端非流式 `generate()` 死代码已随 R-3 删除;#22 建议历史已移入 Review 主路径(新建 `ReviewSuggestionHistorySection`);#19/#21 与后端端点/缓存桥裁剪未完成。
- 方案(打包执行,不删除功能与代码):
  - #19:`legacy_dashboard_compat.dart` 等重新装配为 Review 日/周/月纵向洞察视图(聚合计算逻辑保留,`top_bar.dart` 范围切换改为日/周/月切换);路由 `/report/legacy` 与 domain 侧 `dashboard.dart` 实体/mapper 视装配进度迁移。
  - #21:legacy 图表改按 `observedMetric` 口径输出:unknown 天不绘点、只绘已记录数据,图表旁标注「有记录 N 天 / 范围 M 天」覆盖率;废除 unknown→0(服务端)与 unknown→flat/general(客户端)两处口径。observedMetric 口径定义引用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节。
  - #22:建议历史已移入 Review「建议历史」段落(新建 `ReviewSuggestionHistorySection`),数据源 `/today/suggestions/history`,保留 title|reason|type 去重取最高生命周期状态与详情面板。
  - 同包清理:后端零消费端点(`summary/generate` 非流式、`summary/generate/async` + `status`、`clinic-summary/export/async` + `status`)下线或降级为不暴露;旧 Redis `createShareLink` 缓存桥清理。先做客户端死代码清理与数据契约拆分,再评估后端裁剪,避免先砍后端影响导出(#17 PDF 依赖 dashboard 聚合)。
- 依赖:data-export PDF 数据源替代方案须先行确认(见第四节);vital 数据源引用 record 计划 vital 基建一节。

**R-5 服务端 409 双保险(#15 附注，0.1.0 前）**

- 现状:#15 已修复(主路径无入口 + legacy readiness 门控 + prompt 约束),但后端 `summary/generate*` 端点无服务端「数据不足拒绝」守卫,直接调 API 仍可对空数据生成。
- 方案:服务端对全 insufficient 请求返回 409/空结果,作为客户端 gate 之外的双保险;随 R-3/R-4 改造落地。
- 口径:服务端数据不足拒绝守卫为必做项;当前未实现(仅 prompt 弃权 + fallback abstain 空结果语义,无 409 硬拒绝)。

**R-6 文档漂移更新(#17 附注，0.1.0 前）**

- 现状:`Mock_Or_Deferred.md`「clinic share link 无应用内链接管理,只能重新生成」已过时(分享管理已上线);`Active_UI_Report.md` 对 legacy scalar 的描述与 `context.service.ts` 实际 unknown→0 投影不一致。
- 方案:更新两处文档;legacy scalar 口径描述随 R-4 的 #21 改造完成后自然失效。
- 进展:两处文档均未更新。

## 二、跨计划引用与依赖

- 本计划拥有并写全:report 域全部改造项(R-1~R-6)、legacy 打包改造的执行节奏与后端裁剪顺序。
- 引用 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md):vital 趋势数据源基建(R-3/R-4 的纵向洞察输入依赖)。
- 引用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md):F-5 一节的 ObservedMetric/覆盖率口径定义(R-3、R-4 之 #21 共用)。
- 引用 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md):#20 Flutter 桌面/Web 大屏趋势比较冻结项；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- 横切条目(Dashboard 聚合耦合、`applySelectedFields` 单一出口、DataChangeBus、PIN elevation、product events、旧响应解包、`aiSummariesEnabled`、BullMQ)已在 R-2/R-3/R-4 各自展开,无跨计划归属冲突。

## 三、本计划内执行顺序

1. R-3 纵向洞察生成器(P1,依赖 record 计划 vital 基建与 medicine 计划 F-5 口径就绪;服务端口径、客户端死代码清理与 Review 视图装配已完成,剩余日/周/月范围切换与趋势图表装配随 R-4 #19)。
2. R-4 legacy 打包（0.1.0 前）:先确认 data-export PDF 数据源替代方案 → 客户端死代码清理与数据契约拆分(#20 已落地)→ 视图重装配(#19/#21/#22)→ 评估后端裁剪。
3. R-5 服务端 409 双保险、R-6 文档更新,随 R-3/R-4 附带完成(R-5 为必做项)。

## 四、已决边界与保留项

- 0.1.0 前删除服务端 Dashboard 评分计算、PDF 评分卡与 Flutter legacy score 模型；医院 PDF 不保留综合评分。
- 六开关全部真实生效，严格选中边界适用于 API、预览、PDF 和公开分享；原始 JSON/CSV 可移植导出延后至 0.1.0 后 TODO。
- R-5 的服务端数据不足拒绝守卫为必做项；无观测不生成、不通知，单点只陈述事实，不生成趋势结论。
- 桌面/Web 大屏比较不扩展 Flutter 产品面；独立 Next.js + Tauri 桌面 MVP 于 0.1.0 后启动。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
