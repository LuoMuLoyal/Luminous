# 日常记录模块（Record，含餐食分析）功能点盘点与真伪审计

> 审计日期：2026-08-15 ｜ 立场：面向真实用户的生产级产品，不参考历史投入成本
> 范围：Luminous `lib/features/record/`（客户端）+ Lucent `daily-records` / `today-analysis`（联动）/ `files` / `llm-runtime`（后端）
> 方法：抽样读代码验证（后端服务、客户端 flow/页面/控制器），对照 `docs/00-current/*`、`Lucent/docs/00-current/Active_Product_Loop.md`、migration log（2026-07-01 起 meal-analysis 里程碑）、`plans/`（按任务规则视为已执行完毕）。与已有审计（`research/02-功能盘点/today-今日建议.md` 等）不重复，仅评估本模块专属功能点及其联动价值。

## 0. 审计总览

| # | 功能点 | 一句话作用 | 真伪判定 | 结论 | 优先级 |
|---|--------|-----------|---------|------|--------|
| 1 | 餐食记录（拍照/相册/手动） | 创建 meal 记录并可带 1 张图片附件 | 真实现 | 保留 | — |
| 2 | 餐食 AI 识别（vision） | 图片 → LLM 识别菜品/描述 | 真实现 | 保留（改懒触发） | P1 |
| 3 | 菜品分解（模板+LLM） | 菜品名 → 核心食材列表 | 真实现 | 保留 | — |
| 4 | 食材成分 grounding | 食材 → 中国食物成分表营养值 | 真实现（真数据联动） | 保留 | — |
| 5 | 营养估算与评论 | 汇总能量/蛋白/脂肪/碳水 + 规则评论 | 真实现（保守估算有标注） | 保留 | — |
| 6 | 分析结果落库与可追溯 | payload.mealAnalysis + 热字段 + 图片/时间戳/诊断 | 真实现 | 保留 | — |
| 7 | 分析确认/编辑/模板学习 | 确认结果、编辑菜品、学习菜谱模板 | 真实现 | 保留（简化入口） | P2 |
| 8 | 饮水记录 | 快捷一键记录 + 默认量/自定义 ml + 撤销 | 真实现 | 保留 | — |
| 9 | 详情页饮水进度卡 | 当日 ml 聚合 + 进度条 | 部分实现（目标值硬编码 2000） | 改造 | P1 |
| 10 | 睡眠记录 | 结构化录入 + 快速 start/wake 合并 | 真实现 | 保留 | — |
| 11 | 心情记录 | 快捷点选 + moodLabel | 真实现 | 保留 | — |
| 12 | 症状记录 | 多选 + 默认严重度 | 真实现 | 保留 | — |
| 13 | 用药快速记录 | slot-aware dose log 写入/回滚 | 真实现（非创建型） | 保留 | — |
| 14 | 体重/生命体征（vital）、活动 | 完整表单创建，真落库 | 真实现 | 保留 | — |
| 15 | 普通笔记 | 独立类型：快捷入口/筛选/时间线项 | 真实现 | 保留 | — |
| 16 | quick-entry 面板与偏好 | 7 入口 + 排序/图标/角标/撤销 | 真实现 | 保留 | — |
| 17 | NLP 自然语言录入 | 后端候选生成 + 审核/选择性保存 | 真实现 | 保留 | — |
| 18 | 记录编辑/删除/回看/拖拽改期 | 编辑锁定类型、删除确认、详情轮询、桌面拖拽 | 真实现 | 保留 | — |
| 19 | 稀疏记录语义 | 未知≠0、coverage/observed 不混淆 | 真实现（前后端契约一致） | 保留 | — |
| 20 | Record 页摘要网格 | 桌面端当日分类摘要卡 | 部分实现（后端有接口，客户端恒传空 → 永不渲染） | 改造（接线） | P1 |
| 21 | 桌面月历「服务端标记」 | 日期格带记录标记 | 部分实现（仅本地选中日高亮，无真实标记） | 改造或改文档 | P2 |
| 22 | 桌面趋势图 | 7 天血糖折线 | 死代码（硬编码假数据，无任何渲染引用） | 删除 | P2 |

分布：21 项真实现/部分实现中，真实现 16、部分实现 4、死代码 1。未发现「假实现」（占位/伪造/点击代替保存）模式。

---

## 1. 餐食与营养分析链路（功能点 1–7）

### 1.1 餐食记录（拍照/相册/手动）

**现状**：快捷入口单击直接调相机（`presentation/quick_entry/meal_flow.dart`），拍照后在确认对话框补充标题/名称描述/备注，确认后才压缩上传并创建 `DailyRecordKind.meal` 记录；取消不写入。长按入口与创建表单支持无照片手动录入（`MealQuickConfirmationDialog`、`create.dart`）。

