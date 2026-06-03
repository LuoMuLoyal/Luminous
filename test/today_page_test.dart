import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
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
