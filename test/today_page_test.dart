import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
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

  testWidgets(
    'Today loading keeps static sections visible with skeleton slots',
    (tester) async {
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

      expect(find.text(l10n.todayHeroTitle), findsOneWidget);
      expect(find.text(l10n.todayHealthSummaryCardTitle), findsOneWidget);
      expect(find.byKey(const Key('today-medication-card')), findsOneWidget);
      expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

      final todoCard = find.byKey(const Key('today-todo-card'));
      await tester.scrollUntilVisible(todoCard, 240);
      await tester.pump(const Duration(milliseconds: 200));
      expect(todoCard, findsOneWidget);
      expect(find.text(l10n.todayTodoSectionTitle), findsOneWidget);
      expect(find.text(l10n.todayTodoCustomTitle), findsOneWidget);
    },
  );

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
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            _StaticTodayRepository(emptyDashboard),
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

    // Should render without crashing - water card and medication card present.
    expect(find.byKey(const Key('today-water-card')), findsOneWidget);
    expect(find.byKey(const Key('today-medication-card')), findsOneWidget);
    // Unsupported sections should still render with locale-aware mock copy.
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
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
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
}

class _StaticTodayRepository implements TodayRepository {
  const _StaticTodayRepository(this.dashboard);

  final TodayDashboard dashboard;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    return dashboard;
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
