import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayTodoSection extends ConsumerWidget {
  const TodayTodoSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  void _handleTap(BuildContext context, WidgetRef ref, TodayTodoItem item) {
    switch (item.type) {
      case TodayTodoType.medication:
        ref.read(shellProvider.notifier).selectTab(2);
      case TodayTodoType.water:
        context.push('/record/create?kind=water');
      case TodayTodoType.custom:
        context.push('/record/create');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final items = buildTodoItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayTodoSectionTitle,
      child: FCard.raw(
        key: const Key('today-todo-card'),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _TodoRow(
                item: items[index],
                onTap: () => _handleTap(context, ref, items[index]),
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x4l + AppSpacingTokens.sm,
                  color: colors.border,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.item, required this.onTap});

  final TodayTodoItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(
              item.completed
                  ? FLucideIcons.circleCheckBig
                  : FLucideIcons.circleCheck,
              color: item.completed ? item.color : colors.mutedForeground,
              size: AppSpacingTokens.x2l,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: item.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.84,
                    isLoading: item.subtitleIsDynamic ? null : false,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  AppSkeletonText(
                    text: item.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.84,
                    isLoading: item.subtitleIsDynamic ? null : false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                border: Border.all(color: item.color.withValues(alpha: 0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.sm,
                  vertical: AppSpacingTokens.xxs,
                ),
                child: Text(
                  item.source,
                  style: textTheme.labelSmall?.copyWith(
                    color: item.color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.xs),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.lg,
            ),
          ],
        ),
      ),
    );
  }
}
