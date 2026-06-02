import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
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
        MineSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsListRow(
                key: const Key('language-row-system'),
                title: l10n.settingsLanguageSystemLabel,
                trailing: _SelectionIcon(
                  selected: currentLocale == AppLocale.system,
                ),
                onTap: () => ref
                    .read(appLocaleControllerProvider.notifier)
                    .setLocale(AppLocale.system),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('language-row-zh'),
                title: l10n.settingsLanguageChineseLabel,
                trailing: _SelectionIcon(
                  selected: currentLocale == AppLocale.zhCn,
                ),
                onTap: () => ref
                    .read(appLocaleControllerProvider.notifier)
                    .setLocale(AppLocale.zhCn),
                showDivider: true,
              ),
              SettingsListRow(
                key: const Key('language-row-en'),
                title: l10n.settingsLanguageEnglishLabel,
                trailing: _SelectionIcon(
                  selected: currentLocale == AppLocale.en,
                ),
                onTap: () => ref
                    .read(appLocaleControllerProvider.notifier)
                    .setLocale(AppLocale.en),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionIcon extends StatelessWidget {
  const _SelectionIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Icon(
      selected ? Icons.check_rounded : Icons.circle_outlined,
      size: 18,
      color: selected ? theme.colorScheme.primary : surface.mute,
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
