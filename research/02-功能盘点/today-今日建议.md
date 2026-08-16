# Today 模块 功能盘点与审计

> 范围：`Luminous/lib/features/today/`、`Luminous/lib/features/health_context/`（含联动的 `health_event`、`record` quick-entry）；后端 `Lucent/src/modules/today-suggestion/`、`Lucent/src/modules/today-analysis/`。
> 参考文档：`Luminous/docs/01-product/Product_Vision.md`、`Luminous/docs/00-current/Active_UI_Today.md`、`Lucent/docs/00-current/Active_Product_Loop.md`。
> 计划文件按计划均已执行完毕处理，仅评估产品价值。

## 功能点总览

| 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|
| F-1 主建议卡（规则引擎→物化→只读 GET） | Today 首屏最高优先的用药/饮水等行动卡，含证据/边界/主动作 | 真实现 | 保留 | P0 |
| F-2 建议反馈（已采纳/稍后/不适用/不再看到） | 用户反馈写库并驱动抑制/加权 | 真实现 | 保留 | P0 |
| F-3 建议卡 AI 解释 | 按需 LLM 解释，失败回退原文且如实标记非 AI | 真实现 | 保留 | P1 |
| F-4 materialization 状态呈现与缓存兜底 | pending/stale/failed/empty 如实呈现，旧卡保留 | 真实现 | 保留 | P0 |
| F-5 次建议区 + 观察项 | 次级卡与低优先观察，置信度分级标签 | 真实现 | 保留 | P1 |
| F-6 Today Analysis AI 摘要卡（前端） | 「今日摘要」内手动点「生成」走 SSE 流式生成 | 部分实现 | 改造 | P1 |
| F-7 Today Analysis 事件驱动物化（后端） | 症状/服药/事件写入后限次自动生成、3 次/日封顶、手动 5 分钟冷却 | 真实现 | 保留 | P1 |
| F-8 今日摘要概览指标（用药/饮水/睡眠） | 横排 compact 指标，unknown 显示 `--` | 部分实现 | 保留 | P1 |
| F-9 动态问候语 | 按待确认用药数/饮水剩余数生成问候 | 部分实现 | 改造 | P2 |
| F-10 健康观察（health event 区块） | 开始事件/每日三选 check-in/结束必选结果 | 真实现 | 保留 | P0 |
| F-11 轻动作区（5 个快捷入口） | 导航到确认用药/记录/风险检查/提醒/档案 | 真实现 | 保留 | P1 |
| F-12 quick-entry 快速记录执行器 | 水一键记录真实落库+撤销 toast；用药快速确认批量落库、失败如实分项 | 真实现 | 保留 | P0 |
| F-13 baseline observation（后端基线） | 只收录覆盖充分的观测值，连续天数达标才放行趋势规则 | 真实现 | 保留 | P1 |
| F-14 环境/天气卡 | domain 内静态填充花粉高/紫外线中，UI 未渲染 | 假实现（数据伪造但无出口） | 改造 | P2 |
| F-15 顶栏助手/通知入口 | 助手入口跳转、通知铃铛用真实未读数 provider | 真实现 | 保留 | P2 |
| F-16 页级状态锁（dashboard 门控整页） | dashboard 失败→整页错误视图，掩盖可独立渲染的建议区 | 部分实现 | 改造 | P1 |
| F-17 建议卡曝光测量 | 视口内首次可见上报 `suggestion_impression`，去重防重 | 真实现 | 保留 | P2 |
| F-18 静态兜底文案与死代码残留 | `todaySummaryFallbackNarrative`、`TodayMedicationKind.atorvastatin`、heartRate/bloodPressure/mood vital、mealSuggestion/lumiSuggestion、后端 `/today-analysis/recommendations` 静态池、secondaryActions `skip_dose` 死参数 | 假实现/死代码，按改造执行 | 改造 | P2 |
| F-19 咖啡因-睡眠/情绪-睡眠规则 | 用餐饮标题关键词充当"咖啡因记录"证据；未知情绪默认 3 分 | 部分实现 | 改造 | P1 |
| F-20 health_context 快照层 | cache-first + 写失败入 pending sync 队列由 SyncWorker 真实重放 | 真实现 | 保留 | P1 |

