import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_dialog.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 弹出「通知设置」总览弹窗：权限状态 + 健康提醒 + 每周摘要
Future<void> showNotificationGeneralDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => const _NotificationGeneralDialog(),
);

/// 弹出「用药提醒」设置弹窗
Future<void> showMedicationReminderDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => _ReminderToggleDialog(
    title: AppLocalizations.of(context)!.mineReminderMedicineTitle,
    icon: Icons.medication_outlined,
    switchTitle: AppLocalizations.of(
      context,
    )!.settingsNotificationsMedicationReminders,
    valueSelector: (settings) => settings.medicationReminders,
    onChanged: (controller, value) => controller.setMedicationReminders(value),
  ),
);

/// 弹出「饮水提醒」设置弹窗
Future<void> showWaterReminderDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => _ReminderToggleDialog(
    title: AppLocalizations.of(context)!.mineReminderWaterTitle,
    icon: Icons.water_drop_outlined,
    switchTitle: AppLocalizations.of(
      context,
    )!.settingsNotificationsMedicationReminders,
    valueSelector: (settings) => settings.waterReminders,
    onChanged: (controller, value) => controller.setWaterReminders(value),
  ),
);

/// 弹出「睡眠提醒」设置弹窗
Future<void> showSleepReminderDialog(BuildContext context) =>
    showDialog(context: context, builder: (_) => const _SleepReminderDialog());

class _NotificationGeneralDialog extends ConsumerWidget {
  const _NotificationGeneralDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _dialogTypography(context);
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    return AppDialog(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogTitle(
            icon: Icons.notifications_none_rounded,
            title: l10n.mineSettingsNotificationsTitle,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (settings.permissionState !=
              NotificationPermissionState.unsupported)
            _PermissionListTile(
              state: settings.permissionState,
              onTap: () async {
                if (settings.permissionState ==
                    NotificationPermissionState.granted) {
                  return;
                }
                await controller.requestPermission();
              },
            )
          else
            _UnsupportedPermissionHint(l10n: l10n, typography: typography),
          const SizedBox(height: AppSpacingTokens.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationsHealthAlerts),
            value: settings.healthAlerts,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) => controller.setHealthAlerts(value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationsWeeklySummary),
            value: settings.weeklySummary,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) => controller.setWeeklySummary(value),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                MaterialLocalizations.of(context).closeButtonLabel,
                style: typography.bodySmStrong.copyWith(color: surface.body),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderToggleDialog extends ConsumerWidget {
  const _ReminderToggleDialog({
    required this.title,
    required this.icon,
    required this.switchTitle,
    required this.valueSelector,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final String switchTitle;
  final bool Function(NotificationSettingsState settings) valueSelector;
  final Future<void> Function(
    NotificationSettingsController controller,
    bool value,
  )
  onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    return AppDialog(
      maxWidth: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogTitle(icon: icon, title: title),
          const SizedBox(height: AppSpacingTokens.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(switchTitle),
            value: valueSelector(settings),
            onChanged: settingsAsync.isLoading
                ? null
                : (value) => onChanged(controller, value),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepReminderDialog extends ConsumerWidget {
  const _SleepReminderDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _dialogTypography(context);
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    Future<void> pickBedtime() async {
      if (!settings.sleepReminderEnabled) return;
      final selected = await showTimePicker(
        context: context,
        initialTime:
            settings.sleepBedtime ?? const TimeOfDay(hour: 23, minute: 0),
      );
      if (selected != null && context.mounted) {
        await controller.setSleepBedtime(selected);
      }
    }

    Future<void> pickWakeTime() async {
      if (!settings.sleepReminderEnabled) return;
      final selected = await showTimePicker(
        context: context,
        initialTime:
            settings.sleepWakeTime ?? const TimeOfDay(hour: 7, minute: 0),
      );
      if (selected != null && context.mounted) {
        await controller.setSleepWakeTime(selected);
      }
    }

    return AppDialog(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogTitle(
            icon: Icons.nightlight_outlined,
            title: l10n.mineReminderSleepTitle,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationsSleepReminderTitle),
            value: settings.sleepReminderEnabled,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) => controller.setSleepReminderEnabled(value),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationsSleepBedtime),
            trailing: Text(
              _formatTimeOfDay(
                settings.sleepBedtime,
                fallback: l10n.settingsNotificationsTimeUnset,
              ),
              style: typography.bodySm.copyWith(
                color: settings.sleepReminderEnabled
                    ? surface.body
                    : surface.mute,
              ),
            ),
            enabled: settings.sleepReminderEnabled && !settingsAsync.isLoading,
            onTap: pickBedtime,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationsSleepWakeTime),
            trailing: Text(
              _formatTimeOfDay(
                settings.sleepWakeTime,
                fallback: l10n.settingsNotificationsTimeUnset,
              ),
              style: typography.bodySm.copyWith(
                color: settings.sleepReminderEnabled
                    ? surface.body
                    : surface.mute,
              ),
            ),
            enabled: settings.sleepReminderEnabled && !settingsAsync.isLoading,
            onTap: pickWakeTime,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                MaterialLocalizations.of(context).closeButtonLabel,
                style: typography.bodySmStrong.copyWith(color: surface.body),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: AppSpacingTokens.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PermissionListTile extends StatelessWidget {
  const _PermissionListTile({required this.state, required this.onTap});

  final NotificationPermissionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _dialogTypography(context);
    final isGranted = state == NotificationPermissionState.granted;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.notifications_active_outlined,
        color: isGranted ? theme.colorScheme.primary : surface.body,
        size: 20,
      ),
      title: Text(_permissionTitle(l10n, state), style: typography.bodyMd),
      subtitle: Text(
        _permissionSubtitle(l10n, state) ?? '',
        style: typography.bodySm.copyWith(color: surface.mute),
      ),
      trailing: isGranted
          ? Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            )
          : Icon(Icons.chevron_right_rounded, size: 18, color: surface.mute),
      onTap: isGranted ? null : onTap,
    );
  }
}

class _UnsupportedPermissionHint extends StatelessWidget {
  const _UnsupportedPermissionHint({
    required this.l10n,
    required this.typography,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, size: 18, color: surface.mute),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.settingsNotificationsPermissionUnsupported,
              style: typography.bodySm.copyWith(color: surface.mute),
            ),
          ),
        ],
      ),
    );
  }
}

AppTypographyScale _dialogTypography(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.sizeOf(context).width;
  return width < AppBreakpoints.mobile
      ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
      : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
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

String _formatTimeOfDay(TimeOfDay? time, {required String fallback}) {
  if (time == null) return fallback;
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
