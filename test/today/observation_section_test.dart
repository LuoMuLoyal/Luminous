import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

/// A dashboard with no meaningful sleep value, triggering the fallback
/// observation.
const _noSleepDashboard = TodayDashboard(
  user: TodayUserSnapshot(
    moment: TodayDayMoment.morning,
    hasUnreadNotifications: false,
    updatedAtLabel: '--:--',
  ),
  water: TodayWaterSummary(completedCount: 3, targetCount: 8),
  medication: TodayMedicationSummary(
    medicineCount: 2,
    pendingCount: 1,
    nextDoseTimeLabel: '--',
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

/// A dashboard with meaningful sleep value, so the fallback won't trigger.
const _hasSleepDashboard = TodayDashboard(
  user: TodayUserSnapshot(
    moment: TodayDayMoment.morning,
    hasUnreadNotifications: false,
    updatedAtLabel: '--:--',
  ),
  water: TodayWaterSummary(completedCount: 3, targetCount: 8),
  medication: TodayMedicationSummary(
    medicineCount: 2,
    pendingCount: 1,
    nextDoseTimeLabel: '--',
  ),
  vitals: <TodayVitalSummary>[
    TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7.5h'),
  ],
  mealSuggestion: TodayMealSuggestion(
    type: TodayMealSuggestionType.highProteinBalancedLunch,
  ),
  environment: TodayEnvironmentSummary(signals: <TodayEnvironmentSignal>[]),
  lumiSuggestion: TodayLumiSuggestion(
    type: TodayLumiSuggestionType.pollenProtection,
  ),
);

/// A suggestion bundle with only an observation card.
const _observationBundle = TodaySuggestionBundle(
  generatedAt: '2026-07-09T10:00:00.000Z',
  observations: [
    TodaySuggestionCard(
      id: 'sug_obs_001',
      type: TodaySuggestionType.coverage,
      cardTone: TodaySuggestionCardTone.neutral,
      icon: 'info',
      title: '睡眠数据不足，暂无法生成睡眠趋势建议',
      reason: '需要至少 3 天连续睡眠记录才能建立基线。',
      evidence: [],
      boundary: '记录越多，建议越精准。',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record_sleep',
        label: '记录睡眠',
        route: '/record/create?kind=sleep',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.high,
      ruleId: 'coverage_explanation',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
      feedbackOptions: [TodaySuggestionFeedback.suppress],
    ),
  ],
);

/// A suggestion bundle with an observation card that has no feedback options.
const _observationBundleNoFeedback = TodaySuggestionBundle(
  generatedAt: '2026-07-09T10:00:00.000Z',
  observations: [
    TodaySuggestionCard(
      id: 'sug_obs_002',
      type: TodaySuggestionType.coverage,
      cardTone: TodaySuggestionCardTone.neutral,
      icon: 'info',
      title: '睡眠数据不足，暂无法生成睡眠趋势建议',
      reason: '需要至少 3 天连续睡眠记录才能建立基线。',
      evidence: [],
      boundary: '记录越多，建议越精准。',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record_sleep',
        label: '记录睡眠',
        route: '/record/create?kind=sleep',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.high,
      ruleId: 'coverage_explanation',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
    ),
  ],
);

/// A suggestion bundle with no observations.
const _emptyObservationsBundle = TodaySuggestionBundle(
  generatedAt: '2026-07-09T10:00:00.000Z',
);

void main() {
  Widget buildApp({
    required TodaySuggestionNotifier Function() notifierFactory,
    required TodayDashboard dashboard,
  }) {
    return ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        todaySuggestionProvider.overrideWith(notifierFactory),
      ],
      child: TestForuiApp(
        home: SingleChildScrollView(
          child: TodayObservationSection(dashboard: dashboard),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('Observation section', () {
    testWidgets('renders observation cards from suggestion provider', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ObservationBundleNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      // The observation card from the backend should be visible
      expect(find.text('睡眠数据不足，暂无法生成睡眠趋势建议'), findsOneWidget);
      expect(find.text('需要至少 3 天连续睡眠记录才能建立基线。'), findsOneWidget);
      expect(find.byKey(const Key('today-observation-card')), findsOneWidget);
    });

    testWidgets('shows fallback sleep observation when no sleep data', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _EmptyObservationsNotifier.new,
          dashboard: _noSleepDashboard,
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todayObservationSleepMissingTitle), findsOneWidget);
      expect(
        find.text(l10n.todayObservationSleepMissingSubtitle),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when no observations and no fallback', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _EmptyObservationsNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todayObservationEmptyState), findsOneWidget);
    });

    testWidgets('shows loading skeleton while provider is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          notifierFactory: LoadingTodaySuggestionNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      // Should not show observation card content
      expect(find.byKey(const Key('today-observation-card')), findsOneWidget);
      // Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows error state with retry on provider error', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ErrorSuggestionNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.todayObservationErrorTitle), findsOneWidget);
      expect(find.text(l10n.todayRetryAction), findsOneWidget);
    });

    testWidgets('hides spinner while loading', (tester) async {
      await tester.pumpWidget(
        buildApp(
          notifierFactory: LoadingTodaySuggestionNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      final observationCard = find.byKey(const Key('today-observation-card'));
      expect(
        find.descendant(
          of: observationCard,
          matching: find.byType(FCircularProgress),
        ),
        findsNothing,
      );
    });

    testWidgets('combines fallback + backend observations', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ObservationBundleNotifier.new,
          dashboard: _noSleepDashboard,
        ),
      );
      await settle(tester);

      // Should show both the fallback sleep observation and the backend
      // observation card
      expect(find.text(l10n.todayObservationSleepMissingTitle), findsOneWidget);
      expect(find.text('睡眠数据不足，暂无法生成睡眠趋势建议'), findsOneWidget);
    });

    testWidgets('confidence tag maps to localized text', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ObservationBundleNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      // The observation card has confidence.high, which maps to the review tag
      expect(find.text(l10n.todayObservationReviewTag), findsOneWidget);
    });

    testWidgets('renders suppress feedback button for observation cards', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ObservationBundleNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todaySuggestionSuppressAction), findsOneWidget);
    });

    testWidgets('does not render feedback button when options are absent', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _ObservationBundleNoFeedbackNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todaySuggestionSuppressAction), findsNothing);
    });

    testWidgets('does not render feedback button for fallback observations', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _EmptyObservationsNotifier.new,
          dashboard: _noSleepDashboard,
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todaySuggestionSuppressAction), findsNothing);
    });

    testWidgets('enters submitted state after tapping suppress', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildApp(
          notifierFactory: _FeedbackEnabledObservationNotifier.new,
          dashboard: _hasSleepDashboard,
        ),
      );
      await settle(tester);

      await tester.tap(find.text(l10n.todaySuggestionSuppressAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(l10n.todaySuggestionFeedbackSubmitted), findsOneWidget);
    });
  });
}

// ── Test Notifiers ───────────────────────────────────────────────────────

class _ObservationBundleNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => _observationBundle;
}

class _ObservationBundleNoFeedbackNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => _observationBundleNoFeedback;
}

class _EmptyObservationsNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => _emptyObservationsBundle;
}

class _FeedbackEnabledObservationNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => _observationBundle;

  @override
  Future<void> submitFeedback({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
  }) async {
    // no-op success for testing feedback UI transitions
  }
}

class _ErrorSuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async {
    state = AsyncValue.error(
      Exception('observation fetch error'),
      StackTrace.current,
    );
    return Completer<TodaySuggestionBundle?>().future;
  }
}
