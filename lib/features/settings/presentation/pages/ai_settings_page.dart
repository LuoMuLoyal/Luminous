import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/settings/app_settings_switch_row.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    final signedIn = settings != null;

    return PageScaffoldShell(
      title: l10n.settingsAiTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsSwitchRow(
                title: l10n.settingsAiSummariesTitle,
                subtitle: l10n.settingsAiSummariesSubtitle,
                value: settings?.aiSummariesEnabled ?? false,
                onChanged: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAiSummariesEnabled(value);
                },
                enabled: !settingsAsync.isLoading,
                showDivider: true,
              ),
              AppSettingsSwitchRow(
                title: l10n.settingsAiAssistantTitle,
                subtitle: l10n.settingsAiAssistantSubtitle,
                value: settings?.assistantEnabled ?? false,
                onChanged: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAssistantEnabled(value);
                },
                enabled: !settingsAsync.isLoading,
                showDivider: true,
              ),
              AppSettingsSwitchRow(
                title: l10n.settingsAiMemoryTitle,
                subtitle: l10n.settingsAiMemorySubtitle,
                value: settings?.assistantMemoryEnabled ?? false,
                onChanged: (value) {
                  if (!signedIn) {
                    pushAuthRequiredRoute(context, '/settings/ai');
                    return;
                  }
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .setAssistantMemoryEnabled(value);
                },
                enabled: !settingsAsync.isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
