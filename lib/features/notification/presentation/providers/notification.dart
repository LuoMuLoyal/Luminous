import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/unread_count.dart';
import '../../data/repositories/lucent.dart';
import '../../domain/entities/notification.dart';

part 'notification.g.dart';

const _notificationPageSize = 20;

// ── Notification detail ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<NotificationDetail?> notificationDetail(Ref ref, String id) async {
  return authGuarded(
    ref: ref,
    fetch: () async {
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      final result = await ref
          .watch(notificationRepositoryProvider)
          .findOne(id)
          .run();
      return result.fold((failure) => throw failure, (detail) => detail);
    },
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
    return authGuarded(
      ref: ref,
      fetch: _fetchFirstPage,
      signedOutFallback: () => pendingAuthSessionResolution(),
    );
  }

  /// Runs the first page and projects a Left to `AsyncValue.error` by
  /// rethrowing the failure (Riverpod captures it).
  Future<NotificationPage> _fetchFirstPage() async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo
        .findAll(page: 1, pageSize: _notificationPageSize)
        .run();
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !hasMore) return;

    ref.read(notificationListLoadingMoreProvider.notifier).setLoading(true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final nextPage = _currentPage + 1;
      final result = await repo
          .findAll(page: nextPage, pageSize: _notificationPageSize)
          .run();
      final page = result.fold((failure) => throw failure, (page) => page);
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
      // Left 与协议异常（FormatException 逃逸 .run()）均投影到错误态。
      state = AsyncValue.error(e, st);
    } finally {
      ref.read(notificationListLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAllAsRead().run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  Future<void> deleteNotification(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.delete(id).run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(notificationUnreadCountProvider);
    _currentPage = 1;
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(id).run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(notificationUnreadCountProvider);
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      NotificationPage(
        items: current.items
            .map(
              (item) => item.id == id && !item.isRead
                  ? item.copyWith(isRead: true)
                  : item,
            )
            .toList(),
        total: current.total,
        page: current.page,
        pageSize: current.pageSize,
      ),
    );
  }

  Future<void> markAsUnread(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsUnread(id).run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(notificationUnreadCountProvider);
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      NotificationPage(
        items: current.items
            .map(
              (item) => item.id == id && item.isRead
                  ? item.copyWith(isRead: false)
                  : item,
            )
            .toList(),
        total: current.total,
        page: current.page,
        pageSize: current.pageSize,
      ),
    );
  }

  /// Toggles the read status of a notification in-place without refetching.
  Future<void> toggleReadStatus(String id) async {
    final current = state.value;
    if (current == null) return;
    final target = current.items.where((item) => item.id == id).firstOrNull;
    if (target == null) return;
    if (target.isRead) {
      await markAsUnread(id);
    } else {
      await markAsRead(id);
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    state = await AsyncValue.guard(_fetchFirstPage);
  }
}

final notificationListControllerProvider =
    AsyncNotifierProvider<NotificationListController, NotificationPage>(
      NotificationListController.new,
    );
