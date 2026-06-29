import 'package:luminous/features/today/presentation/widgets/shared/today_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/today/domain/entities/today_recommendation.dart';
import 'package:luminous/features/today/presentation/providers/today_recommendations_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayRecommendationSection extends ConsumerWidget {
  const TodayRecommendationSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final recommendationsAsync = ref.watch(todayRecommendationsProvider);

    return TodaySection(
      title: l10n.todayRecommendationSectionTitle,
      actionLabel: l10n.todayRecommendationRefreshAction,
      onAction: () => _refresh(ref),
      child: AppSectionSurface(
        key: const Key('today-recommendation-card'),
        padding: EdgeInsets.zero,
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
                    indent: AppSpacingTokens.x4l + AppSpacingTokens.xs,
                    color: surface.hairline.withValues(alpha: 0.62),
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
            icon: Icons.error_outline_rounded,
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
        icon: Icons.health_and_safety_outlined,
        color: AppColorTokens.cyanDeep,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationMedicineSafetyBody,
        action: l10n.todayLearnMoreAction,
      ),
      'sleep' => TodayRecommendationItem(
        icon: Icons.bedtime_rounded,
        color: AppColorTokens.link,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      'record' => TodayRecommendationItem(
        icon: Icons.edit_note_rounded,
        color: AppColorTokens.warning,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationWaterBody,
        action: l10n.todayCompleteAction,
      ),
      'report' => TodayRecommendationItem(
        icon: Icons.assessment_outlined,
        color: AppColorTokens.violet,
        title: recommendation.text,
        subtitle: l10n.todayRecommendationSleepBody,
        action: l10n.todayLearnMoreAction,
      ),
      _ => TodayRecommendationItem(
        icon: Icons.lightbulb_outline_rounded,
        color: AppColorTokens.cyanDeep,
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              TodayGlyphTile(
                icon: item.icon,
                color: item.color,
                size: AppSpacingTokens.x2l + AppSpacingTokens.xxs,
                radius: AppRadiusTokens.md,
                gradient: false,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    Text(
                      item.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Text(
                item.action,
                style: typography.bodySmStrong.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
