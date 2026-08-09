import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';

class _FakeHealthEventRepository implements HealthEventRepository {
  _FakeHealthEventRepository({this.event, this.error});

  HealthEvent? event;
  Object? error;
  int fetchCount = 0;

  @override
  Future<HealthEvent?> fetchActive() async {
    fetchCount++;
    if (error != null) throw error!;
    return event;
  }

  @override
  Future<HealthEvent?> fetchById(String eventId) => throw UnimplementedError();

  @override
  Future<List<HealthEvent>> fetchHistory() => throw UnimplementedError();

  @override
  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) => throw UnimplementedError();

  @override
  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) => throw UnimplementedError();

  @override
  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) => throw UnimplementedError();
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState(isAuthenticated: true);
}

void main() {
  test('loads active event data and supports explicit refresh', () async {
    final repository = _FakeHealthEventRepository(event: _event);
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        healthEventRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(activeHealthEventProvider), isA<AsyncLoading>());
    expect(await container.read(activeHealthEventProvider.future), _event);
    expect(container.read(activeHealthEventProvider).value, _event);

    await container.read(activeHealthEventProvider.notifier).refresh();

    expect(repository.fetchCount, 2);
    expect(container.read(activeHealthEventProvider).value, _event);
  });

  test('exposes repository failures as provider errors', () async {
    final error = StateError('active event unavailable');
    final repository = _FakeHealthEventRepository(error: error);
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        healthEventRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(activeHealthEventProvider.future),
      throwsA(same(error)),
    );
    expect(container.read(activeHealthEventProvider).hasError, isTrue);
  });

  test(
    'clears the active event state when the session is signed out',
    () async {
      final repository = _FakeHealthEventRepository(event: _event);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          healthEventRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(activeHealthEventProvider.future);
      final subscription = container.listen(
        activeHealthEventProvider,
        (_, __) {},
      );
      addTearDown(subscription.close);
      container.read(authSessionProvider.notifier).state =
          const AuthSessionState();

      await Future<void>.delayed(Duration.zero);
      final state = container.read(activeHealthEventProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<AuthRequiredException>());

      await container.read(activeHealthEventProvider.notifier).refresh();
      expect(
        container.read(activeHealthEventProvider).error,
        isA<AuthRequiredException>(),
      );
      expect(repository.fetchCount, 1);
    },
  );
}

const _event = HealthEvent(
  id: 'event-1',
  title: 'Cold observation',
  status: HealthEventStatus.active,
  startedAt: '2026-08-08T16:00:00.000Z',
  endedAt: null,
  outcome: HealthEventOutcome.improved,
  reasonRecordId: null,
  currentMedicineIds: ['medicine-1'],
  checkIn: HealthEventCheckIn(
    id: 'check-in-1',
    eventId: 'event-1',
    date: '2026-08-09',
    outcome: HealthEventOutcome.improved,
    createdAt: '2026-08-09T01:00:00.000Z',
    updatedAt: '2026-08-09T01:00:00.000Z',
  ),
  coverage: HealthEventCoverage(
    checkInCount: 3,
    firstCheckInDate: '2026-08-07',
    lastCheckInDate: '2026-08-09',
  ),
);
