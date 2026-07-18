import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
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

    return PageScaffold(
      title: l10n.settingsNotificationsSleepReminderTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.level6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsNotificationsSleepReminderTitle),
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
                const SizedBox(height: Spacing.level5),
                IgnorePointer(
                  ignoring: !settings.sleepReminderEnabled,
                  child: Opacity(
                    opacity: settings.sleepReminderEnabled ? 1 : 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTimeField.picker(
                          label: Text(l10n.settingsNotificationsSleepBedtime),
                          enabled: settings.sleepReminderEnabled,
                          control: FTimeFieldControl.lifted(
                            time:
                                settings.sleepBedtime?.toFTime() ??
                                const FTime(23, 0),
                            onChange: (value) => controller.setSleepBedtime(
                              value?.toTimeOfDay(),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.level3),
                        FTimeField.picker(
                          label: Text(l10n.settingsNotificationsSleepWakeTime),
                          enabled: settings.sleepReminderEnabled,
                          control: FTimeFieldControl.lifted(
                            time:
                                settings.sleepWakeTime?.toFTime() ??
                                const FTime(7, 0),
                            onChange: (value) => controller.setSleepWakeTime(
                              value?.toTimeOfDay(),
                            ),
                          ),
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
    );
  }
}

extension _SleepReminderTimeOfDay on TimeOfDay {
  FTime toFTime() => FTime(hour, minute);
}

extension _SleepReminderFTime on FTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
