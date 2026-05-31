import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/record/presentation/record_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Record page renders mobile mock dashboard sections', (
    tester,
  ) async {
    await _pumpRecordPage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final scrollable = find.byType(Scrollable);
    final keys = <String>[
      'record-quick-actions',
      'record-summary',
      'record-timeline',
      'record-trends',
      'record-health-bag',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.text('快速记录'), findsOneWidget);
    expect(find.text('鸡胸肉藜麦沙拉'), findsOneWidget);
    expect(find.text('趋势查看'), findsOneWidget);
  });

  testWidgets('Record page uses desktop side rails', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpRecordPage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('record-calendar-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-filter-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-new-entry-panel')), findsOneWidget);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });
}

Future<void> _pumpRecordPage(WidgetTester tester) async {
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
        home: const RecordPage(),
      ),
    ),
  );
}
