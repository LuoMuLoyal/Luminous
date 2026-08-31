import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail.dart';
import 'package:luminous/features/medicine/presentation/pages/reminder/detail.dart';
import 'package:luminous/features/medicine/presentation/pages/reminder/edit.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Medicine reminder detail renders schedule and dose logs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderDetailPage(currentMedicineId: 'med-1'),
        reminderDataSource: _FakeReminderDataSource(
          [
            _reminder(
              id: 'reminder-1',
              hour: 8,
              minute: 0,
              startDate: '2026-06-10',
            ),
            _reminder(
              id: 'reminder-2',
              hour: 20,
              minute: 0,
              startDate: '2026-06-10',
            ),
          ],
          deliveries: const [
            ReminderDeliveryItem(
              id: 'delivery-1',
              reminderId: 'reminder-1',
              deviceId: 'device-1',
              channel: 'local',
              status: 'delivered',
              scheduledFor: '2026-06-10T08:00:00.000Z',
              deliveredAt: '2026-06-10T08:00:03.000Z',
              errorMessage: null,
              createdAt: '2026-06-10T07:55:00.000Z',
            ),
          ],
        ),
        doseLogDataSource: _FakeDoseLogDataSource([
          const DoseLogItem(
            id: 'dose-1',
            currentMedicineId: 'med-1',
            status: DoseLogStatus.taken,
            scheduledFor: '2026-06-09T08:00:00.000Z',
            createdAt: '2026-06-09T08:01:00.000Z',
            updatedAt: '2026-06-09T08:01:00.000Z',
          ),
        ]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('用药提醒详情'), findsOneWidget);
    expect(find.text('阿托伐他汀钙片'), findsOneWidget);
    expect(find.text('08:00 · 20:00'), findsOneWidget);
    expect(find.text('开始日期'), findsOneWidget);
    expect(find.text('2026-06-10'), findsOneWidget);
    expect(find.textContaining('短信未开通'), findsOneWidget);
    expect(find.textContaining('默认铃声'), findsOneWidget);
    expect(find.text('今日用药打卡'), findsOneWidget);
    expect(find.text('已服用'), findsOneWidget);
    expect(find.text('提醒投递历史'), findsOneWidget);
    expect(find.text('已投递'), findsOneWidget);
  });

  testWidgets('Medicine reminder detail shows not found for missing medicine', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderDetailPage(
          currentMedicineId: 'med-missing',
        ),
        reminderDataSource: _FakeReminderDataSource([]),
        doseLogDataSource: _FakeDoseLogDataSource([]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.medicineReminderNotFoundTitle), findsOneWidget);
    expect(find.text(l10n.medicineReminderNotFoundDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Medicine reminder detail shows generic error on load failure', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderDetailPage(currentMedicineId: 'med-1'),
        reminderDataSource: _FakeReminderDataSource([]),
        doseLogDataSource: _FakeDoseLogDataSource([]),
        overrides: [
          medicineReminderListProvider.overrideWith(
            (ref) => Future<List<MedicineReminderItem>>.error(
              Exception('network failure'),
            ),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.medicineReminderGenericErrorTitle), findsOneWidget);
    expect(
      find.text(l10n.medicineReminderGenericErrorDescription),
      findsOneWidget,
    );
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('medicine card opens detail page when source is cn', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderDetailPage(currentMedicineId: 'med-1'),
        reminderDataSource: _FakeReminderDataSource([]),
        doseLogDataSource: _FakeDoseLogDataSource([]),
        snapshot: _cnMedicineSnapshot,
        overrides: [
          medicineDetailProvider('cn', 'cn_1').overrideWith(
            (ref) async => const MedicineDetail(
              id: 'cn_1',
              source: 'cn',
              name: '阿托伐他汀钙片',
              kind: 'cnProduct',
            ),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('阿托伐他汀钙片'));
    await tester.pumpAndSettle();

    expect(find.byType(MedicineDetailPage), findsOneWidget);
  });

  testWidgets('medicine card does not navigate when sourceRefId is null', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderDetailPage(currentMedicineId: 'med-1'),
        reminderDataSource: _FakeReminderDataSource([]),
        doseLogDataSource: _FakeDoseLogDataSource([]),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('阿托伐他汀钙片'));
    await tester.pumpAndSettle();

    expect(find.byType(MedicineDetailPage), findsNothing);
    expect(find.byType(MedicineReminderDetailPage), findsOneWidget);
  });

  testWidgets('Medicine reminder create page prompts to select medicine', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      _testApp(
        child: const MedicineReminderEditPage(),
        reminderDataSource: _FakeReminderDataSource([]),
        doseLogDataSource: _FakeDoseLogDataSource([]),
        snapshot: _emptySnapshot,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.medicineReminderSelectMedicineHint), findsOneWidget);
    expect(
      find.text(l10n.medicineReminderSelectMedicineAction),
      findsOneWidget,
    );
  });

  test(
    'Medicine reminder form saves whole group through single upsert',
    () async {
      final dataSource = _FakeReminderDataSource([
        _reminder(id: 'reminder-1', hour: 8, minute: 0),
        _reminder(id: 'reminder-2', hour: 20, minute: 0),
      ]);
      final container = ProviderContainer(
        overrides: [
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            dataSource,
          ),
        ],
      );
      addTearDown(container.dispose);

      final saved = await container
          .read(medicineReminderFormProvider.notifier)
          .saveGroup(
            existingReminders: dataSource.items,
            input: const MedicineReminderGroupWriteInput(
              currentMedicineId: 'med-1',
              label: '阿托伐他汀钙片',
              times: [
                MedicineReminderTimeInput(hour: 7, minute: 30),
                MedicineReminderTimeInput(hour: 12, minute: 0),
                MedicineReminderTimeInput(hour: 21, minute: 15),
              ],
              daysOfWeek: null,
              startDate: '2026-06-10',
              endDate: null,
              isActive: true,
              note: '饭后服用',
            ),
          );

      expect(saved, isTrue);
      expect(dataSource.upsertGroupInputs, hasLength(1));

      final input = dataSource.upsertGroupInputs.single;
      expect(input.currentMedicineId, 'med-1');
      expect(input.label, '阿托伐他汀钙片');
      expect(input.daysOfWeek, isNull);
      expect(input.startDate, '2026-06-10');
      expect(input.endDate, isNull);
      expect(input.isActive, isTrue);
      expect(input.note, '饭后服用');

      expect(input.slots, hasLength(3));
      expect(input.slots[0].id, 'reminder-1');
      expect(input.slots[0].scheduledHour, 7);
      expect(input.slots[0].scheduledMinute, 30);
      expect(input.slots[1].id, 'reminder-2');
      expect(input.slots[1].scheduledHour, 12);
      expect(input.slots[1].scheduledMinute, 0);
      expect(input.slots[2].id, isNull);
      expect(input.slots[2].scheduledHour, 21);
      expect(input.slots[2].scheduledMinute, 15);

      // The whole group is submitted once; no per-slot update/create/delete.
      expect(dataSource.updatedIds, isEmpty);
      expect(dataSource.createdInputs, isEmpty);
      expect(dataSource.deletedIds, isEmpty);
    },
  );
}

