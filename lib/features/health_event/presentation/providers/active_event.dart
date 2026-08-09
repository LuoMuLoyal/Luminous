import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
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
      fetch: () => ref.watch(healthEventRepositoryProvider).fetchActive(),
    ).then((event) {
      _ensureAuthenticated(expectedUserId);
      return event;
    });
  }

  Future<void> refresh() async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => authGuarded(
        ref: ref,
        fetch: () => ref.read(healthEventRepositoryProvider).fetchActive(),
      ),
    );
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
    final event = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .create(
            title: title,
            reasonRecordId: reasonRecordId,
            currentMedicineIds: currentMedicineIds,
          ),
    );
    _ensureAuthenticated(expectedUserId);
    state = AsyncData(event);
    return event;
  }

  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    final event = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .checkIn(eventId: eventId, date: date, outcome: outcome),
    );
    _ensureAuthenticated(expectedUserId);
    state = AsyncData(event);
    return event;
  }

  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    final expectedUserId = ref.read(authSessionProvider).user?.id;
    final event = await authGuarded(
      ref: ref,
      fetch: () => ref
          .read(healthEventRepositoryProvider)
          .end(eventId: eventId, outcome: outcome),
    );
    _ensureAuthenticated(expectedUserId);
    state = const AsyncData(null);
    return event;
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
