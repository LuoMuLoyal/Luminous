import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/pages/detail.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

class _FakeRepo extends DailyRecordRepository {
  /// Analysis status returned by [get]; starts unconfirmed and flips to
  /// confirmed after a successful [update], mirroring the PATCH chain.
  String _analysisStatus = 'unconfirmed';

  /// When true, [update] throws so tests can pin the failure contract.
  bool updateThrows = false;

  String? lastUpdateId;
  DailyRecordUpdateInput? lastUpdateInput;

  DailyRecordItem _mealItem(String id) {
    return DailyRecordItem(
      id: id,
      kind: DailyRecordKind.meal,
      occurredAt: '2026-06-10',
      title: '午餐',
      payload: {
        'mealInput': {
          'recognizedDishes': [
            {'rawName': '西红柿炒鸡蛋'},
            {'rawName': '米饭'},
          ],
        },
        'mealAnalysis': {
          'analysisStatus': _analysisStatus,
          'coverage': 'partial',
          'mealDescription': '一份米饭配西红柿炒鸡蛋',
          'recognizedDishes': [
            {
              'dishKey': 'dish-1',
              'rawName': '西红柿炒鸡蛋',
              'normalizedDishName': '西红柿炒鸡蛋',
            },
            {'dishKey': 'dish-2', 'rawName': '米饭', 'normalizedDishName': '米饭'},
          ],
          'resolvedIngredients': [
            {
              'dishKey': 'dish-1',
              'ingredientName': '西红柿',
              'matchedFoodName': '西红柿',
            },
          ],
          'compositionMatches': [
            {
              'dishKey': 'dish-1',
              'ingredientName': '西红柿',
              'matchedFoodName': '西红柿',
              'matchMethod': 'exact',
            },
          ],
          'nutritionEstimate': {'energyKcal': 320, 'proteinG': 16.2},
          'mealCommentary': '这一餐营养结果为保守估算。',
        },
      },
      attachments: const <DailyRecordAttachment>[],
      createdAt: '2026-06-10T08:00:00.000Z',
      updatedAt: '2026-06-10T08:00:00.000Z',
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      TaskEither.right(_mealItem(id));

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) {
    lastUpdateId = id;
    lastUpdateInput = input;
    if (updateThrows) {
      return TaskEither.left(LucentFailure.unknown(message: 'update failed'));
    }
    _analysisStatus = 'confirmed';
    return TaskEither.right(_mealItem(id));
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);
}

/// Fake repository that returns same-day water records plus the viewed record.
class _WaterFakeRepo extends DailyRecordRepository {
  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) {
    return TaskEither.right(_waterRecord(id: id, value: '300'));
  }

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    return TaskEither.right(
      DailyRecordListData(
        items: [
          _waterRecord(id: 'water-1', value: '250'),
          _waterRecord(id: 'water-2', value: '300'),
          _waterRecord(id: 'water-3', value: '1', unit: 'cup'),
        ],
        total: 3,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  DailyRecordItem _waterRecord({
    required String id,
    required String value,
    String unit = 'ml',
  }) {
    return DailyRecordItem(
      id: id,
      kind: DailyRecordKind.water,
      occurredAt: '2026-06-10',
      value: value,
      unit: unit,
      attachments: const <DailyRecordAttachment>[],
      createdAt: '2026-06-10T08:00:00.000Z',
      updatedAt: '2026-06-10T08:00:00.000Z',
    );
  }
}

/// Fake settings repository with a configurable water target count (glasses),
/// mirroring the fake used by `test/today/repository_test.dart`.
class _FakeUserSettingsRepository implements UserSettingsRepository {
  _FakeUserSettingsRepository({
    this.waterTargetCount = 8,
    this.throwOnGet = false,
  });

  final int waterTargetCount;

  /// When true, [getSettings] returns a Left so tests can pin the fallback
  /// contract.
  final bool throwOnGet;

  @override
  TaskEither<LucentFailure, UserSettings> getSettings() {
    if (throwOnGet) {
      return TaskEither.left(
        LucentFailure.unknown(message: 'settings unavailable'),
      );
    }
    return TaskEither.right(
      UserSettings(
        aiSummariesEnabled: true,
        dataSharingConsent: false,
        assistantEnabled: true,
        assistantMemoryEnabled: false,
        waterTargetCount: waterTargetCount,
        assistantContext: const AssistantContextSettings(
          healthProfile: false,
          dailyRecords: false,
          sleepRecords: false,
          currentMedicines: false,
        ),
        securityPin: const SecurityPinSettings(enabled: false),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) => getSettings();

  @override
  TaskEither<LucentFailure, UserSettings> enableSecurityPin(String pin) =>
      getSettings();

  @override
  TaskEither<LucentFailure, UserSettings> changeSecurityPin(
    String oldPin,
    String newPin,
  ) => getSettings();

  @override
  TaskEither<LucentFailure, UserSettings> disableSecurityPin(String pin) =>
      getSettings();
}

void main() {
  testWidgets('RecordDetailPage loads and displays record when authenticated', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'test-id'),
              ),
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('Home')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.byType(RecordDetailPage), findsOneWidget);
    expect(find.textContaining('确认'), findsWidgets);
    expect(find.text('餐食分析'), findsOneWidget);
    expect(find.textContaining('西红柿炒鸡蛋'), findsWidgets);
    expect(find.textContaining('西红柿'), findsWidgets);
    expect(find.textContaining('热量'), findsOneWidget);
    expect(find.textContaining('保守估算'), findsWidgets);
  });

