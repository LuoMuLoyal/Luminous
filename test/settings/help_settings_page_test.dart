import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/presentation/pages/help.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Help page renders only actionable, available resources', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportResourcesProvider('help').overrideWith(
            (ref) async => [
              const SupportResource(
                id: 'enabled-url',
                title: 'Enabled URL',
                actionUrl: 'https://example.com/help',
                actionType: SupportResourceAction.url,
                available: true,
              ),
              const SupportResource(
                id: 'disabled-url',
                title: 'Disabled URL',
                actionUrl: 'https://example.com/help2',
                actionType: SupportResourceAction.url,
                available: false,
              ),
              const SupportResource(
                id: 'no-url',
                title: 'No URL',
                actionUrl: null,
                actionType: SupportResourceAction.url,
                available: true,
              ),
              const SupportResource(
                id: 'no-type',
                title: 'No Type',
                actionUrl: 'https://example.com/help3',
                actionType: null,
                available: true,
              ),
            ],
          ),
        ],
        child: const TestForuiApp(home: HelpSettingsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Enabled URL'), findsOneWidget);
    expect(find.text('Disabled URL'), findsNothing);
    expect(find.text('No URL'), findsNothing);
    expect(find.text('No Type'), findsNothing);
    expect(find.text(l10n.settingsHelpEmpty), findsNothing);
  });

  testWidgets('Help page shows empty state when no actionable resources', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportResourcesProvider('help').overrideWith((ref) async => []),
        ],
        child: const TestForuiApp(home: HelpSettingsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(l10n.settingsHelpEmpty), findsOneWidget);
  });
}
