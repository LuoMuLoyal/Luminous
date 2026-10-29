import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/notification_page.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification.dart';

part 'lucent.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return LucentNotificationRepository(
    api: ref.watch(lucentClientProvider).notifications,
    dao: ref.watch(notificationPageDaoProvider),
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
  LucentNotificationRepository({required this.api, required this.dao});

  final NotificationsApi api;
  final NotificationPageDao dao;

  /// Background refresh throttle: one attempt per scope per window.
  final Map<String, DateTime> _lastRefresh = {};

  @override
  TaskEither<LucentFailure, NotificationPage> findAll({
    required int page,
    required int pageSize,
  }) {
    return TaskEither.tryCatch(() async {
      final scope = 'page=$page&size=$pageSize';

      // 1. Cache-first: the inbox renders the previous page immediately instead
      // of holding a skeleton until the network answers.
      final cached = await dao.fetch(scope);
      if (cached != null) {
        _refreshInBackground(scope, page: page, pageSize: pageSize);
        return NotificationPage.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }

      // 2. Cache miss → network, then write through.
      final remote = await _fetchPage(page: page, pageSize: pageSize);
      await dao.replace(scope, jsonEncode(remote.toJson()));
      return remote;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  Future<NotificationPage> _fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final response = await api.listNotifications(
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
  }

  /// Best-effort refresh: throttled, failures only logged.
  void _refreshInBackground(
    String scope, {
    required int page,
    required int pageSize,
  }) {
    final now = DateTime.now();
    final last = _lastRefresh[scope];
    if (last != null && now.difference(last) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefresh[scope] = now;

    unawaited(
      Future(() async {
        try {
          final remote = await _fetchPage(page: page, pageSize: pageSize);
          await dao.replace(scope, jsonEncode(remote.toJson()));
        } catch (e) {
          appLog.warning('Notification background refresh failed: $e');
        }
      }),
    );
  }

  @override
  TaskEither<LucentFailure, NotificationDetail?> findOne(String id) {
    return TaskEither.tryCatch(() async {
      final response = await api.getNotification(id: id);
      final d = _requireData(response.data, operation: 'findOne');
      return NotificationDetail(
        id: d.id,
        type: NotificationType.fromWire(d.type.value),
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
      final response = await api.getUnreadCount();
      final dto = _requireData(response.data, operation: 'getUnreadCount');
      return dto.count.toInt();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAllAsRead() {
    return TaskEither.tryCatch(() async {
      await api.markAllAsRead();
      // A read/unread/delete changes unread counts and read flags across every
      // cached page, so the whole page cache is dropped rather than patched.
      await dao.invalidateAll();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAsRead(String id) {
    return TaskEither.tryCatch(() async {
      await api.markAsRead(id: id);
      // A read/unread/delete changes unread counts and read flags across every
      // cached page, so the whole page cache is dropped rather than patched.
      await dao.invalidateAll();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> markAsUnread(String id) {
    return TaskEither.tryCatch(() async {
      await api.markAsUnread(id: id);
      // A read/unread/delete changes unread counts and read flags across every
      // cached page, so the whole page cache is dropped rather than patched.
      await dao.invalidateAll();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await api.remove(id: id);
      // A read/unread/delete changes unread counts and read flags across every
      // cached page, so the whole page cache is dropped rather than patched.
      await dao.invalidateAll();
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

  NotificationItem _mapItem(NotificationListResponseItems dto) {
    return NotificationItem(
      id: dto.id,
      type: NotificationType.fromWire(dto.type.value),
      title: dto.title,
      content: dto.content,
      action: dto.action,
      actionPayload: dto.actionPayload,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
    );
  }
}
