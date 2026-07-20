import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/settings/presentation/pages/accessibility.dart';
import 'package:luminous/features/settings/presentation/pages/data_storage.dart';
import 'package:luminous/features/settings/presentation/pages/dnd.dart';
import 'package:luminous/features/settings/presentation/pages/sleep_reminder.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(ProviderScope(child: TestForuiApp(home: page)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('DndSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DndSettingsPage());

      expect(find.text(l10n.settingsNotificationsDndTitle), findsOneWidget);
    });

    testWidgets('renders DnD enabled toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DndSettingsPage());

      expect(find.text(l10n.settingsNotificationsDndEnabled), findsOneWidget);
      expect(find.text(l10n.settingsNotificationsDndSubtitle), findsOneWidget);
    });

    testWidgets('renders DnD unset hint when disabled', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DndSettingsPage());

      // When DnD is disabled (default), time fields are hidden and an
      // "unset" hint is shown instead.
      expect(find.text(l10n.settingsNotificationsTimeUnset), findsOneWidget);
    });

    testWidgets('renders FSwitch for DnD toggle', (tester) async {
      await pumpPage(tester, const DndSettingsPage());

      expect(find.byType(FSwitch), findsOneWidget);
    });
  });

  group('SleepReminderSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const SleepReminderSettingsPage());

      expect(
        find.text(l10n.settingsNotificationsSleepReminderTitle),
        findsNWidgets(2),
      );
    });

    testWidgets('renders sleep reminder toggle with subtitle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const SleepReminderSettingsPage());

      expect(
        find.text(l10n.settingsNotificationsSleepReminderSubtitle),
        findsOneWidget,
      );
    });

    testWidgets('renders unset hint when sleep reminder disabled', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const SleepReminderSettingsPage());

      // When sleep reminder is disabled (default), time fields are hidden
      // and an "unset" hint is shown instead.
      expect(find.text(l10n.settingsNotificationsTimeUnset), findsOneWidget);
    });

    testWidgets('renders FSwitch for sleep reminder toggle', (tester) async {
      await pumpPage(tester, const SleepReminderSettingsPage());

      expect(find.byType(FSwitch), findsOneWidget);
    });
  });

  group('AccessibilitySettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(find.text(l10n.settingsAccessibilityTitle), findsOneWidget);
    });

    testWidgets('renders font size section label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(
        find.text(l10n.settingsAccessibilityFontSizeSection),
        findsOneWidget,
      );
    });

    testWidgets('renders all font size options', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(
        find.text(l10n.settingsAccessibilityFontSizeSmall),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsAccessibilityFontSizeStandard),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsAccessibilityFontSizeLarge),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsAccessibilityFontSizeExtraLarge),
        findsOneWidget,
      );
    });

    testWidgets('renders reduce animations toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(
        find.text(l10n.settingsAccessibilityReduceAnimations),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsAccessibilityReduceAnimationsSubtitle),
        findsOneWidget,
      );
    });

    testWidgets('renders high contrast toggle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(find.text(l10n.settingsAccessibilityHighContrast), findsOneWidget);
      expect(
        find.text(l10n.settingsAccessibilityHighContrastSubtitle),
        findsOneWidget,
      );
    });

    testWidgets('renders font-size row keys', (tester) async {
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(find.byKey(const Key('font-size-row-small')), findsOneWidget);
      expect(find.byKey(const Key('font-size-row-standard')), findsOneWidget);
      expect(find.byKey(const Key('font-size-row-large')), findsOneWidget);
      expect(find.byKey(const Key('font-size-row-extraLarge')), findsOneWidget);
    });

    testWidgets('renders reduce-animations switch key', (tester) async {
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(
        find.byKey(const Key('accessibility-switch-reduce-animations')),
        findsOneWidget,
      );
    });

    testWidgets('renders high-contrast switch key', (tester) async {
      await pumpPage(tester, const AccessibilitySettingsPage());

      expect(
        find.byKey(const Key('accessibility-switch-high-contrast')),
        findsOneWidget,
      );
    });
  });

  group('DataStorageSettingsPage', () {
    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(find.text(l10n.settingsDataStorageTitle), findsOneWidget);
    });

    testWidgets('renders retention section label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(
        find.text(l10n.settingsDataStorageRetentionSection),
        findsOneWidget,
      );
    });

    testWidgets('renders all retention period options', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(
        find.text(l10n.settingsDataStorageRetention30Days),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsDataStorageRetention90Days),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsDataStorageRetentionForever),
        findsOneWidget,
      );
    });

    testWidgets('renders image quality section label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(
        find.text(l10n.settingsDataStorageImageQualitySection),
        findsOneWidget,
      );
    });

    testWidgets('renders all image quality options', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(
        find.text(l10n.settingsDataStorageImageQualityStandard),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settingsDataStorageImageQualityDataSaver),
        findsOneWidget,
      );
    });

    testWidgets('renders sync section label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(find.text(l10n.settingsDataStorageSyncSection), findsOneWidget);
    });

    testWidgets('renders all sync preference options', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(find.text(l10n.settingsDataStorageSyncWifiOnly), findsOneWidget);
      expect(
        find.text(l10n.settingsDataStorageSyncWifiAndMobile),
        findsOneWidget,
      );
    });

    testWidgets('renders retention row keys', (tester) async {
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(find.byKey(const Key('data-retention-row-30')), findsOneWidget);
      expect(find.byKey(const Key('data-retention-row-90')), findsOneWidget);
      expect(
        find.byKey(const Key('data-retention-row-forever')),
        findsOneWidget,
      );
    });

    testWidgets('renders image quality row keys', (tester) async {
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(
        find.byKey(const Key('image-quality-row-standard')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('image-quality-row-dataSaver')),
        findsOneWidget,
      );
    });

    testWidgets('renders sync preference row keys', (tester) async {
      await pumpPage(tester, const DataStorageSettingsPage());

      expect(find.byKey(const Key('sync-pref-row-wifiOnly')), findsOneWidget);
      expect(
        find.byKey(const Key('sync-pref-row-wifiAndMobile')),
        findsOneWidget,
      );
    });
  });
}
