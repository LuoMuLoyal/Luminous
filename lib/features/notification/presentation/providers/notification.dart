import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/lucent.dart';
import '../../data/providers/unread_count.dart';
import '../../domain/entities/notification.dart';

/// Re-export so presentation code can import from one place.
export '../../data/repositories/lucent.dart'
    show notificationRepositoryProvider;
export '../../data/providers/unread_count.dart'
    show notificationUnreadCountProvider;

part 'notification.g.dart';

const _notificationPageSize = 20;

// ── Notification detail ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<NotificationDetail?> notificationDetail(Ref ref, String id) async {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(notificationRepositoryProvider).findOne(id),
    signedOutFallback: () => pendingAuthSessionResolution(),
  );
}

// ── Loading-more flag ──────────────────────────────────────────────────────

class _LoadingMoreNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final notificationListLoadingMoreProvider =
    NotifierProvider<_LoadingMoreNotifier, bool>(_LoadingMoreNotifier.new);

// ── Notification list controller ────────────────────────────────────────────

class NotificationListController extends AsyncNotifier<NotificationPage> {
  int _currentPage = 1;

  bool get hasMore {
    final value = state.value;
    if (value == null) return false;
    return value.hasMore;
  }

  @override
  Future<NotificationPage> build() async {
    _currentPage = 1;
    final repo = ref.read(notificationRepositoryProvider);
    return repo.findAll(page: 1, pageSize: _notificationPageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !hasMore) return;

    ref.read(notificationListLoadingMoreProvider.notifier).setLoading(true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final nextPage = _currentPage + 1;
      final page = await repo.findAll(
        page: nextPage,
        pageSize: _notificationPageSize,
      );
      _currentPage = nextPage;
      state = AsyncValue.data(
        NotificationPage(
          items: [...current.items, ...page.items],
          total: page.total,
          page: nextPage,
          pageSize: _notificationPageSize,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      ref.read(notificationListLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(
      () => repo.findAll(page: 1, pageSize: _notificationPageSize),
    );
  }

  Future<void> deleteNotification(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.delete(id);
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(
      () => repo.findAll(page: 1, pageSize: _notificationPageSize),
    );
  }
}

final notificationListControllerProvider =
    AsyncNotifierProvider<NotificationListController, NotificationPage>(
      NotificationListController.new,
    );
