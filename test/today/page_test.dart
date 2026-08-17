import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/pages/page.dart';
import 'package:luminous/features/today/presentation/providers/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/today/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

class _EmptyActiveHealthEventNotifier extends ActiveHealthEvent {
  @override
  Future<HealthEvent?> build() async => null;
}

class _TrackingActiveHealthEventNotifier extends ActiveHealthEvent {
  static int refreshCalls = 0;
  static int buildCalls = 0;

  @override
  Future<HealthEvent?> build() async {
    buildCalls++;
    return null;
  }

  @override
  Future<void> refresh() {
    refreshCalls++;
    return super.refresh();
  }
}

void main() {
  testWidgets(
    'Today page prioritizes primary suggestion above summary on mobile',
    (tester) async {
      _setMobileViewport(tester);

      await tester.pumpWidget(_signedInTodayApp());
      await _settleDashboard(tester);

      final primarySuggestionTop = tester.getTopLeft(
        find.byKey(const Key('today-primary-suggestion-card')),
      );
      final summaryTop = tester.getTopLeft(
        find.byKey(const Key('today-summary-card')),
      );

      expect(primarySuggestionTop.dy, lessThan(summaryTop.dy));
    },
  );

  testWidgets('Today page renders action-first mobile dashboard sections', (
    tester,
  ) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(_signedInTodayApp());
    await _settleDashboard(tester);

    expect(
      find.byKey(const Key('today-primary-suggestion-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-secondary-suggestions-card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

    for (final key in [
      'today-observation-card',
      'today-quick-actions-primary',
    ]) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        220,
        scrollable: _todayDashboardScrollable(),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(Key(key)), findsOneWidget);
    }
  });

  testWidgets('Today loading shows dedicated skeleton placeholder', (
    tester,
  ) async {
    _setMobileViewport(tester);
    final pending = Completer<TodayDashboard>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) => pending.future),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump();

    expect(find.byType(TodaySkeletonView), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('today-health-event-skeleton')),
      220,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.byKey(const Key('today-health-event-skeleton')),
      findsOneWidget,
    );
    expect(find.byType(InlineSkeletonBlock), findsWidgets);
  });

  testWidgets('Today page shows low-data dashboard without crashing', (
    tester,
  ) async {
    _setMobileViewport(tester);

    const emptyDashboard = TodayDashboard(
      user: TodayUserSnapshot(
        moment: TodayDayMoment.morning,
        hasUnreadNotifications: false,
        updatedAtLabel: '--:--',
      ),
      water: TodayWaterSummary(completedCount: 0, targetCount: 8),
      medication: TodayMedicationSummary(
        medicineCount: 0,
        pendingCount: 0,
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          activeHealthEventProvider.overrideWith(
            _EmptyActiveHealthEventNotifier.new,
          ),
          todayRepositoryProvider.overrideWithValue(
            const StaticTodayRepository(emptyDashboard),
          ),
          todaySuggestionProvider.overrideWith(
            StaticTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await _settleDashboard(tester);

    expect(
      find.byKey(const Key('today-primary-suggestion-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-secondary-suggestions-card')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('today-observation-card')),
      220,
      scrollable: _todayDashboardScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('today-observation-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today suggestion CTAs stay visible', (tester) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(_signedInTodayApp());
    await _settleDashboard(tester);

    // The primary card's action label comes from the backend.
    expect(find.text('去确认'), findsOneWidget);
    expect(
      find.byKey(const Key('today-secondary-suggestions-card')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today page uses wide dashboard layout on desktop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(_signedInTodayApp());
    await _settleDashboard(tester);

    expect(
      find.byKey(
        const PageStorageKey<String>('today-dashboard-desktop-scroll'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-primary-suggestion-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-secondary-suggestions-card')),
      findsOneWidget,
    );
  });

  testWidgets('desktop pull-to-refresh does not refresh active health event', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    _TrackingActiveHealthEventNotifier.refreshCalls = 0;
    _TrackingActiveHealthEventNotifier.buildCalls = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          activeHealthEventProvider.overrideWith(
            _TrackingActiveHealthEventNotifier.new,
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todaySuggestionProvider.overrideWith(
            StaticTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );
    await _settleDashboard(tester);

    await tester.drag(find.byType(CustomScrollView).last, const Offset(0, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(_TrackingActiveHealthEventNotifier.refreshCalls, 0);
    expect(_TrackingActiveHealthEventNotifier.buildCalls, 0);
  });

  testWidgets('Today top bar assistant entry routes to assistant page', (
    tester,
  ) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          activeHealthEventProvider.overrideWith(
            _EmptyActiveHealthEventNotifier.new,
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todaySuggestionProvider.overrideWith(
            StaticTodaySuggestionNotifier.new,
          ),
        ],
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodayPage(),
              ),
              GoRoute(
                path: '/assistant',
                builder: (context, state) =>
                    const Scaffold(body: Text('assistant-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await _settleDashboard(tester);

    await tester.tap(find.byKey(const Key('today-assistant-entry')));
    await tester.pumpAndSettle();

    expect(find.text('assistant-page'), findsOneWidget);
  });

  testWidgets('Signed-out renders preview dashboard without crash', (
    tester,
  ) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todaySuggestionProvider.overrideWith(
            StaticTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await _settleDashboard(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('today-summary-card')),
      220,
      scrollable: _todayDashboardScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TodayDashboardView), findsOneWidget);
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
  });

  testWidgets('Signed-out summary shows preview hint and no generate action', (
    tester,
  ) async {
    _setMobileViewport(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todaySuggestionProvider.overrideWith(
            StaticTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await _settleDashboard(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('today-summary-card')),
      220,
      scrollable: _todayDashboardScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // AI bullets are collapsed by default — expand before asserting on text.
    final expandButton = find.text(l10n.todaySuggestionShowEvidence);
    await tester.scrollUntilVisible(
      expandButton,
      220,
      scrollable: _todayDashboardScrollable(),
    );
    await tester.tap(expandButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.todayAiSummaryPreviewHint), findsOneWidget);
    expect(find.text(l10n.todayAiSummaryGenerateAction), findsNothing);
  });

  testWidgets('Error state shows retry', (tester) async {
    _setMobileViewport(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          activeHealthEventProvider.overrideWith(
            _EmptyActiveHealthEventNotifier.new,
          ),
          todayDashboardProvider.overrideWith(
            (ref) => Future<TodayDashboard>.error(Exception('test error')),
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(StateErrorView), findsOneWidget);
    expect(find.text(l10n.todayErrorTitle), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Today observation section hides spinner while loading', (
    tester,
  ) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          activeHealthEventProvider.overrideWith(
            _EmptyActiveHealthEventNotifier.new,
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todaySuggestionProvider.overrideWith(
            LoadingTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await _settleDashboard(tester);

    final observationCard = find.byKey(const Key('today-observation-card'));
    await tester.scrollUntilVisible(
      observationCard,
      220,
      scrollable: _todayDashboardScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.descendant(
        of: observationCard,
        matching: find.byType(FCircularProgress),
      ),
      findsNothing,
    );
  });

  testWidgets('Pull-to-refresh renders RefreshIndicator', (tester) async {
    _setMobileViewport(tester);

    await tester.pumpWidget(_signedInTodayApp());
    await _settleDashboard(tester);

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}

Widget _signedInTodayApp() {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
      activeHealthEventProvider.overrideWith(
        _EmptyActiveHealthEventNotifier.new,
      ),
      todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
      todaySuggestionProvider.overrideWith(StaticTodaySuggestionNotifier.new),
    ],
    child: const TestForuiApp(home: TodayPage()),
  );
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Future<void> _settleDashboard(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

Finder _todayDashboardScrollable() {
  return find
      .descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      )
      .first;
}