## 逐功能分析

### F-1 主建议卡（规则引擎→物化→只读 GET）

- 现状：Today 首屏主卡承接后端规则引擎产出的最高优先候选（漏服确认、饮水不足、睡眠偏短、症状恶化、档案不全等），卡内含标题、原因、结构化证据折叠区、边界文案和主动作按钮。
- 实际作用：这是产品主张的核心产物，且是真闭环：写入事件 → `RecomputeTriggerListener` 触发 → worker 重算（采集信号→7 条规则→抑制→仲裁→文案→持久化）→ 前端只读 GET 展示。证据不是 AI 联想，而是规则从真实信号构造，例如漏服规则的证据为"计划时间 + 今日状态 unconfirmed"（`Lucent/src/modules/today-suggestion/services/rules/medication/missed-dose.service.ts:94-106`），饮水不足的证据为"当前 ml / 目标 ml / 连续记录天数"且要求 observed 且 coverage sufficient（`rules/lifestyle/water-shortfall.service.ts:55-66,98-114`）。
- 实现真实性：真实现。规则全部有阈值、baseline 门控和证据字段；GET 只读物化结果不触发计算（`services/suggestion.service.ts:44-99`）；无候选时仲裁返回 `primary: null`（`services/arbitration/arbiter.service.ts:28-30`），前端显示真实空态"今日暂无建议"。文案在 LLM 不可用时回退到人工审校模板并带边界句（`constants/copy-fallback.ts:18-64`，如"此提醒基于您的用药计划，不能替代医生或药师建议"）。
- 结论：保留。
- 仍需修的小问题：漏服卡的 secondaryActions 里 `skip_dose` 路由 `/medicine?action=skip`（`missed-dose.service.ts:113-120`）在 Luminous 没有任何消费方（grep 无处理），且前端主卡只渲染 `primaryAction`（`suggestion_primary_card.dart:102-110`），属死数据，按改造接成真实跳过动作
- 优先级：P0。

### F-2 建议反馈（已采纳/稍后/不适用/不再看到）

- 现状：主卡底部按后端 `feedbackOptions` 渲染 4 个 ghost 按钮，提交后切换只读"已反馈"指示器。
- 实际作用：真实行为闭环。后端在事务里写 `userSuggestionFeedback` + 更新建议生命周期，`later`/`suppress` 直接 dismiss，并产生服务端权威 `suggestion_actioned` 产品事件（`Lucent/src/modules/today-suggestion/services/feedback/recorder.service.ts:76-162`）。反馈效果真实影响后续重算：accepted +10% 加权、later 抑制 4 小时、not_applicable -30%×7 天、suppress 30 天（同文件 `computeEffect` 217-254 + suppression 服务）。
- 实现真实性：真实现。前端失败有错误 toast 且不标记已提交（`Luminous/lib/features/today/presentation/widgets/sections/suggestion_interactive.dart:42-64`），不存在"点击=成功"。
- 结论：保留。
- 小问题：提交反馈后整个 section 进入 loading 闪骨架屏（`presentation/providers/suggestion.dart:246-248`），体验上可改为局部保留旧卡静默刷新。
- 优先级：P0。

### F-3 建议卡 AI 解释

- 现状：证据折叠区内「AI 解释」按钮，按需调 `POST /today/suggestions/:id/explain`，最多重试 3 次。
- 实际作用：给已有规则卡生成增强版 reason/boundary。关键诚实点：模型未配置/失败/安全策略拒绝时返回原文并标记 `aiGenerated: false`（`Lucent/src/modules/today-suggestion/services/explanation/explainer.service.ts:87-131`）；前端收到 `aiGenerated == false` 不冒充 AI 内容，而是给重试，重试耗尽显示"暂时不可用"（`suggestion_interactive.dart:179-197,217-233`）。
- 实现真实性：真实现。LLM 输出限定在建议的 evidence[] 上下文并过安全策略。
- 结论：保留。
- 小问题：无限流外的缓存（每次点击都打 LLM，文档明确"AI 解释不缓存"属有意设计）；重试 3 次对"模型未配置"场景无意义，可在首次 `aiGenerated=false` 时直接降级展示原文+标注，少一步空转。
- 优先级：P1。

