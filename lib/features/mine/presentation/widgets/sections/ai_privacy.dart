import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineAiPrivacySection extends StatelessWidget {
  const MineAiPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const Key('mine-ai-privacy-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineAiPrivacySectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          divider: FItemDivider.full,
          children: [
            FTile(
              key: const Key('mine-ai-settings-tile'),
              prefix: Icon(
                SemanticIcons.aiEntry,
                color: SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
              title: Text(l10n.settingsAiTitle),
              subtitle: Text(
                l10n.settingsAiSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => pushAuthRequiredRoute(context, Routes.settingsAi),
            ),
            FTile(
              key: const Key('mine-privacy-report-tile'),
              prefix: Icon(
                SemanticIcons.actionShare,
                color: SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
              title: Text(l10n.minePrivacyReportTitle),
              subtitle: Text(
                l10n.minePrivacyReportSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () =>
                  pushAuthRequiredRoute(context, Routes.settingsExport),
            ),
          ],
        ),
      ],
    );
  }
}
