# 日常记录(Record,含餐食分析)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `research/02-功能盘点/record-日常记录与餐食分析.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考——速览表统计口径自相矛盾(22 项 vs 21 项),本文一律不引用其统计数字)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 6 位。

## 一、目标与范围

范围:Luminous `lib/features/record/`(客户端)+ Lucent `daily-records` / `today-analysis`(联动)/ `files` / `llm-runtime`(后端)。

目标:

1. 接上已存在但未消费的后端能力:Record 页摘要网格、饮水「累计 ml」角标(§4.1)。
2. 统一口径:详情页饮水目标值改读用户设置,消除与 Today Analysis 的口径分裂(§4.4,本文档写全)。
3. 建设 vital 时间序列基建:体重(手动+平台导入)、血糖趋势、血压合并为统一基建(§2.6 已决策，0.1.0 后)。
4. 降低餐食分析链路成本:vision 识别分层触发(§1 改造建议，0.1.0 后)。
5. 桌面资产(趋势图、月历标记)改造为真实数据,形态挂起待 ADR-0012。
6. 落实 Today 联动方向:饮食/饮水/睡眠/心情升级为主动建议平级原料（近 7 天至少 3 条有效记录，或相对个人基线变化至少 50%；全源每天共 3 次分析预算）。

## 二、保留不动(清单)

以下功能点经审计为真实现,本计划不改动:

- 餐食记录(拍照/相册/手动,`presentation/quick_entry/meal_flow.dart`,presign 上传 + 乐观落库)
- 菜品分解(模板优先 + language LLM 兜底,`services/meal-dish/decomposition.service.ts`)
- 食材成分 grounding(三级匹配 `foodCompositionItem`,与中国食物成分表真实联动,不静默归零)
- 营养估算与规则评论(启发式估算有「保守估算」标注与 `matchDiagnostics`)
- 分析落库与可追溯(`payload.mealAnalysis` + 热字段 + revision 幂等 + 失败原因明示)
- 饮水记录(快捷一键 + 默认量偏好 + 真实撤销)
- 睡眠记录(结构化表单 + start/wake 合并 + 跨日计算,有单测)
- 心情记录(快捷点选 + `moodLabel`/`moodLevel`)
- 症状记录(多选批量写入 + 默认严重度偏好)
- 用药快速记录(slot-aware dose log 写入/回滚,非创建型,不猜测 scheduledTime)
- vital/activity 完整表单创建(value/unit 必填校验,后端 `ensureValidVitalPayload` 等)
- 普通笔记(独立类型:快捷入口/筛选/时间线/详情;退出主动建议闭环为既定决策)
- quick-entry 面板与偏好(7 入口 + 排序/图标/角标,阶段 1–9 已收口)
- NLP 自然语言录入(候选生成 + 审核编辑器 + 选择性保存,部分失败汇总全部原因)
- 记录编辑/删除/回看/拖拽改期(类型锁定、软删除、桌面拖拽改 `occurredAt`)
- 稀疏记录语义契约(未知≠0、`ObservedMetric` 三处同构;口径统一方案见「四、跨计划引用」)

## 三、改造项(按优先级分组)

### P1

#### P1-3 餐食分析分层触发(懒触发，调研 §1 改造建议，0.1.0 后)

- 现状:任何带 1 张图片的 meal 记录都自动排队完整链路(vision + 分解 2 次 LLM 调用),`worker.service.ts` 全量执行。
- 方案:保存后自动执行一次低成本 vision 识别(产出 `mealDescription` + `foodItems[]`);菜品分解与 grounding 推迟到用户查看详情、要求精确营养或候选洞察确有需要时再触发。worker 按 `analysisStatus` 分阶段推进,`analysis_failed` 兜底语义不变。
- 涉及文件:Lucent `services/meal-analysis/worker.service.ts`、`vision.service.ts`、`records.service.ts`(详情触发入口);客户端详情页摘要卡增加「分析中/可深入分析」状态展示(`widgets/meal/analysis_summary_card.dart`)。
- 分工:后端改 worker 分段调度与按需触发端点;客户端改详情页状态与触发调用。
- 依赖:无；餐食分层触发为 0.1.0 后事项。

#### P1-4 vital 时间序列基建(体重/血糖/血压统一)(调研 §2.6，已决策，0.1.0 后)

> 本节为跨计划共享基建的权威定义,health-event 计划(C-1 `weightKg`)与 report 计划(纵向洞察周/月单维趋势)引用本节,不在各自计划重复展开。

- 现状:vital 已有完整表单创建与真落库(后端 kind 枚举与 Prisma `DailyRecordKind` 对应),但无时间序列维度;档案字段 `weightKg` 是单点基线。
- 方案:
  - 档案字段 `weightKg` 保留为当前基线;新增体重时间序列记录,来源 = 手动录入 + 已接入的平台导入。
  - 体重、血糖趋势、血压合并为统一「vital 时间序列」基建:同一查询/聚合路径产出单维趋势(带覆盖率标注,沿用稀疏语义:unknown 天不绘点、不静默归零)。
  - 趋势消费方:纵向洞察周/月单维趋势(report 计划)、桌面趋势图(P2-3,同源)。
  - 体重记录入口放进记录页快捷记录(quick-entry 面板新增/替换入口,复用现有偏好基建)。
