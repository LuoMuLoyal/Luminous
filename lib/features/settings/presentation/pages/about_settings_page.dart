import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final infoAsync = ref.watch(appInfoProvider);
    final description = infoAsync.asData?.value?.description;
    final supportEmail = infoAsync.asData?.value?.supportEmail;

    return PageScaffoldShell(
      title: l10n.mineSettingAboutTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        FCard.raw(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FAvatar.raw(
                size: 80,
                child: Icon(
                  FLucideIcons.heartPulse,
                  size: 36,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                infoAsync.asData?.value?.name ?? 'Luminous',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Text(
                '${l10n.mineSettingAboutValue} ${infoAsync.asData?.value?.version ?? ''}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              if (infoAsync.asData?.value?.buildDate.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  l10n.settingsAboutBuildNumberLabel(
                    infoAsync.asData!.value!.buildDate,
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.level3),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level5),
        FTileGroup(
          style: settingsSubpageTileGroupStyle(context.theme),
          children: [
            FTile(
              title: Text(l10n.settingsAboutPrivacyPolicy),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _openUrl(
                context,
                infoAsync.asData?.value?.privacyPolicyUrl ??
                    'https://luminous.app/privacy',
              ),
            ),
            FTile(
              title: Text(l10n.settingsAboutTermsOfService),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _openUrl(
                context,
                infoAsync.asData?.value?.termsOfServiceUrl ??
                    'https://luminous.app/terms',
              ),
            ),
            FTile(
              title: Text(l10n.settingsAboutLicenses),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => showLicensePage(
                context: context,
                applicationName: infoAsync.asData?.value?.name ?? 'Luminous',
              ),
            ),
            FTile(
              title: Text(l10n.settingsAboutSupport),
              subtitle: supportEmail == null || supportEmail.isEmpty
                  ? null
                  : Text(supportEmail),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _openSupport(context, infoAsync.asData?.value),
            ),
          ],
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

  Future<void> _openSupport(BuildContext context, AppInfoDataDto? info) async {
    final email = info?.supportEmail;
    if (email != null && email.isNotEmpty) {
      await const ExternalUrlLauncher().open(
        Uri(scheme: 'mailto', path: email),
      );
      return;
    }
    await _openUrl(context, 'https://luminous.app/support');
  }
}
