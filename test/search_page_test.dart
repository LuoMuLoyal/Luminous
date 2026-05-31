import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Medicine search page renders mock search workflow', (
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
          home: const SearchPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('搜索药品'), findsOneWidget);
    expect(find.text('药品说明书（cn）'), findsOneWidget);
    expect(find.text('最近搜索'), findsOneWidget);
    expect(find.text('热门常备药分类'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('搜索结果'),
      240,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('搜索结果'), findsOneWidget);

    final resultFinder = find.text('布洛芬片');
    await tester.scrollUntilVisible(
      resultFinder,
      240,
      scrollable: find.byType(Scrollable),
    );
    expect(resultFinder, findsOneWidget);
    expect(find.text('加入药箱'), findsWidgets);
  });
}
