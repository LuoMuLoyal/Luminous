# 报告模块(report)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `Luminous/research/02-功能盘点/report-报告模块.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 8 位。

## 一、目标与范围

范围:Luminous `lib/features/report/`(客户端)+ Lucent `src/modules/reports/`、`src/modules/data-export/`、`src/modules/health-events/`(后端)。

目标:

- 修复两处「界面承诺与真实行为不一致」:回顾历史无翻页 UI(#5,已处置)、就诊摘要字段级隐私三开关无实际门控(#8,已处置)。
- 将 legacy dashboard 的 AI 周报生成链路改造为「周/月纵向洞察生成器」(#14,按逐功能分析取 P1):只输出有来源和覆盖率的模式与低风险动作,证据不足弃权,不生成泛化长文——服务端口径与客户端死代码清理已落地,Review 视图装配未完成(见 R-3)。
- legacy 残留(#19-#22)打包改造为纵向洞察口径，0.1.0 前完成；不删除功能与代码——其中 #20 已落地,其余未完成(见 R-4)。

## 二、保留不动(清单)

- #1 事件回顾主视图(`review_view.dart`,事件头部 + 四段,专题视图定位)。
- #2 回顾四段 unknown 语义(reasonCode 本地化,显式 `unknown` 枚举成员)。
- #3 无事件状态处理(「开始健康观察」入口 + 历史,不生成周报)。
- #4 事件交互闭环(复用 health_event sheet,DataChangeBus 自动刷新)。
- #6 回顾呈现测量(`review_opened`,session 去重,服务端 product-events)。
- #7 就诊摘要 preview 脱敏(`maskName`/`calculateAge`/仅诊断年份,`applySelectedFields` 单一过滤出口);入口移入「更多」属已完成定位调整。
- #9 可撤销分享(7 天 TTL,token 仅哈希,原子撤销)。
- #10 分享管理列表(创建/到期/访问次数/撤销态)。
- #11 公开分享页 + 公开 PDF(免认证,过期/撤销 404)。
- #12 就诊摘要占位数据问题(`_fillMissingSections`)——已修复,维持「未选 = 字段不存在」契约,禁止默认值补齐。
- #13 就诊摘要测量(previewed/exported 客户端边界 + 服务端 share 事件)。
- #15 AI 周报无事件/数据不足防护——已修复(主路径无入口 + legacy readiness 门控);P2 双保险建议见下。
- #16 AI 摘要用户开关(`aiSummariesEnabled` 前后端双拒绝)。
- #17 月度/打印 PDF 导出(PIN security elevation + BullMQ 队列 + COS + 五态反馈)。
- #18 导出成功 ≠ 医生查看/获益口径——已修复(文案与测量均已收敛)。

## 三、改造项(按优先级分组)

### P0

无。

### P1（0.1.0 前）

**R-3 周/月纵向洞察生成器(#14，按逐功能分析取 P1，0.1.0 前)**

- 现状:`POST /reports/summary/generate/stream`(SSE)由 `BaseLlmSummaryService` 编排(setting 开关 → dashboard facts → LLM JSON schema → safety policy → 持久化,模板 fallback),链路真实但输出为泛化总结;仅 legacy 页可达。客户端 `ai_summary_remote.dart` 非流式 `generate()` 为零调用死代码。
- 方案:
  - 保留 SSE + BullMQ + LLM 基础设施,换新 prompt 与输入口径:输出固定为时间范围、覆盖率、有来源的已观察模式(最多一个)与低风险行动(最多一个),允许用户反馈;数据不足直接弃权,不生成泛化长文。
  - 客户端删除非流式 `generate()` 死代码。
  - 生成器装配到 Review 的日/周/月视图(与 R-4 legacy 视图改造联动);事件回顾作为专题嵌入,不再统领全部周/月内容。
- 进展:服务端口径与客户端死代码清理已落地(Lucent `9549f48c` 换 prompt/schema 弃权口径与 `coverage/observedPattern/lowRiskAction/disclaimer` 输出、`copy.service.ts` 全 insufficient → abstain;Luminous `eec70285` 删非流式 `generate()`,展示层改三段渲染);**「装配到 Review 日/周/月视图」未完成**(`ReportAiSummarySection` 仍只在 legacy 视图,随 R-4 #19 联动)。
- 依赖:vital 趋势数据源见 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md) 的 vital 基建一节;ObservedMetric/覆盖率口径见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节;本文不重复展开。
- 分工:服务端换 prompt/schema/输入口径;客户端删死代码 + 装配视图。

### P2（legacy 打包，0.1.0 前）

**R-4 legacy 改造包(#19-#22 打包，0.1.0 前)**

- 现状:`/report/legacy` 兼容页(`legacy_dashboard_compat.dart` + `dashboard_view.dart` + legacy sections)承载旧周报视图;后端 `buildScore` 硬编码权重评分(insufficient_data 18 分高于 needs_attention 15 分,明显怪异);legacy scalar 序列存在 unknown→0 投影(服务端 `context.service.ts`)与 unknown→flat/general(客户端 mapper);建议历史仅 legacy 页消费。
- 方案(打包执行,不删除功能与代码):
  - #19:`legacy_dashboard_compat.dart` 等重新装配为 Review 日/周/月纵向洞察视图(聚合计算逻辑保留,`top_bar.dart` 范围切换改为日/周/月切换);路由 `/report/legacy` 与 domain 侧 `dashboard.dart` 实体/mapper 视装配进度迁移。
  - #20:移除后端 `buildScore` 及 dashboard DTO 的 score 总分输出,代之以「洞察对象」(覆盖率 + 单维趋势方向 + 值得关注的模式,不合成总分);Flutter 桌面/Web 大屏趋势比较冻结，不展开。
  - #21:legacy 图表改按 `observedMetric` 口径输出:unknown 天不绘点、只绘已记录数据,图表旁标注「有记录 N 天 / 范围 M 天」覆盖率;废除 unknown→0(服务端)与 unknown→flat/general(客户端)两处口径。observedMetric 口径定义引用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节。
  - #22:建议历史从 legacy 页移入 Review「建议历史」详情视图,数据源 `/today/suggestions/history`,保留 title|reason|type 去重取最高生命周期状态与详情面板。
  - 同包清理:后端零消费端点(`summary/generate` 非流式、`summary/generate/async` + `status`、`clinic-summary/export/async` + `status`)下线或降级为不暴露;旧 Redis `createShareLink` 缓存桥清理。先做客户端死代码清理与数据契约拆分,再评估后端裁剪,避免先砍后端影响导出(#17 PDF 依赖 dashboard 聚合)。
- 进展:#20 已落地(Lucent `912c8efa` 移除 `buildScore` 与 DTO score 输出、Luminous `68d42f47` 移除评分卡与 score 引用);客户端非流式 `generate()` 死代码已随 R-3 删除;#19/#21/#22 与后端端点/缓存桥裁剪未完成。
- 依赖:data-export PDF 数据源替代方案须先行确认(见第六节);vital 数据源引用 record 计划 vital 基建一节。

**R-5 服务端 409 双保险(#15 附注，0.1.0 前)**

- 现状:#15 已修复(主路径无入口 + legacy readiness 门控 + prompt 约束),但后端 `summary/generate*` 端点无服务端「数据不足拒绝」守卫,直接调 API 仍可对空数据生成。
- 方案:服务端对全 insufficient 请求返回 409/空结果,作为客户端 gate 之外的双保险;随 R-3/R-4 改造落地。
- 口径:按第六节,**服务端数据不足拒绝守卫为必做项**;当前未实现(仅 prompt 弃权 + fallback abstain 空结果语义,无 409 硬拒绝)。

**R-6 文档漂移更新(#17 附注，0.1.0 前)**

- 现状:`Mock_Or_Deferred.md`「clinic share link 无应用内链接管理,只能重新生成」已过时(分享管理已上线);`Active_UI_Report.md` 对 legacy scalar 的描述与 `context.service.ts` 实际 unknown→0 投影不一致。
- 方案:更新两处文档;legacy scalar 口径描述随 R-4 的 #21 改造完成后自然失效。
- 进展:两处文档均未更新。

## 四、跨计划引用与依赖

- 本计划拥有并写全:report 域全部改造项(R-1~R-6)、legacy 打包改造的执行节奏与后端裁剪顺序。
- 引用 [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md):vital 趋势数据源基建(R-3/R-4 的纵向洞察输入依赖)。
- 引用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md):F-5 一节的 ObservedMetric/覆盖率口径定义(R-3、R-4 之 #21 共用)。
- 引用 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md):#20 Flutter 桌面/Web 大屏趋势比较冻结项；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- 横切条目(Dashboard 聚合耦合、`applySelectedFields` 单一出口、DataChangeBus、PIN elevation、product events、信封解包、`aiSummariesEnabled`、BullMQ)已在 R-2/R-3/R-4 各自展开,无跨计划归属冲突。

## 五、本计划内执行顺序

1. R-3 纵向洞察生成器(P1,依赖 record 计划 vital 基建与 medicine 计划 F-5 口径就绪;服务端口径与客户端死代码清理已落地,剩余 Review 视图装配)。
2. R-4 legacy 打包（0.1.0 前）:先确认 data-export PDF 数据源替代方案 → 客户端死代码清理与数据契约拆分(#20 已落地)→ 视图重装配(#19/#21/#22)→ 评估后端裁剪。
3. R-5 服务端 409 双保险、R-6 文档更新,随 R-3/R-4 附带完成(R-5 按第六节为必做项)。

## 六、已决边界与保留项

- 0.1.0 前删除服务端 Dashboard 评分计算、PDF 评分卡与 Flutter legacy score 模型；医院 PDF 不保留综合评分。
- 六开关全部真实生效，严格选中边界适用于 API、预览、PDF 和公开分享；原始 JSON/CSV 可移植导出延后至 0.1.0 后 TODO。
- R-5 的服务端数据不足拒绝守卫为必做项；无观测不生成、不通知，单点只陈述事实，不生成趋势结论。
- 桌面/Web 大屏比较不扩展 Flutter 产品面；独立 Next.js + Tauri 桌面 MVP 于 0.1.0 后启动。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
