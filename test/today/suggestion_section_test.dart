import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
  Widget buildApp(
    TodaySuggestionNotifier Function() notifierFactory, {
    Future<TodaySuggestionExplanation?> Function(Ref)? explainFuture,
    Locale locale = const Locale('zh'),
  }) {
    return ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        todaySuggestionProvider.overrideWith(notifierFactory),
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

    testWidgets('shows trigger button again when aiGenerated is false', (
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

      // Should NOT show AI content, should show trigger button again
      expect(find.text('规则文案'), findsNothing);
      expect(find.text(l10n.todaySuggestionAiExplainAction), findsOneWidget);
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
