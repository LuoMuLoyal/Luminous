import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
        context.go('/medicine');
      case TodayPriorityItemType.water:
        context.push('/record/create?kind=water');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final items = buildPriorityItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayPrioritySectionTitle,
      actionLabel: l10n.todayManageAction,
      onAction: () => context.go('/record'),
      child: FCard.raw(
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _PriorityRow(
                item: items[index],
                onTap: () => _handleItemTap(context, ref, items[index]),
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x5l,
                  color: colors.border,
                ),
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
    final textTheme = Theme.of(context).textTheme;

    return AppInkWell(
      key: item.key,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TodayGlyphTile(
            icon: item.icon,
            color: item.color,
            size: AppSpacingTokens.x2l,
            radius: AppRadiusTokens.md,
            gradient: false,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.progress != null) ...[
                  const SizedBox(height: AppSpacingTokens.xs),
                  TodayLinearProgress(
                    progress: item.progress!,
                    color: item.color,
                    height: 5,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          SizedBox(
            width: 82,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppSkeletonText(
                  text: item.detail,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.76,
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                _PriorityActionPill(item: item, onTap: onTap),
              ],
            ),
          ),
        ],
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
    final textTheme = Theme.of(context).textTheme;

    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.sm,
            vertical: AppSpacingTokens.xs,
          ),
          child: Text(
            item.action,
            style: textTheme.labelMedium?.copyWith(
              color: AppColorTokens.onPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
