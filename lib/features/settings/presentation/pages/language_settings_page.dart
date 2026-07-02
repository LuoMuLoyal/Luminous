import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/providers/settings_profile_sync_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;

    return PageScaffoldShell(
      title: l10n.mineSettingsLanguageTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        FTileGroup(
          style: settingsSubpageTileGroupStyle(context.theme),
          children: [
            FTile(
              key: const Key('language-row-system'),
              title: Text(l10n.settingsLanguageSystemLabel),
              suffix: SettingsSelectionIcon(
                selected: currentLocale == AppLocale.system,
              ),
              onPress: () =>
                  _handleLocaleTap(context, ref, l10n, AppLocale.system),
            ),
            FTile(
              key: const Key('language-row-zh'),
              title: Text(l10n.settingsLanguageChineseLabel),
              suffix: SettingsSelectionIcon(
                selected: currentLocale == AppLocale.zhCn,
              ),
              onPress: () =>
                  _handleLocaleTap(context, ref, l10n, AppLocale.zhCn),
            ),
            FTile(
              key: const Key('language-row-en'),
              title: Text(l10n.settingsLanguageEnglishLabel),
              suffix: SettingsSelectionIcon(
                selected: currentLocale == AppLocale.en,
              ),
              onPress: () => _handleLocaleTap(context, ref, l10n, AppLocale.en),
            ),
          ],
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