**实际作用**：meal 记录与图片附件真实落库，是后端分析链路的入料口。

**真伪判定：真实现**。`meal_flow.dart` 的 `saveDraft()` 走 `uploadImage()`（presign 上传，`POST /api/v1/user/daily-records/attachments/images/presign-upload`）+ `createRecord()`；`LucentDailyRecordRepository.create`（`data/repositories/lucent_daily.dart`）先写 Drift 乐观副本，远程成功后 `confirmSync`，离线入队 `PendingSyncItems` 由 SyncWorker 重放。无「点击代替保存」。

**结论**：保留。

### 1.2 餐食 AI 识别（vision）

**现状**：后端 `services/meal-analysis/vision.service.ts` 通过 `LlmRuntimeService.createChatModel('vision')` 调 OpenAI-compatible 多模态模型，System/User prompt 要求只识别可见食物、不编造隐藏食材、输出固定 JSON；结果做长度裁剪、控制字符剥离、安全过滤（`LlmSafetyPolicyService`）；解析失败返回空结果而非编造。`isConfigured()` 未配置 vision 角色时 worker 写 `analysis_failed`，不产生假内容。

**实际作用**：真实 LLM 识别，产出 `mealDescription` + `foodItems[]`（name/confidence/portionText）。

**真伪判定：真实现**。逐行核对 `vision.service.ts`（真实模型调用 + 严格 JSON 解析 + 空结果兜底）；`llm-runtime/services/llm-runtime.service.ts` 的 `hasRoleConfig` 按 role 配置真实存在。

### 1.3 菜品分解（模板 + language LLM）

**现状**：`services/meal-dish/decomposition.service.ts` 先查 `meal_dish_templates` 表（精确/别名匹配），未命中才调 language 角色 LLM 分解为食材列表（含 defaultRatio/confidence），失败记 `unresolvedDishes`。

**真伪判定：真实现**。模板命中路径为零 LLM 成本，模型路径有严格 JSON schema 校验。

### 1.4 食材成分 grounding（与 DrugDataBase 联动）★

**现状**：`services/meal-ingredient/grounding.service.ts` 以 exact → alias → fuzzy 三级匹配 `foodCompositionItem` 表（`normalizedName`/`searchText` 前缀 + 字符重合度打分，阈值与 lead 差距双条件），产出 `matchMethod`/`matchScore`/`coverage`（none/partial/complete），未命中显式标记 `unmatched`，**不静默归零**。

**数据来源**：`FoodCompositionItem` Prisma 模型（能量/蛋白/脂肪/碳水/纤维/钠等 20+ 字段）由 `Lucent/scripts/import/food/import-food-composition.ts` + `parsers/food_items.py` 从 `DrugDataBase/中国食物成分表/中国食物成分表.xlsx`（标准中国食物成分表，migration log 记为 purchased workbook）导入，含 import run 审计。**这是与 `DrugDataBase` 的真实数据联动，不是静态/伪造营养数据。**

**真伪判定：真实现**。

### 1.5 营养估算与评论

**现状**：`matcher.service.ts` 按份量文本启发式（克数/碗/少量 → 默认份量阈值，全部环境变量可配）估算克数，聚合核心营养素；评论为确定性规则（蛋白质充足/碳水偏少/油脂偏高/部分未命中成分表），有「保守估算」字样与 `matchDiagnostics`。

**实际作用**：估算有明确不确定性标注与覆盖率披露，符合产品「证据不足时弃权」原则。

**真伪判定：真实现**（估算本身是启发式近似，但标注诚实、无伪造来源）。

### 1.6 分析落库与可追溯

**现状**：`worker.service.ts`（BullMQ 队列，Redis 断连时同步兜底）幂等检查 revision 后，签名 COS URL → 识别 → 匹配 → 写回 `payload.mealAnalysis`（`analysisStatus='unconfirmed'`、`analyzedAt`、`imageObjectKey`、`sourceRevision`、`matchDiagnostics`）+ 热字段（`mealAnalysisStatus/Coverage/UpdatedAt/FailureReason`）。**证据链完整：图片附件保留、结果时间戳、来源 revision、失败原因明示。**

**真伪判定：真实现**。测试佐证：`meal-analysis/` 四个 spec 共 1424 行、`meal-dish/` 460 行、`meal-ingredient/` 245 行。

### 1.7 确认 / 编辑 / 模板学习