- 涉及文件:Lucent `daily-records`(vital 聚合查询)、趋势输出契约;客户端 `lib/features/record/`(quick-entry 入口、vital 表单复用)、趋势数据层(替换 `_staticTrends`,见 P2-3)。
- 分工:后端出统一 vital 时间序列查询/聚合(带 `ObservedMetric` 式覆盖率);客户端接入 quick-entry 与趋势展示。
- 依赖:ObservedMetric 口径统一(见「四、跨计划引用」);平台导入通道依赖 health-event/mine 侧既有桥接能力。

### P2

#### P2-2 静态残留清理(调研 §4.1 P2，0.1.0 前)

- 现状:`lucent.dart` 中 `_staticWeekDays` 仍有静态残留;`_staticSummary` 已于 P1-1 随本项移除。
- 方案:核对 `_staticWeekDays` 的实际引用范围后一并清理。
- 依赖:P1-1。

#### P2-3 桌面趋势图真实数据化(调研 §4.2，桌面高级能力冻结)

- 现状:`lucent.dart` 的 `_staticTrends` 含一条硬编码血糖序列(`[5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9]`),全库无任何 widget 引用 `RecordTrend`,属死代码与误导性数据资产。
- 方案:不删除,改造——将硬编码序列替换为真实 vital 时间序列查询(P1-4 同源),unknown 天不绘点;`_staticTrends` 与 `RecordTrend` 相关定义替换为真实查询函数,严禁硬编码样本点。作为桌面「大屏纵向阅读」资产保留。
- 挂起:桌面/Web 形态待 ADR-0012,见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md),本文不展开形态决策。
- 依赖:P1-4(vital 时间序列基建);ADR-0012。

#### P2-4 桌面月历服务端标记(调研 §4.3，桌面高级能力冻结)

- 现状:`Active_UI_Record.md` 声称「同月时使用父组件传入的 days(含服务端标记)」,实际 `fetchDashboard.monthDays` 来自 `_staticMonthDays`(仅选中/今天高亮),文档言过其实。
- 方案:改造为真实服务端标记,复用 daily records 按日聚合(与 P2-3 同源);同步修正 `Active_UI_Record.md` 表述。
- 挂起:随桌面/Web 调研启用,见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)。
- 依赖:ADR-0012;P1-1 的 summary 接线可提供聚合路径参考。

#### P2-5 Today 联动:饮食/饮水/睡眠/心情升级为建议平级原料(调研 §5，0.1.0 前)

- 现状:Today Analysis 仅由 symptom record、health-event create/end、symptom check-in、dose log 与合格 suggestion materialization 触发;水/餐/眠/情/笔记只进上下文不触发分析(`today-analysis/.../pipeline/context.service.ts`)。
- 方案:允许饮食、饮水、睡眠、心情在覆盖率足够、变化有行动价值时触发日/周洞察;是否进主卡由覆盖率、时间范围、变化幅度与可行动性门控,不按记录类型一刀切退出闭环;仍禁止无数据或低覆盖时强行生成泛化建议。普通笔记默认只作上下文证据(既定决策,不动)。
- 分工:后端改 today-analysis 触发器与门控;客户端无需改动(建议展示走既有链路)。
- 依赖:today 计划(第 4 位)的今日建议主线改造；采用已定门控阈值后实现。

## 四、跨计划引用与依赖

- **ObservedMetric 口径统一**:`summarizeWaterMetrics`/`toObservedWaterMetric`(Lucent `common`)三处共用 mapper 的口径统一方案见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-5 一节,本文不重复展开;P1-4 的 vital 趋势输出沿用该口径。
- **桌面/Web 形态挂起**:P2-3、P2-4 不再扩展 Flutter 产品面；桌面高级能力继续冻结，本文不展开。
- **被引用**:本文档「P1-4 vital 时间序列基建」一节为共享基建定义,health-event 计划(C-1 `weightKg`)与 report 计划(纵向洞察趋势)引用本节。
- **Today 联动分工**:P2-5 的记录侧原料语义以本文为准,建议主链路改造归 today 计划(第 4 位)。
- **契约**:本计划不改 OpenAPI 契约(P1-1/P1-2 复用既有接口);若 P1-4 新增 vital 趋势端点,需走 `pnpm export:openapi` + `dart run scripts/bootstrap_generated_sources.dart` 标准流程。

## 五、本计划内执行顺序

1. P2-2、P2-5（0.1.0 前）：Today 联动采用已定门控并由 today 计划主链路消费。
2. P1-3、P1-4（0.1.0 后）：餐食分层与 vital 时间序列按既有 P1 和依赖顺序恢复。
3. P2-3、P2-4：桌面高级能力冻结。

## 六、已决边界与延期项

- 饮水目标唯一来自 `user-settings`；`ObservedMetric` 仅来自记录事实，未知不得以 0 代替。
- Today 联动由 Lucent 计算门控：近 7 天至少 3 条有效记录，或相对个人基线变化至少 50%；所有来源共享每天 3 次分析预算。
- 餐食分层分析、vital 时间序列（含体重）为 0.1.0 后；Flutter 桌面趋势图与月历能力冻结。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
- 调研文档全文无工作量(人日)估算,本计划同样不做估算。
