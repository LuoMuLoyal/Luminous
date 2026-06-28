import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_settings_navigation_row.dart';
import 'package:luminous/core/widgets/app_settings_section.dart';
import 'package:luminous/core/widgets/app_settings_switch_row.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    return PageScaffoldShell(
      title: l10n.mineSettingsNotificationsTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        if (settings.permissionState != NotificationPermissionState.unsupported)
          _PermissionCard(
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
        AppSettingsSection(label: l10n.settingsNotificationsGeneralGroup),
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsSwitchRow(
                key: const Key('notification-switch-health-alerts'),
                title: l10n.settingsNotificationsHealthAlerts,
                value: settings.healthAlerts,
                onChanged: settingsAsync.isLoading
                    ? (_) {}
                    : (value) => controller.setHealthAlerts(value),
                showDivider: true,
              ),
              AppSettingsSwitchRow(
                key: const Key('notification-switch-weekly-summary'),
                title: l10n.settingsNotificationsWeeklySummary,
                value: settings.weeklySummary,
                onChanged: settingsAsync.isLoading
                    ? (_) {}
                    : (value) => controller.setWeeklySummary(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsNotificationsReminderGroup),
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsSwitchRow(
                key: const Key('notification-switch-medication'),
                title: l10n.settingsNotificationsMedicationReminders,
                value: settings.medicationReminders,
                onChanged: settingsAsync.isLoading
                    ? (_) {}
                    : (value) => controller.setMedicationReminders(value),
                showDivider: true,
              ),
              AppSettingsSwitchRow(
                key: const Key('notification-switch-water'),
                title: l10n.mineReminderWaterTitle,
                value: settings.waterReminders,
                onChanged: settingsAsync.isLoading
                    ? (_) {}
                    : (value) => controller.setWaterReminders(value),
                showDivider: true,
              ),
              AppSettingsNavigationRow(
                title: l10n.settingsNotificationsSleepReminderTitle,
                value: _sleepReminderSummary(l10n, settings),
                onTap: () => context.push('/settings/notifications/sleep'),
              ),
            ],
          ),
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
  const _PermissionCard({required this.state, required this.onTap});

  final NotificationPermissionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);

    final (title, subtitle, icon, color) = switch (state) {
      NotificationPermissionState.granted => (
        l10n.settingsNotificationsPermissionEnabled,
        l10n.settingsNotificationsPermissionEnabledHint,
        Icons.notifications_active_rounded,
        theme.colorScheme.primary,
      ),
      NotificationPermissionState.denied => (
        l10n.settingsNotificationsPermissionDisabled,
        l10n.settingsNotificationsPermissionDisabledHint,
        Icons.notifications_off_rounded,
        surface.mute,
      ),
      NotificationPermissionState.unsupported => (
        l10n.settingsNotificationsPermissionUnsupported,
        '',
        Icons.notifications_none_rounded,
        surface.mute,
      ),
    };

    return Material(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: InkWell(
        onTap: state == NotificationPermissionState.granted ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.bodyMdStrong.copyWith(color: color),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        subtitle,
                        style: typography.bodySm.copyWith(color: surface.mute),
                      ),
                    ],
                  ],
                ),
              ),
              if (state != NotificationPermissionState.granted)
                Icon(
                  Icons.chevron_right_rounded,
                  color: surface.mute,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
