import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_settings_navigation_row.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/app_settings_master_toggle_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SleepReminderSettingsPage extends ConsumerWidget {
  const SleepReminderSettingsPage({super.key});

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

    return AppSettingsMasterTogglePage(
      title: l10n.settingsNotificationsSleepReminderTitle,
      masterTitle: l10n.settingsNotificationsSleepReminderTitle,
      masterSubtitle: l10n.settingsNotificationsSleepReminderSubtitle,
      masterValue: settings.sleepReminderEnabled,
      onMasterChanged: settingsAsync.isLoading
          ? (_) {}
          : (value) => controller.setSleepReminderEnabled(value),
      children: [
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsNavigationRow(
                title: l10n.settingsNotificationsSleepBedtime,
                value: _formatTimeOfDay(settings.sleepBedtime),
                onTap: settings.sleepReminderEnabled
                    ? () async {
                        final selected = await showTimePicker(
                          context: context,
                          initialTime:
                              settings.sleepBedtime ??
                              const TimeOfDay(hour: 23, minute: 0),
                        );
                        if (selected != null) {
                          await controller.setSleepBedtime(selected);
                        }
                      }
                    : () {},
                enabled: settings.sleepReminderEnabled,
                showDivider: true,
              ),
              AppSettingsNavigationRow(
                title: l10n.settingsNotificationsSleepWakeTime,
                value: _formatTimeOfDay(settings.sleepWakeTime),
                onTap: settings.sleepReminderEnabled
                    ? () async {
                        final selected = await showTimePicker(
                          context: context,
                          initialTime:
                              settings.sleepWakeTime ??
                              const TimeOfDay(hour: 7, minute: 0),
                        );
                        if (selected != null) {
                          await controller.setSleepWakeTime(selected);
                        }
                      }
                    : () {},
                enabled: settings.sleepReminderEnabled,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
