# Today 今日建议改造计划

Created: 2026-08-16
> 来源: `Luminous/research/02-功能盘点/today-今日建议.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 4 位。

## 一、目标与范围

范围:`Luminous/lib/features/today/`、`Luminous/lib/features/health_context/`(含联动的 `health_event`、`record` quick-entry);后端 `Lucent/src/modules/today-suggestion/`、`Lucent/src/modules/today-analysis/`。

目标:

- 补上最大的产品缺口:让服务端事件驱动的 Today Analysis 物化结果出现在首屏(F-6 前端接线 + F-7 触发边界扩展),使「主动分析」闭环。
- 修掉语义裂缝:问候语饮水口径(F-9)、页级状态锁(F-16)、指标降级标记(F-8)、启发式信号规则降级(F-19)。
- 清掉竞赛期残留:静态环境数据、硬编码药名枚举、静态 recommendations 端点(F-14/F-18),按真实化方向改造,不删除。
- 把 6 个「保留」项附带的小修(skip_dose 接线、静默刷新、观察项反馈入口、重试提示、一键饮水接线、死字段接真实未读数)全部落地。
- 本计划拥有并写全「建议反馈与升级通知机制」一节(F-2 反馈闭环、F-7 物化扩展、建议升级通知执行器),health-event 与 mine 计划引用此节。

## 二、保留不动(清单)

- F-1 主建议卡主体:规则引擎→物化→只读 GET 链路、结构化证据、边界文案、LLM 不可用时人工审校模板回退(仅 secondaryActions `skip_dose` 列入改造)。
- F-3 建议卡 AI 解释:按需 LLM、失败回退原文并如实标记 `aiGenerated: false`(仅重试策略小修列入改造)。
- F-4 materialization 五态呈现与缓存兜底:ready/stale/pending/failed/empty 如实区分、旧卡保留、DataChangeBus 去抖刷新——同时作为 F-6 改造复用的模式蓝本。
- F-11 轻动作区 5 个快捷入口:纯导航、路由真实(返回路径问题确认不修,见不确定点)。
- F-13 baseline observation:只收录 observed 且 coverage sufficient 的值,连续 2 天门控趋势规则。
- F-17 建议卡曝光测量:`suggestion_impression` 视口内首次上报、去重防重。
- F-20 health_context 快照层:cache-first + pending_sync 队列 + SyncWorker 真实重放,是多域共同事实底座。

## 三、改造项(按优先级分组)

### P0

**1. F-1 漏服卡 `skip_dose` 接成真实跳过动作**
现状:后端漏服规则产出 secondaryActions `skip_dose`(路由 `/medicine?action=skip`,`missed-dose.service.ts:113-120`),Luminous 无任何消费方,且前端主卡只渲染 `primaryAction`(`suggestion_primary_card.dart:102-110`),属死数据。
方案:① 后端先确认/补齐跳过本次的写端点(更新 dose log 为 skipped,并触发重算);② 前端主卡渲染 secondaryActions(ghost 按钮形态),点击调端点,成功后经 DataChangeBus 刷新建议;③ 跳过动作复用 F-2 反馈的失败语义——失败 toast 且不标记已操作。
分工:后端 Lucent `today-suggestion`(端点)+ Luminous `today` presentation。
依赖:F-2 反馈交互范式。

**2. F-2 反馈提交改局部静默刷新**
现状:提交反馈后整个建议 section 进入 loading 闪骨架屏(`presentation/providers/suggestion.dart:246-248`)。
方案:提交期间保留旧卡内容、按钮置 loading,成功后后台静默拉取新物化结果替换;失败 toast 且不标记已提交(现有语义保留)。
分工:纯前端 `today` presentation/providers。

**3. F-10 健康观察关联选项加载失败重试提示**
现状:关联记录/用药预读 2 秒超时后静默给空选项列表(`dashboard_view.dart:296-348`),用户会误以为"没有可关联的记录"。
方案:超时/失败时在选项区显示一行"加载失败,可重试"并提供重试点;成功路径不变。
分工:纯前端 `today` widgets/views。

**4. F-12 一键饮水执行器挂到 Today 轻动作区**
现状:Today「快速记录」仍跳表单页,一键饮水执行器(`record` 模块 `quick_entry_executor.dart`、`water_flow.dart`)已存在且语义正确(成功后才弹"已保存+撤销"),未复用。
方案:把 `WaterQuickEntryFlow` 直接挂到 Today 轻动作区(所需 provider 均已存在);遵守跨 feature 导入规则——通过 domain 接口或 application 层编排接线,不直接 import record 的 presentation。写入后 `emitDataChange` 刷新链路现成。
分工:纯前端,`today` 接线 + `record` 侧如需导出 domain 接口。

### P1

**5. F-6 Today Analysis 摘要卡接物化结果(核心缺口)**
现状:`TodayAiAnalysisController.build()` 只返回 idle/disabled(`presentation/providers/ai_analysis.dart:13-27`),全工程从不读 `GET /today-analysis`;空数据也可点「生成」走 LLM;LLM 文案与模板兜底无 `aiGenerated` 区分。
方案:① 页面加载即 `GET /today-analysis`,把 empty/pending/ready/stale/failed 映射到卡片状态,复用 F-4 建议卡物化状态呈现模式;服务端已生成的分析直接上首屏,「生成」改「刷新」并走后端 `POST /refresh`(5 分钟冷却已存在);② 后端 context 全空(无记录/用药/睡眠)时直接返回 `empty`,不进 LLM、不产出基于全 0 的文案;③ DTO 加 `aiGenerated` 标志,模板兜底时 UI 标注「基于规则的摘要」(沿用 F-3 诚实标记约定)。
分工:后端 `today-analysis`(empty 守卫 + DTO 字段)→ `pnpm export:openapi` → Luminous 重新生成 client + controller/卡片改造。
依赖:F-4 状态呈现模式;client 再生成流程。

**6. F-7 事件驱动物化扩展触发边界 + 建议升级通知执行器(本节为本计划拥有,health-event/mine 计划引用)**

现状:触发源限症状记录、服药日志、健康事件 create/end/check-in、合格建议物化;`userId+localDate+sourceVersion` 去重、3 次/日封顶、手动 5 分钟冷却、claim 超时回收(`trigger.listener.ts:27-80`、`store.service.ts:70-223`)。普通饮水/餐食/睡眠/心情记录完全不触发;产出物出口为每次生成创建两条通知(`analysis.service.ts:323-342`)。

改造方案(触发扩展):普通生活记录(饮水/餐食/睡眠/心情)纳入触发评估,但不按记录类型永久放行——以「维度平级门控」决定:信号覆盖率达标或变化幅度超阈值才入队,日预算(现有 3 次/日封顶)统一约束全部触发源,去重规则不变。目标是把事件优先口径改为维度平级口径,验证非生病期间的伙伴价值。

建议升级通知执行器(频控与投递):分析生成不再"每次两条通知",改为:
- **频控**:每个用户每天最多 1 条建议升级通知,按 `userId+localDate` 幂等去重;当日多次生成只保留最高优先内容升级已有通知,不追加。
- **投递**:本地通知为主(应用在前台/在线时走应用内通知中心 + 本地系统通知),JPush 为辅(仅离线/杀进程场景补投);两路共用同一条服务端通知记录与未读数,避免重复计数。
- 内容边界:通知文案来自物化结果的 summary,不现场调 LLM。
分工:后端 `today-analysis`(trigger 门控、通知幂等与频控)+ 通知投递执行器;Luminous 侧本地通知接收/点击路由。
依赖:通知基础设施与 JPush 通道见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md),本文只定义 today-analysis 侧的频控规则与触发内容。

**7. F-8 概览指标 Today 侧两条修复**
observedMetric 口径的权威定义见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开,只做 Today 侧:
- 降级标记:repository 对数据源 try/catch 静默降级处(`data/repositories/lucent.dart:70-104`)增加来源级 degraded 标记,某数据源失败时对应指标显示「暂不可用」而非 0/`--`,与"真的没记录"区分。
- `completedCount` 退役:`TodayWaterSummary.remainingCount`(目标次数−记录条数,`domain/entities/dashboard.dart:139-142`)逐步下线,问候语/bullets 等消费方统一到 observedMetric。
分工:纯前端 `today` data/domain;口径本身依赖 medicine 计划 F-5 先落地。

**8. F-16 页级状态锁粒度改造**
现状:`TodayPage` 用 dashboard provider 门控整页(`presentation/pages/page.dart:60-78`),而 `fetchDashboard` 唯一未捕获的 await 是健康快照(`lucent.dart:41`),快照 5 秒超时即整页白屏错误,掩盖完全正常的建议区。
方案(二选一,见不确定点):A. repository 对快照失败同样降级(空 snapshot → 用药/问候指标显示「暂不可用」),页级 fatal 只留给真正全局失败;B. 把 PageStateSwitch 下沉为按 section 的状态切换(建议区已有独立状态视图)。
分工:纯前端 `today` data/presentation。
依赖:与第 7 项(F-8 降级标记)共享降级语义,建议同期做。

**9. F-19 咖啡因-睡眠/情绪-睡眠规则降级**
现状:两条规则信号源是餐饮标题/备注关键词猜测(`collectors/record.service.ts:473-500`)、未知情绪默认 3 分(`record.service.ts:527-529`),证据把猜测值呈现为事实口径。
方案(短期,确定执行):两条规则降级为 observations(不进主/次卡);证据文案改如实口径("近 N 天有 M 条餐饮记录提到咖啡/茶");情绪趋势序列剔除 unknown,平均分只统计可解析记录。中期结构化入口见不确定点。
分工:后端 `today-suggestion` collectors/rules;前端无改动(观察项通路现成)。

**10. F-5 观察项补反馈入口**
现状:观察项卡片后端带 `feedbackOptions`,但前端观察 tile 不渲染反馈入口,低置信内容无法被「不再看到」抑制。
方案:观察 tile 渲染精简版反馈(至少 suppress),复用 F-2 的 recorder 端点与失败语义。
分工:前端 `today` widgets/sections/observation.dart;后端能力已存在。

**11. F-3 AI 解释重试策略小修**
现状:`aiGenerated=false`(模型未配置等)场景下重试 3 次属空转。
方案:首次返回 `aiGenerated=false` 时直接降级展示原文+标注,不再自动重试;瞬时网络错误仍保留重试。
分工:前端 `suggestion_interactive.dart`。

### P2

**12. F-9 动态问候语饮水口径修正**
现状:下午档"饮水还差 N 次"用记录条数口径 `remainingCount`,饮水 unknown 时断言"还差 8 次",与同页 `-- / 2000 ml` 矛盾。
方案:饮水分支改用 `observedMetric.state`:unknown 时不提缺口(如"下午好,今天还没记饮水"),observed 时才报 ml 缺口,未记录天数显示「未记录」;用药待确认问候保留不动。
分工:前端 `view_models.dart` / `lucent.dart`。
依赖:第 7 项口径统一。

**13. F-14 Today 侧「环境上下文」消费方式**
后端真实化方案(高德天气/空气 API + Redis 缓存、城市手动选择)见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的天气真实化一节,本文不重复展开。Today 侧只做:
- 移除 `LucentTodayRepository.fetchDashboard` 的硬编码静态填充(花粉 high/紫外线 medium、静态 `mealSuggestion`/`lumiSuggestion`,`lucent.dart:202-224`),字段通路保留、以真实数据源重新装配。
- 环境数据**不作为 Today 主卡**,降级为「环境上下文」:进入助手工具与记录上下文(供过敏/感冒场景引用),presentation 层不新增 Today 首屏卡片。
分工:前端删静态填充;装配依赖跨计划高德客户端落地。

**14. F-15 顶栏死字段接真实未读数**
现状:domain `TodayUserSnapshot.hasUnreadNotifications` 恒 `false`(`lucent.dart:142`),UI 已绕开它用真实 `notificationUnreadCountProvider`。
方案:死字段接 notifications unread count 真实数据(能力已存在,缺 Today 消费),替换恒 false,不删除字段。
分工:前端 `today` data。

**15. F-18 静态兜底与死代码真实化**
现状:`nextMedicine` 硬编码 atorvastatin + `TodayMedicationKind` 死枚举(`lucent.dart:154`、`view_models.dart:94-100`);vitals 中 heartRate/bloodPressure/mood 不被消费且 bloodPressure 恒 `--`;后端 `/today-analysis/recommendations` 为 8 条静态小贴士且无前端调用;摘要兜底文案弱充数。
方案:① `nextMedicine` 改造为真实「下一剂」信息位——按 reminder 计划 + dose log 已确认状态计算,前后端数据都真实,缺前端接线;② 后端静态 recommendations 端点改造为「冷启动引导卡」:规则引擎空转时输出系统侧模板只读引导,不假装建议、不自由联想;③ mood vital 保留为观察项数据通路(情绪趋势进纵向洞察),heartRate/bloodPressure 保留 vitals 通路、改读 observedMetric 列表;④ 兜底文案保留但改中性引导(“点生成,用今天的记录整理一句总结”,改 `lib/l10n/src/today_zh.arb` 等 fragment 后走 merge + gen-l10n 流程)。
分工:前端 ①③④;后端 ②(recommendations.service.ts)。

## 四、跨计划引用与依赖

- 高德天气/空气 API 真实化(后端客户端、缓存、城市选择):[`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 天气真实化一节;本文只写 Today 侧消费方式(第 13 项)。通知基础设施/JPush 通道同此计划。
- observedMetric 口径权威定义:[`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) F-5 一节;本文只写 Today 侧两条修复(第 7 项)。
- 本计划写全、供他计划引用:**「建议反馈与升级通知机制」**(第三节第 2、6 项:F-2 反馈闭环、F-7 触发扩展、建议升级通知执行器「本地通知为主、JPush 为辅、每天最多 1 条」)——health-event 与 mine 计划的通知/反馈需求引用此节,不重复定义。
- 后端 API 变更(F-6 DTO、F-1 端点、F-7 触发)后须 `pnpm export:openapi`(Lucent)+ `dart run scripts/bootstrap_generated_sources.dart`(Luminous)。
- 本计划全部面向移动端;桌面/Web 形态若涉及,统一引用 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)(ADR-0012 待决策)。

## 五、本计划内执行顺序

1. P0 小修先行(第 1–4 项):互不阻塞,可并行;skip_dose 需先确认后端端点。
2. F-8 降级标记 + F-16 页级状态锁(第 7、8 项)同期做,统一降级语义——但需等 medicine 计划(顺序第 2 位)的 observedMetric 口径落地。
3. F-6 前端接线 + F-7 触发扩展(第 5、6 项):后端先行(empty 守卫、DTO、触发门控、通知频控),导出 OpenAPI 后前端接物化呈现。
4. F-19 规则降级、F-5 观察项反馈、F-3 重试小修(第 9–11 项)。
5. P2(第 12–15 项):F-9 依赖第 7 项;F-14 装配依赖跨计划高德客户端;F-18 各项可独立推进。

## 六、不确定点(待决策)

- **F-16 方案二选一未定**:repository 降级(A)vs PageStateSwitch 下沉按 section 切换(B),调研文档并列两方向未取舍。
- **F-19 中期方案排期未定**:记录页咖啡因/情绪结构化入口是否排期是条件分支;短期降级为观察项是确定的,若入口不排期则两条规则保持降级形态、不删除。
- **F-7 触发扩展参数未定**:「维度平级门控」的各维度覆盖率/变化幅度阈值、日预算数值、生活记录去重细节未给出;通知频控本文已定「每天最多 1 条」原则,但升级保留策略(多条生成时的优先级裁决)细节待定。
- **F-14 花粉/紫外线字段**:高德免费接口不含,仅标注「未实现」,后续是否/如何补齐(其他数据源?)无方案。
- **F-6 本地拼装 bullets 去留**:服务端分析上首屏后,现有本地拼装的三条 bullets 是退役还是作为 empty 态兜底,调研文档未明确。
- **F-18② 冷启动引导卡细节**:具体内容、展示位(Today 内?)、与 F-5 观察项的关系未细化。
- **F-1 `skip_dose` 后端端点是否存在未验证**:后端只产出 action 路由参数,跳过动作的写 API 是否已存在需在动手前确认。
- **F-5 观察项反馈入口排期**:调研原文标注「可后续补」,本计划列入 P1 但允许顺延。
- **F-11 返回路径**:调研原文明确「可接受」,确认不修;若产品后续反悔再单独立项。
- **审计清单引用**:调研文档多处引用外部「审计清单第 1/2/3/4/6 条」,清单原文在 research 目录其他文档,执行时如需引用条目原文须查源文档。
