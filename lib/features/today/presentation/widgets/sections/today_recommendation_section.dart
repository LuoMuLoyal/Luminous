import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_recommendation.dart';
import 'package:luminous/features/today/presentation/providers/today_recommendations_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayRecommendationSection extends ConsumerWidget {
  const TodayRecommendationSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final recommendationsAsync = ref.watch(todayRecommendationsProvider);

    return TodaySection(
      title: l10n.todayRecommendationSectionTitle,
      actionLabel: l10n.todayRecommendationRefreshAction,
      onAction: () => _refresh(ref),
      child: FCard.raw(
        key: const Key('today-recommendation-card'),
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
                rows.add(
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacingTokens.level9 + AppSpacingTokens.level2,
                    color: colors.border,
                  ),
                );
              }
            }
            if (rows.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(children: rows);
          },
          loading: () => const SizedBox(
            height: 144,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => AppStateErrorView(
            title: l10n.todayRecommendationErrorTitle,
            description: l10n.todayRecommendationErrorDescription,
            icon: FLucideIcons.circleAlert,
            actionLabel: l10n.todayRetryAction,
            onAction: () => _refresh(ref),
            compact: true,
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
      'medicine' => () => context.push('/medicine'),
      'sleep' => () => context.push('/record/create?kind=sleep'),
      'record' => () => context.push('/record/create?kind=water'),
      'report' => () => context.push('/report'),
      'habit' || _ => () => context.push('/record'),
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
        color: Color(0xFF0F766E),
        title: recommendation.text,
        subtitle: l10n.todayRecommendationMedicineSafetyBody,
        action: l10n.todayLearnMoreAction,
      ),
      'sleep' => TodayRecommendationItem(
        icon: FLucideIcons.moonStar,
        color: Color(0xFF16A34A),
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      'record' => TodayRecommendationItem(
        icon: FLucideIcons.filePenLine,
        color: Color(0xFFF59E0B),
        title: recommendation.text,
        subtitle: l10n.todayRecommendationWaterBody,
        action: l10n.todayCompleteAction,
      ),
      'report' => TodayRecommendationItem(
        icon: FLucideIcons.chartColumnBig,
        color: Color(0xFF7C3AED),
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      _ => TodayRecommendationItem(
        icon: FLucideIcons.lightbulb,
        color: Color(0xFF0F766E),
        title: recommendation.text,
        subtitle: l10n.todayRecommendationWaterBody,
        action: l10n.todayLearnMoreAction,
      ),
    };
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
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            TodayGlyphTile(
              icon: item.icon,
              color: item.color,
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level2),
                  Text(
                    item.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level2),
            Text(
              item.action,
              style: textTheme.labelMedium?.copyWith(
                color: item.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