Widget _testApp({
  required Widget child,
  required _FakeReminderDataSource reminderDataSource,
  required _FakeDoseLogDataSource doseLogDataSource,
  List overrides = const [],
  HealthContextSnapshot? snapshot,
}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      healthContextSnapshotProvider.overrideWith(
        (ref) async => snapshot ?? _snapshot,
      ),
      medicineReminderRemoteDataSourceProvider.overrideWithValue(
        reminderDataSource,
      ),
      appDatabaseProvider.overrideWithValue(db),
      cachedDoseLogDataSourceProvider.overrideWith((ref) {
        return CachedDoseLogDataSource(
          remote: doseLogDataSource,
          dao: db.medicineDoseLogDao,
        );
      }),
      medicineWorkspaceProvider.overrideWith(
        (ref) async => MockMedicineWorkspaceRepository.previewWorkspace,
      ),
      ...overrides,
    ],
    child: TestForuiRouterApp(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => child),
          GoRoute(
            path: '/medicine/detail/:source/:id',
            builder: (context, state) => MedicineDetailPage(
              source: state.pathParameters['source']!,
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/medicine/reminders/new',
            builder: (context, state) => const MedicineReminderEditPage(),
          ),
          GoRoute(
            path: '/medicine/reminders/:medicineId/edit',
            builder: (context, state) => MedicineReminderEditPage(
              currentMedicineId: state.pathParameters['medicineId'],
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('login')),
          ),
        ],
      ),
    ),
  );
}

