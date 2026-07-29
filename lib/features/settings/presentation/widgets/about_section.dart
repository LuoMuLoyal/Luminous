import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/settings/presentation/widgets/navigation_tile.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// About section: help and about links.
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key, required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsAboutSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            SettingsNavigationTile(
              tileKey: const Key('settings-row-help'),
              icon: SemanticIcons.actionHelp,
              title: l10n.mineSettingHelpTitle,
              onTap: () => context.push(Routes.settingsHelp),
            ),
            SettingsNavigationTile(
              tileKey: const Key('settings-row-about'),
              icon: SemanticIcons.statusInfo,
              title: l10n.mineSettingAboutTitle,
              onTap: () => context.push(Routes.settingsAbout),
            ),
          ],
        ),
      ],
    );
  }
}
