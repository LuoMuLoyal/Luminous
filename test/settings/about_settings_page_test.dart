import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/settings/presentation/pages/about_settings_page.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('About page renders app info and legal rows', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith(
            (ref) async => AppInfoDataDto(
              name: 'Luminous Test',
              version: '1.2.3',
              description: 'Test description',
              buildDate: '2026-06-28T00:00:00Z',
              supportEmail: 'support@example.com',
              privacyPolicyUrl: 'https://example.com/privacy',
              termsOfServiceUrl: 'https://example.com/terms',
            ),
          ),
        ],
        child: const TestForuiApp(
          home: AboutSettingsPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Luminous Test'), findsOneWidget);
    expect(find.textContaining('1.2.3'), findsOneWidget);
    expect(
      find.text(l10n.settingsAboutBuildNumberLabel('2026-06-28T00:00:00Z')),
      findsOneWidget,
    );
    expect(find.text('Test description'), findsOneWidget);
    expect(find.text(l10n.settingsAboutPrivacyPolicy), findsOneWidget);
    expect(find.text(l10n.settingsAboutTermsOfService), findsOneWidget);
    expect(find.text(l10n.settingsAboutLicenses), findsOneWidget);
    expect(find.text(l10n.settingsAboutSupport), findsOneWidget);
    expect(find.text('support@example.com'), findsOneWidget);
  });

  testWidgets('About page renders fallback rows when app info is missing', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appInfoProvider.overrideWith((ref) async => null)],
        child: const TestForuiApp(
          home: AboutSettingsPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Luminous'), findsOneWidget);
    expect(find.text(l10n.settingsAboutPrivacyPolicy), findsOneWidget);
    expect(find.text(l10n.settingsAboutTermsOfService), findsOneWidget);
    expect(find.text(l10n.settingsAboutLicenses), findsOneWidget);
    expect(find.text(l10n.settingsAboutSupport), findsOneWidget);
  });
}