class _FakeReminderDataSource extends MedicineReminderRemoteDataSource {
  _FakeReminderDataSource(this.items, {this.deliveries = const []})
    : super(
        api: MedicineRemindersApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final List<MedicineReminderItem> items;
  final List<ReminderDeliveryItem> deliveries;
  final createdInputs = <MedicineReminderWriteInput>[];
  final updatedIds = <String>[];
  final updatedInputs = <MedicineReminderWriteInput>[];
  final deletedIds = <String>[];
  final upsertGroupInputs = <MedicineReminderGroupUpsertInput>[];

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() =>
      TaskEither.right(items);

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchAll() =>
      TaskEither.right(items);

  @override
  TaskEither<LucentFailure, List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) => TaskEither.right(deliveries);

  @override
  TaskEither<LucentFailure, MedicineReminderItem> create(
    MedicineReminderWriteInput input,
  ) {
    createdInputs.add(input);
    return TaskEither.right(
      _reminder(
        id: 'created-${createdInputs.length}',
        hour: input.scheduledHour,
        minute: input.scheduledMinute,
        daysOfWeek: input.daysOfWeek,
        startDate: input.startDate,
        endDate: input.endDate,
        note: input.note,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) {
    updatedIds.add(id);
    updatedInputs.add(input);
    return TaskEither.right(
      _reminder(
        id: id,
        hour: input.scheduledHour,
        minute: input.scheduledMinute,
        daysOfWeek: input.daysOfWeek,
        startDate: input.startDate,
        endDate: input.endDate,
        note: input.note,
        isActive: input.isActive,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) {
    deletedIds.add(id);
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  ) {
    upsertGroupInputs.add(input);
    return TaskEither.right(items);
  }
}

class _FakeDoseLogDataSource extends DoseLogRemoteDataSource {
  _FakeDoseLogDataSource(this.items)
    : super(
        api: MedicineDoseLogsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final List<DoseLogItem> items;

  @override
  Future<List<DoseLogItem>> fetchForDate(String date) async => items;
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

MedicineReminderItem _reminder({
  required String id,
  int hour = 8,
  int minute = 0,
  List<int>? daysOfWeek,
  String? note,
  bool isActive = true,
  String? startDate,
  String? endDate,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: 'med-1',
    label: '阿托伐他汀钙片',
    scheduledHour: hour,
    scheduledMinute: minute,
    daysOfWeek: daysOfWeek,
    startDate: startDate,
    endDate: endDate,
    isActive: isActive,
    note: note,
    createdAt: '2026-06-08T07:00:00.000Z',
    updatedAt: '2026-06-09T07:00:00.000Z',
  );
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 22,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 1,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [
    CurrentMedicineItem(
      id: 'med-1',
      source: 'manual',
      sourceRefId: null,
      displayName: '阿托伐他汀钙片',
      strengthText: '10mg',
      doseText: '每日一次',
      route: 'oral',
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-06-08T07:00:00.000Z',
      updatedAt: '2026-06-09T07:00:00.000Z',
    ),
  ],
);

final _cnMedicineSnapshot = _snapshot.copyWith(
  currentMedicines: [
    _snapshot.currentMedicines.first.copyWith(
      source: 'cn',
      sourceRefId: 'cn_1',
    ),
  ],
);

const _emptySnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 22,
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
    timezone: null,
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
