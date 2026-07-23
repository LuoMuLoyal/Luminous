import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/data/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/settings_section_label.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (settings.permissionState !=
                NotificationPermissionState.unsupported)
              _PermissionCard(
                key: const Key('notification-permission-card'),
                state: settings.permissionState,
                onTap: () async {
                  if (settings.permissionState ==
                      NotificationPermissionState.granted) {
                    return;
                  }
                  if (settings.permissionState ==
                      NotificationPermissionState.permanentlyDenied) {
                    await controller.openSystemSettings();
                    return;
                  }
                  await controller.requestPermission();
                },
              ),
            const SizedBox(height: Spacing.level5),
            SettingsSectionLabel(label: l10n.settingsNotificationsGeneralGroup),
            const SizedBox(height: Spacing.level3),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                FTile(
                  key: const Key('notification-switch-health-alerts'),
                  title: Text(l10n.settingsNotificationsHealthAlerts),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () => controller.setHealthAlerts(!settings.healthAlerts)
                      : null,
                  suffix: FSwitch(
                    value: settings.healthAlerts,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) => controller.setHealthAlerts(value),
                  ),
                ),
                FTile(
                  key: const Key('notification-switch-weekly-summary'),
                  title: Text(l10n.settingsNotificationsWeeklySummary),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () =>
                            controller.setWeeklySummary(!settings.weeklySummary)
                      : null,
                  suffix: FSwitch(
                    value: settings.weeklySummary,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) => controller.setWeeklySummary(value),
                  ),
                ),
                FTile(
                  key: const Key('notification-switch-sound'),
                  title: Text(l10n.settingsNotificationsSound),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () => controller.setNotificationSoundEnabled(
                          !settings.notificationSoundEnabled,
                        )
                      : null,
                  suffix: FSwitch(
                    value: settings.notificationSoundEnabled,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) =>
                              controller.setNotificationSoundEnabled(value),
                  ),
                ),
                FTile(
                  key: const Key('notification-switch-vibration'),
                  title: Text(l10n.settingsNotificationsVibration),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () => controller.setNotificationVibrationEnabled(
                          !settings.notificationVibrationEnabled,
                        )
                      : null,
                  suffix: FSwitch(
                    value: settings.notificationVibrationEnabled,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) =>
                              controller.setNotificationVibrationEnabled(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level5),
            SettingsSectionLabel(
              label: l10n.settingsNotificationsReminderGroup,
            ),
            const SizedBox(height: Spacing.level3),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                FTile(
                  key: const Key('notification-switch-medication'),
                  title: Text(l10n.settingsNotificationsMedicationReminders),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () => controller.setMedicationReminders(
                          !settings.medicationReminders,
                        )
                      : null,
                  suffix: FSwitch(
                    value: settings.medicationReminders,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) => controller.setMedicationReminders(value),
                  ),
                ),
                FTile(
                  key: const Key('notification-switch-water'),
                  title: Text(l10n.mineReminderWaterTitle),
                  enabled: !settingsAsync.isLoading,
                  onPress: !settingsAsync.isLoading
                      ? () => controller.setWaterReminders(
                          !settings.waterReminders,
                        )
                      : null,
                  suffix: FSwitch(
                    value: settings.waterReminders,
                    enabled: !settingsAsync.isLoading,
                    onChange: settingsAsync.isLoading
                        ? null
                        : (value) => controller.setWaterReminders(value),
                  ),
                ),
                FTile(
                  title: Text(l10n.settingsNotificationsSleepReminderTitle),
                  details: Text(
                    _sleepReminderSummary(
                      l10n,
                      settings,
                      Localizations.localeOf(context),
                    ),
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () =>
                      context.push(Routes.settingsNotificationsSleep),
                ),
                FTile(
                  title: Text(l10n.settingsNotificationsDndTitle),
                  details: Text(
                    _dndSummary(
                      l10n,
                      settings,
                      Localizations.localeOf(context),
                    ),
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(Routes.settingsNotificationsDnd),
                ),
                FTile(
                  title: Text(l10n.settingsNotificationsAdvance),
                  details: Text(_advanceSummary(l10n, settings)),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () =>
                      _showAdvancePicker(context, settings, controller),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingsNotificationsTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}

String _sleepReminderSummary(
  AppLocalizations l10n,
  NotificationSettingsState settings,
  Locale locale,
) {
  if (!settings.sleepReminderEnabled) {
    return l10n.settingsNotificationsTimeUnset;
  }
  final bedtime = _formatTimeOfDay(settings.sleepBedtime, locale);
  final wakeTime = _formatTimeOfDay(settings.sleepWakeTime, locale);
  return '$bedtime - $wakeTime';
}

String _dndSummary(
  AppLocalizations l10n,
  NotificationSettingsState settings,
  Locale locale,
) {
  if (!settings.dndEnabled) {
    return l10n.settingsNotificationsTimeUnset;
  }
  final start = _formatTimeOfDay(settings.dndStartTime, locale);
  final end = _formatTimeOfDay(settings.dndEndTime, locale);
  return '$start - $end';
}

String _advanceSummary(
  AppLocalizations l10n,
  NotificationSettingsState settings,
) {
  if (settings.reminderAdvanceMinutes <= 0) {
    return l10n.settingsNotificationsAdvanceOff;
  }
  return l10n.settingsNotificationsAdvanceMinutes(
    settings.reminderAdvanceMinutes,
  );
}

Future<void> _showAdvancePicker(
  BuildContext context,
  NotificationSettingsState settings,
  NotificationSettingsController controller,
) async {
  final l10n = AppLocalizations.of(context)!;
  const options = <int>[0, 5, 10, 15, 30];

  await showFSheet(
    context: context,
    side: FLayout.btt,
    builder: (context) => _AdvancePickerSheet(
      options: options,
      selected: settings.reminderAdvanceMinutes,
      l10n: l10n,
      onSelect: (minutes) {
        controller.setReminderAdvanceMinutes(minutes);
        Navigator.of(context).pop();
      },
    ),
  );
}

String _formatTimeOfDay(TimeOfDay? time, Locale locale) {
  if (time == null) return '—';
  return formatTimeOfDay(time, locale);
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({super.key, required this.state, required this.onTap});

  final NotificationPermissionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final (title, subtitle, icon, color, ctaLabel) = switch (state) {
      NotificationPermissionState.granted => (
        l10n.settingsNotificationsPermissionEnabled,
        l10n.settingsNotificationsPermissionEnabledHint,
        FLucideIcons.check,
        colors.primary,
        null,
      ),
      NotificationPermissionState.denied => (
        l10n.settingsNotificationsPermissionDisabled,
        l10n.settingsNotificationsPermissionDisabledHint,
        FLucideIcons.circleAlert,
        colors.mutedForeground,
        null,
      ),
      NotificationPermissionState.permanentlyDenied => (
        l10n.settingsNotificationsPermissionPermanentlyDenied,
        l10n.settingsNotificationsPermissionPermanentlyDeniedHint,
        FLucideIcons.circleAlert,
        colors.destructive,
        l10n.settingsNotificationsPermissionOpenSettings,
      ),
      NotificationPermissionState.unsupported => (
        l10n.settingsNotificationsPermissionUnsupported,
        '',
        FLucideIcons.circleAlert,
        colors.mutedForeground,
        null,
      ),
    };

    return FCard(
      child: FTile(
        key: key,
        prefix: Icon(icon, color: color),
        title: Text(
          title,
          style: TypographyToken.level4
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        suffix: state == NotificationPermissionState.granted
            ? null
            : ctaLabel != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctaLabel,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: Spacing.level2),
                  const Icon(FLucideIcons.chevronRight),
                ],
              )
            : const Icon(FLucideIcons.chevronRight),
        onPress: state == NotificationPermissionState.granted ? null : onTap,
      ),
    );
  }
}

class _AdvancePickerSheet extends StatelessWidget {
  const _AdvancePickerSheet({
    required this.options,
    required this.selected,
    required this.l10n,
    required this.onSelect,
  });

  final List<int> options;
  final int selected;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: Text(
                l10n.settingsNotificationsAdvance,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final minutes in options)
                  FTile(
                    title: Text(
                      minutes == 0
                          ? l10n.settingsNotificationsAdvanceOff
                          : l10n.settingsNotificationsAdvanceMinutes(minutes),
                    ),
                    suffix: SettingsSelectionIcon(
                      selected: selected == minutes,
                    ),
                    onPress: () => onSelect(minutes),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
