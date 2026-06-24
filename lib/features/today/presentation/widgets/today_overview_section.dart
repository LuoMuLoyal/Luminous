import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayOverviewSection extends StatelessWidget {
  const TodayOverviewSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildOverviewItems(l10n, dashboard);

    return TodayPanel(
      key: const Key('today-health-summary-card'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.sm,
        AppSpacingTokens.md,
        AppSpacingTokens.sm,
      ),
      radius: AppRadiusTokens.lg,
      shadow: const <BoxShadow>[],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: l10n.todayHealthSummaryCardTitle,
            leading: const Icon(
              Icons.check_circle_outline_rounded,
              color: TodayPalette.teal,
              size: AppSpacingTokens.lg,
            ),
            compact: true,
            trailing: AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 22,
                width: 96,
                radius: AppRadiusTokens.pill,
              ),
              child: AppTextAction(
                label: l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                icon: Icons.refresh_rounded,
                onTap: () => AppToast.show(
                  context,
                  l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                ),
              ),
            ),
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
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.item});

  final TodayOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

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
                  style: typography.caption.copyWith(
                    color: Theme.of(context).extension<AppThemeSurface>()!.body,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
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
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SizedBox(
      height: height,
      child: VerticalDivider(width: 1, thickness: 1, color: surface.hairline),
    );
  }
}
