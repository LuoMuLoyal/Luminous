# lib/features/record — 记录 tab(日常记录)

五 tab 中的第二个 tab(`Routes.record` = `/record`):以"稀疏事件记录"(ADR-0007)
为语义的日常记录录入与时间线——快速录入、NLP 候选录入、记录详情/编辑、按类型
过滤的时间线看板;数据契约被 today / health_data 复用。

## 职责与边界

- 管:`DailyRecord` 读写 + 离线同步、record tab 看板与时间线、全部快速录入 flow
  与本地偏好、NLP 录入流、记录图片附件上传。
- 不管:服药记录本身(medicine 的 DoseLog;`RecordEntryType.medication` 经
  `domain/entities/type_mapping.dart` 映射为 null,medication 永不落 daily record)、
  健康档案(health_context)、报告分析(review)。

## 对外契约

- 路由:`Routes.record`(tab 分支)+ `presentation/routes.dart` 的 5 个 TypedGoRoute
  (RecordCreateRoute / RecordDetailRoute / RecordEditRoute /
  RecordQuickEntrySettingsRoute / RecordQuickEntryReorderRoute),经
  `record_routes.$appRoutes` 注册进 lib/app/router.dart。
- 导出(相对本目录):
  - `domain/entities/record.dart` — `DailyRecordKind` / `DailyRecordItem`
  - `domain/repositories/daily.dart`(`DailyRecordRepository`)、
    `domain/repositories/record.dart`(`RecordRepository`)
  - `data/providers/record_access.dart` — `dailyRecordRepositoryProvider` /
    `dailyRecordListForDateProvider`
  - `application/usecases/water_quick_entry.dart`(`WaterQuickEntryFlow`)、
    `application/usecases/quick_entry_undo.dart`(`QuickEntryUndoService`)、
    `data/datasources/quick_entry_preferences.dart`(`quickEntryPreferencesProvider`)
- 被依赖:today(看板摘要;一键饮水复用 water flow 与 undo 服务)、
  health_data(健康数据同步映射 daily record)、lib/app/router.dart。

## 不变量

- 稀疏记录语义(ADR-0007):只存用户主动记录的事件,不做隐式补录。
- repository 边界:可恢复失败 = `TaskEither` Left;timeline/summary 等次要输入失败
  降级为空(产品行为,仅记 appTalker),协议违例继续抛出
  (test/record/data/repositories/lucent_repository_test.dart)。
- 快速录入 UX:单击 = 记录 + 可撤销(`QuickEntryUndoService`),长按 = 该类型设置;
  成功后 emit `DataChangeTopic.dailyRecords` 驱动跨页刷新
  (test/record/quick_entry/、test/record/presentation/services/quick_entry_undo_test.dart)。
- 睡眠一次性录入:单击睡眠瓦片打开 sheet,收「类型(夜间睡眠/小睡) + 就寝 + 起床 + 睡眠质量 + 备注」
  后落**一条**完整记录,时长由就寝/起床算出。归属日 = 记录页所选日期,语义为**起床日**
  (`occurredAt` 取该日期、`occurredTime` 取起床时刻),sheet 内显式写出「记为 X月X日 睡眠」。
  夜间睡眠最多跨一个午夜,小睡必须同日且 ≤3 小时,夜间睡眠 ≤16 小时;切到小睡时若当前时段不合法
  自动回落到 13:00–13:30(test/record/sleep_quick_entry_sheet_test.dart、
  test/record/domain/services/sleep_entry_test.dart)。
- 睡眠 payload 键位的唯一出处:`domain/services/sleep_entry.dart` 的 `buildSleepPayload`
  (`startedAt`/`endedAt`/`durationMinutes`/`sleepType`,加可选 `quality`/`deepMinutes`/`lightMinutes`/
  `remMinutes`);legacy `startAt`/`endAt` 与 `sleepEvent` 临时事实已停用,不做兼容读。
- 小睡类型来源:手动录入写显式 `sleepType`;设备导入(HealthKit / Health Connect)因没有用户声明,
  仍按时长推断(≤180 分钟记为 nap)。
- `RecordEntryType` ↔ `DailyRecordKind` 映射唯一出处:`domain/entities/type_mapping.dart`
  (test/record/type_mapping_test.dart)。
- 记录类型图标/强调色只取 `SemanticIcons` / `SemanticColor` token
  (`domain/entities/dashboard.dart` 的 `defaultQuickActions`)。
- 日期 wire 契约:本地时区 `yyyy-MM-dd`(`data/providers/record_access.dart`)。

## 依赖禁区

- data→data、presentation→presentation(providers)禁止;settings 只经
  `UserSettingsRepository` domain 接口消费(`data/providers/water_target.dart`)。
- health_context 消费限于 snapshot provider/entity 与 `unit_conversion.dart`;
  不 import 其他 feature 的 presentation providers。

## 陷阱与决策

- `LucentRecordRepository` 把 timeline/summary 失败降级为空是有意产品行为,勿改成 Left。
- create 走乐观写入 + pending-sync 队列(`daily_record` replay handler 注册于
  `data/providers/record_access.dart`);update 重放是 best-effort,勿假设幂等回放。
- 月份日历/趋势区块在仓库内仍是静态 mock(待后端 API);新类型先看 `defaultQuickActions`。
