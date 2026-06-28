import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_settings_navigation_row.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/app_back_button.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);
    final infoAsync = ref.watch(appInfoProvider);
    final description = infoAsync.asData?.value?.description;

    return PageScaffoldShell(
      title: l10n.mineSettingAboutTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        AppSectionSurface(
          surface: surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: surface.canvasSoft2,
                child: Icon(
                  Icons.local_hospital_outlined,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Text(
                infoAsync.asData?.value?.name ?? 'Luminous',
                style: typography.displaySm,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                '${l10n.mineSettingAboutValue} ${infoAsync.asData?.value?.version ?? ''}',
                style: typography.bodySm.copyWith(color: surface.mute),
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  description,
                  style: typography.bodySm.copyWith(color: surface.body),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsNavigationRow(
                title: l10n.settingsAboutPrivacyPolicy,
                onTap: () => _openUrl(context, 'https://luminous.app/privacy'),
                showDivider: true,
              ),
              AppSettingsNavigationRow(
                title: l10n.settingsAboutTermsOfService,
                onTap: () => _openUrl(context, 'https://luminous.app/terms'),
                showDivider: true,
              ),
              AppSettingsNavigationRow(
                title: l10n.settingsAboutLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: infoAsync.asData?.value?.name ?? 'Luminous',
                ),
                showDivider: true,
              ),
              AppSettingsNavigationRow(
                title: l10n.settingsAboutSupport,
                onTap: () => _openUrl(context, 'https://luminous.app/support'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await const ExternalUrlLauncher().open(uri);
    }
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