**现状**：详情页展示分析摘要卡（`widgets/meal/analysis_summary_card.dart`），编辑页可编辑 `mealInput.recognizedDishes`（`dish_editor.dart`）并勾选「确认当前结果」→ PATCH payload `mealAnalysis.analysisStatus='confirmed'`。后端 `records.service.ts` 识别 confirm 请求后 `buildConfirmedMealPayload` 快照 `mealAnalysisLastConfirmed` + `confirmedAt`，并触发 `MealDishTemplateLearningService.learnFromConfirmedAnalysis`（只学习已 grounding 的菜品模板，不学习份量）；菜品编辑导致 `hasMealDishInputChanges` 时以原图重新入队分析，不保留过期结果。分析中状态在详情页按 5s→30s 指数退避轮询（`detail.dart`，防重入）。

**真伪判定：真实现**。

**改造建议**（餐食链路整体）：
- **P1 分层分析**：当前「任何带 1 张图片的 meal 记录」都自动排队完整链路（2 次 LLM 调用：vision+分解）。长期健康伙伴需要保存后即可获得轻量结构化结果，不能把全部分析推迟到用户主动打开详情；建议自动执行一次低成本视觉识别，只有用户查看详情、要求精确营养或候选洞察确有需要时才继续菜品分解与 grounding。
- **P2 确认入口简化**：确认结果目前要进编辑页；详情页摘要卡即可提供「确认」按钮，减少一步跳转。
- **P2 成分表增量**：`FoodCompositionItem` 已含 20+ 营养字段但 UI 只展示 kcal/蛋白；对 C 端当前定位（观察项）够用，不必扩展。

---

## 2. 各记录类型（功能点 8–15）

### 2.1 饮水记录

**现状**：单击即按 `QuickEntryPreferences.waterDefault`（250/500 ml、杯、次、自定义 ml）创建 water 记录，成功 toast 带撤销（`QuickEntryUndoService` 真实删除刚建记录）。角标按偏好显示次数或累计量。

**真伪判定：真实现**。`water_flow.dart` → `createRecord` → 网络创建 + 乐观缓存；撤销走 `deleteDailyRecord` 真实回滚。仅有的问题是 ml 模式角标依赖摘要数据（见 §4.2 断线）。

### 2.2 睡眠记录

**现状**：结构化表单（就寝/起床/质量/深睡浅睡 REM 分钟，`sleep_structured_fields.dart`，payload 存 `startAt/endAt/durationMinutes/quality/deepMinutes/lightMinutes/remMinutes`）；快捷流程 start fact（`sleepEvent=start`）→ wake fact（`startedRecordId` 关联）→ 合并确认后写入标准 episode 并删除两条临时事实；多 start 时弹出选择、不猜测；睡眠兜底校验（醒来须晚于入睡、时长 >0）。

**真伪判定：真实现**。合并、撤销、跨日计算（`_isWakeAfterStart`、bed 减一天）均有实现与单测。

### 2.3 心情 / 2.4 症状

**现状**：mood 快捷弹窗点选即存（payload 带 `moodLabel`/`moodLevel`），详情页本地化展示；symptom 支持多选批量写入（部分失败保留可重试）+ 默认严重程度偏好。

**真伪判定：真实现**。均走真实 `createRecord`，批量确认不显示撤销 toast（显式确认语义正确）。

### 2.5 用药快速记录（非创建型）

**现状**：读取药箱/提醒计划/当日 dose logs：0 药引导去药品页；1 药且附近有 pending slot 走 slot-aware mark，无 slot 走临时服药路径且**不猜测 scheduledTime**；已 taken/skipped 不重复写入；撤销为 dose log 真实回滚（新建删除、旧态恢复）。

**真伪判定：真实现**（`medication_flow.dart` 调用 `markDose(MedicationQuickMarkInput{status:'taken', reminderId, scheduledTime})` 真实写后端 dose log）。

### 2.6 体重/生命体征（vital）与活动（activity）

**现状**：不在 7 个快捷入口内，但完整创建/编辑表单可选（`activeDailyRecordKinds` 含 8 种），value/unit 必填校验，后端 `ensureValidVitalPayload`/`ensureValidActivityPayload` 校验。时间线/筛选/详情支持。

**真伪判定：真实现**（后端 kind 枚举与 Prisma `DailyRecordKind` 完全对应，数据真落库）。

### 2.7 普通笔记

**现状**：独立类型：独占快捷入口（左图标右文字横向布局）、独立筛选 chip、时间线项标题取 note 正文预览、详情/编辑完整支持。

**真伪判定：真实现**。与产品定位一致（笔记=事件回看里的自由文本证据），TODO 中「笔记保留录入与回看、退出主动建议闭环」为既定决策，非缺陷。

---

