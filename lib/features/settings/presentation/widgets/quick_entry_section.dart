import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/settings/presentation/widgets/navigation_tile.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Quick entry settings section.
class QuickEntrySection extends StatelessWidget {
  const QuickEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsQuickEntrySection),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            SettingsNavigationTile(
              tileKey: const Key('settings-row-quick-entry'),
              icon: SemanticIcons.tabRecord,
              title: l10n.settingsQuickEntrySection,
              subtitle: l10n.settingsQuickEntrySubtitle,
              onTap: () => context.push(Routes.recordQuickEntrySettings),
            ),
          ],
        ),
      ],
    );
  }
}
