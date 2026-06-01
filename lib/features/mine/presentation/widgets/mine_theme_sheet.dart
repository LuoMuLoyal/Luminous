import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:luminous/core/theme/app_theme_controller.dart";
import "package:luminous/core/widgets/app_bottom_sheet.dart";
import "package:luminous/l10n/app_localizations.dart";

/// Theme mode selection bottom sheet.
class ThemeModeSheet extends ConsumerWidget {
  const ThemeModeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;
    final l10n = AppLocalizations.of(context)!;

    return AppBottomSheet(
      title: l10n.mineSettingsThemeTitle,
      children: AppThemeModePreference.values.map((mode) {
        return AppBottomSheetOption(
          icon: switch (mode) {
            AppThemeModePreference.system => Icons.settings_brightness_rounded,
            AppThemeModePreference.light => Icons.light_mode_rounded,
            AppThemeModePreference.dark => Icons.dark_mode_rounded,
          },
          label: switch (mode) {
            AppThemeModePreference.system => l10n.mineThemeModeSystem,
            AppThemeModePreference.light => l10n.mineThemeModeLight,
            AppThemeModePreference.dark => l10n.mineThemeModeDark,
          },
          isSelected: mode == current,
          onTap: () {
            ref.read(appThemeControllerProvider.notifier).setMode(mode);
            Navigator.of(context).pop();
          },
        );
      }).toList(),
    );
  }
}
