# lib/features/notification — 通知中心

服务端用户通知的 inbox:分页列表、详情、已读/未读/删除,以及跨 feature 消费的
未读数徽标 provider;不含通知的产生与投递。

## 职责与边界

- 管:`NotificationRepository`(findAll/findOne/getUnreadCount/markAll/markAsRead/
  markAsUnread/delete,`data/repositories/lucent.dart` 装配)、inbox 列表与详情页、
  `notificationUnreadCountProvider`(data 层轮询展示)。
- 不管:通知的产生与三通道投递(in_app/local/push)在 Lucent 后端;本地提醒调度在
  medicine 的 coordinator + `lib/core/notifications/`;通知偏好(勿扰等)在 settings;
  推送到达后的路由处理在 `lib/core/push/message_handler.dart`。

## 对外契约

- 路由:`Routes.notifications`;`presentation/routes.dart`:`NotificationListRoute`
  (`/notifications`)、`NotificationDetailRoute`(`/notifications/:id`)。
- 导出:`domain/repositories/notification.dart`(`NotificationRepository`)、
  `domain/entities/notification.dart`、`data/providers/unread_count.dart`
  (`notificationUnreadCountProvider`)、`data/repositories/lucent.dart`
  (`notificationRepositoryProvider`)。
- 被依赖:today/shell/mine/medicine(未读徽标)、today 看板聚合(未读数)、
  `core/push/message_handler.dart`(推送到达 invalidate 未读)。

## 不变量

- 未读数 provider 刻意放 data 层(纯取数、无 presentation 状态),供其他 feature
  依赖而不违反 presentation→presentation 禁区;失败降级为 0 并记日志(轮询类
  best-effort),不打断页面(`data/providers/unread_count.dart` 头注释)。
- repository 边界:可恢复失败一律 `TaskEither` Left;空 inbox 是合法 Right 不是错误;
  findOne 的 404/空 body 语义见 `domain/repositories/notification.dart` 头注释。
- 任何已读/删除写操作成功后必须 invalidate `notificationUnreadCountProvider`
  (list controller 与 detail page 均如此)。
- `NotificationType.unknown` 哨兵保证后端新增类型向前兼容,不崩
  (`domain/entities/notification.dart`)。
- 测试锚点:`test/notification/providers_test.dart`、`list_page_test.dart`、
  `detail_page_test.dart`、`list_item_test.dart`。

## 依赖禁区

- 不依赖任何业务 feature(通知内容与客户端业务解耦,类型映射只对后端契约)。
- 跨 feature 共享的状态只允许经 data 层 provider 输出;不得把 list controller
  等 presentation 状态提供给其他 feature。
- 不本地持久化通知(无 Drift 缓存),列表与未读数以服务端为准。

## 陷阱与决策

- today 的 `today_suggestion.dart` 直接 import 本 feature `data/repositories/lucent.dart`
  属既有 data→data 边缘,新代码应依赖 `domain/repositories/notification.dart`。
- 分页 20/页,`loadMore` 追加 + `notificationListLoadingMoreProvider` 防并发;
  markAsRead 就地更新不重拉。
- 失败/结果类型约定见 ../../docs/reference/adr/0005-result-type-and-error-handling.md
