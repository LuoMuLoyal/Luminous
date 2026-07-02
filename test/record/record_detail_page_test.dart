import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/presentation/pages/record_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_test_helpers.dart';

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
}
