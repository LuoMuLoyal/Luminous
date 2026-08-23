import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_event.g.dart';

@Riverpod(keepAlive: true)
class ActiveHealthEvent extends _$ActiveHealthEvent {
  @override
  Future<HealthEvent?> build() {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    return authGuarded(
      ref: ref,
      fetch: () => ref.watch(healthEventRepositoryProvider).fetchActive().run(),
    ).then((result) {
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      final event = result.fold((failure) => throw failure, (event) => event);
      _ensureAuthenticated(expectedUserId);
      return event;
    });
  }

  Future<void> refresh() async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final either = await authGuarded(
        ref: ref,
        fetch: () =>
            ref.read(healthEventRepositoryProvider).fetchActive().run(),
      );
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      return either.fold((failure) => throw failure, (event) => event);
    });
    if (!_isSameAuthenticatedUser(expectedUserId)) {
      state = AsyncError(const AuthRequiredException(), StackTrace.current);
      return;
    }
    state = result;
  }

  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    final either = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .create(
            title: title,
            reasonRecordId: reasonRecordId,
            currentMedicineIds: currentMedicineIds,
          )
          .run(),
    );
    // Left 重抛 LucentFailure：调用方（sheet 提交回调）投影到 submitError。
    final event = either.fold((failure) => throw failure, (event) => event);
    _ensureAuthenticated(expectedUserId);
    state = AsyncData(event);
    _emitHealthEventsChanged();
    return event;
  }

  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    final either = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .checkIn(eventId: eventId, date: date, outcome: outcome)
          .run(),
    );
    // Left 重抛 LucentFailure：调用方（sheet 提交回调）投影到 submitError。
    final event = either.fold((failure) => throw failure, (event) => event);
    _ensureAuthenticated(expectedUserId);
    state = AsyncData(event);
    _emitHealthEventsChanged();
    return event;
  }

  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    final either = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .end(eventId: eventId, outcome: outcome)
          .run(),
    );
    // Left 重抛 LucentFailure：调用方（sheet 提交回调）投影到 submitError。
    final event = either.fold((failure) => throw failure, (event) => event);
    _ensureAuthenticated(expectedUserId);
    state = const AsyncData(null);
    _emitHealthEventsChanged();
    return event;
  }

  /// 事件创建/结束/结果确认/check-in 落库成功后广播，让 Review 等依赖
  /// 事件数据的 provider 自动刷新。只在服务端确认成功且身份未变时发射。
  void _emitHealthEventsChanged() {
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.healthEvents);
  }

  void _ensureAuthenticated(String? expectedUserId) {
    if (!_isSameAuthenticatedUser(expectedUserId)) {
      throw const AuthRequiredException();
    }
  }

  bool _isSameAuthenticatedUser(String? expectedUserId) {
    final session = ref.read(authSessionProvider);
    return session.canAccessProtectedData &&
        (expectedUserId == null || session.user?.id == expectedUserId);
  }
}
