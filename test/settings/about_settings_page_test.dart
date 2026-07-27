import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/presentation/pages/about.dart';
import 'package:luminous/features/settings/presentation/providers/package_info.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_forui_app.dart';

void main() {
  PackageInfo fakePackageInfo({
    String appName = 'Luminous',
    String version = '0.1.0',
    String buildNumber = '1',
  }) {
    return PackageInfo(
      appName: appName,
      packageName: 'com.example.luminous',
      version: version,
      buildNumber: buildNumber,
      buildSignature: '',
      installerStore: null,
    );
  }

  testWidgets('About page renders app icon, name, version and legal rows', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith(
            (ref) async => const AppInfo(supportEmail: 'support@example.com'),
          ),
          packageInfoProvider.overrideWith((ref) async => fakePackageInfo()),
        ],
        child: const TestForuiApp(home: AboutSettingsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Luminous'), findsOneWidget);
    expect(find.textContaining('0.1.0'), findsOneWidget);
    expect(find.text(l10n.settingsAboutTagline), findsOneWidget);
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
        overrides: [
          appInfoProvider.overrideWith((ref) async => null),
          packageInfoProvider.overrideWith((ref) async => fakePackageInfo()),
        ],
        child: const TestForuiApp(home: AboutSettingsPage()),
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
