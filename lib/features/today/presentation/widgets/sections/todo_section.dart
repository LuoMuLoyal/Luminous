import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/shell/providers/provider.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class TodayTodoSection extends ConsumerWidget {
  const TodayTodoSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  void _handleTap(BuildContext context, WidgetRef ref, TodayTodoItem item) {
    switch (item.type) {
      case TodayTodoType.medication:
        ref.read(shellProvider.notifier).selectTab(2);
      case TodayTodoType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
      case TodayTodoType.custom:
        context.push(AppRoutes.recordCreate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildTodoItems(l10n, dashboard);

    return TodaySection(
      title: l10n.todayTodoSectionTitle,
      child: FCard.raw(
        key: const Key('today-todo-card'),
        style: todayCardStyle(context),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _TodoRow(
                item: items[index],
                onTap: () => _handleTap(context, ref, items[index]),
              ),
              if (index < items.length - 1) const AppDivider(),
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

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            Icon(
              item.completed
                  ? FLucideIcons.circleCheckBig
                  : FLucideIcons.circleCheck,
              color: item.completed
                  ? item.color.resolve(colors)
                  : colors.mutedForeground,
              size: AppSpacingTokens.level7,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: item.title,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.84,
                    isLoading: item.subtitleIsDynamic ? null : false,
                  ),
                  const SizedBox(height: AppSpacingTokens.level2),
                  AppSkeletonText(
                    text: item.subtitle,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.84,
                    isLoading: item.subtitleIsDynamic ? null : false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.82),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level3,
                  vertical: AppSpacingTokens.level1,
                ),
                child: Text(
                  item.source,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level2),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.level5,
            ),
          ],
        ),
      ),
    );
  }
}
