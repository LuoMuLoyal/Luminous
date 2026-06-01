import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart';
import 'package:luminous/features/search/data/repositories/mock/mock_repository.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Medicine search page renders search interface', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicineSearchRepositoryProvider
              .overrideWith((ref) => const MockMedicineSearchRepository()),
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
          home: const SearchPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Should show search title and search input hint
    expect(find.text('搜索药品'), findsOneWidget);
    expect(
      find.text('搜索药品、成分、疾病、症状...'),
      findsOneWidget,
    );

    // Type a query to trigger search
    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(milliseconds: 500));

    // Mock repository returns results for any search
    expect(find.text('布洛芬片'), findsOneWidget);
  });
}
