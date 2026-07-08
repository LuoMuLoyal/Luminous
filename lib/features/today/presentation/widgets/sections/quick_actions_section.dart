import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayQuickActionsSection extends StatelessWidget {
  const TodayQuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = buildQuickActionItems(l10n);

    return TodaySection(
      title: l10n.todayQuickActionSectionTitle,
      child: FTileGroup(
        key: const Key('today-quick-actions-card'),
        divider: FItemDivider.full,
        children: [
          for (final action in actions)
            FTile(
              prefix: Icon(action.icon, size: AppSpacingTokens.level5),
              title: Text(action.title),
              subtitle: Text(action.subtitle),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => action.usePush
                  ? context.push(action.route)
                  : context.go(action.route),
            ),
        ],
      ),
    );
  }
}
