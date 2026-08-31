# lib/features/medicine — 药箱与服药计划

第三个 tab(`Routes.medicine`,`/medicine`):药箱工作台、服药计划(reminder)、服药打卡
(dose log)、用药风险预检(risk check)与提醒的本地通知调度。

## 职责与边界

- 管:`MedicineWorkspace` 聚合读模型;`ReminderRepository`(CRUD/组 upsert/投递回执)、
  `DoseLogRepository`(cache-first + 离线入队)、`MedicineRiskCheckRepository`
  (records/runCheck/runPrecheck);本地通知 planner/coordinator/delivery reporter;
  safety_tips 安全提示。
- 不管:药箱"当前用药"数据本体与写入在 health_context,加药闭环(搜索/扫码)唯一
  实现在 `search/presentation/widgets/shared/add_to_box.dart`;提醒的推送兜底投递在
  Lucent 后端;本地通知网关在 `lib/core/notifications/`;勿扰/提前量设置在 settings;
  药品搜索/扫码页在 search/scan。

## 对外契约

- 路由:tab `Routes.medicine`;`presentation/routes.dart` 定义 `MedicineSearchRoute`
  (`/medicine/search`,挂 search 的 `SearchPage`)、`MedicineDetailRoute`
  (`/medicine/detail/:source/:id`)、`MedicineRiskCheckRoute`、
  `MedicineRemindersNewRoute`、`MedicineReminderDetailRoute`/`EditRoute`
  (`/medicine/reminders/:medicineId[/edit]`)。
- 导出:`domain/repositories/{dose_log,reminder,risk_check}.dart` 及同名 entities、
  `data/providers/workspace.dart`(`reminderRepositoryProvider` 等)、
  `data/repositories/risk_check.dart`(`medicineRiskCheckRepositoryProvider`)、
  `presentation/routes.dart`、`presentation/widgets/shared/copy.dart`(MedicineCopyKey)。
- 被依赖:today(skip_dose/看板聚合/suggestion)、record(quick entry)、
  search(加药预检)、app/bootstrap(通知同步/回执 keepAlive)、app/router。

## 不变量

- repository 边界:可恢复失败一律 `TaskEither` Left(`LucentErrorMapper`),合法空集为
  Right;provider 层 Left 投影为 `AsyncValue.error`(ADR-0005)。
- 药箱单一事实源:列表派生自 health_context `currentMedicines(isCurrent)`,medicine 不
  本地存药箱;次级输入失败降级为空,不整体失败(`lucent_workspace.dart` 头注释)。
- 本地提醒 resync 全量替换:先 cancel SharedPreferences 旧通知 id 再重排;通知 id 由
  `reminderId@时刻` FNV-1a 稳定派生(31-bit 正数);投递回执按 `reminderId|date|time`
  服务端幂等 + 会话内去重(`presentation/providers/reminder_delivery_reporter.dart`)。
- 风险预检在途防重:运行中按钮禁用(`pages/risk_check.dart` 的
  `_isRunningStatic/_isRunningLlm`);`runPrecheck` 无副作用不落记录。
- 测试锚点:`test/medicine/reminder_notification_planner_test.dart`、
  `reminder_delivery_reporter_test.dart`、`cached_dose_log_data_source_test.dart`、
  `workspace_repository_test.dart`。

## 依赖禁区

- 跨 feature 只依赖 domain 接口/实体,不 import 其他 feature 的 data/presentation。
- 不直接写药箱数据(currentMedicines 写入走 `HealthContextRepository` 接口)。
- 不绕过 `core/notifications` 的 `LocalNotificationGateway` 直调通知插件;通知设置
  只读 settings 的 provider。

## 陷阱与决策

- `MedicineWorkspace.hero/alerts/promisePoints` 是历史原型残留(TODO(archive),无渲染
  消费方);告警应从 `riskCheckRecords` 派生,勿复用遗留字段。
- DND 窗口可跨午夜;`PlannedNotification.payload` 携带逻辑时刻,提前量只改触发时刻
  不改回执口径。dose log 写失败仍入 pending-sync 队列重放,但请求照常返回 Left。
- 失败/结果类型约定见 ../../docs/reference/adr/0005-result-type-and-error-handling.md
