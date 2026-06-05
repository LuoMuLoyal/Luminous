import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
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

    return PageScaffoldShell(
      title: l10n.mineSettingsThemeTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        MineSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsListRow(
                key: const Key('theme-row-system'),
                title: l10n.mineThemeModeSystem,
                icon: Icons.settings_brightness_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.system,
                ),
                onTap: () => _handleThemeTap(
                  ref,
                  AppThemeModePreference.system,
                ),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('theme-row-light'),
                title: l10n.mineThemeModeLight,
                icon: Icons.light_mode_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.light,
                ),
                onTap: () => _handleThemeTap(
                  ref,
                  AppThemeModePreference.light,
                ),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('theme-row-dark'),
                title: l10n.mineThemeModeDark,
                icon: Icons.dark_mode_rounded,
                trailing: _SelectionIcon(
                  selected: currentTheme == AppThemeModePreference.dark,
                ),
                onTap: () => _handleThemeTap(
                  ref,
                  AppThemeModePreference.dark,
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
