# lib/features/record — 记录 tab(日常记录)

五 tab 中的第二个 tab(`Routes.record` = `/record`):以"稀疏事件记录"(ADR-0007)为语义的日常记录录入与
时间线——快速录入、NLP 候选录入、记录详情/编辑、按类型过滤的看板;数据契约被 today / health_data 复用。

## 职责与边界

- 管:`DailyRecord` 读写 + 离线同步、record tab 看板与时间线、全部快速录入 flow 与本地偏好、NLP 录入流、
  记录图片附件上传。
- 不管:服药记录本身(medicine 的 DoseLog;`RecordEntryType.medication` 经
  `domain/entities/type_mapping.dart` 映射为 null,medication 永不落 daily record)、健康档案
  (health_context)、报告分析(review)。

## 对外契约

- 路由:`Routes.record`(tab 分支)+ `presentation/routes.dart` 的 5 个 TypedGoRoute(RecordCreateRoute /
  RecordDetailRoute / RecordEditRoute / RecordQuickEntrySettingsRoute / RecordQuickEntryReorderRoute),
  经 `record_routes.$appRoutes` 注册进 lib/app/router.dart。
- 导出(相对本目录):
  - `domain/entities/record.dart` — `DailyRecordKind` / `DailyRecordItem`
  - `domain/repositories/daily.dart`(`DailyRecordRepository`)、`domain/repositories/record.dart`
    (`RecordRepository`)
  - `data/providers/record_access.dart` — `dailyRecordRepositoryProvider` /
    `dailyRecordListForDateProvider`
  - `application/usecases/water_quick_entry.dart`(`WaterQuickEntryFlow`)、
    `application/usecases/quick_entry_undo.dart`(`QuickEntryUndoService`)、
    `data/datasources/quick_entry_preferences.dart`(`quickEntryPreferencesProvider`)
- 被依赖:today(看板摘要;一键饮水复用 water flow 与 undo 服务)、health_data(健康数据同步映射 daily
  record)、lib/app/router.dart。

## 不变量

- 稀疏记录语义(ADR-0007):只存用户主动记录的事件,不做隐式补录。
- repository 边界:可恢复失败 = `TaskEither` Left;timeline/summary 等次要输入失败降级为空(产品行为,仅记
  appTalker),协议违例继续抛出(test/record/data/repositories/lucent_repository_test.dart)。
- 快速录入 UX:单击 = 记录 + 可撤销(`QuickEntryUndoService`),长按 = 该类型设置;成功后 emit
  `DataChangeTopic.dailyRecords` 驱动跨页刷新(test/record/quick_entry/)。症状走专用底部 sheet(单击即存、
  多选批量亦可撤销),情绪与备注仍走 `RecordFastEntryDialog`。
- 餐食快录:单击 = 先开相机(取消则不写入)、长按 = 无照片手动录入,两条路径都进同一个确认弹窗(入口
  `handleMealQuickAction(source:)`);标题/数值/备注/照片全空时确认按钮置灰,`MealQuickEntryFlow.saveDraft`
  在领域侧同样拒绝空 draft——空餐食记录永不落库
  (test/record/application/usecases/quick_entry_meal_test.dart、test/record/presentation/widgets/dialogs/meal_confirmation_test.dart)。
- 症状:payload `symptom`(目录码) + `severity`(`mild`/`moderate`/`severe`/`unknown`)是**数据真相**;
  记录级 `title`/`value` 只是展示文案(时间线/详情渲染用),规则与统计不得解析它们。`unknown` 表示用户判断
  不了,服务端跳过该条而不是记最小严重度。
- 睡眠:一次性录入(类型/就寝/起床/质量/备注 → 一条记录,时长算出),归属日 = **起床日**并在界面写出,
  小睡为显式类型、必须同日且 ≤3 小时,夜间睡眠 ≤16 小时;payload 键位唯一出处
  `domain/services/sleep_entry.dart`(断言见 test/record/domain/services/sleep_entry_test.dart、
  test/record/sleep_quick_entry_sheet_test.dart)。
- `RecordEntryType` ↔ `DailyRecordKind` 映射唯一出处:`domain/entities/type_mapping.dart`
  (test/record/type_mapping_test.dart)。
- 记录类型图标/强调色只取 `SemanticIcons` / `SemanticColor` token(`domain/entities/dashboard.dart` 的
  `defaultQuickActions`)。
- 餐食分析(契约 v2,一次多模态分析直出):列表条目取 `mealHeadline`(最重要的一条结论)+ 粗化到百位的热量区间
  (`mealCalorieMin|Max`,文案在视图层本地化),**不再有估算/已确认角标**(状态只有
  `analyzing | analyzed | analysis_failed`);详情页取 payload 的 `items`(rank 序)与 `dishes`。
  **客户端唯一可编辑的餐食字段是菜名**(`payload.mealAnalysis.dishes`,整份标记 `source: 'user'`,改菜名不重算
  结论与区间),没有人工确认这一步;失败态的「重新分析」= 把记录已有的那张图作为 attachment 重新 PATCH。
- 日期 wire 契约:本地时区 `yyyy-MM-dd`(`data/providers/record_access.dart`)。

## 依赖禁区

- data→data、presentation→presentation(providers)禁止;settings 只经 `UserSettingsRepository` domain
  接口消费(`data/providers/water_target.dart`)。
- health_context 消费限于 snapshot provider/entity 与 `unit_conversion.dart`;不 import 其他 feature 的
  presentation providers。

## 陷阱与决策

- `LucentRecordRepository` 把 timeline/summary 失败降级为空是有意产品行为,勿改成 Left。
- create 走乐观写入 + pending-sync 队列(`daily_record` replay handler 注册于
  `data/providers/record_access.dart`);update 重放是 best-effort,勿假设幂等回放。
- 月份日历/趋势区块在仓库内仍是静态 mock(待后端 API);新类型先看 `defaultQuickActions`。
