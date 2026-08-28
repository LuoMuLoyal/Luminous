import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/views/dashboard_view.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../../helpers/test_forui_app.dart';
import '../../../today/test_helpers.dart';

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState(isAuthenticated: true);
}

class _FakeHealthEventRepository implements HealthEventRepository {
  _FakeHealthEventRepository({this.active});

  HealthEvent? active;
  String? createdTitle;
  String? createdReasonRecordId;
  List<String>? createdMedicineIds;
  HealthEventOutcome? checkedInOutcome;
  HealthEventOutcome? endedOutcome;

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchActive() =>
      TaskEither.right(active);

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchById(String eventId) =>
      TaskEither.right(active);

  @override
  TaskEither<LucentFailure, List<HealthEvent>> fetchHistory() =>
      TaskEither.right(const []);

  @override
  TaskEither<LucentFailure, HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) {
    createdTitle = title;
    createdReasonRecordId = reasonRecordId;
    createdMedicineIds = currentMedicineIds;
    return TaskEither.right(activeEvent);
  }

  @override
  TaskEither<LucentFailure, HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) {
    checkedInOutcome = outcome;
    return TaskEither.right(
      activeEvent.copyWith(
        checkIn: HealthEventCheckIn(
          id: 'check-in-1',
          eventId: eventId,
          date: date,
          outcome: outcome,
          createdAt: '2026-08-09T00:00:00.000Z',
          updatedAt: '2026-08-09T00:00:00.000Z',
        ),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) {
    endedOutcome = outcome;
    return TaskEither.right(
      activeEvent.copyWith(
        status: HealthEventStatus.ended,
        outcome: outcome,
        endedAt: '2026-08-09T00:00:00.000Z',
      ),
    );
  }
}

void main() {
  testWidgets('shows the start entry when there is no active event', (
    tester,
  ) async {
    final repository = _FakeHealthEventRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('开始一段健康观察'), findsOneWidget);
    expect(find.byKey(const Key('health-event-start-action')), findsOneWidget);
    expect(find.byKey(const Key('health-event-check-in-action')), findsNothing);
  });

  testWidgets('submits a daily result for an active event', (tester) async {
    final repository = _FakeHealthEventRepository(active: activeEvent);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await _scrollTo(tester, const Key('health-event-check-in-action'));
    await tester.tap(find.byKey(const Key('health-event-check-in-action')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('health-event-check-in-outcome-worsened')),
    );
    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();

    expect(repository.checkedInOutcome, HealthEventOutcome.worsened);
  });

  testWidgets('ends an active event only after choosing an outcome', (
    tester,
  ) async {
    final repository = _FakeHealthEventRepository(active: activeEvent);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await _scrollTo(tester, const Key('health-event-end-action'));
    await tester.tap(find.byKey(const Key('health-event-end-action')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('health-event-end-outcome-improved')),
    );
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();

    expect(repository.endedOutcome, HealthEventOutcome.improved);
  });

  testWidgets('does not render health observation controls on desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(_app(_FakeHealthEventRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('health-event-start-action')), findsNothing);
    expect(find.byKey(const Key('health-event-check-in-action')), findsNothing);
    expect(find.byKey(const Key('health-event-end-action')), findsNothing);
  });

  testWidgets(
    'loads symptom and current medicine associations using the profile timezone',
    (tester) async {
      DateTime? requestedDate;
      final repository = _FakeHealthEventRepository();
      final profileSnapshot = _snapshot.copyWith(
        profile: _snapshot.profile.copyWith(timezone: 'Pacific/Kiritimati'),
        currentMedicines: [_currentMedicine],
      );
      await tester.pumpWidget(
        _app(
          repository,
          snapshot: profileSnapshot,
          records: const DailyRecordListData(items: [_symptomRecord], total: 1),
          onRecordsDate: (date) => requestedDate = date,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, const Key('health-event-start-action'));
      await tester.tap(find.byKey(const Key('health-event-start-action')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('health-event-association-record-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('health-event-association-medicine-1')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('health-event-start-title-field')),
        '发热观察',
      );
      await tester.tap(
        find.byKey(const Key('health-event-association-record-1')),
      );
      await tester.tap(
        find.byKey(const Key('health-event-association-medicine-1')),
      );
      await tester.tap(find.byKey(const Key('health-event-start-submit')));
      await tester.pumpAndSettle();

      expect(repository.createdTitle, '发热观察');
      expect(repository.createdReasonRecordId, 'record-1');
      expect(repository.createdMedicineIds, ['medicine-1']);

      timezone_data.initializeTimeZones();
      final expected = timezone.TZDateTime.from(
        DateTime.now().toUtc(),
        timezone.getLocation('Pacific/Kiritimati'),
      );
      expect(requestedDate, isNotNull);
      expect(
        requestedDate,
        DateTime(expected.year, expected.month, expected.day),
      );
    },
  );

  testWidgets('uses Asia/Shanghai for a missing profile timezone', (
    tester,
  ) async {
    DateTime? requestedDate;
    await tester.pumpWidget(
      _app(
        _FakeHealthEventRepository(),
        snapshot: _snapshot.copyWith(
          profile: _snapshot.profile.copyWith(timezone: null),
        ),
        records: const DailyRecordListData(items: [], total: 0),
        onRecordsDate: (date) => requestedDate = date,
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, const Key('health-event-start-action'));
    await tester.tap(find.byKey(const Key('health-event-start-action')));
    await tester.pumpAndSettle();

    timezone_data.initializeTimeZones();
    final expected = timezone.TZDateTime.from(
      DateTime.now().toUtc(),
      timezone.getLocation('Asia/Shanghai'),
    );
    expect(
      requestedDate,
      DateTime(expected.year, expected.month, expected.day),
    );
  });
}

Widget _app(
  _FakeHealthEventRepository repository, {
  Future<void> Function()? onRefresh,
  HealthContextSnapshot snapshot = _snapshot,
  DailyRecordListData records = const DailyRecordListData(items: [], total: 0),
  ValueChanged<DateTime>? onRecordsDate,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      healthEventRepositoryProvider.overrideWithValue(repository),
      healthContextSnapshotProvider.overrideWith((ref) async => snapshot),
      dailyRecordListForDateProvider.overrideWith((ref, date) async {
        onRecordsDate?.call(date);
        return records;
      }),
      todaySuggestionProvider.overrideWith(EmptyTodaySuggestionNotifier.new),
    ],
    child: TestForuiApp(
      home: TodayDashboardView(
        dashboard: TodayDashboard.signedOut(),
        onRefresh: onRefresh ?? _noOpRefresh,
      ),
    ),
  );
}

Future<void> _noOpRefresh() async {}

Future<void> _scrollTo(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: 'Asia/Shanghai',
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

const activeEvent = HealthEvent(
  id: 'event-1',
  title: '感冒观察',
  status: HealthEventStatus.active,
  startedAt: '2026-08-08T16:00:00.000Z',
  currentMedicineIds: [],
  coverage: HealthEventCoverage(checkInCount: 0),
);

const _currentMedicine = CurrentMedicineItem(
  id: 'medicine-1',
  source: 'manual',
  sourceRefId: null,
  displayName: '短期用药',
  strengthText: null,
  doseText: null,
  route: null,
  startedAt: null,
  endedAt: null,
  isCurrent: true,
  note: null,
  createdAt: '2026-08-09T00:00:00.000Z',
  updatedAt: '2026-08-09T00:00:00.000Z',
);

const _symptomRecord = DailyRecordItem(
  id: 'record-1',
  kind: DailyRecordKind.symptom,
  occurredAt: '2026-08-09T00:00:00.000Z',
  occurredTime: null,
  title: '发热',
  value: null,
  unit: null,
  note: null,
  source: null,
  payload: null,
  createdAt: '2026-08-09T00:00:00.000Z',
  updatedAt: '2026-08-09T00:00:00.000Z',
);
