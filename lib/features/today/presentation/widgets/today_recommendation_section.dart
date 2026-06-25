import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayRecommendationSection extends StatelessWidget {
  const TodayRecommendationSection({
    super.key,
    required this.dashboard,
    this.compact = false,
  });

  final TodayDashboard dashboard;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final items = buildRecommendationItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayRecommendationSectionTitle,
      actionLabel: l10n.todayViewMoreAction,
      onAction: () => AppToast.show(context, l10n.todayViewMoreAction),
      child: AppSectionSurface(
        key: const Key('today-recommendation-card'),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _RecommendationRow(item: items[index], compact: compact),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x4l + AppSpacingTokens.xs,
                  color: surface.hairline.withValues(alpha: 0.62),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.item, required this.compact});

  final TodayRecommendationItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, item.action),
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
