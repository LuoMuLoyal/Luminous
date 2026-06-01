import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Theme mode selection bottom sheet.
class ThemeModeSheet extends ConsumerWidget {
  const ThemeModeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surface.mute,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              Text(
                l10n.mineSettingsThemeTitle,
                style: typography.displaySm,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              ...AppThemeModePreference.values.map(
                (mode) => _ThemeModeOption(
                  mode: mode,
                  isSelected: mode == current,
                  onTap: () {
                    ref.read(appThemeControllerProvider.notifier).setMode(mode);
                    Navigator.of(context).pop();
                  },
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final AppThemeModePreference mode;
  final bool isSelected;
  final VoidCallback onTap;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  String get _label => switch (mode) {
    AppThemeModePreference.system => _themeModeLabel(l10n, 'system'),
    AppThemeModePreference.light => _themeModeLabel(l10n, 'light'),
    AppThemeModePreference.dark => _themeModeLabel(l10n, 'dark'),
  };

  IconData get _icon => switch (mode) {
    AppThemeModePreference.system => Icons.settings_brightness_rounded,
    AppThemeModePreference.light => Icons.light_mode_rounded,
    AppThemeModePreference.dark => Icons.dark_mode_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
      child: Material(
        color: isSelected ? surface.canvasSoft2 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Icon(_icon, size: 22, color: surface.body),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Text(
                    _label,
                    style: typography.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _themeModeLabel(AppLocalizations l10n, String mode) {
  return switch (mode) {
    'system' => l10n.mineThemeModeSystem,
    'light' => l10n.mineThemeModeLight,
    'dark' => l10n.mineThemeModeDark,
    _ => mode,
  };
}
