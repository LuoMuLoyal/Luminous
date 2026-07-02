import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SleepReminderSettingsPage extends ConsumerWidget {
  const SleepReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    return FScaffold(
      childPad: false,
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(l10n.settingsNotificationsSleepReminderTitle),
          titleAlignment: Alignment.center,
          prefixes: const [AppBackButton()],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveContentFrame(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FTileGroup(
                    style: settingsSubpageTileGroupStyle(context.theme),
                    children: [
                      FTile(
                        title: Text(
                          l10n.settingsNotificationsSleepReminderTitle,
                        ),
                        subtitle: Text(
                          l10n.settingsNotificationsSleepReminderSubtitle,
                        ),
                        enabled: !settingsAsync.isLoading,
                        onPress: !settingsAsync.isLoading
                            ? () => controller.setSleepReminderEnabled(
                                !settings.sleepReminderEnabled,
                              )
                            : null,
                        suffix: FSwitch(
                          value: settings.sleepReminderEnabled,
                          enabled: !settingsAsync.isLoading,
                          onChange: settingsAsync.isLoading
                              ? null
                              : (value) =>
                                    controller.setSleepReminderEnabled(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.level5),
                  IgnorePointer(
                    ignoring: !settings.sleepReminderEnabled,
                    child: Opacity(
                      opacity: settings.sleepReminderEnabled ? 1 : 0.45,
                      child: FTileGroup(
                        style: settingsSubpageTileGroupStyle(context.theme),
                        children: [
                          FTile(
                            title: Text(l10n.settingsNotificationsSleepBedtime),
                            details: Text(
                              _formatTimeOfDay(settings.sleepBedtime),
                            ),
                            suffix: const Icon(FLucideIcons.chevronRight),
                            onPress: settings.sleepReminderEnabled
                                ? () async {
                                    final selected = await showTimePicker(
                                      context: context,
                                      initialTime:
                                          settings.sleepBedtime ??
                                          const TimeOfDay(hour: 23, minute: 0),
                                    );
                                    if (selected != null) {
                                      await controller.setSleepBedtime(
                                        selected,
                                      );
                                    }
                                  }
                                : null,
                          ),
                          FTile(
                            title: Text(
                              l10n.settingsNotificationsSleepWakeTime,
                            ),
                            details: Text(
                              _formatTimeOfDay(settings.sleepWakeTime),
                            ),
                            suffix: const Icon(FLucideIcons.chevronRight),
                            onPress: settings.sleepReminderEnabled
                                ? () async {
                                    final selected = await showTimePicker(
                                      context: context,
                                      initialTime:
                                          settings.sleepWakeTime ??
                                          const TimeOfDay(hour: 7, minute: 0),
                                    );
                                    if (selected != null) {
                                      await controller.setSleepWakeTime(
                                        selected,
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
