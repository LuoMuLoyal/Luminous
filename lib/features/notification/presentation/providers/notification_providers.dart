import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

const _notificationPageSize = 20;

// ── Unread count ─────────────────────────────────────────────────────────────

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  final authSession = ref.watch(authSessionProvider);
  if (!authSession.canAccessProtectedData) {
    return pendingAuthSessionResolution<int>();
  }

  final api = ref.watch(lucentNotificationsApiProvider);
  final response = await api.notificationsControllerGetUnreadCountV1();
  final data = response.data;
  if (data == null || data.code != 0) {
    throw StateError(data?.message ?? 'Failed to fetch unread count.');
  }
  return data.count.toInt();
});

// ── Notification list ──────────────────────────────────────────────────────

final notificationListPageProvider =
    FutureProvider<NotificationListResponseDto>((ref) async {
      final authSession = ref.watch(authSessionProvider);
      if (!authSession.canAccessProtectedData) {
        return pendingAuthSessionResolution<NotificationListResponseDto>();
      }

      final api = ref.watch(lucentNotificationsApiProvider);
      final response = await api.notificationsControllerFindAllV1(
        page: 1,
        pageSize: _notificationPageSize,
      );
      final data = response.data;
      if (data == null || data.code != 0) {
        throw StateError(data?.message ?? 'Failed to fetch notifications.');
      }
      return data;
    });

// ── Notification detail ──────────────────────────────────────────────────────

final notificationDetailProvider =
    FutureProvider.family<NotificationDetailDto?, String>((ref, id) async {
      final authSession = ref.watch(authSessionProvider);
      if (!authSession.canAccessProtectedData) {
        return pendingAuthSessionResolution<NotificationDetailDto?>();
      }

      final api = ref.watch(lucentNotificationsApiProvider);
      final response = await api.notificationsControllerFindOneV1(id: id);
      final data = response.data;
      if (data == null || data.code != 0) {
        throw StateError(
          data?.message ?? 'Failed to fetch notification detail.',
        );
      }
      return data.data;
    });

// ── Mutations ────────────────────────────────────────────────────────────────

class NotificationListController
    extends AsyncNotifier<NotificationListResponseDto> {
  @override
  Future<NotificationListResponseDto> build() async {
    final api = ref.read(lucentNotificationsApiProvider);
    final response = await api.notificationsControllerFindAllV1(
      page: 1,
      pageSize: _notificationPageSize,
    );
    final data = response.data;
    if (data == null || data.code != 0) {
      throw StateError(data?.message ?? 'Failed to fetch notifications.');
    }
    return data;
  }

  Future<void> markAllAsRead() async {
    final api = ref.read(lucentNotificationsApiProvider);
    await api.notificationsControllerMarkAllAsReadV1();
    ref.invalidate(notificationUnreadCountProvider);
    state = await AsyncValue.guard(() async {
      final response = await api.notificationsControllerFindAllV1(
        page: 1,
        pageSize: _notificationPageSize,
      );
      final data = response.data;
      if (data == null || data.code != 0) {
        throw StateError(data?.message ?? 'Failed to fetch notifications.');
      }
      return data;
    });
  }

  Future<void> deleteNotification(String id) async {
    final api = ref.read(lucentNotificationsApiProvider);
    await api.notificationsControllerRemoveV1(id: id);
    ref.invalidate(notificationUnreadCountProvider);
    state = await AsyncValue.guard(() async {
      final response = await api.notificationsControllerFindAllV1(
        page: 1,
        pageSize: _notificationPageSize,
      );
      final data = response.data;
      if (data == null || data.code != 0) {
        throw StateError(data?.message ?? 'Failed to fetch notifications.');
      }
      return data;
    });
  }
}

final notificationListControllerProvider =
    AsyncNotifierProvider<
      NotificationListController,
      NotificationListResponseDto
    >(NotificationListController.new);