### F-4 materialization 状态呈现与缓存兜底

- 现状：`ready/stale/pending/failed/empty` 五态在 UI 如实区分：pending 显示"生成中"提示、stale 显示"更新于 HH:mm"、failed 给重试、empty 保持真实空态；非 ready 状态保留旧卡内容（`widgets/sections/suggestion.dart:31-77`、`suggestion_state_views.dart:210-270`、`presentation/providers/suggestion.dart:219-232`）。
- 实际作用：把"后台正在重算/重算失败"如实告诉用户，而不是用旧卡假装新鲜或直接空白。冷启动先恢复本地缓存再合并状态；网络失败 stale-while-error 兜底；缓存反序列化失败清缓存并 rethrow（`providers/suggestion.dart:145-217`）。DataChangeBus 去抖 300ms 刷新、resume 比较 `sourceVersion`、FIFO 串行防旧响应覆盖新结果——与文档描述一致且在代码中逐条可见。
- 实现真实性：真实现。旧缓存缺状态元数据按 `ready` 兼容（`domain/entities/suggestion.dart:71-80`）是有意的版本兼容，不算伪造。
- 结论：保留。
- 小问题：无。
- 优先级：P0。

### F-5 次建议区 + 观察项

- 现状：次建议最多 2 张 soft 卡；观察项来自 `bundle.observations`（低优先/低置信候选），置信度映射为 `去看看/值得留意/仅供参考` 三级 FBadge（`widgets/sections/observation.dart:326-336`）。
- 实际作用：分层展示非首要信号。观察项点击走卡片的 `primaryAction.route` 导航。后端观察项不持久化（`suggestion.service.ts:252-267` 注释"low priority"），是合理取舍。
- 实现真实性：真实现。观察项为空时显示真实空态文案；前端额外合并了一条本地 fallback"缺睡眠记录"提示（`observation.dart:73-91`），该提示是诚实的事实陈述（"暂时无法判断睡眠趋势"）且导航到睡眠记录页。
- 结论：保留。
- 小问题：观察项卡片带 `feedbackOptions` 但前端观察 tile 不渲染反馈入口，低置信内容无法被"不再看到"抑制——只能靠 suppress 主/次卡。可后续补。
- 优先级：P1。

### F-6 Today Analysis AI 摘要卡（前端）

- 现状：「今日摘要」卡内右下角「生成」按钮，点击走 `POST /today-analysis/generate/stream`（SSE），流式显示 summary，完成后展示 summary+bullets+confidenceNote（`widgets/sections/summary.dart:221-245`、`data/datasources/ai_remote.dart:56-85`）。
- 实际作用：把当天记录整理成一段人话总结。后端上下文全部来自真实数据（用药/饮水 ml/记录摘要/睡眠/过敏计数，`Lucent/src/modules/today-analysis/services/pipeline/context.service.ts:98-235`），prompt 明确"不要编造缺失数据、不做诊断"（`prompts/analysis.prompt.ts:5-17`），LLM 不可用时回退为基于真实计数的模板文案（`services/pipeline/copy.service.ts:15-76`），confidenceNote 固定声明"不构成诊断"。
- 实现真实性：部分实现。三处扣分：
  1. 前端**从不读** `GET /today-analysis` 物化结果——`TodayAiAnalysisController.build()` 只返回 idle/disabled（`Luminous/lib/features/today/presentation/providers/ai_analysis.dart:13-27`），全工程 grep 无 `todayAnalysisControllerGet` 调用。服务端事件驱动生成的分析（F-7）只通过通知触达，Today 卡本身在用户手动点「生成」前永远显示本地拼装的三条 bullets。"主动分析"在核心界面上不成立。
  2. **空数据也可生成**：`generate` 路径没有任何"上下文为空则拒生成"守卫，零记录用户点生成会得到一段基于全 0/null 事实的 LLM 文案（或模板兜底"今日记录已更新，可先……补全今天的数据"——`Lucent/src/i18n/zh-CN/today-analysis.json:8`，零记录时该句不成立）。触碰审计清单第 3 条。
  3. 分析结果无 `aiGenerated` 类标记，LLM 文案与模板兜底文案在 UI 上无法区分（对比 F-3 的诚实做法）。
