import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/accessibility/settings_controller.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class AccessibilitySettingsPage extends ConsumerWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(accessibilitySettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const AccessibilitySettingsState();
    final controller = ref.read(
      accessibilitySettingsControllerProvider.notifier,
    );

    return PageScaffold(
      title: l10n.settingsAccessibilityTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.level6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSectionLabel(
                  label: l10n.settingsAccessibilityFontSizeSection,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final option in FontSizePreference.values)
                      FTile(
                        key: Key('font-size-row-${option.storageValue}'),
                        title: Text(_fontSizeLabel(l10n, option)),
                        suffix: SettingsSelectionIcon(
                          selected: settings.fontSize == option,
                        ),
                        onPress: () => controller.setFontSize(option),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(label: l10n.settingsGeneralSectionTitle),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      key: const Key('accessibility-switch-reduce-animations'),
                      title: Text(l10n.settingsAccessibilityReduceAnimations),
                      subtitle: Text(
                        l10n.settingsAccessibilityReduceAnimationsSubtitle,
                      ),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () => controller.setReduceAnimations(
                              !settings.reduceAnimations,
                            )
                          : null,
                      suffix: FSwitch(
                        value: settings.reduceAnimations,
                        enabled: !settingsAsync.isLoading,
                        onChange: settingsAsync.isLoading
                            ? null
                            : (value) => controller.setReduceAnimations(value),
                      ),
                    ),
                    FTile(
                      key: const Key('accessibility-switch-high-contrast'),
                      title: Text(l10n.settingsAccessibilityHighContrast),
                      subtitle: Text(
                        l10n.settingsAccessibilityHighContrastSubtitle,
                      ),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () => controller.setHighContrast(
                              !settings.highContrast,
                            )
                          : null,
                      suffix: FSwitch(
                        value: settings.highContrast,
                        enabled: !settingsAsync.isLoading,
                        onChange: settingsAsync.isLoading
                            ? null
                            : (value) => controller.setHighContrast(value),
                      ),
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

  String _fontSizeLabel(AppLocalizations l10n, FontSizePreference preference) {
    return switch (preference) {
      FontSizePreference.small => l10n.settingsAccessibilityFontSizeSmall,
      FontSizePreference.standard => l10n.settingsAccessibilityFontSizeStandard,
      FontSizePreference.large => l10n.settingsAccessibilityFontSizeLarge,
      FontSizePreference.extraLarge =>
        l10n.settingsAccessibilityFontSizeExtraLarge,
    };
  }
}
