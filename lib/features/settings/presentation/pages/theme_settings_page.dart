import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme =
        ref.watch(appThemeControllerProvider).asData?.value ??
        AppThemeModePreference.system;

    return FScaffold(
      childPad: false,
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(l10n.mineSettingsThemeTitle),
          titleAlignment: Alignment.center,
          prefixes: const [AppBackButton()],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveContentFrame(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: l10n.settingsThemeAppearanceTitle),
                  const SizedBox(height: AppSpacingTokens.level3),
                  FTileGroup(
                    style: settingsSubpageTileGroupStyle(context.theme),
                    children: [
                      FTile(
                        key: const Key('theme-row-system'),
                        title: Text(l10n.mineThemeModeSystem),
                        suffix: SettingsSelectionIcon(
                          selected:
                              currentTheme == AppThemeModePreference.system,
                        ),
                        onPress: () =>
                            _handleThemeTap(ref, AppThemeModePreference.system),
                      ),
                      FTile(
                        key: const Key('theme-row-light'),
                        title: Text(l10n.mineThemeModeLight),
                        suffix: SettingsSelectionIcon(
                          selected:
                              currentTheme == AppThemeModePreference.light,
                        ),
                        onPress: () =>
                            _handleThemeTap(ref, AppThemeModePreference.light),
                      ),
                      FTile(
                        key: const Key('theme-row-dark'),
                        title: Text(l10n.mineThemeModeDark),
                        suffix: SettingsSelectionIcon(
                          selected: currentTheme == AppThemeModePreference.dark,
                        ),
                        onPress: () =>
                            _handleThemeTap(ref, AppThemeModePreference.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _handleThemeTap(
  WidgetRef ref,
  AppThemeModePreference preference,
) async {
  await ref.read(appThemeControllerProvider.notifier).setMode(preference);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level2),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
