import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/lucide_icon_bridge.dart';
import 'package:luminous/core/widgets/common/icon_picker_sheet.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
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
                    subtitle: Text(
                      prefs.dynamicSortEnabled
                          ? l10n.recordQuickSortDisableDynamicFirst
                          : l10n.recordQuickSettingsManualOrderHint,
                    ),
                    suffix: const Icon(SemanticIcons.actionNext),
                    onPress: prefs.dynamicSortEnabled
                        ? null
                        : () => context.push(Routes.recordQuickEntryReorder),
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
              FSelect<QuickEntryWaterDefault>.rich(
                key: const Key('record-quick-settings-water-default'),
                label: Text(l10n.recordQuickSettingsWaterDefault),
                format: (value) => waterDefaultLabel(l10n, value),
                control: FSelectControl.lifted(
                  value: prefs.waterDefault,
                  onChange: (value) {
                    if (value != null) {
                      unawaited(controller.setWaterDefault(value));
                    }
                  },
                ),
                children: [
                  for (final option in QuickEntryWaterDefault.values)
                    FSelectItem.item(
                      title: Text(waterDefaultLabel(l10n, option)),
                      value: option,
                    ),
                ],
              ),
              const SizedBox(height: Spacing.level6),
              SettingsSectionLabel(label: l10n.recordQuickSettingsDisplay),
              const SizedBox(height: Spacing.level3),
              FSelect<QuickEntryWaterBadgeMode>.rich(
                key: const Key('record-quick-settings-water-badge'),
                label: Text(l10n.recordQuickSettingsWaterBadge),
                format: (value) => waterBadgeLabel(l10n, value),
                control: FSelectControl.lifted(
                  value: prefs.waterBadgeMode,
                  onChange: (value) {
                    if (value != null) {
                      unawaited(controller.setWaterBadgeMode(value));
                    }
                  },
                ),
                children: [
                  for (final mode in QuickEntryWaterBadgeMode.values)
                    FSelectItem.item(
                      title: Text(waterBadgeLabel(l10n, mode)),
                      value: mode,
                    ),
                ],
              ),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
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
              SettingsSectionLabel(label: l10n.recordQuickSettingsIcons),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.recordQuickSettingsCustomIconHint,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: Spacing.level3),
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                divider: FItemDivider.full,
                children: [
                  for (final action in RecordDashboard.defaultQuickActions)
                    FTile(
                      key: Key(
                        'record-quick-settings-icon-${action.type.name}',
                      ),
                      title: Text(recordCopy(l10n, action.titleKey)),
                      subtitle: Text(l10n.recordQuickIconChangeAction),
                      prefix: Icon(
                        resolveQuickActionIcon(action, prefs),
                        size: IconSizeTokens.level3,
                      ),
                      suffix: const Icon(SemanticIcons.actionNext),
                      onPress: () => _pickCustomIcon(context, ref, action),
                    ),
                  FTile(
                    key: const Key('record-quick-settings-reset-icons'),
                    title: Text(l10n.recordQuickIconResetAction),
                    onPress: prefs.customIcons.isEmpty
                        ? null
                        : controller.resetAllCustomIcons,
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

  Future<void> _pickCustomIcon(
    BuildContext context,
    WidgetRef ref,
    RecordQuickAction action,
  ) async {
    final prefs =
        ref.read(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final iconData = await showAppIconPicker(
      context,
      currentIcon: resolveQuickActionIcon(action, prefs),
    );
    if (iconData == null || !context.mounted) return;
    final iconName = LucideIconBridge.nameOf(iconData);
    if (iconName == null) return;
    await ref
        .read(quickEntryPreferencesProvider.notifier)
        .setCustomIcon(action.type.name, iconName);
  }
}
