# lib/features/health_event — 健康事件

有起止的健康观察期(症状/短期用药/换药)实体与数据:活动事件状态 + 开始/check-in/
结束三个 sheet,由宿主页面内嵌使用,无独立路由页面。

## 职责与边界

- 管:`HealthEvent`/`HealthEventCheckIn`/`HealthEventCoverage` 实体;
  `HealthEventRepository`(fetchActive/fetchById/fetchHistory/create/checkIn/end);
  `activeHealthEventProvider`(keepAlive 读+写 controller);三个 sheet widget。
- 不管:事件历史/回顾 UI 在 review;今日页事件区块渲染在 today;事件关联的原因
  记录在 record(`reasonRecordId` 仅存 id);当前用药选项来自 health_context;
  本 feature 无路由。

## 对外契约

- 路由:无 —— sheet 由 today/review 页内 push 呈现,不注册 GoRouter 路由。
- 导出:`domain/entities/health_event.dart`、`domain/repositories/health_event.dart`、
  `data/providers/health_event.dart`(`healthEventRepositoryProvider`)、
  `presentation/providers/active_event.dart`(`activeHealthEventProvider`)、
  `presentation/widgets/sheets/{start_event,check_in,end_event}.dart`。
- 被依赖:today(`pages/page.dart`、`dashboard_view.dart`)与 review
  (`pages/page.dart`)——消费 provider + 实体 + sheets。

## 不变量

- "无活动事件"(服务端 404)是合法 `Right(null)`,不是错误
  (`domain/repositories/health_event.dart` 头注释);空历史同理。
- 同一时刻至多一个活动事件(`fetchActive` 单数;end 成功后 state 回 `AsyncData(null)`)。
- 写操作(create/checkIn/end)只在服务端确认成功且身份未变时更新 state 并广播
  `DataChangeTopic.healthEvents`(`active_event.dart` `_emitHealthEventsChanged`);
  失败只重抛 `LucentFailure`,由 sheet 调用方投影到 submitError。
- 身份校验:操作前后校验会话用户,变更/未认证抛 `AuthRequiredException`。
- 测试锚点:`test/health_event/data/repositories/lucent_test.dart`、
  `presentation/providers/active_event_test.dart`、`sheets/*_test.dart`。

## 依赖禁区

- domain/data 不 import 宿主 feature(today/review/record);`reasonRecordId`/
  `currentMedicineIds` 只存 id 引用,不 import 其实体。
- 不自建路由/页面;UI 出口仅三个 sheet,嵌入宿主页。

## 陷阱与决策

- 本 feature 对外契约刻意包含 presentation 层(provider + sheets):事件操作按产品
  闭环嵌入 today/review 页内而非独立页面,sheet 是设计好的 UI 契约。
- 写成功广播 healthEvents topic,today 看板/suggestion 等监听方自动重建。
- 事件模型来源与产品决策(已 superseded,保留历史):
  ../../docs/reference/adr/0007-event-led-sparse-record-product-loop.md