- 结论：改造。
- 改造方案：① 页面加载即 `GET /today-analysis`，把 `empty/pending/ready/stale/failed` 映射到卡片状态，复用建议卡的物化状态呈现模式——让服务端已生成的分析直接出现在首屏，「生成」改为「刷新」（受 5 分钟冷却约束，后端已支持 `POST /refresh`）；② 后端在 context 全空（无记录、无用药、无睡眠）时直接返回 `empty` 状态不进 LLM；③ DTO 加 `aiGenerated` 标志，模板兜底时 UI 标注"基于规则的摘要"。
- 优先级：P1。

### F-7 Today Analysis 事件驱动物化（后端）

- 现状：症状记录、服药日志、健康事件 create/end/check-in、合格的建议物化版本触发分析队列；`userId+localDate+sourceVersion` 去重；每自然日最多生成 3 次、手动刷新 5 分钟冷却、claim 超时回收（`Lucent/src/modules/today-analysis/services/recompute/trigger.listener.ts:27-80`、`services/materialization/store.service.ts:70-223`）。普通 daily record（如纯饮水）不触发。
- 实际作用：让已纳入触发范围的变化自动产生分析且成本有界。`GET` 只读历史物化不调 LLM。
- 实现真实性：真实现。并发 claim、序列化事务、capped→stale 投影都齐全。普通记录不触发是刻意的成本控制，合理。
- 结论：保留并扩展触发边界。普通饮水、餐食、睡眠和心情记录完全不触发，在旧的事件优先口径下属于成本控制，在长期健康伙伴定位下会漏掉非生病期间的核心价值。应以"维度平级门控"（覆盖率/变化幅度/日预算）和去重规则决定是否重算，而不是按记录类型永久排除。
- 小问题：产出物目前主要出口是通知（`analysis.service.ts:323-342` 每次生成创建两条通知），Today 卡不接（见 F-6），导致这套物化机制的实际用户价值打折——接上前端后价值才闭环；生活记录触发后还要避免每记一杯水都生成新通知。
- 优先级：P1。

### F-8 今日摘要概览指标（用药/饮水/睡眠）

- 现状：横排三个 compact 指标。用药分母为今日有提醒计划的药品数、无提醒回退全部当前药品（`Luminous/lib/features/today/data/repositories/lucent.dart:109-121`）；饮水优先显示 canonical ml（`500 / 2000 ml`），unknown 显示 `-- / 2000 ml`，分页截断/单位不可换算标 partial（`lucent.dart:353-396`、`view_models.dart:176-185`）；睡眠读真实时长，无数据 `--` 降字重。
- 实际作用：给用户一眼可核对的今日事实。unknown 不投影成 0、不把记录条数当毫升数，符合稀疏记录语义。
- 实现真实性：部分实现。主体真实，但有两处语义裂缝：
  1. `TodayWaterSummary.remainingCount` 仍是"目标次数 − 记录条数"（`domain/entities/dashboard.dart:139-142`），问候语和默认 bullets 使用它，与 ml 口径并存（见 F-9）。
  2. repository 对每个数据源 try/catch 后静默降级（`lucent.dart:70-104`），摘要接口失败时用药/饮水指标静默显示为 0 计数/`--`，无 degraded 标记——单区失败与"真的没记录"在 UI 上不可区分（对比建议区有独立 error 态）。
- 结论：保留。
- 仍需修：指标加来源降级标记（某数据源失败时该指标显示"暂不可用"而非 0）；`completedCount`（条数口径）逐步退役，统一到 observedMetric。
- 优先级：P1。

### F-9 动态问候语

