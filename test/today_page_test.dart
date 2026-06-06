import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Today page renders key dashboard sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
      'today-water-card',
      'today-medication-card',
      'today-health-summary-card',
      'today-meal-card',
      'today-environment-card',
      'today-lumi-card',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 220, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 400));
      expect(finder, findsOneWidget);
    }

    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Today page shows zero water and medicines without crashing', (
    tester,
  ) async {
    final emptyDashboard = TodayDashboard(
      user: const TodayUserSnapshot(
        moment: TodayDayMoment.morning,
        hasUnreadNotifications: false,
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
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    // Should render without crashing — water card and medication card present
    expect(find.byKey(const Key('today-water-card')), findsOneWidget);
    expect(find.byKey(const Key('today-medication-card')), findsOneWidget);
    // Lumi card should show preview badge (scroll to bottom)
    final lumiCard = find.byKey(const Key('today-lumi-card'));
    await tester.scrollUntilVisible(lumiCard, 240);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('预览'), findsOneWidget);
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