## 3. quick-entry / NLP / 编辑回看（功能点 16–18）

### 3.1 quick-entry 面板与偏好（阶段 1–9 已收口）

面板渲染 7 入口 + 动态排序/自定义顺序/自定义图标/饮水默认量与角标/睡眠进行中徽章/心情最新值徽章/症状选项与默认严重度；长按弹类型设置面板（不再有「双击心智负担」）。**真伪判定：真实现**。偏好全部落 SharedPreferences（`PrefKeys`），徽章数据来自真实 timeline/summary。

### 3.2 NLP 自然语言录入

**现状**：header sparkles 入口 → bottom sheet → `POST /daily-records/candidate-records/generate`（后端 `candidates/generator.service.ts` 走 `BaseLlmGeneratorService` + Zod schema 结构化输出）→ 候选审核编辑器（可改 title/value/unit/note、睡眠时间选择器、取消项、只重试失败项）→ 选择性保存；部分失败汇总全部原因（2026-08-15 修复）。语音与 OCR 已按产品职责移除（非隐藏缺陷）。

**真伪判定：真实现**。候选保存逐项 `repo.create()`，无 UI-only 反馈。

### 3.3 编辑/删除/回看/拖拽改期

编辑页锁定类型不可切换、dirty 拦截返回、保存时表单禁用；删除走确认对话框 + `deleteRecord` use case（软删除）；桌面端时间线卡片可拖拽到日历改 `occurredAt`（`Draggable`/`DragTarget` → `repo.update` + 事件刷新）；详情页相邻导航（上一条/下一条）。**真伪判定：真实现**。

---

## 4. 断线与死代码（功能点 20–22）

### 4.1 Record 页摘要网格：接口存在、前端断线 【部分实现/死 UI】

- 后端：`GET /api/v1/user/daily-records/summary` 真实存在（`records.service.summary` → `mapper.toSummaries` 按 kind 聚合 count+latest），**且 Today 页正在消费**（`features/today/data/repositories/lucent.dart` 调用 `fetchSummary`）。
- 客户端：`LucentDailyRecordRepository.fetchSummary` 与 datasource 均实现，但 `LucentRecordRepository.fetchDashboard`（`data/repositories/lucent.dart:73`）硬编码 `summary: _staticSummary`（恒为 `RecordDaySummary(items: [])`）。
- 后果：桌面端 `RecordSummaryGrid` 因 `items.isEmpty` 渲染 `SizedBox.shrink()`，**摘要网格永不可见**；饮水角标「累计 ml」模式同样永远取不到值（仅次数模式因走 timeline 真实数据而正常）。这是「静态空数据冒充/掩盖动态能力」的典型断线：能力在后端，消费端没接。

**结论：改造（接线）**。
- **P1**：`fetchDashboard` 内改为并行拉 `fetchRecords` + `fetchSummary(dateStr)`，把后端 summaries 映射为 `RecordDaySummary.items`；失败时优雅降级为空（与时间线失败处理一致）。恢复桌面摘要卡与饮水 ml 角标。
- **P2**：接线后移除 `_staticSummary`/`_staticWeekDays` 中仅剩的静态残留。

### 4.2 桌面趋势图：硬编码假数据死代码 【死代码】

`lucent.dart` 的 `_staticTrends` 含一条血糖趋势，`points: [5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9]` —— 全库检索确认无任何 widget 引用 `RecordTrend`（仅有定义与 freezed 产物）。这是「静态数据冒充动态」的残留，当前不渲染所以无用户伤害，但属于死代码与误导性数据资产。

**结论：删除**。**P2** 直接删除 `_staticTrends` 与 `RecordTrend` 相关定义（保留 freezed 产物待清理评估）；若未来要「单一维度趋势」（产品愿景允许），应接 Report/Review 的真实单一维度序列，严禁硬编码样本点。

### 4.3 桌面月历「服务端标记」表述与实现不符 【部分实现】

`Active_UI_Record.md` 写「同月时使用父组件传入的 days（含服务端标记）」，但 `fetchDashboard.monthDays` 来自 `_staticMonthDays`（仅选中/今天高亮，无任何服务端数据来源）。不构成造假（无标记≠有数据未显），但文档言过其实。

**结论：改造**。**P2**：要么接真实「当日有记录」标记（时间线数据已在手，成本低），要么修正文档表述为「仅高亮选中日」。

### 4.4 详情页饮水进度卡目标值硬编码

`detail.dart:820` `_waterDailyTargetMl = 2000`，而后端已有 `user-settings.waterTargetCount`（Today Analysis 同源）。**P1**：改读用户设置（经 `user-settings` API 或 summary 契约），避免「详情页说 2000、Today 说 8 杯×250ml」口径分裂。

