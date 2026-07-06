import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/accessibility/accessibility_settings_controller.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/settings_profile_sync_provider.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/theme/theme.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final width = MediaQuery.sizeOf(context).width;

    return PageScaffold(
      title: l10n.mineSettingsAdvancedTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < AppBreakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      key: const Key('advanced-settings-row-clear-cache'),
                      title: Text(l10n.settingsAdvancedClearImageCache),
                      onPress: () async {
                        imageCache.clear();
                        imageCache.clearLiveImages();
                        await AppToast.show(
                          context,
                          l10n.settingsAdvancedCacheCleared,
                        );
                      },
                    ),
                    FTile(
                      key: const Key('advanced-settings-row-reset-defaults'),
                      title: Text(l10n.settingsAdvancedResetDefaults),
                      onPress: () async {
                        await ref
                            .read(appThemeControllerProvider.notifier)
                            .setMode(AppThemeModePreference.system);
                        await ref
                            .read(appThemeControllerProvider.notifier)
                            .setFamily(appDefaultThemeFamily);
                        try {
                          await ref
                              .read(settingsProfileSyncProvider.notifier)
                              .resetProfilePreferences();
                        } catch (e) {
                          debugPrint(
                            'AdvancedSettingsPage: resetProfilePreferences failed: $e',
                          );
                          await ref
                              .read(appLocaleControllerProvider.notifier)
                              .setLocale(AppLocale.system);
                        }
                        await ref
                            .read(
                              notificationSettingsControllerProvider.notifier,
                            )
                            .reset();
                        await ref
                            .read(
                              accessibilitySettingsControllerProvider.notifier,
                            )
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
            ),
          ),
        ),
      ),
    );
  }
}
