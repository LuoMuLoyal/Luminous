import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/settings_profile_sync_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffoldShell(
      title: l10n.mineSettingsAdvancedTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        FTileGroup(
          children: [
            FTile(
              key: const Key('advanced-settings-row-clear-cache'),
              title: Text(l10n.settingsAdvancedClearImageCache),
              onPress: () async {
                imageCache.clear();
                imageCache.clearLiveImages();
                await AppToast.show(context, l10n.settingsAdvancedCacheCleared);
              },
            ),
            FTile(
              key: const Key('advanced-settings-row-reset-defaults'),
              title: Text(l10n.settingsAdvancedResetDefaults),
              onPress: () async {
                await ref
                    .read(appThemeControllerProvider.notifier)
                    .setMode(AppThemeModePreference.system);
                try {
                  await ref
                      .read(settingsProfileSyncProvider.notifier)
                      .resetProfilePreferences();
                } catch (_) {
                  await ref
                      .read(appLocaleControllerProvider.notifier)
                      .setLocale(AppLocale.system);
                }
                await ref
                    .read(notificationSettingsControllerProvider.notifier)
                    .reset();
                if (!context.mounted) {
                  return;
                }
                await AppToast.show(
                  context,
                  l10n.settingsAdvancedDefaultsReset,
                );
              },
            ),
            FTile(
              key: const Key('advanced-settings-row-licenses'),
              title: Text(l10n.settingsAdvancedOpenSourceLicenses),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => showLicensePage(
                context: context,
                applicationName: 'Luminous',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