  testWidgets('water detail shows daily progress and adjacent navigation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _WaterFakeRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _waterMetricSnapshot,
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'water-2'),
              ),
              GoRoute(
                path: '/record/:id',
                builder: (_, state) =>
                    RecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // 250 + 300 ml aggregated; the cup record is not counted.
    expect(find.text('今日饮水'), findsOneWidget);
    expect(find.text('550 / 2000 ml'), findsOneWidget);

    // Adjacent navigation: water-2 sits between water-1 and water-3.
    expect(
      find.byKey(const Key('record-detail-previous-action')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('record-detail-next-action')), findsOneWidget);

    // Copy action is available.
    expect(find.byKey(const Key('record-detail-copy-action')), findsOneWidget);

    // Edit is the primary action in the page body (header icon removed).
    expect(find.byKey(const Key('record-detail-edit-action')), findsOneWidget);
    expect(find.text('编辑这条记录'), findsOneWidget);

    // Navigating next loads the adjacent record.
    await tester.tap(find.byKey(const Key('record-detail-next-action')));
    await tester.pumpAndSettle();
    expect(find.byType(RecordDetailPage), findsOneWidget);
    expect(find.text('今日饮水'), findsOneWidget);
  });

  testWidgets('water detail reads daily water target from user-settings '
      '(waterTargetCount × 250 ml)', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _WaterFakeRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _waterMetricSnapshot,
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(waterTargetCount: 12),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'water-2'),
              ),
              GoRoute(
                path: '/record/:id',
                builder: (_, state) =>
                    RecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // 250 + 300 ml aggregated; target = 12 × 250 = 3000 ml.
    expect(find.text('今日饮水'), findsOneWidget);
    expect(find.text('550 / 3000 ml'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(550 / 3000, 0.0001));
  });

  testWidgets('water detail falls back to the default target when '
      'user-settings are unavailable', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _WaterFakeRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _waterMetricSnapshot,
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(throwOnGet: true),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'water-2'),
              ),
              GoRoute(
                path: '/record/:id',
                builder: (_, state) =>
                    RecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Settings fetch failed → fall back to the mirrored backend default
    // (8 glasses × 250 ml = 2000 ml) so the progress card stays usable.
    expect(find.text('今日饮水'), findsOneWidget);
    expect(find.text('550 / 2000 ml'), findsOneWidget);
  });

  testWidgets('water detail shows fl oz totals when unit system is imperial', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _WaterFakeRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _waterImperialSnapshot,
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'water-2'),
              ),
              GoRoute(
                path: '/record/:id',
                builder: (_, state) =>
                    RecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // 250 + 300 ml → 550 ml ≈ 18.6 fl oz; target 8 × 250 = 2000 ml ≈ 67.6
    // fl oz. The progress bar value still uses the raw ml ratio.
    expect(find.text('今日饮水'), findsOneWidget);
    expect(find.text('18.6 / 67.6 fl oz'), findsOneWidget);
    expect(find.text('550 / 2000 ml'), findsNothing);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(550 / 2000, 0.0001));
  });

  testWidgets('water detail falls back to metric when the health snapshot is '
      'unavailable', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _WaterFakeRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => throw Exception('snapshot unavailable'),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'water-2'),
              ),
              GoRoute(
                path: '/record/:id',
                builder: (_, state) =>
                    RecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Snapshot fetch failed → unit system falls back to metric (ml display).
    expect(find.text('今日饮水'), findsOneWidget);
    expect(find.text('550 / 2000 ml'), findsOneWidget);
    expect(find.textContaining('fl oz'), findsNothing);
  });

  testWidgets('meal detail shows confirm action for unconfirmed analysis and '
      'confirming patches analysisStatus', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        dailyRecordRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(
          showToaster: true,
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'test-id'),
              ),
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('Home')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    final confirmAction = find.byKey(const Key('meal-analysis-confirm-action'));
    expect(confirmAction, findsOneWidget);

    // The confirm action sits below the fold inside the page's scroll view.
    await tester.ensureVisible(confirmAction);
    await tester.pump();
    await tester.tap(confirmAction);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // update was called with the confirmed analysisStatus patch.
    expect(repo.lastUpdateId, 'test-id');
    final payload = repo.lastUpdateInput!.payload! as Map<String, dynamic>;
    expect(
      (payload['mealAnalysis'] as Map<String, dynamic>)['analysisStatus'],
      'confirmed',
    );

    // After the detail reloads the badge reads confirmed and the confirm
    // action is gone.
    expect(confirmAction, findsNothing);
    expect(find.textContaining('已确认'), findsOneWidget);

    // DataChangeBus emitted dailyRecords so the keepAlive recordDashboard
    // refreshes the timeline badge on return to the record page.
    final busState = container.read(dataChangeBusProvider);
    expect(busState[DataChangeTopic.dailyRecords], isNotNull);
    expect(busState[DataChangeTopic.dailyRecords], greaterThan(0));

    // Drain the success toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 2000));
  });

  testWidgets('meal detail confirm failure keeps the confirm action and shows '
      'an error toast', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repo = _FakeRepo()..updateThrows = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
        ],
        child: TestForuiRouterApp(
          showToaster: true,
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordDetailPage(recordId: 'test-id'),
              ),
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('Home')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    final confirmAction = find.byKey(const Key('meal-analysis-confirm-action'));
    expect(confirmAction, findsOneWidget);

    // The confirm action sits below the fold inside the page's scroll view.
    await tester.ensureVisible(confirmAction);
    await tester.pump();
    await tester.tap(confirmAction);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // State unchanged: the confirm action is still present and the error
    // toast is shown.
    expect(confirmAction, findsOneWidget);
    expect(find.text('确认失败，请稍后再试'), findsOneWidget);

    // Drain the error toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 2000));
  });
}

/// Minimal metric health-context snapshot (unitSystem unset → metric) for
/// the water progress card; avoids a real health-context fetch in tests.
const _waterMetricSnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
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

/// Same as [_waterMetricSnapshot] but with imperial unit system, so the
/// water progress card renders fl oz totals (display-only conversion).
const _waterImperialSnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
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
    unitSystem: 'imperial',
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
