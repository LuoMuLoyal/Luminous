import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class TodayOverviewSection extends StatelessWidget {
  const TodayOverviewSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = buildOverviewItems(l10n, dashboard);

    return FCard.raw(
      key: const Key('today-health-summary-card'),
      style: todayCardStyle(context, tone: TodayCardTone.emphasis),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.level4,
          AppSpacingTokens.level3,
          AppSpacingTokens.level4,
          AppSpacingTokens.level3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FLucideIcons.badgeCheck,
                  color: context.theme.colors.primary,
                  size: AppSpacingTokens.level5,
                ),
                const SizedBox(width: AppSpacingTokens.level2),
                Expanded(
                  child: Text(
                    l10n.todayHealthSummaryCardTitle,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 22,
                    width: 96,
                    radius: AppRadiusTokens.levelFull,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) => FButton(
                      variant: FButtonVariant.secondary,
                      size: FButtonSizeVariant.xs,
                      onPress: () => ref.invalidate(todayDashboardProvider),
                      prefix: const Icon(FLucideIcons.refreshCw, size: 14),
                      child: Text(
                        l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var index = 0; index < items.length; index += 1) ...[
                  Expanded(child: _OverviewMetric(item: items[index])),
                  if (index < items.length - 1)
                    const _VerticalMetricDivider(
                      height: AppSpacingTokens.level8,
                    ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: item.color.resolve(colors),
            size: AppSpacingTokens.level4,
          ),
          const SizedBox(width: AppSpacingTokens.level2),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 18,
                    width: 44,
                    radius: AppRadiusTokens.level2,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.value,
                      style: AppTypographyToken.level4
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w800),
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
    return SizedBox(
      height: height,
      child: const AppDivider(axis: Axis.vertical),
    );
  }
}
