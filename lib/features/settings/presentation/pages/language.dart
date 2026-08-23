import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/profile_sync.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                FTile(
                  key: const Key('language-row-system'),
                  title: Text(l10n.settingsLanguageSystemLabel),
                  subtitle: Text(
                    l10n.settingsLanguageSystemCurrentLabel(
                      _resolveCurrentLanguageName(l10n, currentLocale),
                    ),
                  ),
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
                  onPress: () =>
                      _handleLocaleTap(context, ref, l10n, AppLocale.en),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingsLanguageTitle,
      child: SingleChildScrollView(child: content),
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
    if (!context.mounted) return;
    await Toast.show(
      context,
      userMessageFromError(
        error,
        fallback: l10n.settingsSyncFailed,
        l10n: l10n,
      ),
    );
  }
}

String _resolveCurrentLanguageName(AppLocalizations l10n, AppLocale locale) {
  final resolved = locale == AppLocale.system
      ? AppLocale.fromFlutterLocale(
          WidgetsBinding.instance.platformDispatcher.locale,
        )
      : locale;
  return switch (resolved) {
    AppLocale.zhCn => l10n.settingsLanguageChineseLabel,
    AppLocale.en => l10n.settingsLanguageEnglishLabel,
    AppLocale.system => l10n.settingsLanguageChineseLabel,
  };
}
