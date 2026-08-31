import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
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
///
/// Every expected recoverable failure (network, server business failure) is a
/// `TaskEither` Left produced via `LucentErrorMapper.fromObject`; a successful
/// response is a Right. An empty success response body for a data-returning
/// method is a `LucentFailure.network(emptyResponse)` (auth `_requireBody`
/// precedent); void mutations accept an empty (204-style) success body.
/// Protocol violations (non `problem+json` error bodies) keep the mapper's
/// `FormatException` which propagates from `.run()`.
class LucentNotificationRepository implements NotificationRepository {
  LucentNotificationRepository({required this.api});

  final NotificationsApi api;

  @override
  TaskEither<LucentFailure, NotificationPage> findAll({
    required int page,
    required int pageSize,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await api.notificationsControllerFindAllV1(
        page: page,
        pageSize: pageSize,
      );
      final dto = _requireData(response.data, operation: 'findAll');
      return NotificationPage(
        items: dto.items.map(_mapItem).toList(),
        total: dto.total.toInt(),
        page: page,
        pageSize: pageSize,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, NotificationDetail?> findOne(String id) {
    return TaskEither.tryCatch(() async {
      final response = await api.notificationsControllerFindOneV1(id: id);
      final d = _requireData(response.data, operation: 'findOne');
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
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, int> getUnreadCount() {
    return TaskEither.tryCatch(() async {
      final response = await api.notificationsControllerGetUnreadCountV1();
      final dto = _requireData(response.data, operation: 'getUnreadCount');
      return dto.count.toInt();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAllAsRead() {
    return TaskEither.tryCatch(() async {
      await api.notificationsControllerMarkAllAsReadV1();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAsRead(String id) {
    return TaskEither.tryCatch(() async {
      await api.notificationsControllerMarkAsReadV1(id: id);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAsUnread(String id) {
    return TaskEither.tryCatch(() async {
      await api.notificationsControllerMarkAsUnreadV1(id: id);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await api.notificationsControllerRemoveV1(id: id);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (auth `_requireBody` / settings `_requireData` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
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
