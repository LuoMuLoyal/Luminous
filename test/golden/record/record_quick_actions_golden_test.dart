import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/presentation/widgets/record_dashboard_tokens.dart';
import 'package:luminous/features/record/presentation/widgets/record_quick_entry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Record quick actions panel golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final dashboard = MockRecordRepository.dashboardFor(DateTime(2026, 6, 15));
    final quickActions = buildMobileQuickActions(dashboard.quickActions);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final surface = theme.extension<AppThemeSurface>()!;
              final typography = AppTypographyTokens.mobile(
                theme.colorScheme.onSurface,
              );
              return RecordQuickEntryPanel(
                actions: quickActions,
                l10n: l10n,
                typography: typography,
                surface: surface,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('record-quick-actions')),
      matchesGoldenFile('golden/record/record_quick_actions.png'),
    );
  });
}