---

## 5. 稀疏记录语义与 Today 联动（功能点 19，联动评估）

- 客户端边界（Active_UI_Record 已载明并与代码一致）：饮水仅汇总 `unit=='ml'` 可解析值，`0 ml` 是 observed zero，无数据保持 unknown/none，分页不完整标 partial；用药按 reminder slot 保留身份，`planned` 消费为 `unconfirmed`，临时 dose log 不进分母；睡眠 nightSleep/nap 同日均保留。
- 后端：`summarizeWaterMetrics`/`toObservedWaterMetric` 为 Today collector、Today Analysis、Report 共用的纯 mapper（Lucent `common`），`ObservedMetric` 的 `value/state/coverage/sources/observedCount/expectedCount` 已在三处 OpenAPI schema 同构暴露。
- 联动现状：Today Analysis 目前仅由 symptom record、health-event create/end、symptom check-in、dose log 与合格 suggestion materialization 触发；水/餐/眠/情/笔记进入上下文但不会主动触发分析（`today-analysis/.../pipeline/context.service.ts` 的 `buildRecordSummary`/`recentRecords`）。这在“事件优先”旧口径下是成本控制，在长期健康伙伴定位下会漏掉最重要的非生病价值。产品上应允许饮食、饮水、睡眠和心情在覆盖率足够、变化有行动价值时触发日/周洞察；仍禁止无数据或低覆盖时强行生成泛化建议。

**结论**：稀疏语义整体真实现且契约一致；饮食、饮水、睡眠和心情应成为主动建议的平级原料，普通笔记默认只作上下文证据。是否进主卡由覆盖率、时间范围、变化幅度与可行动性门控，而不是按记录类型一刀切退出闭环。

---

## 6. 后端投入错配判断

1. **餐食分析链路是低负担记录的核心资产，但计算层次需要重排**：vision 识别 + 菜品分解 + 三级 grounding + 模板学习让用户可以用一张照片留下结构化线索，直接服务长期健康伙伴。问题不是“用户可能不看详情”，而是每张图都默认跑完整深度分析。建议保存后自动完成能支撑次日建议的轻量识别，只有需要精确成分、用户打开详情或候选洞察要求时再执行深度分解与 grounding。
2. **files 模块与 daily-records presign 上传并存**：`modules/files`（通用上传）与 `daily-records` 自带 presign 端点功能重叠，餐食链路用后者。建议后续统一入口，避免双维护（P2，不阻塞）。
3. **前端断线反向拉低后端投入价值**：后端 summary 端点做好了且 Today 在用，但 Record 页不接线导致桌面摘要卡永远空——这是前端欠账，不是后端过度投入。
4. 未发现「后端为 C 端不需要的能力巨额投入」的明显案例：candidates/meal-analysis/observed metric 均有真实消费方。

---

## 7. 模块级结论

**价值判断**：日常记录模块是 Luminous 最扎实的模块之一——16/21 个功能点真实现，核心链路（写→分析→落库→确认→模板学习→证据追溯）真实完整，营养数据与 `DrugDataBase/中国食物成分表` 真联动、有覆盖率与「保守估算」标注，稀疏语义在前后端契约层保持一致。未发现假实现模式（占位数据、伪造 AI 内容、点击代替保存）。主要问题集中在**客户端接线断线**（摘要网格、饮水 ml 角标、月历标记）与**少量死代码/硬编码**（假血糖趋势、2000ml 目标）。

**餐食分析：保留并提升为健康伙伴核心输入，重构计算触发方式，不降级为纯手动。**
- 核心理由：它把用户最不愿手填的饮食信息压缩成一次拍照，并提供「证据 + 解释 + 边界说明」；成分表 grounding、确认制和模板学习是形成个人饮食上下文的差异化资产。
- 输出边界：不得从一两餐外推全天摄入，也不输出未经覆盖率支撑的“碳水超标”。可表述为「你今天记录的两餐都以主食为主，蔬菜记录较少」，并给一个低风险、可逆的小建议。
- 改造清单：P1 轻量识别自动、深度分析按需；P1 让有覆盖率的餐食/饮水/睡眠/心情进入日周洞察；P1 摘要网格接线（顺带修复饮水 ml 角标）；P1 饮水目标值接用户设置；P2 详情页直接确认结果；P2 删除假趋势死代码；P2 月历标记真实化或修文档。

**改造优先级汇总**：P0 无；P1 四项（分层餐食分析、日周洞察消费、摘要接线、饮水目标值）；P2 四项（确认入口、死代码清理、月历标记、上传入口统一）。
