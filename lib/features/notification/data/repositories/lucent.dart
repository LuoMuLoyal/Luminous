import 'package:dio/dio.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/map_utils.dart';
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
    final dto = response.data!;
    ensureEnvelopeSuccess(code: dto.code, message: dto.message);
    return NotificationPage(
      items: dto.data.items.map(_mapItem).toList(),
      total: dto.data.total.toInt(),
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<NotificationDetail?> findOne(String id) async {
    final response = await api.notificationsControllerFindOneV1(id: id);
    final dto = response.data!;
    ensureEnvelopeSuccess(code: dto.code, message: dto.message);
    final d = dto.data!;
    return NotificationDetail(
      id: d.id,
      type: NotificationType.fromJson(d.type.value),
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
    try {
      final response = await api.notificationsControllerGetUnreadCountV1();
      final dto = response.data!;
      ensureEnvelopeSuccess(code: dto.code, message: dto.message);
      return dto.data.count.toInt();
    } catch (e) {
      // 未读数徽章是后台轮询类展示,单次失败不应让 UI 报错:降级返回 0
      // 并记录日志,下次轮询会自然恢复(失败原因仍可从日志排查)。
      appTalker.warning(
        'NotificationRepository.getUnreadCount 获取失败,降级返回 0: $e',
      );
      return 0;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await api.notificationsControllerMarkAllAsReadV1();
    final dto = response.data!;
    ensureEnvelopeSuccess(code: dto.code, message: dto.message);
  }

  @override
  Future<void> markAsRead(String id) async {
    await api.notificationsControllerMarkAsReadV1(id: id);
  }

  @override
  Future<void> markAsUnread(String id) async {
    await api.notificationsControllerMarkAsUnreadV1(id: id);
  }

  @override
  Future<void> delete(String id) async {
    final response = await api.notificationsControllerRemoveV1(id: id);
    // 生成客户端将该端点建模为 Response<void>(后端 DELETE 返回 204 无响应体),
    // data 无法直接读取;运行时对象实际仍是 Response<Object>,转回以便响应体
    // 意外携带信封时按 findAll 同款模式校验业务码,避免业务失败被静默当成成功。
    final json = coerceToStringMap((response as Response<Object>).data);
    if (json != null && json.containsKey('code')) {
      final envelope = LucentEnvelope<Object?>.fromJson(
        json,
        dataDecoder: (rawData) => rawData,
      );
      ensureEnvelopeSuccess(code: envelope.code, message: envelope.message);
    }
  }

  NotificationItem _mapItem(NotificationListItemDto dto) {
    return NotificationItem(
      id: dto.id,
      type: NotificationType.fromJson(dto.type.value),
      title: dto.title,
      content: dto.content,
      action: dto.action,
      actionPayload: dto.actionPayload,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
    );
  }
}
