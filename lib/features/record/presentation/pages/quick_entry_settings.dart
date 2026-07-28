import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickEntrySettingsPage extends ConsumerWidget {
  const QuickEntrySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final controller = ref.read(quickEntryPreferencesProvider.notifier);

    return PageScaffold(
      title: l10n.recordQuickSettingsTitle,
      child: ResponsiveContentFrame(
        child: SingleChildScrollView(
          key: const Key('record-quick-settings-page'),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level4,
            vertical: Spacing.level4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionLabel(label: l10n.recordQuickSettingsSorting),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  FTile(
                    key: const Key('record-quick-settings-dynamic-sort'),
                    title: Text(l10n.settingsQuickEntryDynamicSortTitle),
                    subtitle: Text(l10n.settingsQuickEntryDynamicSortSubtitle),
                    suffix: FSwitch(
                      value: prefs.dynamicSortEnabled,
                      onChange: controller.setDynamicSortEnabled,
                    ),
                    onPress: () => controller.setDynamicSortEnabled(
                      !prefs.dynamicSortEnabled,
                    ),
                  ),
                  FTile(
                    key: const Key('record-quick-settings-reorder'),
                    title: Text(l10n.recordQuickSettingsManualOrder),
                    subtitle: Text(l10n.recordQuickSettingsManualOrderHint),
                    suffix: const Icon(SemanticIcons.actionNext),
                    onPress: () => context.push(Routes.recordQuickEntryReorder),
                  ),
                  FTile(
                    key: const Key('record-quick-settings-reset-order'),
                    title: Text(l10n.recordQuickSettingsResetOrder),
                    subtitle: Text(l10n.recordQuickSettingsResetOrderHint),
                    onPress: controller.resetCustomOrder,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level6),
              SettingsSectionLabel(label: l10n.recordQuickSettingsDefaults),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  FTile(
                    key: const Key('record-quick-settings-water-default'),
                    title: Text(l10n.recordQuickSettingsWaterDefault),
                    details: Text(
                      l10n.recordQuickSettingsWaterAmount(
                        prefs.waterDefaultAmountMl,
                      ),
                    ),
                    onPress: () => controller.setWaterDefaultAmountMl(
                      prefs.waterDefaultAmountMl == 250 ? 500 : 250,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level6),
              SettingsSectionLabel(label: l10n.recordQuickSettingsDisplay),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  FTile(
                    key: const Key('record-quick-settings-water-badge'),
                    title: Text(l10n.recordQuickSettingsWaterBadge),
                    details: Text(_waterBadgeLabel(l10n, prefs.waterBadgeMode)),
                    onPress: () => controller.setWaterBadgeMode(
                      _nextWaterBadgeMode(prefs.waterBadgeMode),
                    ),
                  ),
                  FTile(
                    key: const Key('record-quick-settings-sleep-badge'),
                    title: Text(l10n.recordQuickSettingsSleepBadge),
                    subtitle: Text(l10n.recordQuickSettingsSleepBadgeHint),
                    suffix: FSwitch(
                      value: prefs.sleepInProgressBadgeEnabled,
                      onChange: controller.setSleepInProgressBadgeEnabled,
                    ),
                    onPress: () => controller.setSleepInProgressBadgeEnabled(
                      !prefs.sleepInProgressBadgeEnabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level6),
              SettingsSectionLabel(label: l10n.recordQuickSettingsRules),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  FTile(title: Text(l10n.recordQuickSettingsMedicationRule)),
                  FTile(title: Text(l10n.recordQuickSettingsMealRule)),
                  FTile(title: Text(l10n.recordQuickSettingsSymptomRule)),
                  FTile(title: Text(l10n.recordQuickSettingsMoodRule)),
                  FTile(title: Text(l10n.recordQuickSettingsSleepRule)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  QuickEntryWaterBadgeMode _nextWaterBadgeMode(
    QuickEntryWaterBadgeMode current,
  ) {
    return switch (current) {
      QuickEntryWaterBadgeMode.dailyTotal =>
        QuickEntryWaterBadgeMode.dailyCount,
      QuickEntryWaterBadgeMode.dailyCount => QuickEntryWaterBadgeMode.hidden,
      QuickEntryWaterBadgeMode.hidden => QuickEntryWaterBadgeMode.dailyTotal,
    };
  }

  String _waterBadgeLabel(
    AppLocalizations l10n,
    QuickEntryWaterBadgeMode mode,
  ) {
    return switch (mode) {
      QuickEntryWaterBadgeMode.dailyTotal =>
        l10n.recordQuickSettingsWaterBadgeDailyTotal,
      QuickEntryWaterBadgeMode.dailyCount =>
        l10n.recordQuickSettingsWaterBadgeDailyCount,
      QuickEntryWaterBadgeMode.hidden =>
        l10n.recordQuickSettingsWaterBadgeHidden,
    };
  }
}
