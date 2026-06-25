import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_setting_row.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);
    final currentTheme =
        ref.watch(appThemeControllerProvider).asData?.value ??
        AppThemeModePreference.system;
    final currentPalette =
        ref.watch(appThemePaletteControllerProvider).asData?.value ??
        AppThemePalettePreference.classic;

    return PageScaffoldShell(
      title: l10n.mineSettingsThemeTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        _SectionLabel(label: l10n.settingsThemeAppearanceTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('theme-row-system'),
                title: l10n.mineThemeModeSystem,
                icon: Icons.settings_brightness_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.system,
                ),
                onTap: () =>
                    _handleThemeTap(ref, AppThemeModePreference.system),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('theme-row-light'),
                title: l10n.mineThemeModeLight,
                icon: Icons.light_mode_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.light,
                ),
                onTap: () => _handleThemeTap(ref, AppThemeModePreference.light),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('theme-row-dark'),
                title: l10n.mineThemeModeDark,
                icon: Icons.dark_mode_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.dark,
                ),
                onTap: () => _handleThemeTap(ref, AppThemeModePreference.dark),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        _SectionLabel(label: l10n.settingsThemePaletteTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('theme-palette-row-classic'),
                title: l10n.settingsThemePaletteClassic,
                icon: Icons.contrast_rounded,
                trailing: _PaletteTrailing(
                  swatches: const [
                    Color(0xFFFFFFFF),
                    Color(0xFFF5F5F5),
                    Color(0xFF171717),
                  ],
                  selected: currentPalette == AppThemePalettePreference.classic,
                ),
                onTap: () =>
                    _handlePaletteTap(ref, AppThemePalettePreference.classic),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('theme-palette-row-blue-pink'),
                title: l10n.settingsThemePaletteBluePink,
                icon: Icons.palette_outlined,
                trailing: _PaletteTrailing(
                  swatches: const [
                    Color(0xFF95CEE8),
                    Color(0xFF47A0C9),
                    Color(0xFFDF8CAD),
                  ],
                  selected:
                      currentPalette == AppThemePalettePreference.bluePink,
                ),
                onTap: () =>
                    _handlePaletteTap(ref, AppThemePalettePreference.bluePink),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('theme-palette-row-yellow-green'),
                title: l10n.settingsThemePaletteYellowGreen,
                icon: Icons.palette_outlined,
                trailing: _PaletteTrailing(
                  swatches: const [
                    Color(0xFFE7F0D6),
                    Color(0xFF4AA112),
                    Color(0xFFD4B01D),
                  ],
                  selected:
                      currentPalette == AppThemePalettePreference.yellowGreen,
                ),
                onTap: () => _handlePaletteTap(
                  ref,
                  AppThemePalettePreference.yellowGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _handleThemeTap(
  WidgetRef ref,
  AppThemeModePreference preference,
) async {
  await ref.read(appThemeControllerProvider.notifier).setMode(preference);
}

Future<void> _handlePaletteTap(
  WidgetRef ref,
  AppThemePalettePreference preference,
) async {
  await ref
      .read(appThemePaletteControllerProvider.notifier)
      .setPalette(preference);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: surface.mute,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaletteTrailing extends StatelessWidget {
  const _PaletteTrailing({required this.swatches, required this.selected});

  final List<Color> swatches;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in swatches) ...[
          _Swatch(color: color),
          const SizedBox(width: AppSpacingTokens.xxs),
        ],
        const SizedBox(width: AppSpacingTokens.xs),
        _SelectionIcon(selected: selected),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        border: Border.all(color: surface.hairline),
      ),
      child: const SizedBox.square(dimension: 18),
    );
  }
}

class _SelectionIcon extends StatelessWidget {
  const _SelectionIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Icon(
      selected ? Icons.check_rounded : Icons.circle_outlined,
      size: 18,
      color: selected ? theme.colorScheme.primary : surface.mute,
    );
  }
}

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
}
