import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

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

    return PageScaffoldShell(
      title: l10n.mineSettingsNotificationsTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        if (settings.permissionState != NotificationPermissionState.unsupported)
          _PermissionCard(
            key: const Key('notification-permission-card'),
            state: settings.permissionState,
            onTap: () async {
              if (settings.permissionState ==
                  NotificationPermissionState.granted) {
                return;
              }
              await controller.requestPermission();
            },
          ),
        const SizedBox(height: AppSpacingTokens.lg),
        _SectionLabel(label: l10n.settingsNotificationsGeneralGroup),
        const SizedBox(height: AppSpacingTokens.sm),
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
                  ? () => controller.setWeeklySummary(!settings.weeklySummary)
                  : null,
              suffix: FSwitch(
                value: settings.weeklySummary,
                enabled: !settingsAsync.isLoading,
                onChange: settingsAsync.isLoading
                    ? null
                    : (value) => controller.setWeeklySummary(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        _SectionLabel(label: l10n.settingsNotificationsReminderGroup),
        const SizedBox(height: AppSpacingTokens.sm),
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
                  ? () => controller.setWaterReminders(!settings.waterReminders)
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
              details: Text(_sleepReminderSummary(l10n, settings)),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => context.push('/settings/notifications/sleep'),
            ),
          ],
        ),
      ],
    );
  }

  String _sleepReminderSummary(
    AppLocalizations l10n,
    NotificationSettingsState settings,
  ) {
    if (!settings.sleepReminderEnabled) {
      return l10n.settingsNotificationsTimeUnset;
    }
    final bedtime = _formatTimeOfDay(settings.sleepBedtime);
    final wakeTime = _formatTimeOfDay(settings.sleepWakeTime);
    return '$bedtime - $wakeTime';
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({super.key, required this.state, required this.onTap});

  final NotificationPermissionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final (title, subtitle, icon, color) = switch (state) {
      NotificationPermissionState.granted => (
        l10n.settingsNotificationsPermissionEnabled,
        l10n.settingsNotificationsPermissionEnabledHint,
        FLucideIcons.check,
        colors.primary,
      ),
      NotificationPermissionState.denied => (
        l10n.settingsNotificationsPermissionDisabled,
        l10n.settingsNotificationsPermissionDisabledHint,
        FLucideIcons.circleAlert,
        colors.mutedForeground,
      ),
      NotificationPermissionState.unsupported => (
        l10n.settingsNotificationsPermissionUnsupported,
        '',
        FLucideIcons.circleAlert,
        colors.mutedForeground,
      ),
    };

    return FTile(
      key: key,
      prefix: Icon(icon, color: color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      suffix: state == NotificationPermissionState.granted
          ? null
          : const Icon(FLucideIcons.chevronRight),
      onPress: state == NotificationPermissionState.granted ? null : onTap,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
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