- 现状：按时段+待确认用药数/饮水剩余数生成问候副标题（`view_models.dart:71-92`）。
- 实际作用：轻量情境感。用药口径与概览一致（pendingCount）。
- 实现真实性：部分实现。下午档"饮水还差 N 次"用的是**记录条数**口径的 `remainingCount`（`lucent.dart:90` 的 `recordCounts['water']`），在饮水数据 unknown（未记录或摘要接口失败）时断言"还差 8 次"，把未知映射成确定性缺口结论——与同页概览的 `-- / 2000 ml` 直接矛盾，触碰审计清单第 2 条。
- 结论：改造。
- 改造方案：问候语饮水分支改用 `observedMetric.state`（observed 口径：只统计已记录数据）：unknown 时不提缺口（如"下午好，今天还没记饮水"），observed 时才报 ml 缺口，未记录天数显示为"未记录"而非缺额；用药待确认问候保留（用药语义已收敛到 reminder slot，可信）。
- 优先级：P2。

### F-10 健康观察（health event 区块）

- 现状：无 active event 时显示"开始一段健康观察"入口（只要求短标题，关联记录/用药可选）；active 时显示标题+当天一次三选 check-in（好转/差不多/加重）+结束（必选结果）（`widgets/views/dashboard_view.dart:184-424`）。
- 实际作用：当前健康事件专题的主入口。创建/check-in/结束全部走真实 API，失败保留输入可重试，当天已 check-in 不重复给入口，时区按用户 profile（`core/utils/local_date.dart`）。后端限制同时只有一个 active 事件、check-in 每日一条可更正；这说明事件域实现完整，不代表事件仍是产品主单位。
- 实现真实性：真实现。`saved` 标志确保只有真正提交成功才触发刷新（`dashboard_view.dart:287-293`），无"弹窗关闭=已保存"语义。
- 结论：保留。
- 小问题：关联选项预读有 2 秒超时，超时静默给空选项列表（`dashboard_view.dart:296-348`）——用户可能以为"没有可关联的记录"，可加一行"加载失败可重试"。
- 优先级：P0。

### F-11 轻动作区（5 个快捷入口）

- 现状：`确认用药 / 快速记录 / 用药安全 / 提醒设置 / 健康档案` 五个 FTile 入口，确认用药副标题按 `pendingCount` 动态生成并带 badge（`widgets/sections/quick_actions.dart`、`view_models.dart:319-368`）。
- 实际作用：纯导航入口，路由全部真实存在（`/medicine`、`/record/create?kind=water`、`/medicine/risk-check`、`/medicine/reminders/new`、`/mine`）。点击不声称完成任何业务动作——不存在"快捷入口点击=已保存成功"的伪语义。
- 实现真实性：真实现（作为导航）。
- 结论：保留。
- 小问题："确认用药"用 `context.go` 切 tab，用户确认完后无返回路径回 Today（靠底部 tab），可接受。
- 优先级：P1。

### F-12 quick-entry 快速记录执行器

- 现状：记录页快速入口的执行层。饮水一键记录：真实调 `createRecord` 落库，**成功后才**弹"已保存+撤销"toast，失败弹失败 toast（`Luminous/lib/features/record/presentation/services/quick_entry_executor.dart:69-102`、`quick_entry/water_flow.dart:38-50`）；撤销是真实删除该记录。用药快速确认：单药自动确认、多药弹选择、批量提交分项统计成功/失败并如实展示，撤销区分删除新日志/恢复原状态（`quick_entry/medication_flow.dart:190-262`）。
- 实际作用：把"记一次水/确认一次服药"压到一次点击，且保存语义严格在服务端成功边界之后。这正是审计清单第 6 条的反面教材级正确实现。
- 实现真实性：真实现。写入后 `emitDataChange` 驱动 Today 建议/摘要刷新。
- 结论：保留。
- 小问题：Today 轻动作区的"快速记录"仍是跳表单页，未复用一键饮水执行器——Today 上想快记一杯水要三步。建议把 `WaterQuickEntryFlow` 直接挂到 Today（其所需 provider 均已存在）。
- 优先级：P0。

### F-13 baseline observation（后端基线）

