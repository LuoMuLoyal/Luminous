import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/core/providers/channel.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/data_access.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_event.g.dart';

@Riverpod(keepAlive: true)
class ActiveHealthEvent extends _$ActiveHealthEvent {
  @override
  Future<HealthEvent?> build() {
    final expectedUserId = ref.read(authSessionProvider).userId;
    return authGuarded(
      ref: ref,
      fetch: () => ref.watch(healthEventRepositoryProvider).fetchActive().run(),
    ).then((result) {
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      final event = result.fold(
        (failure) => throw LucentFailureException(failure),
        (event) => event,
      );
      _ensureAuthenticated(expectedUserId);
      return event;
    });
  }

  Future<void> refresh() async {
    final expectedUserId = ref.read(authSessionProvider).userId;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final either = await authGuarded(
        ref: ref,
        fetch: () =>
            ref.read(healthEventRepositoryProvider).fetchActive().run(),
      );
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      return either.fold(
        (failure) => throw LucentFailureException(failure),
        (event) => event,
      );
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
  }) {
    return _mutate(
      (repo) => repo
          .create(
            title: title,
            reasonRecordId: reasonRecordId,
            currentMedicineIds: currentMedicineIds,
          )
          .run(),
      onSuccess: (event) => AsyncData(event),
    );
  }

  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) {
    return _mutate(
      (repo) =>
          repo.checkIn(eventId: eventId, date: date, outcome: outcome).run(),
      onSuccess: (event) => AsyncData(event),
    );
  }

  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) {
    return _mutate(
      (repo) => repo.end(eventId: eventId, outcome: outcome).run(),
      onSuccess: (_) => const AsyncData(null),
    );
  }

  /// 写操作的唯一入口：失败以 [LucentFailureException] 上浮（调用方——sheet
  /// 提交回调——用 `LucentErrorMapper.fromObject` 投影到 submitError），
  /// 成功才改状态并广播。
  ///
  /// 身份在请求发起前就校验一次：身份已经变了就不该发请求，而不是等请求
  /// 回来才发现"写进了别人的会话"。
  Future<HealthEvent> _mutate(
    Future<Either<LucentFailure, HealthEvent>> Function(
      HealthEventRepository repo,
    )
    request, {
    required AsyncValue<HealthEvent?> Function(HealthEvent event) onSuccess,
  }) async {
    final expectedUserId = ref.read(authSessionProvider).userId;
    _ensureAuthenticated(expectedUserId);

    final either = await authGuarded(
      ref: ref,
      fetch: () => request(ref.read(healthEventRepositoryProvider)),
    );
    final event = either.fold(
      (failure) => throw LucentFailureException(failure),
      (event) => event,
    );
    // 请求期间换了用户：响应属于上一个身份，不能写进当前状态。
    _ensureAuthenticated(expectedUserId);
    state = onSuccess(event);
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
        (expectedUserId == null || session.userId == expectedUserId);
  }
}
