import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/domain/services/version_check.dart';
import 'package:luminous/features/settings/presentation/providers/package_info.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  ConsumerState<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

/// State for the check-update tile.
///
/// idle → checking → upToDate / updateAvailable / checkFailed
enum _CheckState { idle, checking, upToDate, updateAvailable, checkFailed }

class _AboutSettingsPageState extends ConsumerState<AboutSettingsPage> {
  _CheckState _checkState = _CheckState.idle;
  String? _latestVersion;

  Future<void> _checkForUpdate() async {
    setState(() => _checkState = _CheckState.checking);

    try {
      // Invalidate to force a fresh fetch.
      ref.invalidate(appInfoProvider);
      final appInfo = await ref.read(appInfoProvider.future);
      final latestVersion = appInfo?.latestVersion;
      final downloadUrl = appInfo?.downloadUrl;

      if (latestVersion == null || latestVersion.isEmpty) {
        setState(() => _checkState = _CheckState.checkFailed);
        return;
      }

      final pkg = await ref.read(packageInfoProvider.future);
      final currentVersion = pkg.version;

      if (compareSemver(currentVersion, latestVersion) < 0) {
        _latestVersion = latestVersion;
        setState(() => _checkState = _CheckState.updateAvailable);
        // Open the download URL if available.
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          final uri = Uri.tryParse(downloadUrl);
          if (uri != null) {
            await const ExternalUrlLauncher().open(uri);
          }
        }
      } else {
        setState(() => _checkState = _CheckState.upToDate);
      }
    } catch (e) {
      appTalker.warning('AboutSettings: version check failed: $e');
      if (mounted) {
        setState(() => _checkState = _CheckState.checkFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final infoAsync = ref.watch(appInfoProvider);
    final supportEmail = infoAsync.asData?.value?.supportEmail;

    final pkgAsync = ref.watch(packageInfoProvider);
    final pkg = pkgAsync.asData?.value;
    final appName = pkg?.appName.isNotEmpty == true ? pkg!.appName : 'Luminous';
    final version = pkg?.version ?? '';
    final buildNumber = pkg?.buildNumber ?? '';
    final typography = context.theme.typography;

    // Resolve the subtitle for the check-update tile.
    Widget? checkUpdateSubtitle;
    switch (_checkState) {
      case _CheckState.idle:
        checkUpdateSubtitle = null;
      case _CheckState.checking:
        checkUpdateSubtitle = Text(l10n.settingsAboutCheckUpdateChecking);
      case _CheckState.upToDate:
        checkUpdateSubtitle = Text(
          l10n.settingsAboutCheckUpdateUpToDate,
          style: TextStyle(color: SemanticColor.success.solid(context)),
        );
      case _CheckState.updateAvailable:
        checkUpdateSubtitle = Text(
          l10n.settingsAboutCheckUpdateAvailable(_latestVersion ?? ''),
          style: TextStyle(color: SemanticColor.warning.solid(context)),
        );
      case _CheckState.checkFailed:
        checkUpdateSubtitle = Text(
          l10n.settingsAboutCheckUpdateFailed,
          style: TextStyle(color: SemanticColor.destructive.solid(context)),
        );
    }

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
                            style: typography.body.lg.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (version.isNotEmpty) ...[
                            const SizedBox(height: Spacing.level1),
                            Text(
                              buildNumber.isNotEmpty
                                  ? '${l10n.settingsAboutVersionLabel(version)} · ${l10n.settingsAboutBuildLabel(buildNumber)}'
                                  : l10n.settingsAboutVersionLabel(version),
                              style: typography.body.xs.copyWith(
                                color: SemanticColor.neutral.solid(context),
                              ),
                            ),
                          ],
                          const SizedBox(height: Spacing.level1),
                          Text(
                            l10n.settingsAboutTagline,
                            style: typography.body.xs.copyWith(
                              color: SemanticColor.neutral.solid(context),
                            ),
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
                  title: Text(l10n.settingsAboutCheckUpdate),
                  subtitle: checkUpdateSubtitle,
                  suffix: _checkState == _CheckState.checking
                      ? SizedBox(
                          width: IconSizeTokens.level3,
                          height: IconSizeTokens.level3,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SemanticColor.neutral.solid(context),
                          ),
                        )
                      : const Icon(SemanticIcons.actionRefresh),
                  onPress: _checkState == _CheckState.checking
                      ? null
                      : _checkForUpdate,
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
