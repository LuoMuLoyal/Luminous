import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
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

class _FakeRepo extends DailyRecordRepository {
  @override
  Future<DailyRecordItem> get(String id) async {
    return DailyRecordItem(
      id: id,
      kind: DailyRecordKind.meal,
      occurredAt: '2026-06-10',
      title: '午餐',
      payload: const {
        'mealInput': {
          'recognizedDishes': [
            {'rawName': '西红柿炒鸡蛋'},
            {'rawName': '米饭'},
          ],
        },
        'mealAnalysis': {
          'analysisStatus': 'unconfirmed',
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
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async => throw UnimplementedError();
  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async =>
      throw UnimplementedError();
  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async => throw UnimplementedError();
  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async => throw UnimplementedError();
  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async =>
      throw UnimplementedError();
  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async => throw UnimplementedError();
  @override
  Future<void> delete(String id) async {}
}

/// Fake repository that returns same-day water records plus the viewed record.
class _WaterFakeRepo extends DailyRecordRepository {
  @override
  Future<DailyRecordItem> get(String id) async {
    return _waterRecord(id: id, value: '300');
  }

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    return DailyRecordListData(
      items: [
        _waterRecord(id: 'water-1', value: '250'),
        _waterRecord(id: 'water-2', value: '300'),
        _waterRecord(id: 'water-3', value: '1', unit: 'cup'),
      ],
      total: 3,
    );
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async =>
      throw UnimplementedError();
  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async => throw UnimplementedError();
  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async => throw UnimplementedError();
  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async =>
      throw UnimplementedError();
  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async => throw UnimplementedError();
  @override
  Future<void> delete(String id) async {}

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

  /// When true, [getSettings] throws so tests can pin the fallback contract.
  final bool throwOnGet;

  @override
  Future<UserSettings> getSettings() async {
    if (throwOnGet) throw Exception('settings unavailable');
    return UserSettings(
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
    );
  }

  @override
  Future<UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) async => getSettings();

  @override
  Future<UserSettings> enableSecurityPin(String pin) async => getSettings();

  @override
  Future<UserSettings> changeSecurityPin(String oldPin, String newPin) async =>
      getSettings();

  @override
  Future<UserSettings> disableSecurityPin(String pin) async => getSettings();
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
}
