import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
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
    final typography = _typography(context);
    final settings =
        ref.watch(notificationSettingsControllerProvider).asData?.value ??
        const NotificationSettingsState();

    return PageScaffoldShell(
      title: l10n.mineSettingsNotificationsTitle,
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
                key: const Key('notification-row-medication'),
                title: l10n.settingsNotificationsMedicationReminders,
                icon: Icons.medication_liquid_outlined,
                trailing: Switch(
                  value: settings.medicationReminders,
                  onChanged: (value) => ref
                      .read(notificationSettingsControllerProvider.notifier)
                      .setMedicationReminders(value),
                ),
                onTap: () => ref
                    .read(notificationSettingsControllerProvider.notifier)
                    .setMedicationReminders(!settings.medicationReminders),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('notification-row-health-alerts'),
                title: l10n.settingsNotificationsHealthAlerts,
                icon: Icons.favorite_border_rounded,
                trailing: Switch(
                  value: settings.healthAlerts,
                  onChanged: (value) => ref
                      .read(notificationSettingsControllerProvider.notifier)
                      .setHealthAlerts(value),
                ),
                onTap: () => ref
                    .read(notificationSettingsControllerProvider.notifier)
                    .setHealthAlerts(!settings.healthAlerts),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('notification-row-weekly-summary'),
                title: l10n.settingsNotificationsWeeklySummary,
                icon: Icons.calendar_today_outlined,
                trailing: Switch(
                  value: settings.weeklySummary,
                  onChanged: (value) => ref
                      .read(notificationSettingsControllerProvider.notifier)
                      .setWeeklySummary(value),
                ),
                onTap: () => ref
                    .read(notificationSettingsControllerProvider.notifier)
                    .setWeeklySummary(!settings.weeklySummary),
              ),
            ],
          ),
        ),
      ],
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
