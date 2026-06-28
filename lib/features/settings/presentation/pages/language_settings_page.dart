import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_setting_row.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/providers/settings_profile_sync_provider.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_selection_icon.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;

    return PageScaffoldShell(
      title: l10n.mineSettingsLanguageTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('language-row-system'),
                title: l10n.settingsLanguageSystemLabel,
                trailing: SettingsSelectionIcon(
                  selected: currentLocale == AppLocale.system,
                ),
                onTap: () =>
                    _handleLocaleTap(context, ref, l10n, AppLocale.system),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('language-row-zh'),
                title: l10n.settingsLanguageChineseLabel,
                trailing: SettingsSelectionIcon(
                  selected: currentLocale == AppLocale.zhCn,
                ),
                onTap: () =>
                    _handleLocaleTap(context, ref, l10n, AppLocale.zhCn),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('language-row-en'),
                title: l10n.settingsLanguageEnglishLabel,
                trailing: SettingsSelectionIcon(
                  selected: currentLocale == AppLocale.en,
                ),
                onTap: () => _handleLocaleTap(context, ref, l10n, AppLocale.en),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _handleLocaleTap(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  AppLocale locale,
) async {
  try {
    await ref.read(settingsProfileSyncProvider.notifier).setLocale(locale);
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    final message = LucentErrorMapper.fromObject(error).message;
    await AppToast.show(
      context,
      message.isNotEmpty ? message : l10n.settingsSyncFailed,
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