- 现状：每次成功重算后，把采集信号中**显式 observed 且 coverage sufficient** 的值（含明确的 0）按 `userId+dimension+localDate` 幂等写入观测表；连续 2 天（`BASELINE_MIN_DAYS`）才建立基线，趋势/行为类规则要求基线就绪才允许触发（`Lucent/src/modules/today-suggestion/services/lifecycle/baseline.service.ts:151-174,82-145`、pipeline 门控 `pipeline.service.ts:89-97`）。
- 实际作用：冷启动保护——新用户前两天不会被"饮水不足""睡眠偏短"等趋势结论骚扰；unknown 永远不进基线（"缺失不等于 0"的落地）。
- 实现真实性：真实现。baseline 写入失败不丢建议、物化标 `BASELINE_OBSERVATION_FAILED` 不假装 ready（`recompute/worker.service.ts:74-106`）。
- 结论：保留。
- 小问题：`consecutiveDays` 实为 30 天回望窗口内的连续覆盖天数，文档与常量名（MIN_DAYS=2）一致，无语义问题。
- 优先级：P1。

### F-14 环境/天气卡

- 现状：**UI 上不存在**。但 `LucentTodayRepository.fetchDashboard` 给 domain 填了硬编码静态数据：花粉 high + 紫外线 medium（`Luminous/lib/features/today/data/repositories/lucent.dart:209-220`）、静态 `mealSuggestion`（高蛋白均衡午餐）和 `lumiSuggestion`（花粉防护）（`lucent.dart:202-224`），注释自述"Deferred by Product_Vision MVP，先不展示"。全工程 grep 确认 presentation 层无消费。
- 实际作用：无。这是审计清单第 1 条的残留形态——用占位数据填充缺失字段，只是恰好没有渲染出口；一旦哪个 UI 误读 `dashboard.environment` 就会把伪造的花粉/紫外线级别当成事实展示。
- 实现真实性：假实现（伪造数据驻留在生产 repository 路径）。Lucent 侧 `signal.types.ts:10` 有 `'environment'` signal source 但无任何环境 collector，后端同样无真实环境数据接入（已决策接高德天气/空气 API，城市手动选择）。
- 结论：改造。
- 改造方案（已决策）：后端 environment 模块重写——静态 reference 替换为高德天气/空气 API 客户端 + Redis 小时级缓存，`dataSource:'real'`、动态 updatedAt，key 走环境变量配置不硬编码；城市来源用户手动选择（免定位权限）；花粉/紫外线字段高德免费接口不含，标注"未实现"；前端降级为"环境上下文"——不作为 Today 主卡，而是进入助手工具与记录上下文（`TodayDashboard` 的静态填充随之移除，字段通路保留，以真实数据源重新装配）。
- 优先级：P2。

### F-15 顶栏助手/通知入口

- 现状：右上助手入口跳 `/assistant`（未登录弹登录引导）；通知铃铛未读点来自真实 `notificationUnreadCountProvider`（`widgets/shared/top_bar.dart:77-79,111-130`）。
- 实际作用：正常入口。
- 实现真实性：真实现。注意 domain 里的 `TodayUserSnapshot.hasUnreadNotifications` 恒为 `false`（`data/repositories/lucent.dart:142`）——是死字段，UI 实际绕开它用了真 provider，不构成假实现，但字段应按改造接真实未读数替换。
- 结论：保留。
- 小问题：`hasUnreadNotifications` 恒 false 死字段按改造处理——接 notifications unread count 真实数据（该能力已存在，缺 Today 消费），替换恒 false 死字段，不做删除。
- 优先级：P2。

### F-16 页级状态锁（dashboard 门控整页）

- 现状：`TodayPage` 用 `resolvePageViewState(session, todayDashboardProvider)` 门控整页（`presentation/pages/page.dart:60-78`）：dashboard 出错 → 整页 `TodayErrorView`，建议区、健康观察区（各有独立 provider）全部不可见。
- 实际作用：首屏骨架统一。但 `LucentTodayRepository.fetchDashboard` 唯一未捕获的 await 是健康快照（`data/repositories/lucent.dart:41`），快照接口 5 秒超时失败 → 整页白屏错误，哪怕建议卡服务完全正常。触碰审计清单第 4 条。
- 实现真实性：部分实现（loading 语义真实，但错误传播粒度过粗，掩盖局部可用数据）。
- 结论：改造。
- 改造方案：dashboard repository 对快照失败同样降级（空 snapshot → 用药/问候指标显示"暂不可用"），页级 fatal 只留给真正的全局失败；或把 PageStateSwitch 下沉为按 section 的状态切换（建议区已有现成的独立状态视图）。
- 优先级：P1。

