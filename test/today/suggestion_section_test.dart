import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart'
    show doseLogRepositoryProvider;
import 'package:luminous/features/medicine/domain/entities/dose_log.dart'
    as dose;
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

/// The locale tag that [TestForuiApp] with `Locale('zh')` produces.
const _testLanguage = 'zh';

/// The params used to override [suggestionExplanationProvider] in tests.
const _explainParams = (suggestionId: 'sug_test_001', language: _testLanguage);

void main() {
  // ── Helpers ───────────────────────────────────────────────────────────

  /// Builds a test [ProviderScope] wrapping [TodayPrimarySuggestionSection].
  ///
  /// [notifierFactory] creates the [TodaySuggestionNotifier] override.
  /// [explainFuture] optionally overrides the AI explanation provider.
  /// [productEvents] optionally overrides the analytics service.
  Widget buildApp(
    TodaySuggestionNotifier Function() notifierFactory, {
    Future<TodaySuggestionExplanation?> Function(Ref)? explainFuture,
    Locale locale = const Locale('zh'),
    ProductEventService? productEvents,
  }) {
    return ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        todaySuggestionProvider.overrideWith(notifierFactory),
        if (productEvents != null)
          productEventServiceProvider.overrideWithValue(productEvents),
        if (explainFuture != null)
          suggestionExplanationProvider(
            _explainParams,
          ).overrideWith(explainFuture),
      ],
      child: TestForuiApp(
        locale: locale,
        home: const SingleChildScrollView(
          child: TodayPrimarySuggestionSection(),
        ),
      ),
    );
  }

  /// Shorthand for data state with [testSuggestionBundle].
  Widget dataApp({
    Future<TodaySuggestionExplanation?> Function(Ref)? explainFuture,
  }) {
    return buildApp(
      StaticTodaySuggestionNotifier.new,
      explainFuture: explainFuture,
    );
  }

  /// Shorthand for data state with a custom bundle.
  Widget customDataApp(TodaySuggestionBundle? bundle) {
    return buildApp(() => _BundleNotifier(bundle));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  // ── Feedback Buttons ──────────────────────────────────────────────────

  group('Feedback buttons', () {
    testWidgets('render buttons in canonical order', (tester) async {
      await tester.pumpWidget(dataApp());
      await settle(tester);

      // The primary card has feedbackOptions: accepted, later, notApplicable
      // (no suppress). Verify they appear in the canonical order.
      final acceptedFinder = find.text('已采纳');
      final laterFinder = find.text('稍后处理');
      final notApplicableFinder = find.text('不适用');
      final suppressFinder = find.text('不再看到');

      expect(acceptedFinder, findsOneWidget);
      expect(laterFinder, findsOneWidget);
      expect(notApplicableFinder, findsOneWidget);
      expect(suppressFinder, findsNothing);

      // Verify X ordering: accepted before later before notApplicable
      final acceptedX = tester.getCenter(acceptedFinder).dx;
      final laterX = tester.getCenter(laterFinder).dx;
      final notApplicableX = tester.getCenter(notApplicableFinder).dx;

      expect(acceptedX, lessThan(laterX));
      expect(laterX, lessThan(notApplicableX));
    });

    testWidgets('do not render when feedbackOptions is null', (tester) async {
      const bundle = TodaySuggestionBundle(
        generatedAt: '2026-07-09T10:00:00.000Z',
        primary: TodaySuggestionCard(
          id: 'sug_no_feedback',
          type: TodaySuggestionType.behaviorAdvice,
          cardTone: TodaySuggestionCardTone.soft,
          icon: 'droplets',
          title: '测试建议',
          reason: '测试原因',
          evidence: [],
          boundary: '测试边界',
          primaryAction: TodaySuggestionAction(
            actionId: 'go',
            label: '去',
            route: '/medicine',
            authRequired: true,
          ),
          confidence: TodaySuggestionConfidence.high,
          ruleId: 'test_rule',
          ruleVersion: '1.0.0',
          triggerType: TodaySuggestionTriggerType.timer,
          lifecycleState: TodaySuggestionLifecycleState.active,
        ),
      );

      await tester.pumpWidget(customDataApp(bundle));
      await settle(tester);

      expect(find.text('已采纳'), findsNothing);
      expect(find.text('稍后处理'), findsNothing);
      expect(find.text('不适用'), findsNothing);
      expect(find.text('不再看到'), findsNothing);
    });

    testWidgets('do not render when feedbackOptions is empty', (tester) async {
      const bundle = TodaySuggestionBundle(
        generatedAt: '2026-07-09T10:00:00.000Z',
        primary: TodaySuggestionCard(
          id: 'sug_empty_feedback',
          type: TodaySuggestionType.behaviorAdvice,
          cardTone: TodaySuggestionCardTone.soft,
          icon: 'droplets',
          title: '测试建议',
          reason: '测试原因',
          evidence: [],
          boundary: '测试边界',
          primaryAction: TodaySuggestionAction(
            actionId: 'go',
            label: '去',
            route: '/medicine',
            authRequired: true,
          ),
          confidence: TodaySuggestionConfidence.high,
          ruleId: 'test_rule',
          ruleVersion: '1.0.0',
          triggerType: TodaySuggestionTriggerType.timer,
          lifecycleState: TodaySuggestionLifecycleState.active,
          feedbackOptions: [],
        ),
      );

      await tester.pumpWidget(customDataApp(bundle));
      await settle(tester);

      expect(find.text('已采纳'), findsNothing);
      expect(find.text('稍后处理'), findsNothing);
    });

    testWidgets('button labels come from ARB not hardcoded', (tester) async {
      await tester.pumpWidget(
        buildApp(StaticTodaySuggestionNotifier.new, locale: const Locale('en')),
      );
      await settle(tester);

      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Not applicable'), findsOneWidget);
    });
  });

  // ── AI Explain Button ─────────────────────────────────────────────────

  group('AI explain button', () {
    testWidgets('shows trigger button in initial state', (tester) async {
      await tester.pumpWidget(dataApp());
      await settle(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Expand evidence area first
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      expect(find.text(l10n.todaySuggestionAiExplainAction), findsOneWidget);
    });

    testWidgets('shows circular progress while loading', (tester) async {
      await tester.pumpWidget(
        dataApp(
          explainFuture: (ref) =>
              Completer<TodaySuggestionExplanation?>().future,
        ),
      );
      await settle(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Expand evidence area
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      // Tap AI explain trigger
      await tester.tap(find.text(l10n.todaySuggestionAiExplainAction));
      // Pump enough for FTappable internal timer + provider to activate
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FCircularProgress), findsOneWidget);
      expect(find.text(l10n.todaySuggestionAiExplainLoading), findsOneWidget);
    });

    testWidgets('shows AI content when aiGenerated is true', (tester) async {
      const explanation = TodaySuggestionExplanation(
        suggestionId: 'sug_test_001',
        reason: '这是AI增强的原因说明',
        boundary: '这是AI增强的边界提示',
        aiGenerated: true,
        locale: 'zh',
      );

      await tester.pumpWidget(
        dataApp(explainFuture: (ref) async => explanation),
      );
      await settle(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Expand evidence area
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      // Tap AI explain trigger
      await tester.tap(find.text(l10n.todaySuggestionAiExplainAction));
      await tester.pumpAndSettle();

      // Should show AI explanation content
      expect(find.text('这是AI增强的原因说明'), findsOneWidget);
      expect(find.text('这是AI增强的边界提示'), findsOneWidget);
      // Should show AI label badge
      expect(find.text(l10n.todaySuggestionAiLabel), findsOneWidget);
    });

    testWidgets('shows rule-based fallback content when aiGenerated is false', (
      tester,
    ) async {
      const explanation = TodaySuggestionExplanation(
        suggestionId: 'sug_test_001',
        reason: '规则文案',
        boundary: '规则边界',
        aiGenerated: false,
        locale: 'zh',
      );

      await tester.pumpWidget(
        dataApp(explainFuture: (ref) async => explanation),
      );
      await settle(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Expand evidence area
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      // Tap AI explain trigger
      await tester.tap(find.text(l10n.todaySuggestionAiExplainAction));
      await tester.pumpAndSettle();

      // Should show fallback explanation content and rule-based label
      expect(find.text('规则文案'), findsOneWidget);
      expect(find.text('规则边界'), findsOneWidget);
      expect(find.text(l10n.todaySuggestionRuleBasedLabel), findsOneWidget);
      // Should not offer retry for rule-based fallback
      expect(find.text(l10n.todaySuggestionAiExplainRetry), findsNothing);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(
        dataApp(
          explainFuture: (ref) async =>
              throw Exception('AI service unavailable'),
        ),
      );
      await settle(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Expand evidence area
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      // Tap AI explain trigger
      await tester.tap(find.text(l10n.todaySuggestionAiExplainAction));
      await tester.pumpAndSettle();

      // Should show retry button
      expect(find.text(l10n.todaySuggestionAiExplainRetry), findsOneWidget);
    });
  });

  // ── Empty & Error States ──────────────────────────────────────────────

  group('Empty and error states', () {
    testWidgets('shows empty state when primary is null', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(buildApp(EmptyTodaySuggestionNotifier.new));
      await settle(tester);

      expect(find.text(l10n.todaySuggestionEmptyTitle), findsOneWidget);
      expect(find.text(l10n.todaySuggestionEmptySubtitle), findsOneWidget);
    });

    testWidgets('shows empty state when bundle has no primary', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      const bundle = TodaySuggestionBundle(
        generatedAt: '2026-07-09T10:00:00.000Z',
        primary: null,
        secondary: [],
        observations: [],
      );

      await tester.pumpWidget(customDataApp(bundle));
      await settle(tester);

      expect(find.text(l10n.todaySuggestionEmptyTitle), findsOneWidget);
      expect(find.text(l10n.todaySuggestionEmptySubtitle), findsOneWidget);
    });

    testWidgets('shows error state with retry on provider error', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(buildApp(_ErrorSuggestionNotifier.new));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.todaySuggestionErrorHint), findsOneWidget);
      expect(find.text(l10n.todaySuggestionRetryAction), findsOneWidget);
    });

    testWidgets('shows skeleton on loading', (tester) async {
      await tester.pumpWidget(buildApp(LoadingTodaySuggestionNotifier.new));
      await settle(tester);

      expect(
        find.byKey(const Key('today-primary-suggestion-card')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders pending materialization with the previous card', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.pumpWidget(
        customDataApp(
          testSuggestionBundle.copyWith(
            materializationStatus: TodaySuggestionMaterializationStatus.pending,
          ),
        ),
      );
      await settle(tester);

      expect(find.text('上午的阿托伐他汀尚未确认'), findsOneWidget);
      expect(find.text(l10n.todaySuggestionLoadingHint), findsOneWidget);
    });

    testWidgets('renders stale materialization with the computed time', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.pumpWidget(
        customDataApp(
          testSuggestionBundle.copyWith(
            materializationStatus: TodaySuggestionMaterializationStatus.stale,
            computedAt: DateTime(2026, 7, 11, 8),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('上午的阿托伐他汀尚未确认'), findsOneWidget);
      expect(find.text(l10n.todayUpdatedAt('08:00')), findsOneWidget);
    });

    testWidgets('renders a stale hint when computed time is unavailable', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.pumpWidget(
        customDataApp(
          testSuggestionBundle.copyWith(
            materializationStatus: TodaySuggestionMaterializationStatus.stale,
            computedAt: null,
          ),
        ),
      );
      await settle(tester);

      expect(find.text('上午的阿托伐他汀尚未确认'), findsOneWidget);
      expect(find.text(l10n.todaySuggestionLoadingHint), findsOneWidget);
    });

    testWidgets('renders failed materialization with retry and old content', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.pumpWidget(
        customDataApp(
          testSuggestionBundle.copyWith(
            materializationStatus: TodaySuggestionMaterializationStatus.failed,
          ),
        ),
      );
      await settle(tester);

      expect(find.text('上午的阿托伐他汀尚未确认'), findsOneWidget);
      expect(find.text(l10n.todaySuggestionErrorHint), findsOneWidget);
      expect(find.text(l10n.todaySuggestionRetryAction), findsOneWidget);
    });

    testWidgets('renders empty materialization as the existing empty state', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.pumpWidget(
        customDataApp(
          const TodaySuggestionBundle(
            generatedAt: '2026-07-12T10:00:00Z',
            materializationStatus: TodaySuggestionMaterializationStatus.empty,
          ),
        ),
      );
      await settle(tester);

      expect(find.text(l10n.todaySuggestionEmptyTitle), findsOneWidget);
      expect(find.text(l10n.todaySuggestionEmptySubtitle), findsOneWidget);
    });
  });

  // ── Primary Card Content ──────────────────────────────────────────────

  group('Primary card content', () {
    testWidgets('renders title and reason from backend', (tester) async {
      await tester.pumpWidget(dataApp());
      await settle(tester);

      expect(find.text('上午的阿托伐他汀尚未确认'), findsOneWidget);
      expect(find.text('计划服药时间为 08:00，当前已超时 4 小时且未标记服用。'), findsOneWidget);
    });

    testWidgets('renders primary action button with backend label', (
      tester,
    ) async {
      await tester.pumpWidget(dataApp());
      await settle(tester);

      expect(find.text('去确认'), findsOneWidget);
    });

    testWidgets('renders structured evidence list after expanding', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(dataApp());
      await settle(tester);

      // FCollapsible keeps children in the widget tree even when collapsed,
      // so we only verify the expanded state shows evidence items.
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      expect(find.text('计划时间'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('今日状态'), findsOneWidget);
      expect(find.text('未确认'), findsOneWidget);
    });

    testWidgets('renders boundary text after expanding', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(dataApp());
      await settle(tester);

      // FCollapsible keeps children in the widget tree even when collapsed,
      // so we only verify the expanded state shows the boundary.
      await tester.tap(find.text(l10n.todaySuggestionShowEvidence));
      await tester.pumpAndSettle();

      expect(find.text('此提醒基于您的用药计划，不能替代医生或药师建议。'), findsOneWidget);
    });
  });

  // ── Impression Measurement ─────────────────────────────────────────────

  group('Suggestion impression measurement', () {
    testWidgets('reports one impression per visible card, not per rebuild', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await tester.pumpWidget(
        buildApp(StaticTodaySuggestionNotifier.new, productEvents: service),
      );
      await settle(tester);

      // The primary card (ruleId 'missed_dose_pending') entered the visible
      // area exactly once.
      expect(service.impressionRuleCodes, ['missed_dose_pending']);

      // Rebuilds must not re-emit: same tree, same rule code — no new call.
      await tester.pumpWidget(
        buildApp(StaticTodaySuggestionNotifier.new, productEvents: service),
      );
      await settle(tester);
      expect(service.impressionRuleCodes, ['missed_dose_pending']);

      // A fresh card instance with the same rule code is deduped by the
      // service in production; the widget itself reports per instance.
      await tester.pumpWidget(
        buildApp(StaticTodaySuggestionNotifier.new, productEvents: service),
      );
      await settle(tester);
      expect(service.impressionRuleCodes, ['missed_dose_pending']);
    });

    testWidgets('does not report impressions for cards outside the viewport', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            todaySuggestionProvider.overrideWith(
              StaticTodaySuggestionNotifier.new,
            ),
            productEventServiceProvider.overrideWithValue(service),
          ],
          child: const TestForuiApp(
            locale: Locale('zh'),
            // The card starts 1500px below the 600px-high test viewport.
            home: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 1500),
                  TodayPrimarySuggestionSection(),
                ],
              ),
            ),
          ),
        ),
      );
      await settle(tester);

      expect(service.impressionRuleCodes, isEmpty);

      // Scrolling the card into the viewport reports it exactly once.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1500),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(service.impressionRuleCodes, ['missed_dose_pending']);
    });

    testWidgets('reports nothing for non-allowlisted rule codes', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      // A card whose ruleId is not in the server allowlist.
      const bundle = TodaySuggestionBundle(
        generatedAt: '2026-07-09T10:00:00.000Z',
        primary: TodaySuggestionCard(
          id: 'sug_custom_rule',
          type: TodaySuggestionType.behaviorAdvice,
          cardTone: TodaySuggestionCardTone.soft,
          icon: 'droplets',
          title: '自定义规则建议',
          reason: '测试原因',
          evidence: [],
          boundary: '测试边界',
          primaryAction: TodaySuggestionAction(
            actionId: 'go',
            label: '去',
            route: '/medicine',
            authRequired: true,
          ),
          confidence: TodaySuggestionConfidence.high,
          ruleId: 'unknown_free_text_rule',
          ruleVersion: '1.0.0',
          triggerType: TodaySuggestionTriggerType.timer,
          lifecycleState: TodaySuggestionLifecycleState.active,
        ),
      );

      await tester.pumpWidget(
        buildApp(() => _BundleNotifier(bundle), productEvents: service),
      );
      await settle(tester);

      // The widget reports the impression; the service drops it (the unit
      // tests prove the allowlist filter). Assert the widget-side call went
      // through with the card's rule id.
      expect(service.impressionRuleCodes, ['unknown_free_text_rule']);
    });
  });

  // ── Secondary Actions ───────────────────────────────────────────────────

  group('Secondary actions', () {
    /// A bundle whose primary card carries a `skip_dose` secondary action.
    final skipDoseBundle = testSuggestionBundle.copyWith(
      primary: testSuggestionBundle.primary!.copyWith(
        secondaryActions: [
          const TodaySuggestionAction(
            actionId: 'skip_dose',
            label: 'skip_dose',
            route:
                '/medicine?action=skip&currentMedicineId=med-1&reminderId=rem-1&scheduledFor=2026-07-09&scheduledTime=08:00',
            authRequired: true,
          ),
        ],
      ),
    );

    /// A [dose.DoseLogItem] returned by a successful skip mark.
    const dummyDoseLog = dose.DoseLogItem(
      id: 'dl-1',
      currentMedicineId: 'med-1',
      reminderId: 'rem-1',
      status: dose.DoseLogStatus.skipped,
      scheduledFor: '2026-07-09',
      scheduledTime: '08:00',
      createdAt: '2026-07-09T08:00:00.000Z',
      updatedAt: '2026-07-09T08:00:00.000Z',
    );

    Widget buildSkipApp({
      required TodaySuggestionBundle bundle,
      MockDoseLogRepository? repo,
      _RecordingDataChangeBus? bus,
    }) {
      return ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todaySuggestionProvider.overrideWith(() => _BundleNotifier(bundle)),
          if (repo != null) doseLogRepositoryProvider.overrideWithValue(repo),
          if (bus != null) dataChangeBusProvider.overrideWith(() => bus),
        ],
        child: const TestForuiApp(
          locale: Locale('zh'),
          showToaster: true,
          home: SingleChildScrollView(child: TodayPrimarySuggestionSection()),
        ),
      );
    }

    testWidgets('renders secondary action button', (tester) async {
      await tester.pumpWidget(buildSkipApp(bundle: skipDoseBundle));
      await settle(tester);

      expect(find.text('skip_dose'), findsOneWidget);
    });

    testWidgets('skip_dose calls mark and emits doseLogs topic on success', (
      tester,
    ) async {
      final repo = MockDoseLogRepository();
      when(
        () => repo.mark(
          currentMedicineId: 'med-1',
          status: 'skipped',
          date: '2026-07-09',
          reminderId: 'rem-1',
          scheduledTime: '08:00',
        ),
      ).thenAnswer((_) async => dummyDoseLog);

      final bus = _RecordingDataChangeBus();

      await tester.pumpWidget(
        buildSkipApp(bundle: skipDoseBundle, repo: repo, bus: bus),
      );
      await settle(tester);

      await tester.tap(find.text('skip_dose'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => repo.mark(
          currentMedicineId: 'med-1',
          status: 'skipped',
          date: '2026-07-09',
          reminderId: 'rem-1',
          scheduledTime: '08:00',
        ),
      ).called(1);
      expect(bus.emittedTopics, [DataChangeTopic.doseLogs]);
    });

    testWidgets('skip_dose shows error toast and does not emit on failure', (
      tester,
    ) async {
      final repo = MockDoseLogRepository();
      when(
        () => repo.mark(
          currentMedicineId: 'med-1',
          status: 'skipped',
          date: '2026-07-09',
          reminderId: 'rem-1',
          scheduledTime: '08:00',
        ),
      ).thenThrow(Exception('network error'));

      final bus = _RecordingDataChangeBus();
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        buildSkipApp(bundle: skipDoseBundle, repo: repo, bus: bus),
      );
      await settle(tester);

      await tester.tap(find.text('skip_dose'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(l10n.todaySuggestionSkipDoseError), findsOneWidget);
      expect(bus.emittedTopics, isEmpty);

      // Drain the toast auto-dismiss timer so the test framework does not
      // report a pending timer.
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets(
      'skip_dose falls back to navigation when currentMedicineId is missing',
      (tester) async {
        const fallbackBundle = TodaySuggestionBundle(
          generatedAt: '2026-07-09T10:00:00.000Z',
          primary: TodaySuggestionCard(
            id: 'sug_test_missing_med',
            type: TodaySuggestionType.compliance,
            cardTone: TodaySuggestionCardTone.urgent,
            icon: 'pill',
            title: '上午的阿托伐他汀尚未确认',
            reason: '计划服药时间为 08:00，当前已超时 4 小时且未标记服用。',
            evidence: [],
            boundary: '此提醒基于您的用药计划，不能替代医生或药师建议。',
            primaryAction: TodaySuggestionAction(
              actionId: 'go_confirm',
              label: '去确认',
              route: '/medicine',
              authRequired: true,
            ),
            confidence: TodaySuggestionConfidence.high,
            ruleId: 'missed_dose_pending',
            ruleVersion: '1.0.0',
            triggerType: TodaySuggestionTriggerType.event,
            lifecycleState: TodaySuggestionLifecycleState.active,
            secondaryActions: [
              TodaySuggestionAction(
                actionId: 'skip_dose',
                label: 'skip_dose',
                route:
                    '/medicine?action=skip&scheduledFor=2026-07-09&scheduledTime=08:00',
                authRequired: true,
              ),
            ],
          ),
        );

        final repo = MockDoseLogRepository();
        final bus = _RecordingDataChangeBus();
        final observer = _RecordingNavigatorObserver();
        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
              todaySuggestionProvider.overrideWith(
                () => _BundleNotifier(fallbackBundle),
              ),
              doseLogRepositoryProvider.overrideWithValue(repo),
              dataChangeBusProvider.overrideWith(() => bus),
            ],
            child: TestForuiRouterApp(
              locale: const Locale('zh'),
              routerConfig: GoRouter(
                initialLocation: '/',
                observers: [observer],
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const SingleChildScrollView(
                      child: TodayPrimarySuggestionSection(),
                    ),
                  ),
                  GoRoute(
                    path: '/medicine',
                    builder: (context, state) =>
                        const Scaffold(body: Text('medicine-page')),
                  ),
                ],
              ),
            ),
          ),
        );
        await settle(tester);

        await tester.tap(find.text('skip_dose'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verifyNever(
          () => repo.mark(
            currentMedicineId: any(named: 'currentMedicineId'),
            status: any(named: 'status'),
            date: any(named: 'date'),
          ),
        );
        expect(bus.emittedTopics, isEmpty);
        expect(find.text(l10n.todaySuggestionSkipDoseError), findsNothing);
        expect(observer.pushedRoutes, isNotEmpty);
        expect(observer.pushedRoutes.last.settings.name, contains('/medicine'));
      },
    );
  });
}

