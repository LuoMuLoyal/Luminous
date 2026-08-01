import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/features/settings/presentation/pages/help.dart';
import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('Help page renders FAQ items from assets and feedback section', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeControllerProvider.overrideWith(() => _ZhLocaleController()),
          supportRepositoryProvider.overrideWithValue(_FakeSupportRepository()),
        ],
        child: const TestForuiApp(home: HelpSettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsHelpFaqSectionTitle), findsOneWidget);
    // First FAQ question from assets/faq/faq_zh.md.
    expect(find.text('数据会同步到云端吗？'), findsOneWidget);
    expect(find.text(l10n.settingsHelpFeedbackSectionTitle), findsOneWidget);
    expect(find.text(l10n.mineHelpFeedbackTitle), findsOneWidget);
  });

  testWidgets('Help page FAQ expands to show the answer', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeControllerProvider.overrideWith(() => _ZhLocaleController()),
          supportRepositoryProvider.overrideWithValue(_FakeSupportRepository()),
        ],
        child: const TestForuiApp(home: HelpSettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('数据会同步到云端吗？'));
    await tester.pumpAndSettle();

    expect(find.textContaining('自动同步到云端'), findsOneWidget);
  });
}

class _ZhLocaleController extends LocaleController {
  @override
  Future<AppLocale> build() async => AppLocale.zhCn;
}

class _FakeSupportRepository implements SupportRepository {
  @override
  Future<List<SupportResource>> getResources(String scope) async => [];

  @override
  Future<AppInfo?> getAppInfo() async => null;
}
