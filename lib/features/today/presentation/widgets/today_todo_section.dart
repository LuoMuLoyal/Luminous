import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayTodoSection extends StatelessWidget {
  const TodayTodoSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final items = buildTodoItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayTodoSectionTitle,
      child: TodayPanel(
        key: const Key('today-todo-card'),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _TodoRow(item: items[index]),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x4l + AppSpacingTokens.sm,
                  color: surface.hairline.withValues(alpha: 0.62),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.item});

  final TodayTodoItem item;

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
              Icon(
                item.completed
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: item.completed ? item.color : surface.mute,
                size: AppSpacingTokens.x2l,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonText(
                      text: item.title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.84,
                      isLoading:
                          item.subtitleIsDynamic ? null : false,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    AppSkeletonText(
                      text: item.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.84,
                      isLoading:
                          item.subtitleIsDynamic ? null : false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppRadiusTokens.pill),
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.sm,
                    vertical: AppSpacingTokens.xxs,
                  ),
                  child: Text(
                    item.source,
                    style: typography.caption.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
