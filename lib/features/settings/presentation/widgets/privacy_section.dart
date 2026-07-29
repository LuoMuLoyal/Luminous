import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/settings/presentation/widgets/navigation_tile.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Privacy settings section: AI, data sharing consent, and data export.
class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key, required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = signedIn
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsPrivacySectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            SettingsNavigationTile(
              tileKey: const Key('settings-row-ai'),
              icon: SemanticIcons.aiEntry,
              title: l10n.settingsAiTitle,
              subtitle: l10n.settingsAiSubtitle,
              onTap: () {
                if (!signedIn) {
                  unawaited(pushAuthRequiredRoute(context, Routes.settings));
                  return;
                }
                unawaited(context.push(Routes.settingsAi));
              },
            ),
            FTile(
              key: const Key('settings-row-privacy-report'),
              title: Text(l10n.minePrivacyReportTitle),
              subtitle: Text(l10n.minePrivacyReportSubtitle),
              prefix: const Icon(
                SemanticIcons.actionShare,
                size: IconSizeTokens.level3,
              ),
              suffix: FSwitch(
                value: settings?.dataSharingConsent ?? false,
                onChange: (value) async {
                  if (!signedIn) {
                    unawaited(pushAuthRequiredRoute(context, Routes.settings));
                    return;
                  }
                  final confirmed = await _showDataSharingConfirmation(
                    context,
                    value,
                  );
                  if (!context.mounted) return;
                  if (confirmed) {
                    unawaited(
                      ref
                          .read(userSettingsControllerProvider.notifier)
                          .setDataSharingConsent(value),
                    );
                  }
                },
              ),
              onPress: () async {
                final currentValue = settings?.dataSharingConsent ?? false;
                if (!signedIn) {
                  unawaited(pushAuthRequiredRoute(context, Routes.settings));
                  return;
                }
                final confirmed = await _showDataSharingConfirmation(
                  context,
                  !currentValue,
                );
                if (!context.mounted) return;
                if (confirmed) {
                  unawaited(
                    ref
                        .read(userSettingsControllerProvider.notifier)
                        .setDataSharingConsent(!currentValue),
                  );
                }
              },
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-export'),
              icon: SemanticIcons.actionExport,
              title: l10n.mineSettingExportTitle,
              onTap: () {
                if (!signedIn) {
                  unawaited(pushAuthRequiredRoute(context, Routes.settings));
                  return;
                }
                unawaited(context.push(Routes.settingsExport));
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _showDataSharingConfirmation(
    BuildContext context,
    bool value,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return await showAppDialog<bool>(
          context: context,
          maxWidth: 440,
          scrollable: false,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDataSharingConfirmTitle,
                style: TypographyToken.level6.body(context),
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.settingsDataSharingConfirmDescription,
                style: TypographyToken.level4.body(context),
              ),
              const SizedBox(height: Spacing.level5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(false),
                    child: Text(l10n.settingsDataSharingCancelAction),
                  ),
                  const SizedBox(width: Spacing.level2),
                  FButton(
                    onPress: () => Navigator.of(context).pop(true),
                    child: Text(l10n.settingsDataSharingConfirmAction),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }
}