### F-17 建议卡曝光测量

- 现状：主卡进入视口首次上报 `suggestion_impression`（surface=today，ruleCode），session+规则码去重，TickerMode 门控非活动 tab，`Scrollable.maybeOf` 防御取值（`widgets/sections/suggestion_primary_card.dart:194-285`）。
- 实际作用：产品闭环漏斗的第一环（曝光→处理→回顾），与服务端 `suggestion_actioned` 配对。
- 实现真实性：真实现。视口矩形相交判断，无 build 重复计数。
- 结论：保留。
- 小问题：无。
- 优先级：P2。

### F-18 静态兜底文案与死代码残留

- 现状：
  - 「今日摘要」无 AI 内容时显示静态文案"完成今日待办，即可安心收尾。"（`l10n/src/today_zh.arb:264`，`summary.dart:130-140`）——不伪装成 AI/数据结论，属弱充数文案。
  - `TodayMedicationKind`（atorvastatin/vitaminBComplex）与 `medicationName()` 全工程无调用（`view_models.dart:94-100`），repository 硬编码 `nextMedicine: TodayMedicationKind.atorvastatin`（`lucent.dart:154`）——死代码，且"阿托伐他汀"这种真实药名常量留在 codebase 里有误导审查的风险。
  - vitals 数组里 heartRate/bloodPressure/mood 三项不被概览消费（`buildOverviewItems` 只渲染用药/饮水/睡眠，`view_models.dart:150-173`），bloodPressure 恒为 `--` 常量（`lucent.dart:168-171`）。
  - 后端 `GET /today-analysis/recommendations` 是 8 条静态泛化健康小贴士随机抽取（`Lucent/src/modules/today-analysis/services/pipeline/recommendations.service.ts:16-65`），Luminous 无任何调用——典型的"无数据强行生成泛化内容"端点，只是目前无前端出口。
- 实际作用：均无真实用户价值。
- 实现真实性：假实现/死代码。
- 结论：改造。
- 改造方案：① `nextMedicine`/`TodayMedicationKind` 硬编码改造为真实"下一剂"组件——按 reminder 计划 + dose log 已确认状态计算下一剂（前后端都有真实数据，缺前端计算接线），成为 Today/Medicine 的"下一剂"信息位；② 后端静态 recommendations 端点改造为"冷启动引导卡"——规则引擎空转时由系统侧模板输出只读引导（不假装建议、不自由联想），触发源仍限定为结构化记录/授权上下文/规则命中；③ mood vital 保留为"观察项"数据通路（心情是平级维度，情绪趋势进纵向洞察观察区），heartRate/bloodPressure 保留为 vitals 通路、改读 observedMetric 列表；④ 兜底文案保留，改为中性引导（"点生成，用今天的记录整理一句总结"）；`skip_dose` 死参数接成真实跳过动作（见 F-1 小问题）。
- 优先级：P2。

### F-19 咖啡因-睡眠/情绪-睡眠规则

- 现状：后端两条行为建议规则。咖啡因规则触发后给"咖啡因记录 N 天/共 M 次"证据，但其信号来自**餐饮记录标题/备注包含"咖啡/茶"关键词**（`Lucent/src/modules/today-suggestion/services/collectors/record.service.ts:473-500`）；主动作路由到 `/record/create?kind=meal`、label `record_meal`（`rules/sleep/caffeine-sleep.service.ts:151-156`）。情绪规则的情绪分由标题关键词映射，未知情绪在趋势序列里默认 3 分（`record.service.ts:527-529`），证据里的"平均情绪分"含这些默认 3 分。
- 实际作用：表面上是"咖啡因/情绪与睡眠的相关性洞察"，实际数据基础是关键词猜测+默认分填充。证据条目把猜测值呈现为"记录天数/总次数"这类事实口径，用户无法知道所谓咖啡因记录只是饭 title 里有"茶"字。
- 实现真实性：部分实现（规则逻辑真实、阈值和基线门控真实，但信号源是启发式伪装的：触碰审计清单第 1、2 条——把关键词命中伪装成结构化记录，把未知情绪映射成 3 分）。
- 结论：改造。
- 改造方案：短期直接把这两条规则降级为 observations（不进主/次卡），证据文案改成如实口径（"近 N 天有 M 条餐饮记录提到咖啡/茶"）；情绪趋势序列剔除 unknown（不默认 3 分），平均分只统计可解析记录。中期若要保留该洞察，记录页加独立的咖啡因/情绪结构化入口（快速记录已支持 mood 三选/五选），让信号变成真数据。若结构化入口暂不排期，两条规则保持观察项降级形态，不做删除。
- 优先级：P1。

