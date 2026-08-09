import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';

class _FakeHealthEventRepository implements HealthEventRepository {
  _FakeHealthEventRepository({this.event, this.error});

  HealthEvent? event;
  Object? error;
  int fetchCount = 0;
  String? createdTitle;
  List<String>? createdMedicineIds;
  HealthEventOutcome? checkedInOutcome;
  HealthEventOutcome? endedOutcome;
  Completer<HealthEvent?>? fetchCompleter;
  Completer<HealthEvent>? createCompleter;
  Completer<HealthEvent>? checkInCompleter;
  Completer<HealthEvent>? endCompleter;

  @override
  Future<HealthEvent?> fetchActive() async {
    fetchCount++;
    final pending = fetchCompleter;
    if (pending != null) {
      fetchCompleter = null;
      return pending.future;
    }
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
  }) async {
    createdTitle = title;
    createdMedicineIds = currentMedicineIds;
    if (error != null) throw error!;
    final pending = createCompleter;
    if (pending != null) {
      createCompleter = null;
      return pending.future;
    }
    return event!;
  }

  @override
  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    checkedInOutcome = outcome;
    if (error != null) throw error!;
    final pending = checkInCompleter;
    if (pending != null) {
      checkInCompleter = null;
      return pending.future;
    }
    return event!;
  }

  @override
  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    endedOutcome = outcome;
    if (error != null) throw error!;
    final pending = endCompleter;
    if (pending != null) {
      endCompleter = null;
      return pending.future;
    }
    return event!;
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() =>
      AuthSessionState(isAuthenticated: true, user: _testUser);
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

  test('writes through the repository and updates the active state', () async {
    final repository = _FakeHealthEventRepository(event: _event);
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        healthEventRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(activeHealthEventProvider.notifier);
    await container.read(activeHealthEventProvider.future);

    await notifier.create(
      title: 'Cold observation',
      currentMedicineIds: const ['medicine-1'],
    );
    expect(repository.createdTitle, 'Cold observation');
    expect(repository.createdMedicineIds, ['medicine-1']);
    expect(container.read(activeHealthEventProvider).value, _event);

    await notifier.checkIn(
      eventId: _event.id,
      date: '2026-08-09',
      outcome: HealthEventOutcome.improved,
    );
    expect(repository.checkedInOutcome, HealthEventOutcome.improved);

    await notifier.end(
      eventId: _event.id,
      outcome: HealthEventOutcome.unchanged,
    );
    expect(repository.endedOutcome, HealthEventOutcome.unchanged);
    expect(container.read(activeHealthEventProvider).value, isNull);
  });

  test(
    'does not restore an old event when logout races with refresh',
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
      final pending = Completer<HealthEvent?>();
      repository.fetchCompleter = pending;

      final refresh = container
          .read(activeHealthEventProvider.notifier)
          .refresh();
      await Future<void>.delayed(Duration.zero);
      container.read(authSessionProvider.notifier).state = AuthSessionState(
        isAuthenticated: true,
        user: _otherTestUser,
      );
      pending.complete(_event);
      await refresh;

      expect(
        container.read(activeHealthEventProvider).error,
        isA<AuthRequiredException>(),
      );
    },
  );

  test('does not publish a build response after a user switch', () async {
    final repository = _FakeHealthEventRepository();
    final pending = Completer<HealthEvent?>();
    repository.fetchCompleter = pending;
    final container = _containerFor(repository);
    addTearDown(container.dispose);
    final states = <AsyncValue<HealthEvent?>>[];
    final subscription = container.listen<AsyncValue<HealthEvent?>>(
      activeHealthEventProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    repository.event = null;
    _switchToOtherUser(container);
    pending.complete(_event);

    await container.read(activeHealthEventProvider.future);

    expect(container.read(activeHealthEventProvider).value, isNull);
    expect(states.where((state) => state.value == _event), isEmpty);
  });

  test('rejects create response after user switch', () async {
    final repository = _FakeHealthEventRepository();
    final container = _containerFor(repository);
    addTearDown(container.dispose);
    final notifier = container.read(activeHealthEventProvider.notifier);
    await container.read(activeHealthEventProvider.future);
    final pending = Completer<HealthEvent>();
    repository.createCompleter = pending;

    final operation = notifier.create(title: 'Cold observation');
    await Future<void>.delayed(Duration.zero);
    _switchToOtherUser(container);
    pending.complete(_event);

    await expectLater(operation, throwsA(isA<AuthRequiredException>()));
  });

  test('rejects check-in response after user switch', () async {
    final repository = _FakeHealthEventRepository();
    final container = _containerFor(repository);
    addTearDown(container.dispose);
    final notifier = container.read(activeHealthEventProvider.notifier);
    await container.read(activeHealthEventProvider.future);
    final pending = Completer<HealthEvent>();
    repository.checkInCompleter = pending;

    final operation = notifier.checkIn(
      eventId: _event.id,
      date: '2026-08-09',
      outcome: HealthEventOutcome.improved,
    );
    await Future<void>.delayed(Duration.zero);
    _switchToOtherUser(container);
    pending.complete(_event);

    await expectLater(operation, throwsA(isA<AuthRequiredException>()));
  });

  test('rejects end response after user switch', () async {
    final repository = _FakeHealthEventRepository();
    final container = _containerFor(repository);
    addTearDown(container.dispose);
    final notifier = container.read(activeHealthEventProvider.notifier);
    await container.read(activeHealthEventProvider.future);
    final pending = Completer<HealthEvent>();
    repository.endCompleter = pending;

    final operation = notifier.end(
      eventId: _event.id,
      outcome: HealthEventOutcome.unchanged,
    );
    await Future<void>.delayed(Duration.zero);
    _switchToOtherUser(container);
    pending.complete(_event);

    await expectLater(operation, throwsA(isA<AuthRequiredException>()));
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

ProviderContainer _containerFor(_FakeHealthEventRepository repository) {
  return ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      healthEventRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

void _switchToOtherUser(ProviderContainer container) {
  container.read(authSessionProvider.notifier).state = AuthSessionState(
    isAuthenticated: true,
    user: _otherTestUser,
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

final _testUser = AuthUser(
  id: 'user-1',
  email: null,
  nickname: null,
  avatar: null,
  emailVerifiedAt: null,
  createdAt: _testDate,
  updatedAt: _testDate,
);

final _otherTestUser = AuthUser(
  id: 'user-2',
  email: null,
  nickname: null,
  avatar: null,
  emailVerifiedAt: null,
  createdAt: _testDate,
  updatedAt: _testDate,
);

final _testDate = DateTime.utc(2026, 8, 9);
