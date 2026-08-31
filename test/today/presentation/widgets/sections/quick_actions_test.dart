import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('TodayQuickActionsSection', () {
    testWidgets(
      'one-tap water action creates a record, emits dailyRecords, and shows toast',
      (tester) async {
        final repository = _FakeDailyRecordRepository();
        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            dailyRecordRepositoryProvider.overrideWithValue(repository),
            quickEntryPreferencesProvider.overrideWith(
              _FakeQuickEntryPreferencesController.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestForuiApp(
              showToaster: true,
              home: TodayQuickActionsSection(
                dashboard: _placeholderDashboard(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('去喝水'));
        await tester.pump();

        // Wait for the async create + toast to complete.
        await tester.pump(const Duration(milliseconds: 100));

        expect(repository.createdInputs, hasLength(1));
        final created = repository.createdInputs.single;
        expect(created.kind, DailyRecordKind.water);
        expect(created.value, '250');
        expect(created.unit, 'ml');
        expect(
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(created.occurredAt),
          isTrue,
        );
        expect(
          RegExp(r'^\d{2}:\d{2}$').hasMatch(created.occurredTime ?? ''),
          isTrue,
        );

        // DataChangeBus emitted dailyRecords.
        final busState = container.read(dataChangeBusProvider);
        expect(busState[DataChangeTopic.dailyRecords], isNotNull);
        expect(busState[DataChangeTopic.dailyRecords], greaterThan(0));

        // Toast with the saved message is visible.
        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        expect(find.text(l10n.recordQuickSavedToast), findsOneWidget);

        // Drain the toast timer so later tests start with clean Toast state.
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets('one-tap water action shows failure toast when create fails', (
      tester,
    ) async {
      final repository = _FailingDailyRecordRepository();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          dailyRecordRepositoryProvider.overrideWithValue(repository),
          quickEntryPreferencesProvider.overrideWith(
            _FakeQuickEntryPreferencesController.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestForuiApp(
            showToaster: true,
            home: TodayQuickActionsSection(dashboard: _placeholderDashboard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('去喝水'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.recordCreateFailedToast), findsOneWidget);

      // Drain the toast timer so later tests start with clean Toast state.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('signed-out user sees auth dialog when tapping water action', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestForuiApp(
            home: TodayQuickActionsSection(dashboard: _placeholderDashboard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('去喝水'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    });
  });
}

TodayDashboard _placeholderDashboard() {
  return const TodayDashboard(
    user: TodayUserSnapshot(
      moment: TodayDayMoment.morning,
      hasUnreadNotifications: false,
      updatedAtLabel: '--:--',
    ),
    water: TodayWaterSummary(completedCount: 0, targetCount: 8),
    medication: TodayMedicationSummary(
      medicineCount: 0,
      pendingCount: 0,
      nextDoseTimeLabel: '--:--',
    ),
    vitals: <TodayVitalSummary>[
      TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
    ],
    mealSuggestion: TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: TodayEnvironmentSummary(signals: <TodayEnvironmentSignal>[]),
    lumiSuggestion: TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  final List<DailyRecordCreateInput> createdInputs = [];

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) {
    createdInputs.add(input);
    return TaskEither.right(
      DailyRecordItem(
        id: 'water-test-1',
        kind: input.kind,
        occurredAt: input.occurredAt,
        occurredTime: input.occurredTime,
        createdAt: '2026-08-17T08:30:00Z',
        updatedAt: '2026-08-17T08:30:00Z',
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(const DailyRecordListData(items: [], total: 0));

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(const DailyRecordSummaryData(summaries: []));

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
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
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
}

class _FakeQuickEntryPreferencesController
    extends QuickEntryPreferencesController {
  @override
  Future<QuickEntryPreferences> build() async {
    return const QuickEntryPreferences();
  }
}

class _FailingDailyRecordRepository implements DailyRecordRepository {
  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => TaskEither.left(LucentFailure.unknown(message: 'create failed'));

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(const DailyRecordListData(items: [], total: 0));

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(const DailyRecordSummaryData(summaries: []));

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
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
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
}
