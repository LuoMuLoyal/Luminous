import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Shell page uses five desktop tabs plus settings/help actions', (
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Luminous'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);
    expect(find.text('记录'), findsAtLeastNWidgets(1));
    expect(find.text('用药'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('更多'), findsAtLeastNWidgets(1));
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('帮助'), findsOneWidget);

    await tester.tap(find.text('我的').first);
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsAtLeastNWidgets(2));
    expect(find.text('我的 · 即将上线'), findsOneWidget);

    await tester.tap(find.text('更多').first);
    await tester.pumpAndSettle();
    expect(find.text('更多'), findsAtLeastNWidgets(2));
    expect(find.text('更多 · 即将上线'), findsOneWidget);
  });
}
