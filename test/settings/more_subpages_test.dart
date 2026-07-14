import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/settings/presentation/pages/advanced.dart';
import 'package:luminous/features/settings/presentation/pages/ai.dart';
import 'package:luminous/features/settings/presentation/pages/data_export_page.dart';
import 'package:luminous/features/settings/presentation/pages/feature_flags.dart';
import 'package:luminous/features/settings/presentation/pages/security_pin.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

// -- Stub controllers --------------------------------------------------

class _StubSettingsController extends UserSettingsController {
  final UserSettingsDataDto data;

  _StubSettingsController(this.data);

  @override
  Future<UserSettingsDataDto> build() async => data;
}

class _StubExportController extends DataExportController {
  final DataExportRequestDataDto? exportData;

  _StubExportController(this.exportData);

  @override
  Future<DataExportRequestDataDto?> build() async => exportData;
}

UserSettingsDataDto _buildSettings({
  bool pinEnabled = false,
  String? lastChangedAt,
  bool aiSummaries = false,
  bool assistantEnabled = true,
  bool assistantMemory = false,
  bool healthProfile = true,
  bool dailyRecords = true,
  bool sleepRecords = true,
  bool currentMedicines = true,
}) {
  return UserSettingsDataDto(
    aiSummariesEnabled: aiSummaries,
    dataSharingConsent: true,
    assistantEnabled: assistantEnabled,
    assistantMemoryEnabled: assistantMemory,
    waterTargetCount: 8,
    assistantContext: AssistantContextSettingsDto(
      healthProfile: healthProfile,
      dailyRecords: dailyRecords,
      sleepRecords: sleepRecords,
      currentMedicines: currentMedicines,
    ),
    updatedAt: '2026-06-12T00:00:00.000Z',
    securityPin: SecurityPinSettingsDto(
      enabled: pinEnabled,
      lastChangedAt: lastChangedAt,
    ),
  );
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(ProviderScope(child: TestForuiApp(home: page)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> pumpPageWithSettings(
    WidgetTester tester,
    Widget page,
    UserSettingsDataDto settings,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWith(
            () => _StubSettingsController(settings),
          ),
        ],
        child: TestForuiApp(home: page),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> pumpPageWithExport(
    WidgetTester tester,
    Widget page,
    DataExportRequestDataDto? exportData,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataExportControllerProvider.overrideWith(
            () => _StubExportController(exportData),
          ),
        ],
        child: TestForuiApp(home: page),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  // -- SecurityPinSettingsPage -----------------------------------------

  group('SecurityPinSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsSecurityPinTitle), findsOneWidget);
    });

    testWidgets('shows disabled status when PIN not enabled', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(pinEnabled: false),
      );

      expect(find.text(l10n.settingsSecurityPinStatusDisabled), findsOneWidget);
      expect(find.byIcon(FLucideIcons.shieldOff), findsOneWidget);
    });

    testWidgets('shows enabled status when PIN is enabled', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(
          pinEnabled: true,
          lastChangedAt: '2026-07-01T10:00:00.000Z',
        ),
      );

      expect(find.text(l10n.settingsSecurityPinStatusEnabled), findsOneWidget);
      expect(find.byIcon(FLucideIcons.shieldCheck), findsOneWidget);
    });

    testWidgets('shows enable section when PIN disabled', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsSecurityPinEnableSection), findsOneWidget);
      expect(find.text(l10n.settingsSecurityPinEnableAction), findsOneWidget);
    });

    testWidgets('shows change and disable sections when PIN enabled', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(pinEnabled: true, lastChangedAt: '2026-07-01'),
      );

      expect(find.text(l10n.settingsSecurityPinChangeSection), findsOneWidget);
      expect(find.text(l10n.settingsSecurityPinDisableSection), findsOneWidget);
      expect(find.text(l10n.settingsSecurityPinChangeAction), findsOneWidget);
      expect(find.text(l10n.settingsSecurityPinDisableAction), findsOneWidget);
    });

    testWidgets('shows never changed label when lastChangedAt is null', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsSecurityPinNeverChanged), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const SecurityPinSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsSecurityPinDescription), findsOneWidget);
    });
  });

  // -- FeatureFlagsSettingsPage ----------------------------------------

  group('FeatureFlagsSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(find.text(l10n.settingsFeatureFlagsTitle), findsOneWidget);
    });

    testWidgets('renders warning banner', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(find.text(l10n.settingsFeatureFlagsWarning), findsOneWidget);
      expect(find.byIcon(FLucideIcons.flaskConical), findsOneWidget);
    });

    testWidgets('renders AI section with toggles', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(find.text(l10n.settingsFeatureFlagsAiSection), findsOneWidget);
      expect(find.text(l10n.settingsFeatureFlagsAiRuntime), findsOneWidget);
      expect(find.text(l10n.settingsFeatureFlagsGenUi), findsOneWidget);
    });

    testWidgets('renders assistant section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(
        find.text(l10n.settingsFeatureFlagsAssistantSection),
        findsOneWidget,
      );
      expect(find.text(l10n.settingsFeatureFlagsStreamMode), findsOneWidget);
    });

    testWidgets('renders medicine section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(
        find.text(l10n.settingsFeatureFlagsMedicineSection),
        findsOneWidget,
      );
      expect(find.text(l10n.settingsFeatureFlagsBarcodeScan), findsOneWidget);
    });

    testWidgets('renders report section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(find.text(l10n.settingsFeatureFlagsReportSection), findsOneWidget);
      expect(find.text(l10n.settingsFeatureFlagsPdfExport), findsOneWidget);
    });

    testWidgets('renders FSwitch widgets for toggles', (tester) async {
      await pumpPage(tester, const FeatureFlagsSettingsPage());

      expect(find.byType(FSwitch), findsNWidgets(5));
    });
  });

  // -- AiSettingsPage --------------------------------------------------

  group('AiSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiTitle), findsOneWidget);
    });

    testWidgets('renders AI summaries toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiSummariesTitle), findsOneWidget);
      expect(find.text(l10n.settingsAiSummariesSubtitle), findsOneWidget);
    });

    testWidgets('renders assistant toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiAssistantTitle), findsOneWidget);
      expect(find.text(l10n.settingsAiAssistantSubtitle), findsOneWidget);
    });

    testWidgets('renders memory toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiMemoryTitle), findsOneWidget);
      expect(find.text(l10n.settingsAiMemorySubtitle), findsOneWidget);
    });

    testWidgets('renders context section with 4 context tiles', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiContextSectionTitle), findsOneWidget);
      expect(find.text(l10n.settingsAiContextHealthProfile), findsOneWidget);
      expect(find.text(l10n.settingsAiContextDailyRecords), findsOneWidget);
      expect(find.text(l10n.settingsAiContextSleepRecords), findsOneWidget);
      expect(find.text(l10n.settingsAiContextCurrentMedicines), findsOneWidget);
    });

    testWidgets('shows disabled hint when assistant not enabled', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(assistantEnabled: false),
      );

      expect(find.text(l10n.settingsAiContextDisabledHint), findsOneWidget);
    });

    testWidgets('renders FSwitch widgets for toggles', (tester) async {
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.byType(FSwitch), findsNWidgets(7));
    });
  });

  // -- DataExportPage --------------------------------------------------

  group('DataExportPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithExport(tester, const DataExportPage(), null);

      expect(find.text(l10n.mineSettingExportTitle), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithExport(tester, const DataExportPage(), null);

      expect(find.text(l10n.settingsExportDescription), findsOneWidget);
    });

    testWidgets('shows request button when idle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithExport(tester, const DataExportPage(), null);

      expect(find.text(l10n.settingsExportRequestButton), findsOneWidget);
    });

    testWidgets('shows status row with label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithExport(tester, const DataExportPage(), null);

      expect(find.text(l10n.mineSettingExportValue), findsWidgets);
    });
  });

  // -- AdvancedSettingsPage --------------------------------------------

  group('AdvancedSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(find.text(l10n.mineSettingsAdvancedTitle), findsOneWidget);
    });

    testWidgets('renders clear cache tile', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('advanced-settings-row-clear-cache')),
        findsOneWidget,
      );
      expect(find.text(l10n.settingsAdvancedClearImageCache), findsOneWidget);
    });

    testWidgets('renders reset defaults tile', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('advanced-settings-row-reset-defaults')),
        findsOneWidget,
      );
      expect(find.text(l10n.settingsAdvancedResetDefaults), findsOneWidget);
    });

    testWidgets('renders licenses tile', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('advanced-settings-row-licenses')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsAdvancedOpenSourceLicenses),
        findsOneWidget,
      );
    });

    testWidgets('renders developer section in debug mode', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(find.text(l10n.settingsDeveloperSectionTitle), findsOneWidget);
    });

    testWidgets('renders developer option tiles with keys', (tester) async {
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('dev-settings-row-api-endpoint')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dev-settings-row-log-level')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dev-settings-row-feature-flags')),
        findsOneWidget,
      );
    });

    testWidgets('renders developer option labels', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(find.text(l10n.settingsDevApiEndpoint), findsOneWidget);
      expect(find.text(l10n.settingsDevLogLevel), findsOneWidget);
      expect(find.text(l10n.settingsFeatureFlagsTitle), findsOneWidget);
    });

    testWidgets('renders chevron icons for tappable tiles', (tester) async {
      await pumpPage(tester, const AdvancedSettingsPage());

      // 4 tiles have chevronRight: licenses, api-endpoint, log-level, feature-flags
      expect(find.byIcon(FLucideIcons.chevronRight), findsNWidgets(4));
    });

    testWidgets('renders SettingsSectionLabel for developer section', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(find.text(l10n.settingsDeveloperSectionTitle), findsOneWidget);
    });

    testWidgets('renders all three tiles in main FTileGroup', (tester) async {
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('advanced-settings-row-clear-cache')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('advanced-settings-row-reset-defaults')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('advanced-settings-row-licenses')),
        findsOneWidget,
      );
    });
  });
}
