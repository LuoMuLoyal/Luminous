import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
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
    final typography = _typography(context);
    final settings =
        ref.watch(notificationSettingsControllerProvider).asData?.value ??
        const NotificationSettingsState();

    return PageScaffoldShell(
      title: l10n.mineSettingsNotificationsTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        if (settings.permissionState != NotificationPermissionState.unsupported)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
            child: MineSectionSurface(
              typography: typography,
              surface: surface,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SettingsListRow(
                    key: const Key('notification-row-permission'),
                    title: _permissionTitle(l10n, settings.permissionState),
                    subtitle: _permissionSubtitle(
                      l10n,
                      settings.permissionState,
                    ),
                    icon: Icons.notifications_active_outlined,
                    trailing: settings.permissionState ==
                            NotificationPermissionState.granted
                        ? Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: surface.mute,
                          ),
                    onTap: () async {
                      if (settings.permissionState ==
                          NotificationPermissionState.granted) {
                        return;
                      }
                      await ref
                          .read(
                            notificationSettingsControllerProvider.notifier,
                          )
                          .requestPermission();
                    },
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
            child: MineSectionSurface(
              typography: typography,
              surface: surface,
              padding: const EdgeInsets.all(AppSpacingTokens.md),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 18,
                    color: surface.mute,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      l10n.settingsNotificationsPermissionUnsupported,
                      style: typography.bodySm.copyWith(color: surface.mute),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                trailing: IgnorePointer(
                  child: Switch(
                    value: settings.medicationReminders,
                    onChanged: (_) {},
                  ),
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
                trailing: IgnorePointer(
                  child: Switch(
                    value: settings.healthAlerts,
                    onChanged: (_) {},
                  ),
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
                trailing: IgnorePointer(
                  child: Switch(
                    value: settings.weeklySummary,
                    onChanged: (_) {},
                  ),
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

String _permissionTitle(
  AppLocalizations l10n,
  NotificationPermissionState state,
) {
  return switch (state) {
    NotificationPermissionState.granted =>
      l10n.settingsNotificationsPermissionEnabled,
    NotificationPermissionState.denied =>
      l10n.settingsNotificationsPermissionDisabled,
    NotificationPermissionState.unsupported =>
      l10n.settingsNotificationsPermissionUnsupported,
  };
}

String? _permissionSubtitle(
  AppLocalizations l10n,
  NotificationPermissionState state,
) {
  return switch (state) {
    NotificationPermissionState.granted =>
      l10n.settingsNotificationsPermissionEnabledHint,
    NotificationPermissionState.denied =>
      l10n.settingsNotificationsPermissionDisabledHint,
    NotificationPermissionState.unsupported => null,
  };
}

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
}