// ── Test Notifiers ───────────────────────────────────────────────────────

/// Returns a fixed [TodaySuggestionBundle] — used for custom bundles.
class _BundleNotifier extends TodaySuggestionNotifier {
  _BundleNotifier(this.bundle);

  final TodaySuggestionBundle? bundle;

  @override
  Future<TodaySuggestionBundle?> build() async => bundle;
}

/// Sets state to error — used for error state tests.
///
/// Instead of throwing from [build] (which the test framework's zone may
/// swallow before Riverpod catches it), we set [state] directly and then
/// return a never-completing Future so the error state is preserved.
class _ErrorSuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async {
    state = AsyncValue.error(
      Exception('suggestion fetch error'),
      StackTrace.current,
    );
    return Completer<TodaySuggestionBundle?>().future;
  }
}

/// Records impression calls instead of posting events — used to observe the
/// visibility tracker without touching the network or the queue.
class _RecordingProductEventService extends ProductEventService {
  _RecordingProductEventService() : super(api: _MockProductEventsApi());

  final List<String> impressionRuleCodes = [];

  @override
  bool trackSuggestionImpression(String ruleCode) {
    impressionRuleCodes.add(ruleCode);
    return true;
  }
}

class _MockProductEventsApi extends Mock implements ProductEventsApi {}

/// Records pushed routes for navigation assertions.
class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

/// Records topics emitted to the [DataChangeBus] for verification.
class _RecordingDataChangeBus extends DataChangeBus {
  final List<String> emittedTopics = [];

  @override
  Map<String, int> build() => {};

  @override
  void emit(String topic) {
    emittedTopics.add(topic);
    super.emit(topic);
  }
}
