import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';

const _notificationPageSize = 20;

// ── Unread count ─────────────────────────────────────────────────────────────

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final api = ref.watch(lucentClientProvider).notifications;
      final response = await api.notificationsControllerGetUnreadCountV1();
      if (response.code != 0) {
        throw StateError(response.message);
      }
      return response.count.toInt();
    },
    signedOutFallback: () => pendingAuthSessionResolution(),
  );
});

// ── Notification list ──────────────────────────────────────────────────────

final notificationListPageProvider =
    FutureProvider<NotificationListResponseDto>((ref) async {
      return authGuarded(
        ref: ref,
        fetch: () async {
          final api = ref.watch(lucentClientProvider).notifications;
          final response = await api.notificationsControllerFindAllV1(
            page: 1,
            pageSize: _notificationPageSize,
          );
          if (response.code != 0) {
            throw StateError(response.message);
          }
          return response;
        },
        signedOutFallback: () => pendingAuthSessionResolution(),
      );
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
      return authGuarded(
        ref: ref,
        fetch: () async {
          final api = ref.watch(lucentClientProvider).notifications;
          final response = await api.notificationsControllerFindOneV1(id: id);
          if (response.code != 0) {
            throw StateError(response.message);
          }
          return response.data;
        },
        signedOutFallback: () => pendingAuthSessionResolution(),
      );
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
    final api = ref.read(lucentClientProvider).notifications;
    final response = await api.notificationsControllerFindAllV1(
      page: 1,
      pageSize: _notificationPageSize,
    );
    if (response.code != 0) {
      throw StateError(response.message);
    }
    return response;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !hasMore) return;

    ref.read(notificationListLoadingMoreProvider.notifier).setLoading(true);
    try {
      final api = ref.read(lucentClientProvider).notifications;
      final nextPage = _currentPage + 1;
      final response = await api.notificationsControllerFindAllV1(
        page: nextPage,
        pageSize: _notificationPageSize,
      );
      if (response.code != 0) {
        throw StateError(response.message);
      }
      _currentPage = nextPage;
      state = AsyncValue.data(
        NotificationListResponseDto(
          code: response.code,
          message: response.message,
          items: [...current.items, ...response.items],
          total: response.total,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      ref.read(notificationListLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    final api = ref.read(lucentClientProvider).notifications;
    await api.notificationsControllerMarkAllAsReadV1();
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(() async {
      final response = await api.notificationsControllerFindAllV1(
        page: 1,
        pageSize: _notificationPageSize,
      );
      if (response.code != 0) {
        throw StateError(response.message);
      }
      return response;
    });
  }

  Future<void> deleteNotification(String id) async {
    final api = ref.read(lucentClientProvider).notifications;
    await api.notificationsControllerRemoveV1(id: id);
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(() async {
      final response = await api.notificationsControllerFindAllV1(
        page: 1,
        pageSize: _notificationPageSize,
      );
      if (response.code != 0) {
        throw StateError(response.message);
      }
      return response;
    });
  }
}

final notificationListControllerProvider =
    AsyncNotifierProvider<
      NotificationListController,
      NotificationListResponseDto
    >(NotificationListController.new);
