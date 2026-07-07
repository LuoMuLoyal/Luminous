import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/theme/theme.dart';

String themeModeLabel(
  AppLocalizations l10n,
  AppThemeModePreference preference,
) {
  return switch (preference) {
    AppThemeModePreference.system => l10n.mineThemeModeSystem,
    AppThemeModePreference.light => l10n.mineThemeModeLight,
    AppThemeModePreference.dark => l10n.mineThemeModeDark,
  };
}

String themeFamilyLabel(AppLocalizations l10n, AppThemeFamily family) {
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

String themePreferenceSummary(
  AppLocalizations l10n,
  AppThemePreference preference,
) {
  return '${themeModeLabel(l10n, preference.mode)} · ${themeFamilyLabel(l10n, preference.family)}';
}
