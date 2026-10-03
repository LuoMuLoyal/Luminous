import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/pages/advanced.dart';
import 'package:luminous/features/settings/presentation/pages/ai.dart';
import 'package:luminous/features/settings/presentation/pages/data_export.dart';
import 'package:luminous/features/settings/presentation/pages/feature_flags.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

// -- Stub controllers --------------------------------------------------

class _StubSettingsController extends UserSettingsController {
  _StubSettingsController(this.data, {this.onSetContext});
  final UserSettings data;

  /// Optional override for the context-toggle patch; lets tests simulate a
  /// successful or failing PATCH without touching the repository layer.
  final Future<void> Function(AssistantContextPatch patch)? onSetContext;

  @override
  Future<UserSettings> build() async => data;

  @override
  Future<void> setAssistantContext(AssistantContextPatch patch) async {
    await onSetContext?.call(patch);
  }
}

class _StubExportController extends DataExportController {
  _StubExportController(this.exportData);
  final DataExportRequestData? exportData;

  @override
  Future<DataExportRequestData?> build() async => exportData;
}

UserSettings _buildSettings({
  bool aiSummaries = false,
  bool assistantEnabled = true,
  bool assistantMemory = false,
  bool healthProfile = true,
  bool dailyRecords = true,
  bool sleepRecords = true,
  bool currentMedicines = true,
}) {
  return UserSettings(
    aiSummariesEnabled: aiSummaries,
    dataSharingConsent: true,
    assistantEnabled: assistantEnabled,
    assistantMemoryEnabled: assistantMemory,
    waterTargetCount: 8,
    assistantContext: AssistantContextSettings(
      healthProfile: healthProfile,
      dailyRecords: dailyRecords,
      sleepRecords: sleepRecords,
      currentMedicines: currentMedicines,
    ),
    updatedAt: '2026-06-12T00:00:00.000Z',
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
    UserSettings settings, {
    bool showToaster = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWith(
            () => _StubSettingsController(settings),
          ),
        ],
        child: TestForuiApp(home: page, showToaster: showToaster),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Pumps the AI settings page with a context-toggle override, so tests can
  /// drive the next-turn toast. The toaster is enabled for toast assertions.
  Future<void> pumpAiPageWithContextOverride(
    WidgetTester tester,
    UserSettings settings,
    Future<void> Function(AssistantContextPatch patch) onSetContext,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWith(
            () => _StubSettingsController(settings, onSetContext: onSetContext),
          ),
        ],
        child: const TestForuiApp(home: AiSettingsPage(), showToaster: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> pumpPageWithExport(
    WidgetTester tester,
    Widget page,
    DataExportRequestData? exportData,
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
      expect(find.byIcon(SemanticIcons.recordSymptom), findsOneWidget);
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

    testWidgets('renders AI privacy section with usage notes', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPageWithSettings(
        tester,
        const AiSettingsPage(),
        _buildSettings(),
      );

      expect(find.text(l10n.settingsAiPrivacySectionTitle), findsOneWidget);
      expect(find.text(l10n.settingsAiPrivacyMemoryNote), findsOneWidget);
      expect(find.text(l10n.settingsAiPrivacyContextNote), findsOneWidget);
      expect(find.text(l10n.settingsAiPrivacyHistoricalNote), findsOneWidget);
    });

    testWidgets('context toggle shows next-turn toast on success', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpAiPageWithContextOverride(
        tester,
        _buildSettings(),
        (_) async {},
      );

      // First context tile (Health Profile) switch.
      final switchFinder = find.byType(FSwitch).at(3);
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(l10n.settingsAiContextChangeNextTurnToast),
        findsOneWidget,
      );

      // Drain the toast timer so later tests start with clean Toast state.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('context toggle shows no success toast on failure', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpAiPageWithContextOverride(
        tester,
        _buildSettings(),
        (_) async => throw Exception('patch failed'),
      );

      final switchFinder = find.byType(FSwitch).at(3);
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(l10n.settingsAiContextChangeNextTurnToast),
        findsNothing,
      );

      // Drain the failure toast timer too.
      await tester.pump(const Duration(seconds: 2));
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

      // 4 tiles have chevronRight: clear-cache, api-endpoint, log-level, feature-flags
      expect(find.byIcon(SemanticIcons.actionNext), findsNWidgets(4));
    });

    testWidgets('renders SettingsSectionLabel for developer section', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(find.text(l10n.settingsDeveloperSectionTitle), findsOneWidget);
    });

    testWidgets('renders both tiles in main FTileGroup', (tester) async {
      await pumpPage(tester, const AdvancedSettingsPage());

      expect(
        find.byKey(const Key('advanced-settings-row-clear-cache')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('advanced-settings-row-reset-defaults')),
        findsOneWidget,
      );
    });

    testWidgets('API endpoint sheet fits a phone viewport on every preset', (
      tester,
    ) async {
      // 真机（1080x2400 @3x = 360x800 逻辑像素）上 sheet 曾溢出 2.3px，确认按钮
      // 被裁掉，导致改不了端点。这里用同一逻辑尺寸回归：任一 preset 下内容都必须
      // 放得下（Custom 还多一个 URL 输入框，是最坏情况）。
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AdvancedSettingsPage());

      await tester.tap(find.byKey(const Key('dev-settings-row-api-endpoint')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.settingsDevApiEndpointLocal), findsOneWidget);
      expect(find.text(l10n.settingsDevApiEndpointCustom), findsOneWidget);

      // Forui 的 sheet 本身不画背景，body 必须自带 SheetSurface，否则内容
      // 直接叠在被压暗的页面上（真机表现就是 sheet 背景透明）。
      expect(find.byType(SheetSurface), findsOneWidget);

      // 「本地开发」这一行必须显示本机真正会用的地址（Android = 10.0.2.2），
      // 而不是 preset 里写死的 127.0.0.1。
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text(l10n.settingsDevApiEndpointLocal),
            matching: find.byType(FTile),
          ),
          matching: find.text('http://10.0.2.2:3000'),
        ),
        findsOneWidget,
      );

      final confirm = find.widgetWithText(
        FButton,
        l10n.settingsDevApiEndpointConfirm,
      );
      expect(confirm, findsOneWidget);
      expect(
        tester.getRect(confirm).bottom,
        lessThanOrEqualTo(800.0),
        reason: '确认按钮被 sheet 底部裁掉就无法切换端点',
      );

      // 切到「自定义」——多出 URL 输入框，仍然不能溢出。
      await tester.tap(find.text(l10n.settingsDevApiEndpointCustom));
      await tester.pumpAndSettle();

      expect(find.text(l10n.settingsDevApiEndpointCustomUrl), findsOneWidget);
      expect(confirm, findsOneWidget);
      expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(800.0));
    });

    testWidgets('log level sheet also paints its own surface', (tester) async {
      await pumpPage(tester, const AdvancedSettingsPage());

      await tester.tap(find.byKey(const Key('dev-settings-row-log-level')));
      await tester.pumpAndSettle();

      expect(find.byType(SheetSurface), findsOneWidget);
    });
  });
}
