import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayPrimarySuggestionSection extends StatelessWidget {
  const TodayPrimarySuggestionSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildSuggestionItems(l10n, dashboard);
    final primary = items.first;
    final colors = context.theme.colors;

    return TodaySection(
      title: l10n.todayPrimarySuggestionSectionTitle,
      child: FCard.raw(
        key: const Key('today-primary-suggestion-card'),
        style: todayCardStyle(context, tone: TodayCardTone.emphasis),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FBadge(
                    variant: FBadgeVariant.outline,
                    child: Text(l10n.todayPrimarySuggestionBadge),
                  ),
                  const Spacer(),
                  TodayGlyphTile(
                    icon: primary.icon,
                    color: primary.color.resolve(colors),
                    size: AppSpacingTokens.level8,
                    radius: AppRadiusTokens.level3,
                    gradient: false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                primary.title,
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Text(
                primary.reason,
                style: AppTypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              _SuggestionMetaBlock(
                label: l10n.todaySuggestionEvidenceLabel,
                value: primary.evidence,
              ),
              const SizedBox(height: AppSpacingTokens.level3),
              _SuggestionMetaBlock(
                label: l10n.todaySuggestionBoundaryLabel,
                value: primary.boundary,
              ),
              if (primary.progress case final progress?) ...[
                const SizedBox(height: AppSpacingTokens.level3),
                FDeterminateProgress(value: progress),
              ],
              const SizedBox(height: AppSpacingTokens.level4),
              FButton(
                onPress: () => _openSuggestion(context, primary),
                mainAxisSize: MainAxisSize.max,
                child: Text(primary.action),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSuggestion(BuildContext context, TodaySuggestionItem item) {
    switch (item.type) {
      case TodayPriorityItemType.medication:
        context.go(AppRoutes.medicine);
      case TodayPriorityItemType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
    }
  }
}

class TodaySecondarySuggestionsSection extends StatelessWidget {
  const TodaySecondarySuggestionsSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildSuggestionItems(
      l10n,
      dashboard,
    ).skip(1).take(2).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.theme.colors;

    return TodaySection(
      title: l10n.todaySecondarySuggestionSectionTitle,
      child: FTileGroup(
        key: const Key('today-secondary-suggestions-card'),
        divider: FItemDivider.full,
        children: [
          for (var index = 0; index < items.length; index += 1)
            FTile(
              prefix: TodayGlyphTile(
                icon: items[index].icon,
                color: items[index].color.resolve(colors),
                size: AppSpacingTokens.level7,
                radius: AppRadiusTokens.level3,
                gradient: false,
              ),
              title: Text(items[index].title),
              subtitle: Text(
                '${items[index].reason} · ${items[index].evidence}',
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => _openSuggestion(context, items[index]),
            ),
        ],
      ),
    );
  }

  void _openSuggestion(BuildContext context, TodaySuggestionItem item) {
    switch (item.type) {
      case TodayPriorityItemType.medication:
        context.go(AppRoutes.medicine);
      case TodayPriorityItemType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
    }
  }
}

class _SuggestionMetaBlock extends StatelessWidget {
  const _SuggestionMetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacingTokens.level1),
        Text(value, style: AppTypographyToken.level4.body(context)),
      ],
    );
  }
}
