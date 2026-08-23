import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/data/repositories/lucent_ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/repositories/ai.dart';
import 'package:luminous/features/today/presentation/pages/page.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

void main() {
  testWidgets(
    'Today summary shows preview hint and hides refresh action when signed out',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
            todayRepositoryProvider.overrideWithValue(
              const MockTodayRepository(),
            ),
            todaySuggestionProvider.overrideWith(
              EmptyTodaySuggestionNotifier.new,
            ),
          ],
          child: const TestForuiApp(home: TodayPage()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await _scrollToSummaryCard(tester);
      await _expandAiBullets(tester, l10n);

      expect(find.text(l10n.todayAiSummaryPreviewHint), findsOneWidget);
      expect(
        find.widgetWithText(FButton, l10n.todayAnalysisRefreshAction),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Today summary shows settings action when AI summaries are disabled',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            todayRepositoryProvider.overrideWithValue(
              const MockTodayRepository(),
            ),
            userSettingsControllerProvider.overrideWith(
              DisabledUserSettingsController.new,
            ),
            todaySuggestionProvider.overrideWith(
              EmptyTodaySuggestionNotifier.new,
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: const TestForuiApp(home: TodayPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await _scrollToSummaryCard(tester);
      await _expandAiBullets(tester, l10n);

      expect(find.text(l10n.todayAiSummaryDisabledHint), findsOneWidget);
      expect(
        find.widgetWithText(FButton, l10n.todayAiSummaryOpenSettingsAction),
        findsOneWidget,
      );
    },
  );

  testWidgets('Today summary renders empty analysis state', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(
            _StaticTodayAiRepository(
              TodayAiAnalysis(
                date: '2026-06-12',
                generatedAt: generatedAt,
                summary: '',
                bullets: [],
                actionLabel: '',
                confidenceNote: '',
                materializationStatus:
                    TodayAiAnalysisMaterializationStatus.empty,
                aiGenerated: false,
              ),
            ),
          ),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    expect(find.text(l10n.todayAnalysisEmptyTitle), findsOneWidget);
    expect(find.text(l10n.todayAnalysisEmptyBody), findsOneWidget);
    expect(
      find.widgetWithText(FButton, l10n.todayAnalysisRefreshAction),
      findsOneWidget,
    );
  });

  testWidgets('Today summary renders refresh button and rule-based label', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(
            _StaticTodayAiRepository(
              TodayAiAnalysis(
                date: '2026-06-12',
                generatedAt: generatedAt,
                summary: '今天的节奏基本稳定。',
                bullets: [],
                actionLabel: '',
                confidenceNote: '基于规则生成。',
                materializationStatus:
                    TodayAiAnalysisMaterializationStatus.ready,
                aiGenerated: false,
              ),
            ),
          ),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    expect(find.text('今天的节奏基本稳定。'), findsOneWidget);
    expect(find.text(l10n.todayAnalysisRuleBasedLabel), findsOneWidget);
    expect(
      find.widgetWithText(FButton, l10n.todayAnalysisRefreshAction),
      findsOneWidget,
    );
  });

  testWidgets('Today summary shows materialization notice for pending state', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(
            _StaticTodayAiRepository(
              TodayAiAnalysis(
                date: '2026-06-12',
                generatedAt: generatedAt,
                summary: 'Original summary.',
                bullets: [],
                actionLabel: '',
                confidenceNote: '',
                materializationStatus:
                    TodayAiAnalysisMaterializationStatus.pending,
                aiGenerated: true,
              ),
            ),
          ),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    expect(find.text('Original summary.'), findsOneWidget);
    expect(find.text(l10n.todayAnalysisPendingHint), findsOneWidget);
  });

  testWidgets('Today summary shows materialization notice for failed state', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(
            _StaticTodayAiRepository(
              TodayAiAnalysis(
                date: '2026-06-12',
                generatedAt: generatedAt,
                summary: 'Original summary.',
                bullets: [],
                actionLabel: '',
                confidenceNote: '',
                materializationStatus:
                    TodayAiAnalysisMaterializationStatus.failed,
                aiGenerated: true,
              ),
            ),
          ),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    expect(find.text('Original summary.'), findsOneWidget);
    expect(find.text(l10n.todayAnalysisFailedHint), findsOneWidget);
  });

  testWidgets('Today summary triggers refresh on button tap', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final repository = _TappableTodayAiRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    final refreshButton = find.widgetWithText(
      FButton,
      l10n.todayAnalysisRefreshAction,
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      refreshButton,
      220,
      scrollable: find
          .descendant(
            of: find.byKey(
              const PageStorageKey<String>('today-dashboard-scroll'),
            ),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.refreshCount, 0);
    await tester.tap(refreshButton);
    await tester.pump(const Duration(milliseconds: 500));
    expect(repository.refreshCount, 1);
  });
}

Future<void> _scrollToSummaryCard(WidgetTester tester) async {
  await tester.pump();
  await tester.scrollUntilVisible(
    find.byKey(const Key('today-summary-card')),
    220,
    scrollable: find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('today-dashboard-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _expandAiBullets(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  final expandButton = find.text(l10n.todaySuggestionShowEvidence);
  await tester.scrollUntilVisible(
    expandButton,
    220,
    scrollable: find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('today-dashboard-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(expandButton);
  await tester.pump(const Duration(milliseconds: 300));
}

class _StaticTodayAiRepository implements TodayAiRepository {
  _StaticTodayAiRepository(this.analysis);

  final TodayAiAnalysis analysis;

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> read(DateTime date) =>
      TaskEither.right(analysis);

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> refresh(DateTime date) =>
      TaskEither.right(analysis);

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> generate({String? date}) =>
      TaskEither.right(analysis);

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    yield TodayAiGenerationResultEvent(analysis);
  }
}

class _TappableTodayAiRepository implements TodayAiRepository {
  int refreshCount = 0;

  TodayAiAnalysis get _analysis => TodayAiAnalysis(
    date: '2026-06-12',
    generatedAt: generatedAt,
    summary: 'Summary.',
    bullets: const [],
    actionLabel: '',
    confidenceNote: '',
    materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
    aiGenerated: true,
  );

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> read(DateTime date) =>
      TaskEither.right(_analysis);

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> refresh(DateTime date) {
    refreshCount++;
    return TaskEither.right(_analysis);
  }

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> generate({String? date}) =>
      TaskEither.right(_analysis);

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    yield TodayAiGenerationResultEvent(_analysis);
  }
}
