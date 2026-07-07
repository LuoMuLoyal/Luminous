import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/spacing_tokens.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DndSettingsPage extends ConsumerWidget {
  const DndSettingsPage({super.key});

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
      title: l10n.settingsNotificationsDndTitle,
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
                      title: Text(l10n.settingsNotificationsDndEnabled),
                      subtitle: Text(l10n.settingsNotificationsDndSubtitle),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () => controller.setDndEnabled(!settings.dndEnabled)
                          : null,
                      suffix: FSwitch(
                        value: settings.dndEnabled,
                        enabled: !settingsAsync.isLoading,
                        onChange: settingsAsync.isLoading
                            ? null
                            : (value) => controller.setDndEnabled(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level5),
                IgnorePointer(
                  ignoring: !settings.dndEnabled,
                  child: Opacity(
                    opacity: settings.dndEnabled ? 1 : 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FTimeField.picker(
                          label: Text(l10n.settingsNotificationsDndStart),
                          enabled: settings.dndEnabled,
                          control: FTimeFieldControl.lifted(
                            time:
                                settings.dndStartTime?.toFTime() ??
                                const FTime(22, 0),
                            onChange: (value) => controller.setDndStartTime(
                              value?.toTimeOfDay(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.level3),
                        FTimeField.picker(
                          label: Text(l10n.settingsNotificationsDndEnd),
                          enabled: settings.dndEnabled,
                          control: FTimeFieldControl.lifted(
                            time:
                                settings.dndEndTime?.toFTime() ??
                                const FTime(7, 0),
                            onChange: (value) =>
                                controller.setDndEndTime(value?.toTimeOfDay()),
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

extension _DndTimeOfDay on TimeOfDay {
  FTime toFTime() => FTime(hour, minute);
}

extension _DndFTime on FTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
