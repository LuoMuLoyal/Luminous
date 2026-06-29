import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show TodayAnalysisApi;
import 'package:luminous/features/today/data/datasources/today_recommendations_remote_data_source.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/entities/today_recommendation.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_recommendations_provider.dart';
import 'package:luminous/features/today/presentation/widgets/views/today_dashboard_view.dart';
import 'package:luminous/features/today/presentation/widgets/views/today_skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'today_test_helpers.dart';

void main() {
  testWidgets('Today page renders key mobile dashboard sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable);
    final keys = <String>[
      'today-health-summary-card',
      'today-ai-summary-card',
      'today-medication-card',
      'today-water-card',
      'today-recommendation-card',
      'today-todo-card',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 220, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 400));
      expect(finder, findsOneWidget);
    }

    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Today loading shows dedicated skeleton placeholder', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final pending = Completer<TodayDashboard>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) => pending.future),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(TodaySkeletonView), findsOneWidget);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);
    expect(find.text(l10n.todayHeroTitle), findsNothing);
    expect(find.text(l10n.todayHealthSummaryCardTitle), findsNothing);
  });

  testWidgets('Today page shows zero water and medicines without crashing', (
    tester,
  ) async {
    final emptyDashboard = TodayDashboard(
      user: const TodayUserSnapshot(
        moment: TodayDayMoment.morning,
        hasUnreadNotifications: false,
        updatedAtLabel: '--:--',
      ),
      water: const TodayWaterSummary(completedCount: 0, targetCount: 8),
      medication: const TodayMedicationSummary(
        medicineCount: 0,
        pendingCount: 0,
        nextDoseTimeLabel: '--',
        nextMedicine: TodayMedicationKind.atorvastatin,
      ),
      vitals: const <TodayVitalSummary>[
        TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '--'),
        TodayVitalSummary(type: TodayVitalType.bloodPressure, valueLabel: '--'),
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
        TodayVitalSummary(type: TodayVitalType.mood, valueLabel: '--'),
      ],
      mealSuggestion: const TodayMealSuggestion(
        type: TodayMealSuggestionType.highProteinBalancedLunch,
      ),
      environment: const TodayEnvironmentSummary(
        signals: <TodayEnvironmentSignal>[
          TodayEnvironmentSignal(
            type: TodayEnvironmentSignalType.pollen,
            level: TodayEnvironmentLevel.low,
          ),
          TodayEnvironmentSignal(
            type: TodayEnvironmentSignalType.uv,
            level: TodayEnvironmentLevel.low,
          ),
        ],
      ),
      lumiSuggestion: const TodayLumiSuggestion(
        type: TodayLumiSuggestionType.pollenProtection,
      ),
      priorityItems: const <TodayPriorityItem>[],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            StaticTodayRepository(emptyDashboard),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('today-water-card')), findsOneWidget);
    expect(find.byKey(const Key('today-medication-card')), findsOneWidget);

    final recommendationCard = find.byKey(
      const Key('today-recommendation-card'),
    );
    await tester.scrollUntilVisible(recommendationCard, 240);
    await tester.pump(const Duration(milliseconds: 200));
    final l10n = AppLocalizations.of(tester.element(find.byType(TodayPage)))!;
    expect(find.text(l10n.todayRecommendationSectionTitle), findsOneWidget);

    final todoCard = find.byKey(const Key('today-todo-card'));
    await tester.scrollUntilVisible(todoCard, 240);
    await tester.pump(const Duration(milliseconds: 200));
    expect(todoCard, findsOneWidget);
    expect(find.text(l10n.todayTodoCustomTitle), findsOneWidget);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(
        const PageStorageKey<String>('today-dashboard-desktop-scroll'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today-water-card')), findsOneWidget);
    expect(find.byKey(const Key('today-medication-card')), findsOneWidget);
  });

  testWidgets('Today top bar assistant entry routes to assistant page', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('today-assistant-entry')));
    await tester.pumpAndSettle();

    expect(find.text('assistant-page'), findsOneWidget);
  });

  testWidgets('Signed-out renders without crash', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TodayDashboardView), findsOneWidget);
    expect(find.byKey(const Key('today-health-summary-card')), findsOneWidget);
  });

  testWidgets('Error state shows retry', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayDashboardProvider.overrideWith(
            (ref) => Future<TodayDashboard>.error(Exception('test error')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppStateErrorView), findsOneWidget);
    expect(find.text(l10n.todayErrorTitle), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Today recommendation section shows error retry on failure', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          todayRecommendationsRemoteDataSourceProvider.overrideWithValue(
            _FailingTodayRecommendationsDataSource(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final recommendationCard = find.byKey(
      const Key('today-recommendation-card'),
    );
    await tester.scrollUntilVisible(recommendationCard, 240);
    await tester.pumpAndSettle();

    expect(find.text(l10n.todayRecommendationErrorTitle), findsOneWidget);
    expect(find.text(l10n.todayRecommendationErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Pull-to-refresh renders RefreshIndicator', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Water card renders', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final waterCard = find.byKey(const Key('today-water-card'));
    await tester.scrollUntilVisible(waterCard, 240);
    await tester.pump(const Duration(milliseconds: 200));

    expect(waterCard, findsOneWidget);
    expect(find.text(l10n.todayWaterPriorityTitle), findsOneWidget);
  });

  testWidgets('Medication card renders', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final medicationCard = find.byKey(const Key('today-medication-card'));
    await tester.scrollUntilVisible(medicationCard, 240);
    await tester.pump(const Duration(milliseconds: 200));

    expect(medicationCard, findsOneWidget);
    expect(find.text(l10n.todayMedicationCardTitle), findsOneWidget);
  });
}

class _FailingTodayRecommendationsDataSource
    extends TodayRecommendationsRemoteDataSource {
  _FailingTodayRecommendationsDataSource()
    : super(api: TodayAnalysisApi(Dio(BaseOptions())));

  @override
  Future<List<TodayRecommendation>> fetchRecommendations({
    List<String>? excludeIds,
  }) async {
    throw Exception('test error');
  }
}
