import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/core/design/design.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final infoAsync = ref.watch(appInfoProvider);
    final description = infoAsync.asData?.value?.description;
    final supportEmail = infoAsync.asData?.value?.supportEmail;
    final buildDate = infoAsync.asData?.value?.buildDate;

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < Breakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: Spacing.level4),
                  Text(
                    infoAsync.asData?.value?.name ?? 'Luminous',
                    style: TypographyToken.level6
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    '${l10n.mineSettingAboutValue} ${infoAsync.asData?.value?.version ?? ''}',
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                  if (buildDate != null && buildDate.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level1),
                    Text(
                      l10n.settingsAboutBuildNumberLabel(buildDate),
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level3),
                    Text(
                      description,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.foreground),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.level5),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                FTile(
                  title: Text(l10n.settingsAboutPrivacyPolicy),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push('${AppRoutes.legal}/privacy'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutTermsOfService),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push('${AppRoutes.legal}/terms'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutLicenses),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => showLicensePage(
                    context: context,
                    applicationName:
                        infoAsync.asData?.value?.name ?? 'Luminous',
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
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingAboutTitle,
      child: SingleChildScrollView(child: content),
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
