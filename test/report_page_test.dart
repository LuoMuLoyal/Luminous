import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Report page renders mobile north-star sections', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
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
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.tabReport), findsOneWidget);
    expect(find.text(l10n.reportWeekDateRange), findsOneWidget);
    expect(find.text(l10n.reportScoreTitle), findsOneWidget);
    expect(find.text(l10n.reportMetricMedicationTitle), findsOneWidget);
    expect(find.text(l10n.reportTrendSectionTitle), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    final keys = <String>[
      'report-score-hero',
      'report-metrics-grid',
      'report-trend-section',
      'report-findings-section',
      'report-ai-summary-section',
      'report-export-section',
      'report-patterns-section',
      'report-privacy-section',
      'report-reference-notice',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 250));
      expect(finder, findsOneWidget);
    }

    expect(find.text(l10n.reportReferenceNotice), findsOneWidget);
  });
}
