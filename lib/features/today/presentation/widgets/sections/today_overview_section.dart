import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayOverviewSection extends StatelessWidget {
  const TodayOverviewSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final items = buildOverviewItems(l10n, dashboard);

    return FCard.raw(
      key: const Key('today-health-summary-card'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.md,
          AppSpacingTokens.sm,
          AppSpacingTokens.md,
          AppSpacingTokens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FLucideIcons.badgeCheck,
                  color: Color(0xFF0F766E),
                  size: AppSpacingTokens.lg,
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                Expanded(
                  child: Text(
                    l10n.todayHealthSummaryCardTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 22,
                    width: 96,
                    radius: AppRadiusTokens.pill,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) => FButton(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.xs,
                      onPress: () => ref.invalidate(todayDashboardProvider),
                      prefix: Icon(
                        FLucideIcons.refreshCw,
                        size: 14,
                        color: colors.primary,
                      ),
                      child: Text(
                        l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var index = 0; index < items.length; index += 1) ...[
                  Expanded(child: _OverviewMetric(item: items[index])),
                  if (index < items.length - 1)
                    const _VerticalMetricDivider(height: AppSpacingTokens.x3l),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.item});

  final TodayOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: AppSpacingTokens.md),
          const SizedBox(width: AppSpacingTokens.xs),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 18,
                    width: 44,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.value,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalMetricDivider extends StatelessWidget {
  const _VerticalMetricDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SizedBox(
      height: height,
      child: VerticalDivider(width: 1, thickness: 1, color: colors.border),
    );
  }
}
