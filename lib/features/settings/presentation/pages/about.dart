import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/package_info.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final infoAsync = ref.watch(appInfoProvider);
    final supportEmail = infoAsync.asData?.value?.supportEmail;

    final pkgAsync = ref.watch(packageInfoProvider);
    final pkg = pkgAsync.asData?.value;
    final appName = pkg?.appName.isNotEmpty == true ? pkg!.appName : 'Luminous';
    final version = pkg?.version ?? '';
    final buildNumber = pkg?.buildNumber ?? '';

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
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.level5),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(width: Spacing.level4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: TypographyToken.level6
                                .body(context)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (version.isNotEmpty) ...[
                            const SizedBox(height: Spacing.level1),
                            Text(
                              buildNumber.isNotEmpty
                                  ? '${l10n.settingsAboutVersionLabel(version)} · ${l10n.settingsAboutBuildLabel(buildNumber)}'
                                  : l10n.settingsAboutVersionLabel(version),
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                            ),
                          ],
                          const SizedBox(height: Spacing.level1),
                          Text(
                            l10n.settingsAboutTagline,
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.level5),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                FTile(
                  title: Text(l10n.settingsAboutPrivacyPolicy),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push('${Routes.legal}/privacy'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutTermsOfService),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push('${Routes.legal}/terms'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutDisclaimer),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push('${Routes.legal}/disclaimer'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutMinorProtection),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () =>
                      context.push('${Routes.legal}/minor-protection'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutSdkList),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push('${Routes.legal}/sdk-list'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutPermissions),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push('${Routes.legal}/permissions'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutAccountCancellation),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () =>
                      context.push('${Routes.legal}/account-cancellation'),
                ),
                FTile(
                  title: Text(l10n.settingsAboutLicenses),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => showLicensePage(
                    context: context,
                    applicationName: appName,
                  ),
                ),
                FTile(
                  title: Text(l10n.settingsAboutSupport),
                  subtitle: supportEmail == null || supportEmail.isEmpty
                      ? null
                      : Text(supportEmail),
                  suffix: const Icon(SemanticIcons.actionExternalLink),
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

  Future<void> _openSupport(BuildContext context, AppInfo? info) async {
    final email = info?.supportEmail;
    if (email != null && email.isNotEmpty) {
      await const ExternalUrlLauncher().open(
        Uri(scheme: 'mailto', path: email),
      );
      return;
    }
    await _openUrl(context, kFallbackSupportUrl);
  }
}
