import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';

import '../helpers/test_forui_app.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_reminder_pages.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    'Medicine reminder form syncs times through update/create/delete',
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
      expect(dataSource.updatedIds, ['reminder-1', 'reminder-2']);
      expect(dataSource.createdInputs, hasLength(1));
      expect(dataSource.deletedIds, isEmpty);
      expect(dataSource.updatedInputs.first.scheduledHour, 7);
      expect(dataSource.updatedInputs.first.scheduledMinute, 30);
      expect(dataSource.updatedInputs.first.daysOfWeek, isNull);
      expect(dataSource.updatedInputs.first.startDate, '2026-06-10');
      expect(dataSource.updatedInputs.first.endDate, isNull);
      expect(dataSource.createdInputs.single.scheduledHour, 21);
      expect(dataSource.createdInputs.single.scheduledMinute, 15);
    },
  );
}

Widget _testApp({
  required Widget child,
  required _FakeReminderDataSource reminderDataSource,
  required _FakeDoseLogDataSource doseLogDataSource,
  List overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
      medicineReminderRemoteDataSourceProvider.overrideWithValue(
        reminderDataSource,
      ),
      doseLogRemoteDataSourceProvider.overrideWithValue(doseLogDataSource),
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

  @override
  Future<List<MedicineReminderItem>> fetchActive() async => items;

  @override
  Future<List<MedicineReminderItem>> fetchAll() async => items;

  @override
  Future<List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) async {
    return deliveries;
  }

  @override
  Future<MedicineReminderItem> create(MedicineReminderWriteInput input) async {
    createdInputs.add(input);
    return _reminder(
      id: 'created-${createdInputs.length}',
      hour: input.scheduledHour,
      minute: input.scheduledMinute,
      daysOfWeek: input.daysOfWeek,
      startDate: input.startDate,
      endDate: input.endDate,
      note: input.note,
    );
  }

  @override
  Future<MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) async {
    updatedIds.add(id);
    updatedInputs.add(input);
    return _reminder(
      id: id,
      hour: input.scheduledHour,
      minute: input.scheduledMinute,
      daysOfWeek: input.daysOfWeek,
      startDate: input.startDate,
      endDate: input.endDate,
      note: input.note,
      isActive: input.isActive,
    );
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
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
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
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
