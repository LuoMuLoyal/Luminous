import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Medicine page renders core mock workspace sections', (
    tester,
  ) async {
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
          home: const MedicinePage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable);
    final keys = <String>[
      'medicine-hero',
      'medicine-quick-actions',
      'medicine-today-plan',
      'medicine-safety-panel',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 300));
      expect(finder, findsOneWidget);
    }

    expect(find.text('今日服用计划'), findsOneWidget);
    expect(find.text('拍照识别药品'), findsOneWidget);
    expect(find.text('二甲双胍缓释片'), findsOneWidget);
    expect(find.text('阿托伐他汀钙片'), findsOneWidget);
    expect(find.text('奥美拉唑肠溶胶囊'), findsOneWidget);
    expect(find.text('需补药提醒'), findsOneWidget);
    expect(find.text('安全边界'), findsOneWidget);
  });
}
