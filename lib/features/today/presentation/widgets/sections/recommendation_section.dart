import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/recommendation.dart';
import 'package:luminous/features/today/presentation/providers/recommendations_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class TodayRecommendationSection extends ConsumerWidget {
  const TodayRecommendationSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recommendationsAsync = ref.watch(todayRecommendationsProvider);

    return TodaySection(
      title: l10n.todayRecommendationSectionTitle,
      actionLabel: l10n.todayRecommendationRefreshAction,
      onAction: () => _refresh(ref),
      child: FCard.raw(
        key: const Key('today-recommendation-card'),
        style: todayCardStyle(context, tone: TodayCardTone.soft),
        child: recommendationsAsync.when(
          data: (recommendations) {
            final rows = <Widget>[];
            for (var index = 0; index < recommendations.length; index += 1) {
              final recommendation = recommendations[index];
              final item = _mapToItem(context, recommendation);
              if (item == null) continue;
              rows.add(
                _RecommendationRow(
                  item: item,
                  onTap: _navigateForCategory(context, recommendation.category),
                  compact: compact,
                ),
              );
              if (index < recommendations.length - 1) {
                rows.add(const AppDivider());
              }
            }
            if (rows.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(children: rows);
          },
          loading: () => const _RecommendationLoadingState(),
          error: (_, __) => _RecommendationErrorState(
            title: l10n.todayRecommendationErrorTitle,
            actionLabel: l10n.todayRetryAction,
            onAction: () => _refresh(ref),
          ),
        ),
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.read(todayRecommendationsProvider.notifier).refresh();
  }

  VoidCallback? _navigateForCategory(BuildContext context, String? category) {
    return switch (category) {
      'medicine' => () => context.push(AppRoutes.medicine),
      'sleep' => () => context.push('${AppRoutes.recordCreate}?kind=sleep'),
      'record' => () => context.push('${AppRoutes.recordCreate}?kind=water'),
      'report' => () => context.push(AppRoutes.report),
      'habit' || _ => () => context.push(AppRoutes.record),
    };
  }

  TodayRecommendationItem? _mapToItem(
    BuildContext context,
    TodayRecommendation recommendation,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final category = recommendation.category ?? 'habit';
    return switch (category) {
      'medicine' => TodayRecommendationItem(
        icon: FLucideIcons.shieldPlus,
        color: AppColors.primary,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationMedicineSafetyBody,
        action: l10n.todayLearnMoreAction,
      ),
      'sleep' => TodayRecommendationItem(
        icon: FLucideIcons.moonStar,
        color: AppColors.primary,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      'record' => TodayRecommendationItem(
        icon: FLucideIcons.filePenLine,
        color: AppColors.primary,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationWaterBody,
        action: l10n.todayCompleteAction,
      ),
      'report' => TodayRecommendationItem(
        icon: FLucideIcons.chartColumnBig,
        color: AppColors.primary,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      _ => TodayRecommendationItem(
        icon: FLucideIcons.lightbulb,
        color: AppColors.primary,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationWaterBody,
        action: l10n.todayLearnMoreAction,
      ),
    };
  }
}

class _RecommendationLoadingState extends StatelessWidget {
  const _RecommendationLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.level4),
      child: AppInlineSkeleton(
        children: [
          for (var index = 0; index < 3; index += 1) ...[
            const Row(
              children: [
                AppInlineSkeletonCircle(size: AppSpacingTokens.level8),
                SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: AppInlineSkeleton(
                    spacing: AppSpacingTokens.level2,
                    children: [
                      AppInlineSkeletonBlock(height: 18, widthFactor: 0.72),
                      AppInlineSkeletonBlock(height: 14, widthFactor: 0.9),
                    ],
                  ),
                ),
              ],
            ),
            if (index < 2) const AppDivider(),
          ],
        ],
      ),
    );
  }
}

class _RecommendationErrorState extends StatelessWidget {
  const _RecommendationErrorState({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.level4),
      child: Row(
        children: [
          TodayGlyphTile(
            icon: FLucideIcons.circleAlert,
            color: colors.primary,
            size: AppSpacingTokens.level7,
            radius: AppRadiusTokens.level3,
            gradient: false,
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Text(
              title,
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          FButton(
            onPress: onAction,
            variant: FButtonVariant.secondary,
            size: FButtonSizeVariant.xs,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.item,
    required this.compact,
    this.onTap,
  });

  final TodayRecommendationItem item;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            TodayGlyphTile(
              icon: item.icon,
              color: item.color.resolve(colors),
              size: AppSpacingTokens.level7 + AppSpacingTokens.level1,
              radius: AppRadiusTokens.level3,
              gradient: false,
            ),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level2),
                  Text(
                    item.subtitle,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level2),
            Text(
              item.action,
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(
                    color: item.color.resolve(colors),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
