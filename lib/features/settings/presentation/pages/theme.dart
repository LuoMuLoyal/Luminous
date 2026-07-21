import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/theme_controller.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/utils/theme_preference_labels.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/core/theme/theme.dart';

import 'package:luminous/core/design/design.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentPreference =
        ref.watch(themeControllerProvider).asData?.value ??
        const ThemePreference();

    return PageScaffold(
      title: l10n.mineSettingsThemeTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSectionLabel(label: l10n.settingsThemeModeSectionTitle),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      key: const Key('theme-row-system'),
                      title: Text(l10n.mineThemeModeSystem),
                      suffix: SettingsSelectionIcon(
                        selected:
                            currentPreference.mode ==
                            AppThemeModePreference.system,
                      ),
                      onPress: () => _handleThemeModeTap(
                        ref,
                        AppThemeModePreference.system,
                      ),
                    ),
                    FTile(
                      key: const Key('theme-row-light'),
                      title: Text(l10n.mineThemeModeLight),
                      suffix: SettingsSelectionIcon(
                        selected:
                            currentPreference.mode ==
                            AppThemeModePreference.light,
                      ),
                      onPress: () => _handleThemeModeTap(
                        ref,
                        AppThemeModePreference.light,
                      ),
                    ),
                    FTile(
                      key: const Key('theme-row-dark'),
                      title: Text(l10n.mineThemeModeDark),
                      suffix: SettingsSelectionIcon(
                        selected:
                            currentPreference.mode ==
                            AppThemeModePreference.dark,
                      ),
                      onPress: () =>
                          _handleThemeModeTap(ref, AppThemeModePreference.dark),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsThemeFamilySectionTitle,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final family in AppThemeFamily.values)
                      FTile(
                        key: Key('theme-family-row-${family.storageValue}'),
                        title: Text(themeFamilyLabel(l10n, family)),
                        prefix: _ThemeFamilyDot(family: family),
                        suffix: SettingsSelectionIcon(
                          selected: currentPreference.family == family,
                        ),
                        onPress: () => _handleThemeFamilyTap(ref, family),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _handleThemeModeTap(
  WidgetRef ref,
  AppThemeModePreference preference,
) async {
  await ref.read(themeControllerProvider.notifier).setMode(preference);
}

Future<void> _handleThemeFamilyTap(WidgetRef ref, AppThemeFamily family) async {
  await ref.read(themeControllerProvider.notifier).setFamily(family);
}

/// 主题色系的预览色点，使用对应 family 的 light 主题 primary 色。
class _ThemeFamilyDot extends StatelessWidget {
  const _ThemeFamilyDot({required this.family});

  final AppThemeFamily family;

  @override
  Widget build(BuildContext context) {
    final color = switch (family) {
      AppThemeFamily.blue => const Color(0xFF3B82F6),
      AppThemeFamily.green => const Color(0xFF22C55E),
      AppThemeFamily.neutral => const Color(0xFF737373),
      AppThemeFamily.orange => const Color(0xFFF97316),
      AppThemeFamily.red => const Color(0xFFEF4444),
      AppThemeFamily.rose => const Color(0xFFF43F5E),
      AppThemeFamily.slate => const Color(0xFF64748B),
      AppThemeFamily.violet => const Color(0xFF8B5CF6),
      AppThemeFamily.yellow => const Color(0xFFEAB308),
      AppThemeFamily.zinc => const Color(0xFF71717A),
    };
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.theme.colors.border, width: 0.5),
      ),
    );
  }
}
