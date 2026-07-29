import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/widgets/navigation_tile.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// General settings section: theme, language, data storage, advanced,
/// accessibility, and notifications.
class GeneralSection extends ConsumerWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themePref =
        ref.watch(themeControllerProvider).value ?? const ThemePreference();
    final currentTheme = themePref.mode;
    final currentFamily = themePref.family;
    final currentLocale =
        ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;
    final dataStorageAsync = ref.watch(dataStorageSettingsControllerProvider);
    final dataStorage =
        dataStorageAsync.asData?.value ?? const DataStorageSettingsState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsGeneralSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            SettingsNavigationTile(
              tileKey: const Key('settings-row-theme'),
              icon: SemanticIcons.actionSettings,
              title: l10n.mineSettingsThemeTitle,
              value: _themeSummaryLabel(l10n, currentTheme, currentFamily),
              onTap: () => context.push(Routes.settingsTheme),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-language'),
              icon: SemanticIcons.actionExternalLink,
              title: l10n.mineSettingsLanguageTitle,
              value: _languageLabel(l10n, currentLocale),
              onTap: () => context.push(Routes.settingsLanguage),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-data-storage'),
              icon: SemanticIcons.actionSettings,
              title: l10n.settingsDataStorageTitle,
              subtitle: l10n.settingsDataStorageSubtitle,
              value: _retentionLabel(l10n, dataStorage.retentionPeriod),
              onTap: () => context.push(Routes.settingsDataStorage),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-advanced'),
              icon: SemanticIcons.actionSettings,
              title: l10n.mineSettingsAdvancedTitle,
              onTap: () => context.push(Routes.settingsMore),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-accessibility'),
              icon: SemanticIcons.actionSettings,
              title: l10n.settingsAccessibilityTitle,
              subtitle: l10n.settingsAccessibilitySubtitle,
              onTap: () => context.push(Routes.settingsAccessibility),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-notifications'),
              icon: SemanticIcons.notificationBell,
              title: l10n.mineSettingsNotificationsTitle,
              value: _notificationSummary(l10n, ref),
              onTap: () => context.push(Routes.settingsNotifications),
            ),
          ],
        ),
      ],
    );
  }

  String _notificationSummary(AppLocalizations l10n, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    if (settings == null) return '—';

    final enabledCount = [
      settings.medicationReminders,
      settings.waterReminders,
      settings.sleepReminders,
      settings.healthAlerts,
      settings.weeklySummary,
    ].where((v) => v).length;

    return l10n.settingsNotificationsSummary(enabledCount);
  }

  String _retentionLabel(AppLocalizations l10n, DataRetentionPeriod period) {
    return switch (period) {
      DataRetentionPeriod.thirtyDays => l10n.settingsDataStorageRetention30Days,
      DataRetentionPeriod.ninetyDays => l10n.settingsDataStorageRetention90Days,
      DataRetentionPeriod.forever => l10n.settingsDataStorageRetentionForever,
    };
  }

  String _themeModeLabel(
    AppLocalizations l10n,
    AppThemeModePreference preference,
  ) {
    return switch (preference) {
      AppThemeModePreference.system => l10n.mineThemeModeSystem,
      AppThemeModePreference.light => l10n.mineThemeModeLight,
      AppThemeModePreference.dark => l10n.mineThemeModeDark,
    };
  }

  String _themeFamilyLabel(AppLocalizations l10n, AppThemeFamily family) {
    return switch (family) {
      AppThemeFamily.blue => l10n.settingsThemeFamilyBlue,
      AppThemeFamily.green => l10n.settingsThemeFamilyGreen,
      AppThemeFamily.neutral => l10n.settingsThemeFamilyNeutral,
      AppThemeFamily.orange => l10n.settingsThemeFamilyOrange,
      AppThemeFamily.red => l10n.settingsThemeFamilyRed,
      AppThemeFamily.rose => l10n.settingsThemeFamilyRose,
      AppThemeFamily.slate => l10n.settingsThemeFamilySlate,
      AppThemeFamily.violet => l10n.settingsThemeFamilyViolet,
      AppThemeFamily.yellow => l10n.settingsThemeFamilyYellow,
      AppThemeFamily.zinc => l10n.settingsThemeFamilyZinc,
    };
  }

  String _themeSummaryLabel(
    AppLocalizations l10n,
    AppThemeModePreference mode,
    AppThemeFamily family,
  ) {
    return '${_themeModeLabel(l10n, mode)} · ${_themeFamilyLabel(l10n, family)}';
  }

  String _languageLabel(AppLocalizations l10n, AppLocale locale) {
    return switch (locale) {
      AppLocale.system => l10n.settingsLanguageSystemLabel,
      AppLocale.en => l10n.settingsLanguageEnglishLabel,
      AppLocale.zhCn => l10n.settingsLanguageChineseLabel,
    };
  }
}
