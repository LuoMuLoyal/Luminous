/// 产品事件与本地通知的接缝。
///
/// presentation 层不应直接依赖 `lib/core/analytics/` 与
/// `lib/core/notifications/`（二者都会触碰 I/O）。展示层只读这里导出的
/// 服务/provider 接口，具体实现由 core 层的组合根装配。
library;

export 'package:luminous/core/analytics/product_event_service.dart'
    show ProductEventService, productEventServiceProvider;
export 'package:luminous/core/notifications/local_notification_gateway.dart'
    show LocalNotificationGateway, localNotificationGatewayProvider;
