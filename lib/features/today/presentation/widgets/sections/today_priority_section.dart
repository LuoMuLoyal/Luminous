import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

class TodayPrioritySection extends ConsumerWidget {
  const TodayPrioritySection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  void _handleItemTap(
    BuildContext context,
    WidgetRef ref,
    TodayViewPriorityItem item,
  ) {
    switch (item.type) {
      case TodayPriorityItemType.medication:
        context.go(AppRoutes.medicine);
      case TodayPriorityItemType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildPriorityItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayPrioritySectionTitle,
      actionLabel: l10n.todayManageAction,
      onAction: () => context.go(AppRoutes.record),
      child: FCard.raw(
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _PriorityRow(
                item: items[index],
                onTap: () => _handleItemTap(context, ref, items[index]),
              ),
              if (index < items.length - 1) const AppDivider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriorityRow extends ConsumerWidget {
  const _PriorityRow({required this.item, required this.onTap});

  final TodayViewPriorityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FTappable(
      key: item.key,
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TodayGlyphTile(
              icon: item.icon,
              color: item.color.resolve(colors),
              size: AppSpacingTokens.level7,
              radius: AppRadiusTokens.level3,
              gradient: false,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    item.subtitle,
                    style: typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.progress != null) ...[
                    const SizedBox(height: AppSpacingTokens.level2),
                    FDeterminateProgress(
                      value: item.progress!,
                      style: .delta(
                        constraints: const BoxConstraints(
                          minWidth: double.infinity,
                        ),
                        trackDecoration: .shapeDelta(color: colors.primary),
                        fillDecoration: .value(
                          ShapeDecoration(
                            shape: RoundedSuperellipseBorder(
                              borderRadius:
                                  context.theme.style.borderRadius.pill,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                item.color
                                    .resolve(colors)
                                    .withValues(alpha: 0.82),
                                item.color.resolve(colors),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppSkeletonText(
                    text: item.detail,
                    style: typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.76,
                  ),
                  const SizedBox(height: AppSpacingTokens.level2),
                  _PriorityActionPill(item: item, onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityActionPill extends ConsumerWidget {
  const _PriorityActionPill({required this.item, required this.onTap});

  final TodayViewPriorityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72),
      child: FButton(
        onPress: onTap,
        variant: FButtonVariant.primary,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        style: .delta(
          decoration: .delta([
            .all(.shapeDelta(color: item.color.resolve(colors))),
          ]),
        ),
        child: Text(item.action, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
