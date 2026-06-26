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

// ── Loading-more flag ──────────────────────────────────────────────────────

class _LoadingMoreNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final notificationListLoadingMoreProvider =
    NotifierProvider<_LoadingMoreNotifier, bool>(_LoadingMoreNotifier.new);

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
  int _currentPage = 1;

  bool get hasMore {
    final value = state.value;
    if (value == null) return false;
    return value.items.length < value.total.toInt();
  }

  @override
  Future<NotificationListResponseDto> build() async {
    _currentPage = 1;
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

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !hasMore) return;

    ref.read(notificationListLoadingMoreProvider.notifier).setLoading(true);
    try {
      final api = ref.read(lucentNotificationsApiProvider);
      final nextPage = _currentPage + 1;
      final response = await api.notificationsControllerFindAllV1(
        page: nextPage,
        pageSize: _notificationPageSize,
      );
      final data = response.data;
      if (data == null || data.code != 0) {
        throw StateError(data?.message ?? 'Failed to fetch notifications.');
      }
      _currentPage = nextPage;
      state = AsyncValue.data(
        NotificationListResponseDto(
          code: data.code,
          message: data.message,
          items: [...current.items, ...data.items],
          total: data.total,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      ref.read(notificationListLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    final api = ref.read(lucentNotificationsApiProvider);
    await api.notificationsControllerMarkAllAsReadV1();
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
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
    _currentPage = 1;
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
