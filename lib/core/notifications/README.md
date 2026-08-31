# lib/core/notifications — 本地通知平台网关

单文件目录(`local_notification_gateway.dart`,`local_notification_gateway.g.dart` 为生成物):
`LocalNotificationGateway` 封装 flutter_local_notifications 的初始化、排程、取消、活动通知
查询与 tap 事件流。

## 职责与边界

- 管:插件初始化(单飞 + 时区初始化)、`schedule` / `cancel` / `getActiveNotifications`、
  `tapEvents` 广播流(含冷启动 launch-details 一次性重放)、Android 响铃/静默通道选择与
  精确排程降级。
- 不管:提醒排程业务与 payload 编解码(features/medicine 的 `ReminderNotificationPayload`
  与 coordinator)、送达回执的幂等回写(features/medicine/presentation/providers/
  reminder_delivery_reporter.dart)、远程推送(`../push/`)、通知权限设置页(features/settings)。

## 对外契约

- 导出:`LocalNotificationGateway` + `localNotificationGatewayProvider`、`tapEvents`
  (`Stream<NotificationResponse>`)、`ensureInitialized` / `schedule` / `cancel` /
  `getActiveNotifications`。
- 被依赖:features/medicine(用药提醒 coordinator + 送达回执 reporter)、features/settings
  (睡眠提醒 coordinator)、`../push/message_handler.dart`。

## 不变量

- 平台不可用一律优雅降级:非移动平台 / `MissingPluginException` / `PlatformException` /
  插件绑定缺失 → `ensureInitialized` 为 false、`schedule` 返回 false、
  `getActiveNotifications` 返回空列表,不抛错不崩溃
  (`test/core/notifications/local_notification_gateway_test.dart` 覆盖非移动路径)。
- `ensureInitialized` 单飞:并发调用共享同一 future,不竞态误判可用性。
- 过去时间不排程(经 package:clock 取当前时间,可注入);Android 无精确排程权限时降级
  inexact 模式。
- tap 事件不丢:无监听者时缓冲,首个监听者 flush;冷启动 launch response 仅重放一次。

## 依赖禁区

- 仅依赖 flutter_local_notifications、riverpod_annotation、clock/timezone;不依赖 features
  与 `../push/`(单向:push 与 features 消费本目录)。

## 陷阱与决策

- Android 通道 id 固定为响铃/静默两个(按 `playSound` 选择),调用方只传展示用
  channelName/channelDescription,不传 channel id。
- 平台判定用 `defaultTargetPlatform`(非 dart:io),web/桌面/测试可编译;测试注入
  `debugDefaultTargetPlatformOverride` 与插件 platform-interface fake,不启动真实设备能力。
- `LateInitializationError` 按消息前缀识别(Dart 3.12 无公开类型),升级 SDK 后复查
  `_isLateInitializationError`。
- 展示后的送达回执以 `reminderId|date|time` 幂等(服务端幂等 + 会话内去重):原料
  (`tapEvents` + `getActiveNotifications`)由本目录提供,回写逻辑归 medicine。
