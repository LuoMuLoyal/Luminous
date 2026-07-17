import 'package:luminous/core/network/api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification.dart';

part 'lucent.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return LucentNotificationRepository(
    api: ref.watch(lucentClientProvider).notifications,
  );
}

/// Lucent-backed implementation of [NotificationRepository].
class LucentNotificationRepository implements NotificationRepository {
  LucentNotificationRepository({required this.api});

  final NotificationsApi api;

  @override
  Future<NotificationPage> findAll({
    required int page,
    required int pageSize,
  }) async {
    final response = await api.notificationsControllerFindAllV1(
      page: page,
      pageSize: pageSize,
    );
    ensureEnvelopeSuccess(code: response.code, message: response.message);
    return NotificationPage(
      items: response.items.map(_mapItem).toList(),
      total: response.total.toInt(),
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<NotificationDetail?> findOne(String id) async {
    final response = await api.notificationsControllerFindOneV1(id: id);
    ensureEnvelopeSuccess(code: response.code, message: response.message);
    final d = response.data;
    return NotificationDetail(
      id: d.id,
      type: NotificationType.fromJson(d.type.json),
      title: d.title,
      content: d.content,
      action: d.action,
      actionPayload: d.actionPayload,
      isRead: d.isRead,
      createdAt: d.createdAt,
      readAt: d.readAt,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await api.notificationsControllerGetUnreadCountV1();
    ensureEnvelopeSuccess(code: response.code, message: response.message);
    return response.count.toInt();
  }

  @override
  Future<void> markAllAsRead() async {
    await api.notificationsControllerMarkAllAsReadV1();
  }

  @override
  Future<void> markAsUnread(String id) async {
    await api.notificationsControllerMarkAsUnreadV1(id: id);
  }

  @override
  Future<void> delete(String id) async {
    await api.notificationsControllerRemoveV1(id: id);
  }

  NotificationItem _mapItem(NotificationListItemDto dto) {
    return NotificationItem(
      id: dto.id,
      type: NotificationType.fromJson(dto.type.json),
      title: dto.title,
      content: dto.content,
      action: dto.action,
      actionPayload: dto.actionPayload,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
    );
  }
}
