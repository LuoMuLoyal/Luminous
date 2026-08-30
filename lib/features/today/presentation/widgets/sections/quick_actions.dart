import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/application/usecases/quick_entry_water.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayQuickActionsSection extends ConsumerWidget {
  const TodayQuickActionsSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final actions = buildQuickActionItems(
      l10n,
      dashboard,
      onWaterQuickEntry: () => executeTodayWaterQuickEntry(context, ref),
    );
    // First 2 are primary, rest are secondary.
    final primaryActions = actions.take(2).toList();
    final secondaryActions = actions.skip(2).toList();

    return TodaySection(
      title: l10n.todayQuickActionSectionTitle,
      child: Column(
        children: [
          FTileGroup(
            key: const Key('today-quick-actions-primary'),
            divider: FItemDivider.full,
            children: [
              for (final action in primaryActions)
                FTile(
                  prefix: Icon(
                    action.icon,
                    size: IconSizeTokens.level3,
                    color: SemanticColor.primary.solid(context),
                  ),
                  title: Text(action.title),
                  subtitle: Text(action.subtitle),
                  details: action.badge != null
                      ? FBadge(
                          variant: FBadgeVariant.outline,
                          child: Text(action.badge!),
                        )
                      : null,
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => _handleAction(context, ref, action),
                ),
            ],
          ),
          if (secondaryActions.isNotEmpty) ...[
            const SizedBox(height: Spacing.level3),
            FTileGroup(
              key: const Key('today-quick-actions-secondary'),
              divider: FItemDivider.full,
              children: [
                for (final action in secondaryActions)
                  FTile(
                    prefix: Icon(
                      action.icon,
                      size: IconSizeTokens.level3,
                      color: SemanticColor.neutral.solid(context),
                    ),
                    title: Text(action.title),
                    subtitle: Text(action.subtitle),
                    suffix: const Icon(SemanticIcons.actionNext),
                    onPress: () => _handleAction(context, ref, action),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    TodayQuickActionItem action,
  ) {
    if (action.onTap != null) {
      action.onTap!();
      return;
    }
    if (action.usePush) {
      unawaited(context.push(action.route));
    } else {
      context.go(action.route);
    }
  }
}
