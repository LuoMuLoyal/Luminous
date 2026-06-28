import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_setting_row.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/settings_profile_sync_provider.dart';
import 'package:luminous/core/widgets/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return PageScaffoldShell(
      title: l10n.mineSettingsAdvancedTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('advanced-settings-row-clear-cache'),
                title: l10n.settingsAdvancedClearImageCache,
                icon: Icons.image_outlined,
                onTap: () async {
                  imageCache.clear();
                  imageCache.clearLiveImages();
                  await AppToast.show(
                    context,
                    l10n.settingsAdvancedCacheCleared,
                  );
                },
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('advanced-settings-row-reset-defaults'),
                title: l10n.settingsAdvancedResetDefaults,
                icon: Icons.refresh_rounded,
                onTap: () async {
                  await ref
                      .read(appThemeControllerProvider.notifier)
                      .setMode(AppThemeModePreference.system);
                  await ref
                      .read(appThemePaletteControllerProvider.notifier)
                      .setPalette(AppThemePalettePreference.classic);
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
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('advanced-settings-row-licenses'),
                title: l10n.settingsAdvancedOpenSourceLicenses,
                icon: Icons.description_outlined,
                showChevron: true,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Luminous',
                ),
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