### F-20 health_context 快照层

- 现状：`healthContextSnapshotProvider`（keepAlive）→ cache-first repository：本地缓存立返+30 秒节流后台刷新；写操作失败入 `pending_sync` 队列，`SyncWorker` 用序列化的原始 HTTP 请求真实重放，重放成功后刷新缓存（`Luminous/lib/features/health_context/data/repositories/lucent.dart:47-78,217-241`、`data/providers/health_context.dart:45-65`）。
- 实际作用：Today dashboard、健康观察关联选项、用药确认等共同的事实底座（当前用药/过敏/档案）。
- 实现真实性：真实现。特别注意：这不是"只有本地开关、无真实执行器"的伪自动化——失败写入的重放 handler 做的是真实 `dio.request`，且写失败会向 UI 抛错（不假装成功）。
- 结论：保留。
- 小问题：无。
- 优先级：P1。

## 模块级结论

**对产品目标的贡献**：Today 是当前全产品最接近长期健康伙伴愿景的模块。核心产物（主动建议卡）做到了愿景要求的四条：证据可追溯（规则构造的结构化证据，非 AI 联想）、有明确动作（真实路由）、有边界声明（模板与 LLM 均带 boundary）、有时效才进首屏（漏服 30 分钟宽限、饮水规则下午才触发、baseline 冷启动门控）。稀疏记录语义在水口径（unknown ≠ 0、partial 标记、记录条数不当毫升）、服药槽位（planned→unconfirmed 不算漏服）、baseline 观测（只收录充分覆盖值）上落地得相当扎实。反馈闭环、物化状态、曝光测量都是真实现，没有"请求成功=业务成果"的伪语义。当前主要偏差不是技术真实性，而是候选信号与触发机制仍偏向用药和健康事件，未充分消费餐食、睡眠、饮水和心情的跨日价值。

**冗余与假实现**（按严重度）：

1. F-6 是最大的产品缺口而非假实现：后端事件驱动的 Today Analysis 物化（F-7）做完了，前端却只接手动流式生成，"主动分析"在核心界面缺位；且空数据可生成泛化总结、LLM 与模板兜底不可区分。
2. F-7 的触发范围仍是事件优先：普通生活记录不触发主动分析，无法完整验证非生病期间的伙伴价值。
3. F-19 两条相关性规则的信号源是关键词启发式，证据口径把猜测伪装成事实，建议降级或改造。
4. F-14/F-18 静态环境数据（花粉高/紫外线中）、硬编码药名枚举、静态 recommendations 端点等是竞赛期残留，按改造方案执行——环境数据真实化（接高德天气/空气 API，城市手动选择）、下一剂组件接真实计算、recommendations 改造为冷启动引导卡，均不删除。
5. F-9 问候语饮水口径与 F-16 页级状态锁是语义/韧性裂缝，工程量小、收益直接。

**缺口**：

- Today 缺"一键饮水"（执行器已存在，未接）。
- 建议卡的 secondaryActions（如"跳过本次"）在后端产出但前端不渲染，动作集合不完整。
- 环境/天气信号对产品"过敏/感冒场景"本有真实价值（花粉+过敏史→建议），已决策接高德天气/空气 API（城市手动选择、免定位权限），花粉/紫外线字段标注"未实现"；前端以"环境上下文"形态进入助手工具与记录上下文，不作为 Today 主卡。

**总评**：主链路可信、可保留并继续投入；需要动手的是 F-6 前端接线、F-7 生活记录触发与日预算重构、F-19 降级、F-14/F-18 真实化改造、F-9/F-16 两处小改造。本模块没有发现需要整体砍掉的功能，但若不补生活维度，实际验证的仍是事件助手而不是长期健康伙伴。
