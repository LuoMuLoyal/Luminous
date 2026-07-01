import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/presentation/pages/record_edit.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_test_helpers.dart';

/// Fake repository that returns a canned record.
class _FakeRecordRepo extends DailyRecordRepository {
  DailyRecordUpdateInput? lastUpdateInput;

  @override
  Future<DailyRecordItem> get(String id) async {
    return DailyRecordItem(
      id: id,
      kind: DailyRecordKind.meal,
      occurredAt: '2026-06-10',
      title: 'Test Meal',
      payload: const {
        'mealInput': {
          'recognizedDishes': [
            {'rawName': '西红柿炒鸡蛋'},
            {'rawName': '米饭'},
          ],
        },
        'mealAnalysis': {
          'analysisStatus': 'unconfirmed',
          'recognizedDishes': [
            {'rawName': '西红柿炒鸡蛋'},
            {'rawName': '米饭'},
          ],
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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    lastUpdateInput = input;
    return get(id);
  }

  @override
  Future<void> delete(String id) async {}
}

void main() {
  testWidgets('RecordEditPage loads and displays record when authenticated', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final repo = _FakeRecordRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
          ),
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const RecordEditPage(recordId: 'test-id'),
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

    expect(find.byType(RecordEditPage), findsOneWidget);
    expect(find.text(l10n.recordEditAction), findsWidgets);
    expect(find.text('西红柿炒鸡蛋'), findsOneWidget);
    expect(find.text('米饭'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('meal-dish-field-0')), '番茄炒蛋');
    await tester.ensureVisible(find.byKey(const Key('meal-dish-remove-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-dish-remove-1')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('meal-dish-add-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-dish-add-action')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('meal-dish-field-1')), '青菜');
    await tester.ensureVisible(find.byKey(const Key('meal-confirm-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-confirm-action')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('record-edit-save-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record-edit-save-action')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    final payload = repo.lastUpdateInput?.payload as Map<String, dynamic>?;
    final mealInput = payload?['mealInput'] as Map<String, dynamic>?;
    final dishes = mealInput?['recognizedDishes'] as List<dynamic>?;
    expect(dishes, [
      {'rawName': '番茄炒蛋'},
      {'rawName': '青菜'},
    ]);
    expect(payload?['mealAnalysis'], <String, dynamic>{
      'analysisStatus': 'confirmed',
    });
  });
}
