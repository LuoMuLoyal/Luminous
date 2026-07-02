import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AiSettingsPage extends ConsumerWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    final signedIn = settings != null;

    return PageScaffoldShell(
      title: l10n.settingsAiTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        FTileGroup(
          children: [
            FTile(
              title: Text(l10n.settingsAiSummariesTitle),
              subtitle: Text(l10n.settingsAiSummariesSubtitle),
              suffix: FSwitch(
                value: settings?.aiSummariesEnabled ?? false,
                enabled: !settingsAsync.isLoading,
                onChange: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAiSummariesEnabled(value);
                },
              ),
              enabled: !settingsAsync.isLoading,
              onPress: !settingsAsync.isLoading
                  ? () {
                      final next = !(settings?.aiSummariesEnabled ?? false);
                      if (!signedIn) {
                        pushAuthRequiredRoute(context, '/settings/ai');
                        return;
                      }
                      ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAiSummariesEnabled(next);
                    }
                  : null,
            ),
            FTile(
              title: Text(l10n.settingsAiAssistantTitle),
              subtitle: Text(l10n.settingsAiAssistantSubtitle),
              suffix: FSwitch(
                value: settings?.assistantEnabled ?? false,
                enabled: !settingsAsync.isLoading,
                onChange: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAssistantEnabled(value);
                },
              ),
              enabled: !settingsAsync.isLoading,
              onPress: !settingsAsync.isLoading
                  ? () {
                      final next = !(settings?.assistantEnabled ?? false);
                      if (!signedIn) {
                        pushAuthRequiredRoute(context, '/settings/ai');
                        return;
                      }
                      ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAssistantEnabled(next);
                    }
                  : null,
            ),
            FTile(
              title: Text(l10n.settingsAiMemoryTitle),
              subtitle: Text(l10n.settingsAiMemorySubtitle),
              suffix: FSwitch(
                value: settings?.assistantMemoryEnabled ?? false,
                enabled: !settingsAsync.isLoading,
                onChange: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAssistantMemoryEnabled(value);
                },
              ),
              enabled: !settingsAsync.isLoading,
              onPress: !settingsAsync.isLoading
                  ? () {
                      final next = !(settings?.assistantMemoryEnabled ?? false);
                      if (!signedIn) {
                        pushAuthRequiredRoute(context, '/settings/ai');
                        return;
                      }
                      ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAssistantMemoryEnabled(next);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
