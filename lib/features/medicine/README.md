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
  `presentation/routes.dart`、`presentation/widgets/shared/copy.dart`(MedicineCopyKey)、
  `presentation/services/reminder_calendar.dart`(口径见下)。
- 被依赖:today(skip_dose/看板聚合/suggestion)、record(quick entry)、
  search(加药预检)、app/bootstrap(通知同步/回执 keepAlive)、app/router。

## 不变量

- repository 边界:可恢复失败一律 `TaskEither` Left(`LucentErrorMapper`),合法空集为
  Right;provider 层 Left 投影为 `AsyncValue.error`(ADR-0005)。
- 药箱单一事实源:列表派生自 health_context `currentMedicines(isCurrent)`,medicine 不
  本地存药箱;次级输入失败降级为空,不整体失败(`lucent_workspace.dart` 头注释)。
- **Take/Skip 只对已排程槽位显示**:`plan.items` 覆盖全部 current 药品,无提醒药的
  `slots` 为空、`todayStatus` 由缺省 dose log 派生为 `pending`——`pending` 不等于
  「有待服用剂次」。`_TodayPlanRow` 的按钮门控是 `canMark && slots.isNotEmpty`,仅靠
  `buildMedicineDoseMarkRequest` 会让药箱里每味药都长出打卡按钮。
- 本地提醒 resync 全量替换:先 cancel SharedPreferences 旧通知 id 再重排;通知 id 由
  `reminderId@时刻` FNV-1a 稳定派生(31-bit 正数);投递回执按 `reminderId|date|time`
  服务端幂等 + 会话内去重(`presentation/providers/reminder_delivery_reporter.dart`)。
- 风险预检在途防重:运行中按钮禁用(`pages/risk_check.dart` 的
  `_isRunningStatic/_isRunningLlm`);`runPrecheck` 无副作用不落记录。
- 风险检查的失败**立即**进 `AsyncValue.error`,不吃 riverpod 默认的退避重试:
  `presentation/providers/risk_check.dart` 的 `medicineRiskCheckRecords`(读记录)与
  `runMedicineRiskCheck`(命令)都挂着 `_noRunRetry`。默认策略是约 40s 重试,读记录失败
  时用户只看到「一直在转」,命令失败则每次重试都重新 POST 一次检查。手动重试 = 页面
  错误态上的「重试」(invalidate records provider)或再点一次运行按钮。
- 「AI 分析未配置」只认服务端稳定码 `LLM_NOT_CONFIGURED`,**不看 `statusCode == 503`**:
  同一端点上运行时的 LLM 失败也返回 503,用状态码兜底会把可重试故障说成永久缺配置。
  其余失败一律走 toast(`pages/risk_check.dart` 的 `_isLlmNotConfigured`)。
- 加入系统日历是**单向**导出:`presentation/services/reminder_calendar.dart` 把一组的
  多个时间点映射成一个 `Event`(纯函数,`buildReminderCalendarEvent` 返回
  `Either<LucentFailure, Event>`),drift 仍是唯一事实源,日历里的改动不回读。
  三处口径易踩:
  - 锚点日期 = 今天起第一个匹配 `daysOfWeek` 的星期几(`daysOfWeek` 用 Dart 周日=0,
    与 `MedicineReminderItem.matchesDate` 一致),不是无脑取今天;`endDate` 为空时不给
    `Recurrence.endDate`,留空即开放系列。
  - 时区取 `today` 的 `readUserTimezone`(即 health_context 快照 profile.timezone,
    失败回落 `Asia/Shanghai`),与 `core/utils/local_date.dart` 同口径。
  - 写入经 `reminderCalendarWriterProvider`(`ReminderCalendarWriter` 接口)注入,测试
    替 fake 即可;插件返回 `false`(用户取消/拒绝授权/无日历应用)必须映射成
    `ClientErrorCode.reminderCalendarWriteFailed` 并提示失败,**不得报成功**。
  Android 走 `Intent.ACTION_INSERT` 由日历应用自己写库,不需要 `WRITE_CALENDAR`;
  iOS 需要 `Info.plist` 的 `NSCalendarsUsageDescription`。
- 药品详情不走生成客户端的 `MedicinesApi.getDetail`:OpenAPI 的 `detail` 是 `cnProduct` /
  `drugbank` 的 `oneOf`,生成器额外产出的 `MedicineDetailResponseDetail` 包装类把两个
  分支的全部字段都标成 required,任何真实响应都会抛 `CheckedFromJsonException`(在生成的
  调用内部 → `DioExceptionType.unknown` → 页面只能给通用错误)。`data/datasources/
  medicine_detail_remote.dart` 因此直用同一 Dio 取原始 JSON,按 `kind` 分派到对应分支类
  再重建包装类给 mapper。改动这段前先确认生成器对 `oneOf` 的产出形态。
- 测试锚点:`test/medicine/reminder_notification_planner_test.dart`、
  `reminder_delivery_reporter_test.dart`、`cached_dose_log_data_source_test.dart`、
  `workspace_repository_test.dart`、`detail_page_test.dart`(详情页分区默认展开口径)、
  `reminder_calendar_test.dart`(日历导出的锚点日期/时区/拒绝语义)。
- 详情页分区顺序即阅读频次:`pages/detail_sections.dart` 的 `Tier` 是唯一排序真源
  (primary→safety→clinical→pharmacokinetics→reference),**只有 `Tier.primary` 默认展开**。
  分区顺序/默认展开的断言进 `detail_page_test.dart`,勿在文档里另立一份顺序表。
- 折叠分区的正文仍在 widget 树内(Forui `FAccordion` 用 `FCollapsible` 裁剪,不是移除);
  判定"是否展开"要断言 `FCollapsible.value`,不能断言文案不存在。
- **切换折叠项时不要 `setState` 重建整个 accordion**:Forui 的 `InheritedAccordionData`
  把整个 expanded 集合作为通知依据,重建会让每个 item 重跑 `didChangeDependencies`,
  命中 `case _` 分支把 `AnimationController.value` 重置回 `initiallyExpanded`
  —— 用户刚展开的分区会立刻弹回。现口径:展开集合放进 `ValueNotifier`,只有真正需要
  知道展开态的子树(序列区)用 `ValueListenableBuilder` 订阅。
- 序列正文**默认不加载**:详情响应只带 `sequenceSummary` 计数,正文走
  `GET /medicines/:id/sequences`(实测单药可达 96 KB)。因 accordion 会预先构建折叠项,
  "被构建"≠"被打开",所以门控挂在展开集合上而非构建时。
- 分子性质(结构描述符)与序列相反,**随详情下发**:32 个标量一次带回,渲染即可,不必另开请求。
  两处口径易踩:
  - OpenAPI 的 `number` 经生成器落成 Dart `num`,实体统一用 `double`;
    `data/mappers/medicine_detail.dart` 的 `_toDouble` 是唯一收敛点,新增数值字段照此走。
  - 类药性规则在源里是 **0/1 旗标**,不是布尔也不是文案;**渲染层**翻成「符合/不符合」,
    实体保持原始数值,别在 mapper 里丢信息。
  - 缺失字段不占位(不渲染空标签);全字段皆空等同无数据,分区整体不出现。

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
